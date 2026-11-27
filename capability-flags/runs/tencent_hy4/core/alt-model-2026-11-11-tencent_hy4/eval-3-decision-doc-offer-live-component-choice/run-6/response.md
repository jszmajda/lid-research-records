**Phase 1 — HLD check (coherence pre-flight).** No architectural change: the HLD itself assigns the concurrency mechanism to record-store, so settling it doesn't touch the root. I removed two stale residues of the open-choice state — the Architecture table's "concurrency choice open" status, and the note's "unresolved choice / must wait for its contract" phrasing, now a standing dependency ("tablet-sync and review-export are sized around the contract that node publishes"). `docs/high-level-design.md`. No tenet added yet — see ask 3.

**Phase 2 — record-store LLD, finished.** Rewritten as its fresh author with whole-visit revisions as current intent; the "Open Design Choice" and "After selection, define…" narration is gone. Full doc (please read cold): `docs/intent/record-store/record-store-design.md`. Substance:
- Each submission is a complete visit snapshot naming its **base revision ID**; a server-assigned revision ID, author, receipt time, and idempotency key are recorded. Competing revisions (same base) make the visit unresolved; the store never assembles a visit from parts of different submissions.
- A submission naming the current revision with no competing sibling becomes the new current revision without review; competitors are held for review, never chosen by arrival time/author/field. No field-level combination.
- Current-state retrieval returns the current revision + an unresolved indicator; history returns every revision in receipt order; a coordinator resolves by selecting one competing revision, retaining coordinator identity, selected ID, and contributing IDs, with losing revisions kept.
- The rejected field-aware three-way merge and its rationale (maintained merge rules can't recognize scientific relationships like a species ID + its cover estimate; the cost is a larger review queue two coordinators can absorb) now live in the **Decisions & Alternatives** table, not body prose.
- Downstream obligations on tablet-sync and review-export are recorded here as **cascade notes**, not co-owned.

I have **not** touched tablet-sync, review-export, or the EARS specs (Phase 3).

**LLD-level edge-case probe** (delegated zero-context reader, findings summarized and focused; it looked hardest at base-revision state transitions, idempotency, and the unresolved-state response shape):
1. A submission names a base that is neither current nor shared with a sibling — rejected as stale, or admitted as a competing branch?
2. A non-competing edit is promoted to current, then a later edit naming that same original base arrives — does the visit retroactively become unresolved, or does the promotion stand? (Genuine fork: "only competitors go to review" vs "every submission is held for review." The draft currently assumes the former.)
3. Can a new edit join an unresolved visit's competing set, or a completed resolution be reopened by later arrivals?
4. Two root submissions (no base) for the same new visit UUID — competing on a null base, or a duplicate-visit rejection?
5. While unresolved and the visit never had an agreed state, what does retrieval return as the "last agreed current revision"?
6. Is the named base validated to exist and belong to the same visit; what happens on a nonexistent or cross-visit base ID?
7. Does "identical payload" for a retry mean byte-for-byte (incl. base ID) or scientific-field equality; is a same-key/different-base retry rejected?
8. Is "receipt order" by timestamp, insertion sequence, or revision ID, and how are ties broken?
9. Is the current-state response the full payload or a revision ID, and is the unresolved indicator a boolean/enum/presence of a competing-ID set?

You triage: which gaps I fix in the LLD now, which I defer as Open Questions, and — for the fork in #2 — which reading is your intent. I have resolved none of them.

**STOP — I need your ruling before Phase 3 (EARS narrowing) and Phase 4 (intent-narrowing audit):**

1. **Decision doc?** This choice clears the earns-its-place bar — a credible competing option, three real criteria (review queue, merge-rule maintenance, preserving whole-visit scientific intent), and two sibling segments sized around it — so a cold reader would re-litigate it. Offering once: shall I write a full segment-level decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md` (context, gates + weighted criteria naming the tenet, options, selection), or is the Decisions & Alternatives row I added enough? I won't write it unless you say.
2. **Cascade hold.** I paused at the segment boundary and left tablet-sync and review-export untouched per "we'll do them after." Confirm the cascade notes (obligations noted, not co-owned) are the right form, and that those two segments stay deferred.
3. **Tenet.** Your reason — "a bigger review queue over merge rules that combine scientifically related edits without noticing" — is a genuine one-line lean (its reverse is defensible for a different team). Shall I add it to the HLD's `## Tenets`, e.g. *"Prefer human review of competing edits over automatic combination that cannot recognize scientific relationships."*? I won't add it without your word.
4. **Probe triage + approval.** Numbered feedback on the finished LLD, the gap triage, and the #2 fork, then explicit approval to proceed to Phase 3 (I'll narrow REC-004/005/006, which still carry policy-neutral phrasing such as "regardless of the concurrency policy's outcome") and Phase 4.