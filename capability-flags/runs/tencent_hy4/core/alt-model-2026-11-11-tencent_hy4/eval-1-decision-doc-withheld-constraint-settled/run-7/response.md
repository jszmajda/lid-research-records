Coherence pre-flight first (resuming last session's change): HLD ↔ registry LLD ↔ REG-001–004 are mutually consistent; no tests or code exist yet and all four specs are `[ ]` active gaps, so there is nothing downstream to drift. One pre-flight drift item: the HLD and LLD still said the backend "remains open" / "not selected yet" — fixed before drafting.

One finding worth flagging: the on-site HTTPS directory and managed search service both need runtime network access, which the HLD tenets forbid ("no runtime network access is permitted"; "kiosks have no network route during normal operation"). The local SQLite index is the only tenet-compliant option. Since an inherited constraint already settles the choice and it affects only the registry node (the certificate interface is unchanged), I recorded it as a **Decisions & Alternatives row**, not a full decision doc — a long deliberation is a symptom, not the earns-its-place test. I also kept the backend out of the HLD; its substance belongs in the registry LLD.

Files changed:
- `docs/intent/registry/registry-design.md` — finished (below).
- `docs/high-level-design.md` — removed the stale "remains open" phrase.
- `docs/intent/registry/registry-specs.md` and the entire `certificates/` segment — untouched: the backend is private to the registry node, so no EARS change and no cross-segment cascade.

**Phase 2 output — finished `registry-design.md` (full)**

```
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks have no network route during normal operation; signed USB snapshots are the only registry update channel.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, backend preparation, and lookup all belong to this node. Lookups are served from a local embedded SQLite index built from the active snapshot. The index, its storage, and its query path are private to this node.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build a new SQLite index from the validated records without exposing partially imported data. Keep the previous snapshot and its index available throughout; activate the new index only after validation and index construction both succeed. An import failure leaves the previous snapshot active and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active SQLite index and return the snapshot date even when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index, rebuilt on the kiosk when a snapshot is activated | On-site HTTPS directory; managed search service | Serial-number lookups must complete from files on the kiosk with no runtime network access, and kiosks have no network route during normal operation; a centrally maintained or externally hosted index would require connectivity the kiosks do not have. A local index keeps validation, rebuilding, and querying inside this node and gives predictable lookup latency without a separate service, at the cost of a per-kiosk rebuild on each snapshot. |
```

**LLD-level edge-case probe — gaps for you to triage**

1. **No active snapshot (fresh kiosk / first boot).** REG-002 requires the active snapshot date in every result, but before the first successful import there is none. Two plausible readings: lookups are refused until a snapshot exists (so REG-002 never applies), or `NotFound` is returned with no/undefined date. This is a genuine spec fork (affects REG-002, and CERT-001/CERT-002 which consume the result) — I won't pick a reading for you.
2. **Snapshot arrives mid-lookup.** Are in-flight lookups served from the old index until the atomic swap, or is there a lock/window? Ordering/concurrency assumption is unstated.
3. **Index-construction failure** (corrupt write, disk full, 150 MB snapshot on a 4 GB kiosk). REG-003 covers rejection plus retention, but the LLD doesn't say whether a partially built index is discarded or what error the technician sees.
4. **Index persistence across reboots.** Is the SQLite index persisted on disk and reused, or rebuilt on every boot? Unstated state transition.
5. **Snapshot-date authority.** REG-002's date comes from the manifest or from index metadata; if they disagree, which wins? Unstated invariant.

**Stop — I need your ruling before continuing:**

- Review the finished LLD above (numbered feedback welcome).
- Triage each gap: which to fix in the LLD now, which to defer to an *Open Questions & Future Decisions* section.
- Resolve gap 1 explicitly — which of the two no-snapshot behaviors do you want?
- Confirm the certificate interface stays unchanged and I should **not** cascade into the `certificates/` segment.
- Approve moving to Phase 3 (EARS consistency check). I expect no spec changes since the backend is internal, but coverage, contradiction, and implicit-scope checks still run there.