Local SQLite is recorded in the registry design, and I've stopped at the end of Phase 2 (LLD) for your review. I haven't touched the specs, tests, or code.

## What changed

**`docs/intent/registry/registry-design.md`**
- **Backend:** Lookup is now served by a local embedded SQLite index that each kiosk builds from the snapshot it imports. The index file, schema, and location are private to the registry.
- **Import:** Import is now an ordered flow: verify signature, reject unsupported schema, check uniqueness, build the index in a staging location, then activate by one atomic switch. Any failure discards staging, keeps the previous snapshot, and reports the failing step.
- **Lookup:** Normalization is applied both at index build and at query time, so stored and queried serials agree.
- **Decisions & Alternatives:** I added two rows. The first records SQLite against the HTTPS directory and managed search service. The second records staging plus atomic switch against rebuilding in place. The HTTPS and managed-service options are rejected because both need runtime network access, which the HLD tenets forbid.
- **Decision doc:** I didn't offer a separate decision doc, since the HLD tenets settle the choice.

**`docs/high-level-design.md`**
- One line changed: the registry bullet no longer says the backend "remains open". It's a factual update, and the certificates node is unaffected (the interface and result types are unchanged).

## Needs your call (edge-case probe of this LLD)

1. **Duplicate definition (spec fork).** REG-003 says "duplicate serial numbers", but lookup normalizes case and whitespace. Should `ab-1` and `AB-1` in one snapshot count as duplicates and reject the import? Or are only exact matches duplicates? If only exact matches count, two records could collapse to the same lookup key. I recommend rejecting on the normalized form. This is your call, and I haven't written either reading into a spec.
2. **No snapshot yet.** What should `findBySerial` do on a kiosk that has never imported a valid snapshot? There is no snapshot date to return, so neither `Found` nor `NotFound` fits as defined.
3. **Corrupt active index.** If the active index fails an integrity check at startup, should the kiosk refuse lookups, or fall back to the previous snapshot if one is kept? That depends on whether we retain one.
4. **Disk space.** Staging a new index alongside the active one, with snapshots up to 150 MB, needs free space. Should import check it up front and fail with a clear error?
5. **250 ms goal.** Should a cold-start lookup count against it, or only warm lookups?

I've logged items 1–4 under Deferred in the LLD. Tell me which to resolve now, and which can stay deferred.

Please also review the HLD one-line edit. Once you approve the LLD and HLD, Phase 3 drafts the EARS updates. They would add the staging/atomic-activation spec and the failure-reporting spec, and tighten REG-003 per your answer to item 1.