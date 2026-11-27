# Phase 1 — HLD check

The HLD covers this change; the concurrency mechanism is delegated to record-store, not the root, so no architectural change is needed. I made the status cascade:

- Architecture table: record-store state `Drafted; concurrency choice open` → `Drafted`.
- The paragraph that said tablet-sync/review-export "must wait for its contract" now states the selection: *whole-visit revisions — each edit preserves a complete submitted visit, and competing revisions become coordinator review work rather than an automatic merge.*

If that reframing is wrong, say so and I'll revert it.

# Phase 2 — Record Store LLD (drafted)

I rewrote `docs/intent/record-store/record-store-design.md` around the whole-visit policy. Its content:

**Context** — owns visit persistence and what a visit's current record is when independently edited copies arrive. Visits are client UUIDs referencing a catalog plot UUID (site-catalog); arrival order is not authority. Accepts whole-visit revisions. Fixes the submission envelope, current-state response, unresolved-work representation, and resolution operation.

**Revision Model** — a visit is a graph of immutable complete revisions. Submission envelope: `visit_id`, `base_revision_id` (null = creation), `idempotency_key`, `payload` (plot_id, observation_date, observers, species_cover, notes); server adds `revision_id`, `author_id`, `receipt_time`. Terms: **head revision** = no other revision names it as base; **resolution** = a coordinator's recorded choice of one competing revision as survivor. **Settled** = exactly one non-superseded head (its current record); **unresolved** = two or more non-superseded heads. Sequential edits stay settled; two edits from the same base are unresolved.

**Submission and Retrieval** — authenticate and validate field types/plot reference; persist with author and receipt time. Idempotency: same key + identical payload returns original result; same key + different payload rejected, original unchanged. Retrieval returns `settled` (current payload + metadata) or `unresolved` (no single payload; the competing head revisions). Unresolved visits have no current record and are ineligible for export.

**Concurrency: Whole-Visit Revisions** — competing complete revisions are preserved, not merged; the server can't infer field relationships (a revised species ID vs. its cover). Each submission names its base, so an edit on the current head continues the visit while an edit on a base another edit already used creates a competing head.

**Resolution** — a coordinator selects one competing head as survivor; store records coordinator identity, contributing revision IDs, outcome (REC-006), marks the other heads superseded, visit settled on the chosen revision. Superseded revisions remain as history; a later resolution may replace the outcome; payloads are never edited.

**Decisions & Alternatives** — three rows: whole-visit vs field-aware merge; resolution-by-selection vs merge/coordinator-authored payload; head-derived settlement vs a separate mutable pointer.

**Open Questions & Future Decisions** — five deferred items, listed under the probe below.

# LLD-level edge-case probe

I delegated the probe to a blind reader given only the LLD. Genuine gaps needing your triage (fix in the LLD now vs. defer as open questions):

1. **Re-resolution is self-contradictory.** Resolution marks every other head superseded, leaving one non-superseded head — yet the text says a later resolution may pick a different survivor. Among what, and is superseded status reversible?
2. **Re-opening.** A submission whose base is a now-superseded competitor (or a losing branch) — does the visit return to unresolved, and is the survivor's status reverted?
3. **`base_revision_id` integrity.** Unknown base, or a base belonging to another `visit_id`: accept, reject, error?
4. **Null base on an existing visit.** Second root revision, rejection, or idempotent no-op?
5. **Resolution envelope.** No idempotency key or concurrency control: retried resolution, two coordinators resolving concurrently.
6. **Coordinator authorization.** Submissions authenticate the worker; resolution only *records* identity. Is authorization enforced, and what qualifies as a coordinator?
7. **Idempotency-key scope.** Per-visit or global? Same key across different `visit_id`s?
8. **Error/absent-state shapes.** Retrieval of an unknown `visit_id`; rejection error shapes for type/plot validation and key reuse.
9. **`plot_id` invariant.** Must every revision of a visit carry the same plot_id?
10. **Resolution eligibility/outcome values.** Can resolution target a settled or single-head visit, and with what result? What are the permitted `outcome` values?

(Also from the LLD's own Deferred list: whether superseding a head cascades to its descendants; whether a resolution may pick only a head; whether a coordinator may author a new revision as the outcome.)

# Decision record

The whole-visit vs. field-aware merge choice looks like it will stay live for a cold reader (credible options traded against multiple criteria, and tablet-sync/review-export will be sized around it). I've recorded it as a Decisions row. **Should I also write a full decision doc at `docs/intent/record-store/decisions/concurrent-edit-policy.md`?** (Yes/no — I'll write it only if you accept.)

---

I've stopped here rather than drafting the Phase 3 EARS specs, since they should follow a settled LLD. Two asks: **(a)** triage gaps 1–10 (and the Deferred list) into *fix in the LLD* vs *keep deferred*, and **(b)** confirm or reject the decision-doc offer. On your approval I'll fold in the fixes and draft the record-store EARS specs — still holding tablet-sync and review-export until after that.