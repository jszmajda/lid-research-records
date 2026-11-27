I've revised the record-store LLD for whole-visit revisions and made one edit to the HLD. This is the Phase 2 stop: I haven't touched the EARS specs, tests or code, and I'm waiting for your approval.

## What changed

**`docs/intent/record-store/record-store-design.md`**
- The open design choice section is gone. The design is now built around whole-visit revisions:
  - **Submission envelope:** visit ID, base revision ID (absent when the submission creates the visit), complete visit payload, and idempotency key. The server assigns the revision ID and receipt time.
  - **Revisions and heads:** an accepted submission is a revision whose parent is its base. A revision with no accepted child is a head. One head means that revision is current. More than one head means unresolved review work. Receipt order never decides anything.
  - **Current-state response:** returns either `Current` (the single head) or `Unresolved` (all competing heads, plus the last resolved revision for reference). No competing head is presented as current.
  - **Resolution:** the coordinator names the full set of heads being resolved and supplies the resulting complete visit. That creates a revision with all those heads as parents. It is rejected if a new head arrived since the coordinator's view.
- The Decisions & Alternatives table records the concurrency choice with your rationale (merge rules that can combine scientifically related edits unnoticed, against a larger review queue). The three-way merge option is recorded there as the rejected alternative.
- Deferred items:
  - Tablet-sync defines how a tablet chains successive offline edits.
  - Review-export defines the comparison workflow and export eligibility.

**`docs/high-level-design.md`**
- I changed the record-store State cell and the "concurrency mechanism" paragraph, which still said the choice was open. This is an HLD-level edit, so please look at it too.

## Decision doc offer

Do you want the whole-visit versus three-way-merge choice recorded as a standalone decision doc in `docs/intent/record-store/decisions/`? Tablet-sync and review-export will be sized around it, and a cold reader could be tempted to reverse it for the smaller review queue. The alternative is the table row it already has. I'd lean toward the doc, but it's your call.

## Question that needs your answer

**Can a coordinator hand-author the resolved visit, or only pick one competing revision verbatim?**
- I drafted it so the coordinator supplies a complete visit payload, which may equal one head. That lets a coordinator reconcile an observer fix with a species change.
- The strict alternative is "pick one head unchanged". It keeps the exported record always identical to something a worker submitted, but a coordinator then can't combine two edits without a third submission.

## LLD edge-case probe

Gaps I found, for you to triage (fix in the LLD now, or defer):

1. **Chained offline edits.** A tablet makes edit B on top of its own edit A before A is accepted, so it has no server revision ID for A. If the client generated the revision ID, B could name A. I deferred this to tablet-sync, but it changes the envelope, so it may belong here.
2. **Late edit on an already-resolved visit.** Its base is an ancestor of the resolved head, so it becomes a competing head and reopens review. This follows from the rules; confirm it's the behavior you want.
3. **Two creates of the same visit UUID.** Both have no base, so they become competing roots. I treat this as ordinary competition.
4. **Edit based on one of several competing heads.** It extends that head and the visit stays unresolved. A resolution must still name every head.
5. **Idempotency and the resolution race.** Resolving with a stale head set is rejected. I haven't specified what the coordinator sees when that happens.

## One more thing to check

Your tenet "Prefer workflows two coordinators can operate" sits against a design where every concurrent edit, even unrelated ones, goes to review. You've accepted the larger queue, so I haven't changed anything. The design has no volume estimate or queue-management mechanism, though. If you have a rough sense of how often visits get corrected twice, it would help review-export's design.

Reply with numbered feedback on the above (the hand-authoring question, the decision doc, and which gaps to fix). Once you approve, I'll move to Phase 3 and write the REC specs.