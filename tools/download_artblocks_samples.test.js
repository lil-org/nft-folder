"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const http = require("node:http");
const { execFile } = require("node:child_process");
const { promisify } = require("node:util");
const test = require("node:test");
const { identity, folderName, bundledIdentities, retryDelay, selectTokens, mediaCandidates,
  sniffExtension, downloadCandidate, downloadToken, verifiedDownload, validateMedia, graphql,
  resolveCuratedRecords, prepareCuratedRecords, main } = require("./download_artblocks_samples");
const { captureCuration } = require("./artblocks/curation");

const ADDRESS = "0x0a1bbd57033f57e7b6743621b79fcb9eb2ce3676";
const project = { id: `${ADDRESS}-2`, chain_id: 1, contract_address: ADDRESS, project_id: "2", name: "Parnassus" };
const runFile = promisify(execFile);

async function temporaryDirectory(t) {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "artblocks-samples-test-"));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  return directory;
}

async function serverFixture(t, handler) {
  const server = http.createServer(handler);
  await new Promise(resolve => server.listen(0, "127.0.0.1", resolve));
  t.after(() => new Promise(resolve => { server.closeAllConnections(); server.close(resolve); }));
  return `http://127.0.0.1:${server.address().port}`;
}

function context(output, options = {}) {
  return { output, maxRetries: 0, timeoutMs: 5000, minFreeGiB: 0, stopReason: null, ...options };
}

function token(options = {}) {
  return { token_id: "2000000", chain_id: 1, invocation: 0, id: `${ADDRESS}-2000000`, ...options };
}

test("exclusions match chain and project, including legacy Parnassus on a shared contract", async t => {
  const bundle = await temporaryDirectory(t);
  await fs.mkdir(path.join(bundle, "Tokens"));
  await fs.writeFile(path.join(bundle, "items.json"), JSON.stringify([
    { address: ADDRESS.toUpperCase().replace("0X", "0x"), chainId: 1, abId: "01", name: "First" },
    { address: ADDRESS, chainId: 1, collectionId: "legacy", name: "Parnassus" },
  ]));
  await fs.writeFile(path.join(bundle, "Tokens", `${ADDRESS}legacy.json`), JSON.stringify({
    items: [["2000000", 0, "0.png"], { id: "2000001" }],
  }));
  const projects = [project, { ...project, project_id: "1" }, { ...project, project_id: "3" }, { ...project, chain_id: 42161 }];
  const { keys, inferred } = await bundledIdentities(projects, bundle);
  assert.deepEqual([...keys].sort(), [identity(1, ADDRESS, 1), identity(1, ADDRESS, 2)].sort());
  assert.equal(keys.has(identity(1, ADDRESS, 3)), false);
  assert.equal(keys.has(identity(42161, ADDRESS, 2)), false);
  assert.deepEqual(inferred[0].projectIds, ["2"]);
});

test("first tokens use numeric invocation order and reject incomplete or foreign selections", () => {
  const tokens = Array.from({ length: 23 }, (_, n) => token({ token_id: String(2000000 + n), invocation: n })).reverse();
  assert.deepEqual(selectTokens(tokens, project, 100).map(t => t.invocation), Array.from({ length: 23 }, (_, n) => n));
  assert.equal(selectTokens(tokens.slice(-3), project, 3).length, 3);
  assert.throws(() => selectTokens(tokens.slice(1), project, 100), /Incomplete/u);
  assert.throws(() => selectTokens([token({ token_id: "3000000" })], project, 1), /identity mismatch/u);
  assert.throws(() => selectTokens([token({ chain_id: 8453 })], project, 1), /identity mismatch/u);
});

test("media preference puts animation before standard renders and markup last", () => {
  const candidates = mediaCandidates(token({
    video: { url: "https://example.org/a.mp4" }, gif: { url: "https://example.org/a.gif" },
    preview_asset_url: "https://example.org/a.png", primary_asset_url: "https://example.org/a.svg",
    high_res_image: { url: "https://example.org/high.png" }, low_res_image: { url: "https://example.org/low.png" },
    live_view_url: `https://generator.artblocks.io/1/${ADDRESS}/2000000`,
  }), project);
  assert.deepEqual(candidates.map(c => c.source), ["video", "gif", "preview_asset_url", "media_proxy", "high_res_image", "low_res_image", "primary_asset_url", "live_view_url"]);
  assert.equal(sniffExtension(Buffer.from("<html><body>error</body></html>"), "image/png"), "html");
  assert.equal(sniffExtension(Buffer.from('{"error":"not found"}')), null);
  assert.equal(folderName({ ...project, name: "../Árt / ☃" }).startsWith("art--1--"), true);
  assert.equal(folderName(project) === folderName({ ...project, chain_id: 8453 }), false);
  assert.equal(retryDelay(0, "5"), 5000);
  assert.equal(retryDelay(3, null), 8000);
});

test("redirects download verified images and resume detects tampering", async t => {
  const directory = await temporaryDirectory(t);
  const original = path.join(directory, "fixture.png");
  await runFile("magick", ["-size", "8x8", "xc:red", original]);
  const png = await fs.readFile(original);
  const base = await serverFixture(t, (req, res) => {
    if (req.url === "/redirect") { res.writeHead(302, { Location: "/image.png" }); res.end(); }
    else { res.writeHead(200, { "Content-Type": "image/png", "Content-Length": png.length }); res.end(png); }
  });
  const temporary = path.join(directory, "item.part");
  const download = await downloadCandidate(context(directory), { url: `${base}/redirect`, source: "image", extension: "png" }, temporary);
  assert.equal(download.extension, "png");
  assert.equal(download.resolvedURL, `${base}/image.png`);
  assert.equal(download.bytes, png.length);
  const file = "2000000.png";
  await fs.rename(temporary, path.join(directory, file));
  const entry = { token: token(), status: "downloaded", download: { ...download, file } };
  assert.equal(await verifiedDownload(directory, entry, true), true);
  const modified = Buffer.from(png);
  modified[modified.length - 1] ^= 1;
  await fs.writeFile(path.join(directory, file), modified);
  assert.equal(await verifiedDownload(directory, entry), false);
});

test("a broken video falls back to GIF before PNG or HTML", async t => {
  const directory = await temporaryDirectory(t);
  const fixture = path.join(directory, "fixture.gif");
  await runFile("magick", ["-delay", "10", "-size", "8x8", "xc:red", "-size", "8x8", "xc:blue", "-loop", "0", fixture]);
  const gif = await fs.readFile(fixture);
  const requests = [];
  const base = await serverFixture(t, (req, res) => {
    requests.push(req.url);
    if (req.url === "/video.mp4") { res.writeHead(404); res.end(); }
    else if (req.url === "/render.gif") { res.writeHead(200, { "Content-Type": "image/gif" }); res.end(gif); }
    else { res.writeHead(500); res.end(); }
  });
  const entry = { token: token({ video: { url: `${base}/video.mp4` }, gif: { url: `${base}/render.gif` },
    image: { url: `${base}/image.png` }, primary_asset_url: `${base}/generator.html` }), status: "pending", failures: [] };
  await downloadToken(context(directory), { directory, manifest: { project } }, entry);
  assert.equal(entry.download.extension, "gif");
  assert.equal(entry.download.kind, "animated-image");
  assert.equal(entry.status, "downloaded");
  assert.deepEqual(requests, ["/video.mp4", "/render.gif"]);
  assert.equal(entry.failures.length, 1);
  assert.deepEqual((await fs.readdir(directory)).filter(x => x.endsWith(".part")), []);
});

test("image URLs returning HTML and access-denied documents are rejected", async t => {
  const directory = await temporaryDirectory(t);
  const base = await serverFixture(t, (req, res) => {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end("<!doctype html><html><title>Access denied</title><body>No</body></html>");
  });
  const temporary = path.join(directory, "bad.part");
  await assert.rejects(downloadCandidate(context(directory), { url: `${base}/image.png`, source: "image", extension: "png" }, temporary), /error document/u);
  await assert.rejects(fs.stat(temporary), { code: "ENOENT" });
});

test("interrupted transfers retry cleanly and leave no partial file", async t => {
  const directory = await temporaryDirectory(t);
  const fixture = path.join(directory, "fixture.png");
  await runFile("magick", ["-size", "8x8", "xc:blue", fixture]);
  const png = await fs.readFile(fixture);
  let calls = 0;
  const base = await serverFixture(t, (req, res) => {
    calls++;
    res.writeHead(200, { "Content-Type": "image/png", "Content-Length": png.length });
    if (calls === 1) { res.write(png.subarray(0, 20)); setTimeout(() => res.destroy(), 10); }
    else res.end(png);
  });
  const temporary = path.join(directory, "retry.part");
  const result = await downloadCandidate(context(directory, { maxRetries: 1 }), { url: `${base}/image.png`, source: "image", extension: "png" }, temporary);
  assert.equal(calls, 2);
  assert.equal(result.bytes, png.length);
  assert.equal((await validateMedia(temporary)).extension, "png");
});

test("the disk reserve pauses before starting a download", async t => {
  const directory = await temporaryDirectory(t);
  const state = context(directory, { minFreeGiB: 1000000 });
  await assert.rejects(downloadCandidate(state, { url: "https://example.org/image.png" }, path.join(directory, "space.part")), /Paused for disk space/u);
  assert.match(state.stopReason, /Paused for disk space/u);
});

test("GraphQL rate-limit errors returned with HTTP 200 wait and retry", async t => {
  const directory = await temporaryDirectory(t);
  let calls = 0;
  const base = await serverFixture(t, (req, res) => {
    calls++;
    req.resume();
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(calls === 1 ? { errors: [{ message: "rate limit of 100 exceeded",
      extensions: { code: "rate-limit-exceeded" } }] } : { data: { result: 42 } }));
  });
  const delays = [];
  const data = await graphql(context(directory, { apiURL: base, maxRetries: 1,
    sleep: async ms => { delays.push(ms); } }), "{ result }");
  assert.deepEqual(data, { result: 42 });
  assert.equal(calls, 2);
  assert.deepEqual(delays, [60000]);
});

function registry(samples, group = "good", directory = "renamed collection ") {
  return {
    version: 1,
    source: { endpoint: "https://data.artblocks.io/v1/graphql", discoveredAt: "2026-09-06T00:00:00Z" },
    collections: {
      [identity(1, ADDRESS, 2)]: { name: "Parnassus", artist: "Artist", group, directory, samples },
      [identity(1, ADDRESS, 3)]: { name: "Removed", artist: "Artist", group: "excluded", directory: "removed" },
    },
  };
}

test("a fresh checkout restores exact saved media into its group and skips excluded projects", async t => {
  const directory = await temporaryDirectory(t);
  const output = path.join(directory, "samples");
  const fixture = path.join(directory, "fixture.png");
  await runFile("magick", ["-size", "8x8", "xc:green", fixture]);
  const png = await fs.readFile(fixture);
  const requests = [];
  const base = await serverFixture(t, (req, res) => {
    requests.push(req.url);
    res.writeHead(200, { "Content-Type": "image/png" });
    res.end(png);
  });
  const curation = registry([{ tokenId: "2000000", invocation: 0, url: `${base}/reviewed.png`, extension: "png" }]);
  const state = context(output);
  const records = await resolveCuratedRecords(state, curation);
  assert.equal(records.length, 1);
  await assert.rejects(fs.stat(output), { code: "ENOENT" });
  assert.equal(records[0].directory, path.join(output, "good", "renamed collection "));
  await prepareCuratedRecords(records);
  const entry = records[0].manifest.tokens[0];
  await downloadToken(state, records[0], entry);
  assert.equal(entry.status, "downloaded");
  assert.equal(entry.download.sourceURL, `${base}/reviewed.png`);
  await downloadToken(state, records[0], entry);
  assert.deepEqual(requests, ["/reviewed.png"]);
  assert.deepEqual(await fs.readdir(output), ["good"]);
  assert.equal(curation.collections[identity(1, ADDRESS, 3)].group, "excluded");
});

test("resolution follows moved and renamed manifests for every group without creating flat copies", async t => {
  const output = await temporaryDirectory(t);
  for (const group of ["good", "ok", "hmm"]) {
    const saved = registry([{ tokenId: "2000000", invocation: 0, url: "https://example.org/reviewed.png", extension: "png" }], group, "before");
    const [record] = await resolveCuratedRecords(context(output), saved);
    await prepareCuratedRecords([record]);
    const targetGroup = group === "hmm" ? "good" : "hmm";
    const target = path.join(output, targetGroup, "after ");
    await fs.mkdir(path.dirname(target), { recursive: true });
    await fs.rename(record.directory, target);
    const resolved = await resolveCuratedRecords(context(output, { group: targetGroup }), saved);
    assert.equal(resolved.length, 1);
    assert.equal(resolved[0].directory, target);
    assert.equal(resolved[0].manifest.project.directory, path.join(targetGroup, "after "));
    assert.equal((await resolveCuratedRecords(context(output, { group }), saved)).length, 0);
    await assert.rejects(fs.stat(path.join(output, "before")), { code: "ENOENT" });
    await fs.rm(target, { recursive: true });
  }
});

test("saved media references do not silently switch format", async t => {
  const directory = await temporaryDirectory(t);
  const fixture = path.join(directory, "fixture.png");
  await runFile("magick", ["-size", "8x8", "xc:blue", fixture]);
  const png = await fs.readFile(fixture);
  const base = await serverFixture(t, (req, res) => {
    res.writeHead(200, { "Content-Type": "image/png" });
    res.end(png);
  });
  const entry = { token: token(), reference: { url: `${base}/reviewed.mp4`, extension: "mp4" }, status: "pending", failures: [] };
  await downloadToken(context(directory), { directory, manifest: { project } }, entry);
  assert.equal(entry.status, "failed");
  assert.match(entry.failures[0].error, /requires mp4, received png/u);
  assert.deepEqual(await fs.readdir(directory), ["fixture.png"]);
});

test("verification on a fresh checkout reports missing media without creating folders or changing decisions", async t => {
  const directory = await temporaryDirectory(t);
  const output = path.join(directory, "absent");
  const file = path.join(directory, "curation.json");
  const text = JSON.stringify(registry([{ tokenId: "2000000", invocation: 0, url: "https://example.org/reviewed.png", extension: "png" }]));
  await fs.writeFile(file, text);
  const exitCode = process.exitCode;
  try {
    await main(["--verify-only", "--output", output, "--curation", file]);
    assert.equal(process.exitCode, 2);
  } finally { process.exitCode = exitCode; }
  assert.equal(await fs.readFile(file, "utf8"), text);
  await assert.rejects(fs.stat(output), { code: "ENOENT" });
  await assert.rejects(captureCuration(output, JSON.parse(text)), /ENOENT|samples directory/u);
});

test("restoration rejects a renamed folder occupying another saved collection's location before writing", async t => {
  const output = await temporaryDirectory(t);
  const first = registry([{ tokenId: "2000000", invocation: 0, url: "https://example.org/2.png", extension: "png" }], "good", "original");
  const [record] = await resolveCuratedRecords(context(output), first);
  await prepareCuratedRecords([record]);
  const occupied = path.join(output, "good", "other");
  await fs.rename(record.directory, occupied);
  first.collections[identity(1, ADDRESS, 4)] = { name: "Other", artist: "Artist", group: "good", directory: "other",
    samples: [{ tokenId: "4000000", invocation: 0, url: "https://example.org/4.png", extension: "png" }] };
  const manifestFile = path.join(occupied, "manifest.json");
  const before = await fs.readFile(manifestFile, "utf8");
  await assert.rejects(resolveCuratedRecords(context(output), first), /occupied by another identity/u);
  assert.equal(await fs.readFile(manifestFile, "utf8"), before);
  await assert.rejects(fs.stat(path.join(output, "good", "original")), { code: "ENOENT" });
});

test("the CLI restores only the requested group and resumes without more network requests", async t => {
  const directory = await temporaryDirectory(t);
  const output = path.join(directory, "samples");
  const fixture = path.join(directory, "fixture.png");
  await runFile("magick", ["-size", "8x8", "xc:green", fixture]);
  const png = await fs.readFile(fixture);
  const requests = [];
  const base = await serverFixture(t, (req, res) => {
    requests.push(req.url);
    res.writeHead(200, { "Content-Type": "image/png" });
    res.end(png);
  });
  const curation = registry([{ tokenId: "2000000", invocation: 0, url: `${base}/2.png`, extension: "png" }], "ok");
  curation.collections[identity(1, ADDRESS, 4)] = { name: "Not selected", artist: "Artist", group: "good", directory: "not-selected",
    samples: [{ tokenId: "4000000", invocation: 0, url: `${base}/4.png`, extension: "png" }] };
  const file = path.join(directory, "curation.json");
  const text = JSON.stringify(curation);
  await fs.writeFile(file, text);
  const args = ["--output", output, "--curation", file, "--group", "ok"];
  await main(args);
  await main(args);
  const summary = JSON.parse(await fs.readFile(path.join(output, "download-summary.json"), "utf8"));
  assert.equal(summary.status, "complete");
  assert.equal(summary.selectedCollections, 1);
  assert.equal(summary.retainedCollections, 2);
  assert.equal(summary.excludedCollections, 1);
  assert.deepEqual(requests, ["/2.png"]);
  assert.equal(await fs.readFile(file, "utf8"), text);
  assert.deepEqual((await fs.readdir(output, { withFileTypes: true })).filter(e => e.isDirectory()).map(e => e.name), ["ok"]);
});
