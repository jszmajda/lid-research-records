I've updated `docs/high-level-design.md` to commit to self-hosted WebSockets. This is the Phase 1 stop, so nothing below the HLD has been touched.

**What changed in the HLD**
- **Approach:** the open-choice wording is replaced. Committed revisions are pushed to browsers over self-hosted WebSockets, and a reconnecting browser catches up from the last revision it holds. The three nodes are described around that choice:
  - The change store keeps replayable revisions and publishes them reliably.
  - Delivery manages socket sessions and connection capacity.
  - Browser sync owns reconnect, catch-up and visible connectivity state.
- **Architecture:** the Change store, Delivery and Browser sync entries now state what each node owns under this approach, instead of "depends on the approach".
- **Key Design Decisions:** there is a new entry for self-hosted WebSockets. It names polling and the hosted service as rejected, with the cost you accepted (owning connection capacity and reconnect handling).

**For your review**
1. **Decision doc.** This choice weighs several criteria and the three unwritten nodes are about to be sized around it, so it could earn a standalone decision doc in `docs/decisions/`. I recorded it as a Key Design Decisions entry for now. Do you want the full doc instead?
2. **Tenets.** "Self-hosted and managed infrastructure are both permitted" still holds, so I left it. Is there a lean you want recorded for the unanticipated calls this choice will raise, for example how much connection-capacity risk to accept versus simplicity? If not, I'll leave the tenets as they are.
3. **Access LLD (segment boundary).** `docs/intent/access/access-design.md` still says the delivery approach is "still-open" in its Context section. Its specs don't depend on the choice, but that sentence is now stale. I haven't edited it because it sits in another segment. May I make that one-line fix?

Once you approve the HLD, I'll move to Phase 2 with the LLD for the first of the three nodes. Which should go first: change-store, delivery or browser-sync? I'd suggest change-store, because the other two consume its revision and publication contract.