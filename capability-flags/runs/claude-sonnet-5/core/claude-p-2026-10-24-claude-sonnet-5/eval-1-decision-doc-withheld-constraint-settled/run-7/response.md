## Phase 1 — HLD check

No changes needed. The backend choice doesn't touch the registry/certificate interface or the project's architecture, and `docs/high-level-design.md` already stands as the root design.

One thing worth flagging: the HLD's existing tenets — *"All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"* and *"Kiosks have no network route during normal operation"* — already ruled out the HTTPS-directory and managed-search options before any tradeoff comparison. They weren't actually close once that constraint is applied; I've recorded that as the deciding rationale below rather than treating it as a closer call.

## Phase 2 — Registry LLD updated

Updated `docs/intent/registry/registry-design.md`:

- **Architecture**: names the local embedded SQLite index as the chosen backend — built and validated on each kiosk from the active snapshot, nothing leaving the kiosk.
- **Snapshot Import**: the index build is now part of import validation; a build failure is a validation failure; the new snapshot and its index activate together as a unit, and a failed import leaves the previous snapshot *and* its index active.
- **Lookup Behavior**: lookups resolve against the active snapshot's SQLite index.
- **Decisions & Alternatives** (new table): records the HTTPS-directory and managed-search alternatives and the rationale — both need network access at lookup time, which conflicts with the no-runtime-network tenet, so the embedded index was the only compliant candidate.

No decision doc offered: an inherited HLD constraint (no runtime network access) dominates the choice, so a table row is sufficient.

## LLD-level edge-case probe (delegated, blind to this conversation)

Gaps found in the registry LLD's own description of import/build/lookup, for you to triage:

- **Activation atomicity**: is a lookup during snapshot/index activation guaranteed to see the old-or-new state, never a half-swapped one?
- **Import failure taxonomy**: "a useful error" / "an index build failure is a validation failure" aren't specific — are signature, schema-version, duplicate-serial, and index-build failures distinguishable to the caller?
- **Zero-record snapshot**: does an empty but validly-signed snapshot activate, replacing a populated one?
- **Normalized-duplicate serials**: uniqueness is checked how — on raw record strings, or after whitespace/case normalization? Two records could collide only after normalization.
- **Non-ASCII serial characters**: "uppercase ASCII letters" is silent on non-ASCII letters, if any can appear.
- **Re-import of the already-active snapshot**: idempotent, rejected, or rebuilt?
- **Snapshot date ordering**: must a new snapshot be newer than the active one, or can an older/stale USB stick's snapshot activate?
- **Lookup before any import**: what does `findBySerial` return (including snapshot date) on a fresh kiosk with no snapshot ever imported?
- **Per-record schema conformance**: does validation check individual record field shapes, or only signature/version/uniqueness?

Which of these do you want folded into the LLD now, and which should stay as open questions for later? Once you've triaged, I'll finalize the LLD text and we can move to Phase 3 (EARS specs) on your approval.