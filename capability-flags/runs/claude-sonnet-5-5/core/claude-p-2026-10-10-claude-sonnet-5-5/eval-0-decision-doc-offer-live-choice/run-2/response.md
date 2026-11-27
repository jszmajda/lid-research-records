I've updated `docs/high-level-design.md` (Phase 1) to take the self-hosted WebSockets approach.

**What changed in the HLD**
- **Approach:**
  - Committed changes reach browsers over self-hosted WebSockets, giving fast updates well inside the 15-second goal without tying the board to a realtime vendor.
  - The accepted cost is owning connection capacity and reconnect handling.
  - The change store provides replayable revisions and reliable publication, delivery manages socket sessions, and browser sync reconnects and catches up from its last seen revision.
  - I removed the "still open" and "depends on the approach" wording.
- **Architecture:** the change-store, delivery, and browser-sync entries now state what each node owns under this approach. The access entry is unchanged.
- **Key Design Decisions:** a new entry records the choice, with polling and the hosted service as the rejected alternatives and the reasons you gave.

**Cascade check:** the access design doesn't depend on the delivery choice. It already puts delivery-specific subscription credentials in the delivery node. I made no changes there.

**Questions for you**
1. **Decision doc:** the delivery choice sizes three nodes that aren't written yet, and a cold reader could reasonably re-litigate it. Do you want a standalone decision doc under `docs/decisions/`, or is the Key Design Decisions entry enough?
2. **Tenets:** the tenet "Self-hosted and managed infrastructure are both permitted" still reads fine, but your choice leans away from vendor coupling and toward owning operations. Do you want a one-line lean recorded, such as preferring infrastructure we operate over provider coupling when the options are otherwise close, or should the tenets stay as they are?
3. **Anything to change in the HLD** before we move on? If it looks right, say so and I'll start on the three nodes: change store, delivery, and browser sync. I'll draft their LLDs one at a time, stopping after each.