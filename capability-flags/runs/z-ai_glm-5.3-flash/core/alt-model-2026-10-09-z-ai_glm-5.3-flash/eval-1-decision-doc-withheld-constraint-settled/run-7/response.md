I've finished the registry design around the local SQLite index. Here's the summary, then I'm pausing for your review before any tests are written.

## What changed

**`docs/intent/registry/registry-design.md`** (updated):

- **Architecture**: the open backend question is closed — the lookup backend is now a local embedded SQLite index, private to the registry component. The certificates interface (`Found(record, snapshotDate)` / `NotFound(snapshotDate)`) is untouched.
- **Snapshot Import**: each kiosk builds its own index on snapshot arrival. The new index is built in a temporary file, records are streamed in, then record counts and an index integrity check verify the result. Activation is a snapshot-date-stamped atomic rename, so the lookup path never reads a partial index. An import failure deletes the temp index, keeps the previous index active, and reports a useful error.
- **Lookup Behavior**: serials are stored in the index already normalized the same way lookups normalize them, so lookup is a single exact-match read on the primary key — that's what meets the 250 ms goal on 90,000 records, with no network route.
- **Decisions & Alternatives**: a new row records the SQLite choice against the HTTPS directory and managed search service, with the rationale (no service to run, no runtime network use, per-kiosk rebuild cost stays inside the node). Since the choice only affects this node's internals and the certificate interface is unchanged either way, I recorded it as a table row rather than a full decision doc — but tell me if you'd like a standalone doc given how long the deliberation ran.
- **Open Questions**: deferred on-disk layout details (temp-file location, rename semantics per platform) to implementation.

**No changes to the specs** — REG-001 through REG-004 already cover the behaviors this design realizes (normalization, snapshot date on every result, reject-and-retain on invalid imports, all-at-once activation). I checked for coverage, contradiction, implicit scoping, and context-free reading; no drift found. The certificates segment needs no cascade — its design already declares backend configuration invisible.

## Please review

1. Does the snapshot-import mechanics (temp-file build → count/integrity verify → atomic rename) match what you intend?
2. Deferred to implementation: temp-file location and rename semantics. OK to leave those out of the design?
3. Keep the choice as a Decisions row, or write a full decision doc?

On your approval, the next step is Phase 5 — failing tests first against REG-001..004.