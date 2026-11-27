I've updated `docs/high-level-design.md` to record self-hosted WebSockets as the delivery approach. This is the Phase 1 (HLD) stop, so nothing below the HLD has changed yet.

**What changed in the HLD**
- **Approach:** The "still open" paragraph is replaced. Committed revisions are pushed over self-hosted WebSockets, and a reconnecting browser catches up from its last-seen revision. Delivery manages socket sessions and publishes revisions to them, and change storage keeps replayable revisions with reliable publication. Browsers reconnect, catch up, and show connection loss rather than a stale board. The deployment owns connection capacity and reconnect load.
- **Architecture bullets:** The change store, delivery and browser sync nodes no longer say "depends on the approach". Each now states what it owns under WebSockets.
- **Key Design Decisions:** A new entry records the choice over polling and the hosted service, with your rationale (fast updates without vendor coupling, at the cost of connection and reconnect operations).
- **Tenets and goals:** Unchanged.

**For your review**
1. **Decision doc:** This choice has a few things going for it that a cold reader could re-litigate, namely cost, operations burden and vendor coupling, and three nodes are about to be sized around it. Do you want a full decision doc in `docs/decisions/`, or is the Key Design Decisions entry enough? I've written the entry only.
2. **Tenet:** "Self-hosted and managed infrastructure are both permitted" is still true but no longer leans on anything. Do you want a tenet that captures why you picked self-hosting, such as preferring operating our own connections over provider coupling? Or should the existing tenet stay as it is?
3. **Stale wording in Access (a different segment):** `access-design.md` still says authorization is "independent of the still-open change-delivery approach". I haven't touched it. Do you want me to update that line? The access specs aren't affected.
4. **Open question for the delivery LLD:** Sessions expire after 8 hours and assignments can be revoked (ACCESS-003/004), but a socket can stay open longer. Delivery will need to decide what happens to open sockets then. I'll raise this in Phase 2 unless you'd rather settle it now.

Once you approve or give numbered feedback, I'll move on to the three nodes, starting with the change store LLD.