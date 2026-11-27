The HLD now records self-hosted WebSockets as the delivery approach. Nothing else changed. Please review `docs/high-level-design.md` before we start the three nodes.

**What changed in `docs/high-level-design.md`:**
- **Approach** now states the chosen approach, the owned costs (connection capacity for up to 800 browsers, reconnect handling, replayable revision storage), and why polling and the hosted service were not chosen.
- **Architecture:** the change-store, delivery, and browser-sync entries describe their responsibilities under WebSockets instead of "depends on the approach."
- **Key Design Decisions:** a new entry records the choice and the two rejected alternatives.
- **Tenets and Goals** are unchanged.

**Cascade note:** `docs/intent/access/access-design.md` says change delivery is "still open" in its Context section. That is now stale. I did not edit it, since access is not one of the three nodes. I can fix that line with the access node later, or now if you prefer.

**Decisions for you:**
1. **Decision doc:** this choice has several criteria and will size the three nodes around it. Do you want it recorded as a decision doc in `docs/decisions/`, linked from the HLD entry? I left the HLD entry as the record for now.
2. **Tenet:** your reason for the choice, avoiding a realtime vendor, could become a tenet, for example "Real-time delivery must not depend on a hosted realtime provider." The current tenet "Self-hosted and managed infrastructure are both permitted" still holds, so I did not change it. Should I add the new tenet, keep the current one, or change it?

I have stopped here for your review, as the workflow requires at this phase boundary.