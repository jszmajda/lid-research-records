Done — the decision doc is written and linked from the LLD.

**`docs/intent/record-store/decisions/concurrency-reconciliation.md`** (frontmatter `node: record-store`, no status field, no spec IDs, written cold). It covers your three asks:
- **Proper write-up**: `Decision Elements` (weighted criteria — scientific coherence, coordinator load, maintenance burden, export readiness, submission/tablet state — each anchored to an HLD tenet, goal, or non-goal), two options with per-criterion verdicts, and a `Selection` that states plainly that this chooses *against* the review-load advantage rather than pretending it's absent.
- **Why we'd still consider the other approach**: field-aware three-way merge gets its strongest honest case under "Why it stays a live alternative" (disjoint edits are common; smaller queue; better when review capacity is the binding constraint), plus explicit `Reconsideration triggers` in Selection — volume growth beyond two coordinators, reliable scientific-relationship detection becoming available, or a stabilized schema making merge rules cheap.
- **What the tablet and export work must accommodate**: a dedicated downstream-obligations block spelling out tablet-sync (base revision ID, complete snapshots, retry/idempotency state, surfacing N competing revisions) and review-export (revision comparison screen, coordinator selection, eligibility from record-store state, holding unresolved visits out of the Friday CSV) — recorded as cascades owned by those sibling segments, not co-owned.

I also ran the latent-criteria probe: two candidates (undoing a resolution; review UI surface) score equally and were dropped; one survives (review-queue capacity as volume grows) and is carried as a reconsideration trigger rather than a scored criterion. **One signal worth flagging**: the "prefer conservative review over unnoticed scientific combinations" lean that drives the major criterion isn't stated by any current HLD tenet — the doc leans on the closest existing tenets, goals, and non-goal. That connects to the tenet question below.

The LLD's Decisions row now links to the doc.

---

**Still at the Phase 2 STOP.** Your reply ruled on item 1 only; the following remain open, and I have not answered any of them for you:

2. **Tenet.** "Take a bigger review queue over merge rules that can combine scientifically related edits unnoticed" — add it under the HLD `## Tenets`, or keep it only in the decision record? I have **not** added it (and the doc's tenet-coverage loop is closed on existing tenets only, as noted above).
3. **Probe triage.** For each of the seven LLD edge-case gaps from my last message: fix in the LLD now, or defer as an open question? I have **not** resolved any of them.
4. **Cross-segment cascade.** I described tablet-sync and review-export obligations in the decision doc, but have **not** written those designs. Confirm the hold per "we'll do tablet sync and review/export after that"?
5. **Next phase.** `REC-004` still reads "regardless of the concurrency policy's outcome," and the new revisioning contract (submission envelope, unresolved marker, resolution, export eligibility) has no spec coverage. That's the Phase 3 spec cascade within this segment. Do I have your explicit approval to proceed?

Please give numbered feedback on the doc and rulings on 2–5. I'll stop here until you do.