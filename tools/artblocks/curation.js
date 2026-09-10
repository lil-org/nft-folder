"use strict";

const fs = require("node:fs/promises");
const path = require("node:path");

const GROUPS = Object.freeze(["good", "ok", "hmm"]);
const EXTENSIONS = new Set(["png", "jpg", "jpeg", "webp", "gif", "avif", "heic", "heif", "tif", "tiff", "bmp", "mp4", "mov", "webm", "m4v", "svg", "html"]);

function object(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function identity(chain, address, project) {
  if (!/^\d+$/u.test(String(chain)) || !Number.isSafeInteger(Number(chain)) || Number(chain) < 1
    || typeof address !== "string" || !/^0x[\da-f]{40}$/iu.test(address) || !/^\d+$/u.test(String(project))) {
    throw new Error(`Invalid Art Blocks identity: ${chain}:${address}:${project}`);
  }
  return `${Number(chain)}:${address.toLowerCase()}:${BigInt(project)}`;
}

function projectIdentity(project) {
  if (!object(project)) throw new Error("Missing Art Blocks project identity");
  return identity(project.chain_id, project.contract_address, project.project_id);
}

function parseIdentity(key) {
  const [chain, address, project, ...extra] = String(key).split(":");
  if (extra.length || identity(chain, address, project) !== key) throw new Error(`Non-normalized Art Blocks identity: ${key}`);
  return { chain: Number(chain), address, project };
}

function basename(value) {
  if (typeof value !== "string" || !value || value === "." || value === ".." || /[\\/\x00-\x1f\x7f]/u.test(value)
    || path.basename(value) !== value || path.isAbsolute(value)) {
    throw new Error(`Unsafe collection directory: ${JSON.stringify(value)}`);
  }
  return value;
}

function safeURL(value) {
  let url;
  try { url = new URL(value); } catch { throw new Error(`Invalid media URL: ${value}`); }
  if (typeof value !== "string" || value !== value.trim() || /[\x00-\x1f\x7f]/u.test(value)
    || !["https:", "http:"].includes(url.protocol) || !url.hostname || url.username || url.password) {
    throw new Error(`Unsafe media URL: ${value}`);
  }
}

function validateSamples(key, samples) {
  const { project } = parseIdentity(key);
  if (!Array.isArray(samples) || samples.length > 23) throw new Error(`Invalid sample selection: ${key}`);
  let last = -1;
  for (const sample of samples) {
    if (!object(sample) || typeof sample.tokenId !== "string" || !/^(0|[1-9]\d*)$/u.test(sample.tokenId)
      || !Number.isInteger(sample.invocation) || sample.invocation < 0 || sample.invocation >= 1000000
      || BigInt(sample.tokenId) / 1000000n !== BigInt(project)
      || Number(BigInt(sample.tokenId) % 1000000n) !== sample.invocation) {
      throw new Error(`Sample identity mismatch: ${key}`);
    }
    if (sample.invocation <= last) throw new Error(`Duplicate or out-of-order samples: ${key}`);
    last = sample.invocation;
    if (!EXTENSIONS.has(sample.extension)) throw new Error(`Unsafe sample extension: ${sample.extension}`);
    safeURL(sample.url);
  }
}

function validateCuration(value) {
  if (!object(value) || value.version !== 1 || !object(value.source) || !object(value.collections)) {
    throw new Error("Invalid curation registry structure");
  }
  safeURL(value.source.endpoint);
  if (typeof value.source.discoveredAt !== "string" || !Number.isFinite(Date.parse(value.source.discoveredAt))) {
    throw new Error("Invalid curation discovery timestamp");
  }
  const directories = new Set();
  for (const [key, entry] of Object.entries(value.collections)) {
    parseIdentity(key);
    if (!object(entry) || typeof entry.name !== "string" || typeof entry.artist !== "string"
      || ![...GROUPS, "excluded"].includes(entry.group)) throw new Error(`Invalid curation entry: ${key}`);
    basename(entry.directory);
    if (entry.group === "excluded") {
      if (Object.hasOwn(entry, "samples")) throw new Error(`Excluded collection has samples: ${key}`);
    } else {
      const location = `${entry.group}/${entry.directory.toLowerCase()}`;
      if (directories.has(location)) throw new Error(`Conflicting collection directory: ${location}`);
      directories.add(location);
      validateSamples(key, entry.samples);
    }
  }
  return value;
}

async function lstat(file, optional = false) {
  try {
    const stat = await fs.lstat(file);
    if (stat.isSymbolicLink()) throw new Error(`Symlinks are not supported: ${file}`);
    return stat;
  } catch (error) {
    if (optional && error.code === "ENOENT") return null;
    throw error;
  }
}

async function readJSON(file, optional = false) {
  const stat = await lstat(file, optional);
  if (!stat) return null;
  if (!stat.isFile()) throw new Error(`Expected JSON file: ${file}`);
  return JSON.parse(await fs.readFile(file, "utf8"));
}

function validateManifest(manifest, file) {
  if (!object(manifest) || manifest.version !== 1 || !Array.isArray(manifest.tokens)) throw new Error(`Invalid manifest: ${file}`);
  const key = projectIdentity(manifest.project);
  const { address, project } = parseIdentity(key);
  if (manifest.identity !== key || manifest.project.id !== `${address}-${project}`) throw new Error(`Manifest identity mismatch: ${file}`);
  const tokens = manifest.tokens.map(entry => ({ tokenId: entry.token?.token_id, invocation: entry.token?.invocation,
    url: entry.download?.sourceURL ?? "https://example.invalid/pending", extension: entry.download?.extension ?? "png" }));
  validateSamples(key, tokens);
  for (const entry of manifest.tokens) {
    if (entry.token.chain_id !== manifest.project.chain_id || entry.token.id !== `${address}-${entry.token.token_id}`) {
      throw new Error(`Manifest token identity mismatch: ${file}`);
    }
  }
  return key;
}

async function scanGroups(root, { required = false } = {}) {
  root = path.resolve(root);
  const rootStat = await lstat(root, !required);
  const found = new Map();
  if (!rootStat) return found;
  if (!rootStat.isDirectory()) throw new Error(`Expected samples directory: ${root}`);
  const children = await fs.readdir(root, { withFileTypes: true });
  for (const child of children) {
    if (child.isSymbolicLink()) throw new Error(`Symlinks are not supported: ${path.join(root, child.name)}`);
    if (child.isDirectory() && !GROUPS.includes(child.name)) throw new Error(`Unknown or ungrouped collection directory: ${child.name}`);
  }
  for (const group of GROUPS) {
    const groupPath = path.join(root, group);
    const stat = await lstat(groupPath, !required);
    if (!stat) continue;
    if (!stat.isDirectory()) throw new Error(`Expected group directory: ${groupPath}`);
    for (const child of (await fs.readdir(groupPath, { withFileTypes: true })).sort((a, b) => a.name.localeCompare(b.name, "en"))) {
      if (child.name === ".DS_Store" && child.isFile()) continue;
      basename(child.name);
      const directory = path.join(groupPath, child.name);
      const collectionStat = await lstat(directory);
      if (!collectionStat.isDirectory()) throw new Error(`Unexpected file in collection group: ${directory}`);
      const file = path.join(directory, "manifest.json");
      const manifest = await readJSON(file);
      const key = validateManifest(manifest, file);
      if (found.has(key)) throw new Error(`Duplicate manifest identity: ${key}`);
      found.set(key, { group, directory, basename: child.name, manifest });
    }
  }
  return found;
}

function metadata(project) {
  return { name: project.name ?? "", artist: project.artist_name ?? "", directory: project.directory };
}

function reconcileMetadata(key, known, incoming) {
  if (known && ((known.name && incoming.name && known.name !== incoming.name)
    || (known.artist && incoming.artist && known.artist !== incoming.artist))) {
    throw new Error(`Conflicting collection metadata: ${key}`);
  }
  return { name: known?.name || incoming.name, artist: known?.artist || incoming.artist,
    directory: known?.directory ?? incoming.directory };
}

async function captureCuration(root, previous = null) {
  if (previous) validateCuration(previous);
  const groups = await scanGroups(root, { required: true });
  const inventory = await readJSON(path.join(root, "inventory.json"), true);
  if (!previous && !inventory) throw new Error("Capture requires the saved inventory or a previous curation registry");
  const known = new Map();
  if (inventory) {
    if (!Array.isArray(inventory.projects) || (Number.isInteger(inventory.total) && Number.isInteger(inventory.excluded)
      && inventory.projects.length !== inventory.total - inventory.excluded)) throw new Error("Invalid or incomplete saved inventory");
    for (const project of inventory.projects) {
      const key = projectIdentity(project);
      if (known.has(key)) throw new Error(`Duplicate inventory identity: ${key}`);
      const entry = metadata(project);
      basename(entry.directory);
      known.set(key, entry);
    }
  }
  for (const [key, entry] of Object.entries(previous?.collections ?? {})) {
    known.set(key, { ...reconcileMetadata(key, entry, known.get(key) ?? entry), directory: entry.directory });
  }
  const entries = new Map();
  for (const [key, entry] of known) entries.set(key, { ...entry, group: "excluded" });
  for (const [key, record] of groups) {
    const manifest = record.manifest;
    if (!manifest.selectionComplete || manifest.metadataError || !Number.isInteger(manifest.availableCount)
      || manifest.availableCount < 0 || manifest.requestedCount !== 23
      || manifest.expectedCount !== Math.min(23, manifest.availableCount)
      || manifest.tokens.length !== manifest.expectedCount) throw new Error(`Incomplete manifest selection: ${key}`);
    const samples = [];
    for (const entry of manifest.tokens) {
      const sample = { tokenId: entry.token.token_id, invocation: entry.token.invocation,
        url: entry.download?.sourceURL, extension: entry.download?.extension };
      if (entry.status !== "downloaded" || entry.download?.file !== `${sample.tokenId}.${sample.extension}`) {
        throw new Error(`Incomplete sample download: ${key}/${sample.tokenId}`);
      }
      validateSamples(key, [sample]);
      const file = path.join(record.directory, entry.download.file);
      const stat = await lstat(file);
      if (!stat.isFile() || stat.size < 1 || !Number.isSafeInteger(entry.download.bytes) || stat.size !== entry.download.bytes) {
        throw new Error(`Missing or incomplete sample file: ${file}`);
      }
      samples.push(sample);
    }
    const old = previous?.collections[key];
    if (old?.samples && (old.samples.length !== samples.length || old.samples.some((sample, index) =>
      ["tokenId", "invocation", "url", "extension"].some(field => sample[field] !== samples[index][field])))) {
      throw new Error(`Conflicting saved sample selection: ${key}`);
    }
    const entry = reconcileMetadata(key, known.get(key), metadata(manifest.project));
    entries.set(key, { name: entry.name, artist: entry.artist, group: record.group, directory: record.basename, samples });
  }
  const collections = Object.fromEntries([...entries].sort(([a], [b]) => a < b ? -1 : a > b ? 1 : 0).map(([key, entry]) => [key,
    { name: entry.name, artist: entry.artist, group: entry.group, directory: entry.directory,
      ...(entry.group === "excluded" ? {} : { samples: entry.samples }) }]));
  return validateCuration({ version: 1,
    source: previous ? { ...previous.source } : { endpoint: inventory.apiURL, discoveredAt: inventory.fetchedAt }, collections });
}

function curationStats(registry) {
  validateCuration(registry);
  const stats = { collections: 0, good: 0, ok: 0, hmm: 0, excluded: 0, retained: 0, sampleRefs: 0 };
  for (const entry of Object.values(registry.collections)) {
    stats.collections++;
    stats[entry.group]++;
    if (entry.group !== "excluded") { stats.retained++; stats.sampleRefs += entry.samples.length; }
  }
  return stats;
}

function projectFromEntry(key, entry) {
  const { chain, address, project } = parseIdentity(key);
  return { id: `${address}-${project}`, chain_id: chain, contract_address: address, project_id: project,
    name: entry.name, artist_name: entry.artist, directory: entry.directory, group: entry.group,
    invocations: entry.samples?.length ?? 0 };
}

module.exports = { GROUPS, identity, projectIdentity, validateCuration, scanGroups, captureCuration, curationStats, projectFromEntry };
