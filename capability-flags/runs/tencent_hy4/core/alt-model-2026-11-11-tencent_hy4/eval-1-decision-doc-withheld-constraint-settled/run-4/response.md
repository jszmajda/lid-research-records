**Phase 2 — Registry LLD (stop)**

Coherence pre-flight (resumption): clean. REG-001..004 still trace to this LLD; there are no tests/code yet (all specs `[ ]`); the LLD still matches the HLD — registry owns validation/lookup, certificates use a fixed result type. The HLD's "private lookup backend remains open" is its *delegation* of that choice to this node, not a pending-status claim, so no HLD edit. The choice stays private to this segment (certificate interface unchanged), so there is no cross-segment cascade to pause on.

Decision recording: I recorded it as a `Decisions & Alternatives` row, **not** a decision doc. The HLD's no-runtime-network tenet eliminates the two connectivity-dependent options, and the decision touches only this node. The earns-its-place test runs from the landed state, not the deliberation — a cold reader wouldn't re-litigate this, however close the options looked while you weighed them. Rejected alternatives and their reason live in the table, never as body-prose asides.

Revised `docs/intent/registry/registry-design.md` in full:

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, backend preparation, and lookup all belong to this node. A local embedded SQLite index built from the active snapshot is the lookup backend. Kiosks have no runtime network access, so the backend runs entirely against files on the kiosk: each kiosk validates a snapshot and rebuilds its own index when a snapshot arrives, with no service to run and no connectivity required.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build a new SQLite index from the validated records without exposing partially imported data. Activate the new snapshot and its index together only after all validation succeeds. An import failure leaves the previous snapshot and its index active and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active SQLite index and return the snapshot date even when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index built from the active snapshot | On-site HTTPS directory; managed search service | Kiosks have no runtime network access (HLD tenet); both alternatives require live connectivity for lookup. SQLite keeps validation, index build, and query on local files inside this node, gives predictable lookup latency, and leaves the fixed `findBySerial` result type unchanged for the certificates node. Each kiosk validates and rebuilds its own index when a snapshot arrives. |
```

LLD-level edge-case probe (delegated to a blind reader given only the artifacts; surfaced as questions, not resolved):

1. [state transition] First boot with no snapshot/index and `findBySerial` called before any import — is there a defined "no active snapshot" state, and which `snapshotDate` is returned when both `Found` and `NotFound` require one?
2. [error shape] Active index missing/corrupt/locked at query time — what does `findBySerial` return, given its result type has no error/unavailable variant (throw, `NotFound`, something else; carrying which `snapshotDate`)?
3. [state transition] Validation succeeds but the SQLite index build fails (I/O, disk full) — is this an "import failure" that keeps the previous snapshot+index active, or a distinct class; what is the state of the partial index and validated-but-not-activated snapshot?
4. [error shape] "Reports a useful error" — what is the concrete shape, channel, and consumer (structured reason codes for signature/schema/duplicate/build-failure, exception, log)?
5. [ordering] At the instant the new snapshot+index activate together, what happens to a lookup already in flight against the old index (complete on old, switch, block), and is the swap atomic with respect to concurrent lookups?
6. [unstated invariant] Where does the index file live, what designates the active snapshot/index, and is the previous snapshot+index retained after a successful swap or discarded?
7. [state transition] Per arriving snapshot, is the index rebuilt fully from the complete record set or updated incrementally — and does "rebuild" mean recreate-from-scratch every time?
8. [state transition] On normal startup with no new snapshot, does the component open the persisted index directly or re-validate and rebuild — and is active-snapshot identity persisted so a boot can reconstruct state without an import?
9. [unstated invariant] When serials are "normalized … before lookup", are index keys stored raw (normalization only on query input) or stored normalized (at build time) — and is uniqueness validation on raw or normalized form (so `" abc "` and `"ABC"` are / are not duplicates)?

STOP — before I move to Phase 3 (EARS update), I need your ruling:

1. Review the revised LLD above: approve, or give numbered feedback.
2. Triage gaps 1–9: which should I fix in the LLD now, and which should I defer to `Open Questions & Future Decisions`? (Any gap fixed now may need a matching EARS line in Phase 3; per the skill I won't resolve a reading that admits more than one on your behalf.)

On approval I'll draft the corresponding EARS changes — new specs for the per-snapshot index build/rebuild and the atomic snapshot+index swap — and present them with the Phase 3 consistency report (coverage, contradiction, implicit scoping, context-free reading) at the next stop. I'm using the default inspector (you reading the output); say the word if you'd rather I dispatch a delegated or zero-context inspector for this phase.