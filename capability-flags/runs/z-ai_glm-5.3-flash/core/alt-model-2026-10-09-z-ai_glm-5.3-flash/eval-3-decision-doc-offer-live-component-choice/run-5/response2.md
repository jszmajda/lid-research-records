All three pieces of this round are done. Here's the state and what I need from you.

## Decision doc

**docs/intent/record-store/decisions/whole-visit-revisions.md** is written. It covers:

- **Gates and criteria**: no-silent-discard as the gate; whole-visit scientific integrity, review workload sustainability, implementation/maintenance burden (major), export readiness, tablet storage cost (minor) — each tied back to the HLD tenets where they derive from them.
- **Both options at full strength**: field-aware three-way merge gets its honest best case — smaller queue, better export throughput, automatic combination of genuinely disjoint edits — alongside its risk: rules for scalars, observer lists, and species entries can't know that a species re-identification and its cover estimate belong together.
- **Why the other approach stays live**: if two coordinators measurably can't sustain the review queue, or unresolved visits routinely block the Friday export, the decision should be revisited — and what a reversal would require (surfaced-not-silent auto-combinations, the no-discard gate intact, contracts re-derived).
- **Downstream accommodations**: what tablet-sync (base revision IDs, complete payloads, pending-competing display, retry state machine) and review-export (revision comparison view, resolution recording, unresolved exclusion from CSV, revision-history provenance) must each build in.

## LLD updates

The probe fixes you went along with are in the design doc: invalid and pending-base submissions are rejected without storage; tip moves to a winning competing revision with sequence numbers untouched; a losing competing revision leaves the prior tip current; distinct-key identical payloads are distinct revisions; zero-revision retrieval is a not-found error; rejected-key retries return the original rejection. Re-opening a resolved visit is recorded under Deferred for review-export to settle. The Decisions row links the decision doc.

## Phase 3 — EARS specs (ready for your review)

**docs/intent/record-store/record-store-specs.md** now has REC-001 through REC-022. Consistency report:

- **Coverage**: one gap found and closed — the LLD's authentication/field-validation step had no spec, now REC-022. The revision chain, competing sets, idempotency, retrieval, history, and resolution all have specs.
- **Contradiction**: none. The two tip-based submission specs are explicitly disjoint (REC-008 requires no unresolved competing set; REC-012 applies when unresolved); accepted vs. rejected idempotency-key retries are disjoint (REC-002 / REC-014).
- **Implicit scoping**: REC-004 previously said "regardless of the concurrency policy's outcome" — conversation residue; reworded to "regardless of which one becomes the visit's current state," which stands alone.
- **Context-free reading**: each spec carries its own condition; no spec relies on section names or this conversation to disambiguate. REC-006 (policy-neutral resolution retention) coexists with REC-018 (concrete resolution fields) — REC-018 concretizes rather than contradicts it.

**Stop: please review the spec file.** If it looks right, the next step is the Phase 4 intent-narrowing edge audit (cross-spec and cross-segment divergence probes on the new spec lines) at its own stop — say go and I'll run it.