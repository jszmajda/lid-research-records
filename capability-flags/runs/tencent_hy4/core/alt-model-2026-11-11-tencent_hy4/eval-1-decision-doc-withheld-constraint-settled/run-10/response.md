Phase 2 stop — I've drafted the registry design around the local SQLite index. I did **not** roll on into EARS/tests/code; every phase boundary gets its own approval.

**Coherence pre-flight (resumption).** HLD ↔ registry LLD ↔ REG-001..004 are consistent; the LLD reflects the HLD, which delegates the backend to this node. No code/tests exist yet (arrow is docs-only). Two flags: the HLD line "Its private lookup backend remains open" now names a decision this LLD resolves — I left it untouched rather than auto-repair an upward (HLD-originating) cascade; say the word if you want it cleaned. No `docs/arrows/` overlay and no review-depth declaration, so stops run unconsolidated.

**How the choice was recorded.** As a Decisions & Alternatives row in the registry LLD — not a decision doc, and I'm not offering one. Judged from the landed state: the HLD tenet (no runtime network access; USB-only snapshots) eliminates the HTTPS-directory and managed-search options, and all three keep the certificate interface unchanged, so the decision affects only this node. An inherited constraint settles it; a cold reader wouldn't re-litigate it. The fact that it felt close while deliberating isn't the test. I also stripped the "not selected yet / pending the user's choice" residue and moved rejected alternatives into the table.

**Phase 2 output — `docs/intent/registry/registry-design.md` (drafted in full):**

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks have no network route during normal operation; signed USB snapshots are the only registry update channel.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface and does not read registry storage.

Lookup is served by a local embedded SQLite index that the registry builds and owns. Each kiosk validates and rebuilds the index when a snapshot arrives; snapshot validation, index preparation, and lookup all stay inside this node. No service is run and no runtime network access is used.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build the SQLite index for the new snapshot without exposing partially imported records, then activate it only after all validation and index preparation succeed. An import or index-build failure leaves the previous snapshot and its index active and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active SQLite index and return the snapshot date even when no matching record exists. Lookups are served entirely from the local index, with no runtime network access.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Lookup backend | Local embedded SQLite index, rebuilt on each snapshot | On-site HTTPS directory; managed search service | The offline kiosk constraint — no runtime network access, USB-only snapshots — eliminates both network-dependent backends. An embedded index keeps lookups local and predictable, confines snapshot validation and index-rebuild cost to this node, and leaves the certificate interface and result unchanged. |
```

**LLD-level edge-case probe** (delegated to a fresh reader given only the LLD; gaps surfaced, not resolved):

1. What does `findBySerial` return before any snapshot has ever been activated, or after a first-ever import fails with no "previous snapshot" to fall back to — is "no active snapshot" a defined state, and what `snapshotDate` would `NotFound` carry then?
2. When a lookup arrives during an index build or at the instant of activation, does it block, keep reading the previous index, or fail — and which `snapshotDate` does a lookup that starts before the swap and finishes after it return?
3. What happens when a second snapshot arrives mid-import, or an older/same-dated snapshot is imported after a newer one: is import serialized or queued, does last-arrival win, and is any snapshot-date monotonicity or duplicate-import rule enforced?
4. Is normalization applied to stored records at index-build time, to the `findBySerial` argument only, or both — and is the uniqueness check on raw or normalized serials (are `ABC` and ` abc ` duplicates, and which form is the index key)?
5. Where does the returned `snapshotDate` live — snapshot-level metadata, the index, or per record — and is its value from the signed snapshot, the manifest, or wall-clock import time?
6. What is the activation/persistence model: where does the staging index reside while the previous one stays active, is activation an atomic swap, is a partially built index discarded before retry, and what state is recovered on restart/power loss between "prepared" and "activated"?
7. What is the import operation's return shape — typed, distinguishable failures (bad signature / unsupported version / duplicate serials / build failure) versus one generic "useful error" — and can `findBySerial` ever yield anything other than `Found`/`NotFound` (missing, corrupt, or locked index)?
8. How is a single malformed NDJSON line, an empty serial, or a missing/ill-typed date or description handled — whole-snapshot rejection or skip-the-record — and what exactly counts as a "supported schema version" (values, source, and whether version rejection is ordered before signature verification)?
9. How does `findBySerial` handle an empty, whitespace-only, or non-string serial and non-ASCII characters, given normalization defines only trimming surrounding whitespace and uppercasing ASCII letters (and which characters count as "surrounding whitespace")?

Please rule on this stop:
- **Approve or revise the LLD** (send numbered feedback). On approval I move to Phase 3 (EARS) to check coverage/contradiction/scope for the new "build and rebuild the local index" content against REG-001..004, then stop again before Phases 4–6.
- **Triage the probe gaps**: which should I fix in the LLD now, and which should I defer into Open Questions & Future Decisions?
- Optional: do you want the HLD's stale "remains open" line cleaned up?