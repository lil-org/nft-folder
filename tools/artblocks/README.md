# Art Blocks curation

`curation.json` preserves the review decisions independently of downloaded files. Each entry is keyed by `chain-id:lowercase-contract-address:project-id` and contains its name, artist, group, and local folder basename. Retained collections also record the reviewed token IDs, invocations, media URLs, and extensions.

The initial snapshot contains 55 `good`, 237 `ok`, 227 `hmm`, and 618 `excluded` collections. The 519 retained collections have 11,627 sample references. The source inventory was fetched on September 6, 2026; these are review decisions for that inventory, not a current API count.

The entire project-root `samples/` directory remains Git-ignored, including media, raw manifests, and generated reports. Only this compact registry, documentation, and tooling belong in Git. Excluded collections have no sample references and are never automatically downloaded again.

## Capture and check decisions

Run commands from the repository root with Node.js 22 or newer:

```sh
node tools/download_artblocks_samples.js --check-curation
node tools/download_artblocks_samples.js --capture-curation
```

Both operations are offline. Capture requires all three local group directories and either the original `samples/inventory.json` or an existing registry. It matches collections using their manifests, preserves actual folder names (including spaces), and requires each retained sample to exist with its recorded byte size. It writes deterministic JSON and records previously known collections absent from the groups as `excluded`.

To change a rating, move its whole collection folder between `samples/good/`, `samples/ok/`, and `samples/hmm/`, then capture and review the JSON diff. To exclude a collection, delete its folder and capture. To restore an excluded collection, recover its original folder and manifest into one of the groups, then capture; excluded entries intentionally do not retain token references. Duplicate identities, conflicting sample selections, invalid paths, and incomplete downloads cause capture to fail before writing the registry.

Checking validates the registry and compares it with local groups when collections are present. On a fresh checkout with no local collections, it validates saved decisions without inferring deletions. An ordinary download never changes curation decisions. Capture should only run after intentional local organization; do not use it on a partially restored sample set.

## Restore or resume samples

Downloading and media verification additionally require ImageMagick's `magick` and FFmpeg's `ffprobe` on `PATH`:

```sh
node tools/download_artblocks_samples.js --group good
node tools/download_artblocks_samples.js
node tools/download_artblocks_samples.js --verify-only --group good
```

Downloads default to all three retained groups, restoring the exact reviewed tokens and selected media URLs into their group folders. Existing moved or renamed folders are found by manifest identity; group filters follow their current local location. The tool reuses valid files and creates local manifests from the registry on a fresh checkout. It does not replace missing reviewed items with other tokens or silently choose a different media format. Unavailable saved URLs are reported for later review.

Transfers follow redirects, validate media contents, use temporary files before renaming, and resume using SHA-256 and size checks. Six workers use up to five transient retries and preserve 10 GiB of free disk space. Local `download-summary.json` and `download-report.md` describe the selected run. Verification is read-only and exits nonzero for missing or invalid files.

Use `--output <directory>` for another local sample root or `--curation <file>` for a separate registry.

## Discover new projects

```sh
node tools/download_artblocks_samples.js --discover
```

Discovery queries the public `https://data.artblocks.io/v1/graphql` endpoint, verifies pagination against the aggregate count, and compares the result with the app's bundled collection identities and saved decisions. Unknown projects are written as `unreviewed` to the ignored `samples/discovery.json`. Discovery does not download them, recreate excluded collections, overwrite the original inventory, or assign ratings.

Adding a new project to the app is a separate bundling task. The sample downloader only preserves and restores the review corpus.

## Tests

```sh
node --test tools/download_artblocks_samples.test.js tools/artblocks/curation.test.js
```

Integration tests use a temporary local HTTP server and generated fixture images. They do not download public Art Blocks media or modify the real sample corpus.
