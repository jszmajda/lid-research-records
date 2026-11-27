Phase 2 (LLD) is drafted. Here's where it stands and what I need from you before I move to specs.

## Record-store LLD — finished around whole-visit revisions

I rewrote `docs/intent/record-store/record-store-design.md`. The shape:

- **Revision model** — a visit is a line of immutable whole-visit **revisions**, each carrying its author, receipt time, and the **base revision** it was edited from. Each visit has one **current revision** and is either *resolved* or *unresolved* (one or more open **competing revisions**).
- **Adoption rule** — *first revision* (no base) → current; *fast-forward* (base is current, no open competitors) → new current; otherwise **competing**, retained against current, visit goes unresolved. Fast-forward uses arrival order only to hold a provisional current; divergence always forces review, so arrival order never finalizes authority.
- **Resolution** — a coordinator selects one whole revision as current; the others close as *superseded* (retained, never merged). Resolved visits are export-eligible; unresolved are held out. Review-export owns the coordinator UI and export set built on that signal.
- **Public contract** — submission envelope (`visitId`, `baseRevisionId`, `idempotencyKey`, `payload`), stored revision, current-state response, and resolution op are now spelled out as tables, so tablet-sync and review-export can size against them.
- A **Decisions & Alternatives** table records the choice (and the field-aware-merge alternative with why it was declined), plus two sub-decisions: the fast-forward race behavior, and whole-revision-selection over coordinator-composed merges.

**I removed the policy-open prose entirely** rather than narrating that it was resolved, per *docs carry current intent*.

## 1. Decision-doc offer

This choice clears the bar for a full decision doc: two credible options traded against multiple criteria (review volume vs. merge-maintenance burden vs. whole-visit preservation), and two whole nodes (tablet-sync, review-export) about to be sized around the result. Its substance lives in record-store, so it'd go at `docs/intent/record-store/decisions/concurrent-visit-edits.md`.

Want the full decision doc, or is the **Decisions & Alternatives row** I already wrote enough? (I lean toward writing the doc — a cold reader deciding whether to revisit this later would want the criteria laid out.)

## 2. Edge-case probe — please triage

A blind probe (given only the artifacts) surfaced these internal gaps. I've already captured the base-revision lifecycle ones as Deferred in the LLD. The ones I think are worth **settling in the LLD now** rather than deferring:

- **a. Idempotency equality** — is "identical payload" byte-exact, field-canonicalized, or semantic, and is the key scoped per visit/base or global? This directly shapes REC-002/003 tests.
- **b. Competitor re-anchoring** — when current advances (a fast-forward or a resolution), do already-open competitors re-anchor to the new current, or stay pinned to the current they diverged from? Affects what a coordinator compares.
- **c. Resolution error shapes** — resolving an already-resolved visit, a `selectedRevisionId` that's unknown/superseded/foreign, or two coordinators resolving concurrently. Is selecting the already-current revision a valid no-op?
- **d. Fast-forward after competitors exist** — a genuine base-is-current edit arriving once competitors are open is demoted to competing (current stays frozen until resolution). Intended, or should it still fast-forward?

And ones I'd **keep deferred** (base pointing at an open or superseded competitor; validation error precedence) unless you want them pinned now.

Which of a–d do you want folded into the LLD before I draft specs, and which deferred?

## 3. Small HLD cascade (root — flagging, not silently editing)

The HLD architecture doesn't change (it always delegated the mechanism to record-store), but its State cell for record-store reads **"Drafted; concurrency choice open"**. I'd update it to **"Drafted; concurrency contract defined"** so the root isn't stale. OK to make that one-cell edit?

I'll hold here for your review before touching the EARS specs (Phase 3).