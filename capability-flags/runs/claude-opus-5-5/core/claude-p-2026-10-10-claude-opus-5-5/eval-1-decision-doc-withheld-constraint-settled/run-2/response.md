The registry design is drafted around the local SQLite index and is ready for your review, with ten gaps from an independent probe for you to triage. Nothing is committed, and I have not touched the registry specs yet — those come after you approve this.

I also changed one line in `docs/high-level-design.md`: the registry entry now says the backend is a local embedded SQLite index, private to the node, instead of "remains open". The certificates design is unchanged.

## Draft: `docs/intent/registry/registry-design.md`

**Context** and the `findBySerial` interface are unchanged. The rest is new or revised:

**Architecture.** Snapshot validation, index preparation, and lookup all belong to this node. Lookups are served from a local embedded SQLite index that the kiosk builds from each snapshot it imports. The index's file location, schema, and queries are not visible to any other node.

**Index.** Each imported snapshot becomes one SQLite database file on kiosk storage, built once at import and never modified afterwards.
- **Records table:** one row per record, keyed by normalized serial number, carrying the description, calibration date, and due date.
- **Snapshot metadata:** the snapshot date and schema version, held in the same file, so a result's record and date always come from the same snapshot.
- **Active and staging files:** exactly one file is active, at a fixed path in the registry's storage directory. A file being built sits at a staging path in the same directory, so activation is a rename within one filesystem.

**Snapshot Import.** Import runs in this order and stops at the first failure:
1. Verify the signature manifest against the snapshot files using the bundled public key. No record is parsed before the signature verifies.
2. Reject a schema version the kiosk does not support.
3. Build a new index file at the staging path, reading records one at a time. A record whose normalized serial is already in the staging index fails the import as a duplicate.
4. Run SQLite's integrity check on the staging file.
5. Activate by renaming the staging file over the active path.

Around those steps:
- **During an import:** lookups keep answering from the previous snapshot. A lookup in progress at activation completes against the snapshot it started on; every later lookup sees the new snapshot in full.
- **On failure:** the staging file is deleted, the previous snapshot stays active, and the error reports which step failed and why (invalid signature, unsupported schema version, duplicate serial, unreadable media, insufficient storage).
- **At startup:** a staging file left by an interrupted import is deleted before any lookup is served.
- **Concurrency:** only one import runs at a time.

**Lookup Behavior.** Normalize surrounding whitespace and uppercase ASCII letters; punctuation remains significant. The normalized serial is one primary-key query on a read-only connection to the active file. The snapshot date is returned even when no record matches. The index needs no warm-up and holds no in-memory copy of the registry.

**Decisions & Alternatives.**

| Decision | Chosen | Alternatives | Rationale |
|---|---|---|---|
| Lookup backend | Local SQLite index built on each kiosk | On-site HTTPS directory; managed search service | Both alternatives answer lookups over a network, which the tenets rule out. The cost is that every kiosk validates and builds its own index. |
| Where the index is built | On the kiosk, from the signed records | Ship a prebuilt SQLite file in the snapshot | The kiosk only trusts what it verified, and the snapshot format stays independent of the index schema. |
| Replacing the active snapshot | Build a separate file, then rename over the active path | Replace rows in the active database in one transaction | A rename is all-or-nothing and leaves the previous file intact until it succeeds. |

**Open questions (deferred).** Whether the previous index file is kept after activation, and whether a snapshot older than the active one is accepted.

## Gaps to triage

For each, tell me whether to fix it in the design or defer it. My suggestion follows each one.

1. **No result for "no snapshot yet".** Both result variants require a snapshot date, so a freshly installed kiosk has nothing valid to return. Fixing this means a third result or an error on the interface certificates uses, so it crosses into the certificates design. I'd fix it, but it needs your go-ahead to touch that node.
2. **No error shape for a storage fault.** An unreadable index or an empty serial after normalization would currently come back as `NotFound`, which wrongly says the equipment is not in the registry. I'd fix it; it has the same cross-node reach as gap 1.
3. **Power loss around activation.** Nothing says the staging file is flushed to disk before the rename, or what happens at startup if the active file is damaged. I'd fix it by flushing before the rename and integrity-checking the active file at startup. What the kiosk does when the active file fails that check is yours to decide.
4. **Connections across activation.** The "same snapshot" guarantees only hold if each lookup opens its own connection and reads record and date together. I'd fix it by stating that, and by adding a failed rename to the failure reasons.
5. **Malformed records.** The design does not say whether a bad JSON line, a missing field, or an empty snapshot fails the import or is skipped. I'd fail the whole import, consistent with duplicates.
6. **What the signature covers.** It is unstated whether the manifest authenticates every file's content, including the date and schema version, and whether the build reads the same bytes that were verified. I'd fix it: the manifest covers all content, and the kiosk copies the snapshot to local storage before verifying and building from that copy.
7. **Normalization wording.** The sentence can be read two ways; I'd reword it to "trim surrounding whitespace and convert ASCII letters to uppercase". Internal whitespace and non-ASCII characters would stay significant, like punctuation, unless you say otherwise.
8. **Serials that differ only by case or whitespace.** They collide after normalization and reject the whole snapshot, leaving the kiosk on old data until the inventory team reissues. I think rejecting is right, but it is your call. I'd also report every duplicate, not just the first.
9. **The two deferred questions are half-decided.** The rename already destroys the previous file, and an older snapshot would currently activate silently and move the registry backwards. I'd settle both now: no rollback copy, and reject a snapshot older than the active one. Should re-importing the same snapshot be accepted?
10. **Second import request, load, and disk space.** The design does not say whether a second import is rejected or queued, whether free space is checked up front, or whether the 250 ms goal holds while a build runs. I'd reject the second request and check space before building; the 250 ms question I'd defer to measurement.

Reply with the numbers to fix or defer (or "fix all as suggested") plus answers to the open points in 3, 8, and 9, and whether I may update the certificates design for 1 and 2.