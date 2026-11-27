Finishing up: the record-store design is drafted and probed; here's where it stands.

## Record-store design: draft ready for your review

I rewrote `docs/intent/record-store/record-store-design.md` around whole-visit revisions. The specs are untouched; they come after you approve this design.

### The contract as drafted

- **Revision**: one complete submitted visit, never altered after acceptance. The tablet generates its UUID, which doubles as the idempotency key, so offline edits can chain.
- **Envelope**: `visit_id`, `revision_id`, `base_revision_id` (absent on a visit's first revision) and the full payload. The server adds author and receipt time.
- **Visit states**: `current` (one head revision) or `unresolved` (two or more competing revisions, and no current revision).
- **Acceptance**:
  - An edit based on the current revision replaces it.
  - An edit based on a competing revision replaces that competitor.
  - An edit based on anything else joins as a competitor, so a late edit reopens a resolved visit instead of being dropped or overwriting the resolution.
- **Rejections**: `invalid_payload`, `unknown_base`, `base_not_in_visit`, `visit_exists`, `revision_id_reused`.
- **Retrieval**: visit state returns the current revision, or the competing revisions plus a "last agreed revision" for comparison. Visit history returns every revision and resolution record.
- **Resolution**: coordinator only. The coordinator either selects one competing revision or replaces them with a hand-written one. A resolution is rejected as `stale_review` if the competing set changed during review.

The Decisions table records the concurrency choice with field-aware merge as the rejected alternative, plus six smaller choices I made.

### Gaps found by the probe

A cold-reader subagent probed the draft, seeing only the HLD and this design. I have not applied any of its findings; please triage each as fix or defer.

**Your call — these change the review queue or the contract:**

1. **Identical payloads from the same base.** The draft sends them to review like any other pair. Auto-collapsing them would shrink the queue but adds a payload-comparison rule. Keep or collapse?
2. **Coordinator "replace" outcome.** Should a coordinator be able to hand-write a combined revision, or only select one? If replace stays, its base is undefined in the draft. I'd record all the competing revisions it replaces as its parents, in the resolution record.
3. **Unbounded reopening.** A late edit based on a set-aside revision reopens a visit weeks later, even one already exported. Is that acceptable, and is "already exported, now unresolved" a problem for review-export to handle later?
4. **Editing an unresolved visit.** A worker's new edit either extends one competitor (taking a side) or adds another head. Allow both as drafted, or block edits until the visit is resolved?
5. **Shared-tablet authorship.** The author is whoever is signed in at sync time, which may not be who wrote the edit offline. Should the envelope carry a tablet-recorded author as well?
6. **Rejected link in an offline chain.** If the oldest edit is rejected, every edit based on it fails with `unknown_base` and stays only on the tablet. Is that acceptable under "do not silently discard a submitted edit", or should the server keep rejected submissions?
7. **Listing operation.** Nothing enumerates unresolved visits or the export set. I'd add a list-by-state operation here, since review-export cannot work without it.

**Defects I'd fix unless you object:**

8. "Last agreed revision" is ill-defined after a resolution: it can point at a set-aside revision or at nothing. I'd redefine it as the most recent revision that was the visit's current revision.
9. Resolution has no idempotency key, and it is not stated to be serialized with submissions. I'd add both.
10. Rejection precedence is unstated, and replaying an accepted revision whose plot no longer validates is undefined. I'd fix an order and have a replay always return the original result.
11. "Set aside" under replace is ambiguous. I'd state that all competing revisions are set aside and none becomes a head again.
12. "Identical envelope" wrongly includes the server-added author and receipt time. I'd narrow it to the tablet-supplied fields.

### Other things to rule on

- **Decision doc.** The revisions-versus-merge choice will stay live for a cold reader, and two more designs are about to be sized around it. Do you want a full decision doc at `docs/intent/record-store/decisions/`, or is the Decisions row enough?
- **HLD.** I made two wording edits to `docs/high-level-design.md`: the record-store state now reads "Drafted", and the paragraph about the "unresolved choice" now says the two downstream designs build on the record-store contract.
- **Site catalog.** `site-catalog-design.md` still says tablet-sync's reconciliation behavior "remains pending that choice". That is a different segment, so I left it. OK to update that sentence?

Once you've ruled on 1–12 and the three items above, I'll revise the design and move to the EARS specs. REC-004 and REC-005 need rewording there, and the new behaviors need spec lines.