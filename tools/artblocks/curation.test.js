"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");
const { GROUPS, identity, projectIdentity, validateCuration, scanGroups, captureCuration, curationStats,
  projectFromEntry } = require("./curation");

const ADDRESS = "0x0a1bbd57033f57e7b6743621b79fcb9eb2ce3676";
const SOURCE = { endpoint: "https://data.artblocks.io/v1/graphql", discoveredAt: "2026-09-06T17:42:51.705Z" };

function project(id, overrides = {}) {
  return { id: `${ADDRESS}-${id}`, chain_id: 1, contract_address: ADDRESS, project_id: String(id), name: `Art ${id}`,
    artist_name: "Artist", invocations: 2, directory: `art-${id}`, ...overrides };
}

async function fixture(t, projects = [project(2), project(3)]) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "artblocks-curation-"));
  t.after(() => fs.rm(root, { recursive: true, force: true }));
  for (const group of GROUPS) await fs.mkdir(path.join(root, group));
  await fs.writeFile(path.join(root, "inventory.json"), JSON.stringify({ fetchedAt: SOURCE.discoveredAt,
    apiURL: SOURCE.endpoint, total: projects.length, excluded: 0, projects }));
  return root;
}

async function writeCollection(root, group, item = project(2), directory = item.directory, options = {}) {
  const count = options.count ?? 2;
  const target = path.join(root, group, directory);
  await fs.mkdir(target, { recursive: true });
  const manifest = { version: 1, identity: projectIdentity(item), project: item, selectionComplete: true,
    requestedCount: 23, availableCount: count, expectedCount: Math.min(23, count), metadataError: null,
    tokens: Array.from({ length: Math.min(23, count) }, (_, invocation) => {
      const tokenId = String(BigInt(item.project_id) * 1000000n + BigInt(invocation));
      const extension = invocation % 2 ? "png" : "mp4";
      return { token: { token_id: tokenId, invocation, chain_id: item.chain_id, id: `${item.contract_address}-${tokenId}` },
        status: "downloaded", download: { file: `${tokenId}.${extension}`, extension, bytes: 7,
          sourceURL: `https://media.artblocks.io/${tokenId}.${extension}`, resolvedURL: `https://redirect.example/${tokenId}.${extension}` } };
    }) };
  for (const entry of manifest.tokens) await fs.writeFile(path.join(target, entry.download.file), "fixture");
  await fs.writeFile(path.join(target, "manifest.json"), JSON.stringify(manifest));
  return { target, manifest };
}

test("capture preserves explicit groups, selected URLs and numeric sample order; omissions become excluded", async t => {
  const root = await fixture(t, [project(3), project(2), project(4)]);
  await writeCollection(root, "good", project(2), "AlgoBeats ");
  await writeCollection(root, "hmm", project(3), "A custom title", { count: 12 });
  const registry = await captureCuration(root);
  assert.deepEqual(registry.source, SOURCE);
  assert.deepEqual(Object.keys(registry.collections), [2, 3, 4].map(id => identity(1, ADDRESS, id)));
  assert.equal(registry.collections[identity(1, ADDRESS, 2)].directory, "AlgoBeats ");
  assert.equal(registry.collections[identity(1, ADDRESS, 2)].samples[0].url, "https://media.artblocks.io/2000000.mp4");
  assert.deepEqual(registry.collections[identity(1, ADDRESS, 3)].samples.map(s => s.invocation), Array.from({ length: 12 }, (_, i) => i));
  assert.deepEqual(registry.collections[identity(1, ADDRESS, 4)], { name: "Art 4", artist: "Artist", group: "excluded", directory: "art-4" });
  assert.deepEqual(curationStats(registry), { collections: 3, good: 1, ok: 0, hmm: 1, excluded: 1, retained: 2, sampleRefs: 14 });
  assert.equal(JSON.stringify(await captureCuration(root)), JSON.stringify(registry));
});

test("moving and renaming groups is resolved through manifests while sample choices stay fixed", async t => {
  const root = await fixture(t);
  const { target } = await writeCollection(root, "good");
  const first = await captureCuration(root);
  const destination = path.join(root, "ok", "AlgoBeats ");
  await fs.rename(target, destination);
  const scanned = await scanGroups(root);
  assert.equal(scanned.get(identity(1, ADDRESS, 2)).directory, destination);
  assert.equal(scanned.get(identity(1, ADDRESS, 2)).basename, "AlgoBeats ");
  assert.equal(scanned.get(identity(1, ADDRESS, 2)).manifest.project.directory, "art-2");
  const second = await captureCuration(root, first);
  assert.equal(second.collections[identity(1, ADDRESS, 2)].group, "ok");
  assert.equal(second.collections[identity(1, ADDRESS, 2)].directory, "AlgoBeats ");
  assert.deepEqual(second.collections[identity(1, ADDRESS, 2)].samples, first.collections[identity(1, ADDRESS, 2)].samples);
  await fs.rm(destination, { recursive: true });
  await fs.rm(path.join(root, "inventory.json"));
  const third = await captureCuration(root, second);
  assert.equal(third.collections[identity(1, ADDRESS, 2)].group, "excluded");
  assert.equal(third.collections[identity(1, ADDRESS, 2)].directory, "AlgoBeats ");
  assert.equal(Object.hasOwn(third.collections[identity(1, ADDRESS, 2)], "samples"), false);
  assert.deepEqual(third.source, first.source);
});

test("fresh checkouts can scan without folders but cannot infer exclusions by capture", async t => {
  const root = await fixture(t);
  await writeCollection(root, "ok");
  const registry = await captureCuration(root);
  await fs.rm(root, { recursive: true });
  assert.equal((await scanGroups(root)).size, 0);
  await assert.rejects(captureCuration(root, registry), { code: "ENOENT" });
  await fs.mkdir(path.join(root, "good"), { recursive: true });
  await assert.rejects(captureCuration(root, registry), { code: "ENOENT" });
  assert.equal(registry.collections[identity(1, ADDRESS, 2)].group, "ok");
  for (const group of ["ok", "hmm"]) await fs.mkdir(path.join(root, group));
  await assert.rejects(captureCuration(root), /saved inventory or a previous/u);
});

test("duplicate identities, unknown groups and legacy flat directories stop scanning", async t => {
  const root = await fixture(t);
  const { target } = await writeCollection(root, "good");
  await writeCollection(root, "hmm", project(2), "renamed");
  await assert.rejects(scanGroups(root), /Duplicate manifest identity/u);
  await fs.rm(path.join(root, "hmm", "renamed"), { recursive: true });
  await fs.mkdir(path.join(root, "maybe"));
  await assert.rejects(scanGroups(root), /Unknown or ungrouped/u);
  await fs.rmdir(path.join(root, "maybe"));
  await fs.rename(target, path.join(root, "old-flat-folder"));
  await assert.rejects(scanGroups(root), /Unknown or ungrouped/u);
});

test("capture rejects partial selections, missing media and media size mismatches", async t => {
  const root = await fixture(t);
  const { target, manifest } = await writeCollection(root, "good");
  const file = path.join(target, "manifest.json");
  await fs.writeFile(file, JSON.stringify({ ...manifest, selectionComplete: false }));
  await assert.rejects(captureCuration(root), /Incomplete manifest selection/u);
  await fs.writeFile(file, JSON.stringify({ ...manifest, expectedCount: 23 }));
  await assert.rejects(captureCuration(root), /Incomplete manifest selection/u);
  manifest.tokens[0].status = "pending";
  await fs.writeFile(file, JSON.stringify(manifest));
  await assert.rejects(captureCuration(root), /Incomplete sample download/u);
  manifest.tokens[0].status = "downloaded";
  await fs.writeFile(file, JSON.stringify(manifest));
  await fs.writeFile(path.join(target, manifest.tokens[0].download.file), "truncated");
  await assert.rejects(captureCuration(root), /Missing or incomplete sample file/u);
  await fs.rm(path.join(target, manifest.tokens[0].download.file));
  await assert.rejects(captureCuration(root), { code: "ENOENT" });
});

test("registry validation rejects unsafe paths, URLs, extensions and foreign or unordered tokens", async t => {
  const root = await fixture(t);
  await writeCollection(root, "good");
  const original = await captureCuration(root);
  const key = identity(1, ADDRESS, 2);
  for (const directory of ["../outside", "sub/path", "sub\\path", ".", "/absolute", "null\0name"]) {
    const bad = structuredClone(original);
    bad.collections[key].directory = directory;
    assert.throws(() => validateCuration(bad), /Unsafe collection directory/u);
  }
  for (const url of ["file:///etc/passwd", "javascript:alert(1)", "data:image/png,a", "https://name:password@example.com/media", "https://example.com/\nfile"]) {
    const bad = structuredClone(original);
    bad.collections[key].samples[0].url = url;
    assert.throws(() => validateCuration(bad), /Unsafe media URL/u);
  }
  for (const sample of [{ tokenId: "3000000" }, { invocation: 2 }, { extension: "../png" }]) {
    const bad = structuredClone(original);
    Object.assign(bad.collections[key].samples[0], sample);
    assert.throws(() => validateCuration(bad), /identity mismatch|Unsafe sample extension/u);
  }
  const reversed = structuredClone(original);
  reversed.collections[key].samples.reverse();
  assert.throws(() => validateCuration(reversed), /out-of-order/u);
  const duplicate = structuredClone(original);
  duplicate.collections[key].samples[1] = duplicate.collections[key].samples[0];
  assert.throws(() => validateCuration(duplicate), /Duplicate/u);
  const excluded = structuredClone(original);
  excluded.collections[key].group = "excluded";
  assert.throws(() => validateCuration(excluded), /Excluded collection has samples/u);
  assert.throws(() => identity(0, ADDRESS, 2), /Invalid/u);
  assert.equal(identity("01", ADDRESS.toUpperCase(), "002"), key);
});

test("symlinked group, collection, manifest and media paths are rejected", async t => {
  const root = await fixture(t);
  const { target, manifest } = await writeCollection(root, "good");
  const media = path.join(target, manifest.tokens[0].download.file);
  await fs.rm(media);
  await fs.symlink(path.join(target, manifest.tokens[1].download.file), media);
  await assert.rejects(captureCuration(root), /Symlinks/u);
  await fs.rm(media);
  await fs.writeFile(media, "fixture");
  const file = path.join(target, "manifest.json");
  await fs.rename(file, path.join(root, "manifest-copy.json"));
  await fs.symlink(path.join(root, "manifest-copy.json"), file);
  await assert.rejects(scanGroups(root), /Symlinks/u);
  await fs.rm(file);
  await fs.rename(path.join(root, "manifest-copy.json"), file);
  await fs.symlink(target, path.join(root, "ok", "aliased"));
  await assert.rejects(scanGroups(root), /Symlinks/u);
  await fs.rm(path.join(root, "ok", "aliased"));
  await fs.rmdir(path.join(root, "ok"));
  await fs.symlink(path.join(root, "good"), path.join(root, "ok"));
  await assert.rejects(scanGroups(root), /Symlinks/u);
});

test("manifest/project mismatches and changed committed sample references stop capture", async t => {
  const root = await fixture(t);
  const { target, manifest } = await writeCollection(root, "good");
  const file = path.join(target, "manifest.json");
  const registry = await captureCuration(root);
  await fs.writeFile(file, JSON.stringify({ ...manifest, identity: identity(1, ADDRESS, 3) }));
  await assert.rejects(scanGroups(root), /Manifest identity mismatch/u);
  manifest.tokens[0].token.chain_id = 42161;
  await fs.writeFile(file, JSON.stringify(manifest));
  await assert.rejects(scanGroups(root), /Manifest token identity mismatch/u);
  manifest.tokens[0].token.chain_id = 1;
  manifest.tokens[0].download.sourceURL = "https://elsewhere.example/new.mp4";
  await fs.writeFile(file, JSON.stringify(manifest));
  await assert.rejects(captureCuration(root, registry), /Conflicting saved sample selection/u);
  manifest.tokens[0].download.sourceURL = registry.collections[identity(1, ADDRESS, 2)].samples[0].url;
  manifest.project.artist_name = "Another artist";
  await fs.writeFile(file, JSON.stringify(manifest));
  await assert.rejects(captureCuration(root, registry), /Conflicting collection metadata/u);
});

test("empty collections and complete 23-item selections preserve exact restoration inputs", async t => {
  const root = await fixture(t);
  await writeCollection(root, "good", project(2), "empty", { count: 0 });
  await writeCollection(root, "ok", project(3), "full", { count: 100 });
  const registry = await captureCuration(root);
  const empty = registry.collections[identity(1, ADDRESS, 2)];
  const full = registry.collections[identity(1, ADDRESS, 3)];
  assert.deepEqual(empty.samples, []);
  assert.equal(full.samples.length, 23);
  const restored = projectFromEntry(identity(1, ADDRESS, 3), full);
  assert.equal(projectIdentity(restored), identity(1, ADDRESS, 3));
  assert.equal(restored.directory, "full");
  assert.equal(restored.group, "ok");
  assert.equal(restored.artist_name, "Artist");
  assert.equal(full.samples[22].tokenId, "3000022");
  assert.equal(full.samples[22].extension, "mp4");
});
