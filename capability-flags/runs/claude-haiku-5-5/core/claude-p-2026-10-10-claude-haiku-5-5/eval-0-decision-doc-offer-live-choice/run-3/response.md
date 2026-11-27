I've updated the HLD (`docs/high-level-design.md`) for the self-hosted WebSockets approach. This is the Phase 1 stop, so I haven't started the three nodes.

**What changed in the HLD**
- **Approach:** replaced the "still open" text with the chosen design. Editors submit commands over HTTPS, and the server assigns each committed edit one revision and publishes it. Browsers receive revisions over a WebSocket to the board's own server. A reconnecting browser replays from its last applied revision, and the coordinator sees when the socket isn't live. The trade-off is stated: no realtime vendor fees or client coupling, in exchange for owning connection capacity, reconnect behavior, and socket operations.
- **Architecture:** the change store, delivery, and browser-sync bullets now describe their responsibilities for this approach instead of "depends on the approach." Change store keeps seven days of revisions for replay and uses a publication outbox. Delivery owns the socket sessions, subscription credentials, and fan-out. Browser sync owns reconnect, resume, and connection state. All three are still marked "not written yet."
- **Key Design Decisions:** added a row recording the choice, with polling and the hosted service named as the rejected alternatives and why.

Tenets and goals are unchanged. The file is modified but not committed.

**Things to check before the three nodes**
- `docs/intent/access/access-design.md` still says the access design is "independent of the still-open change-delivery approach." That's now stale. I left it alone because the access node is outside this stop. It's the first cascade item when we walk the nodes.
- The 99.5% availability goal now depends on our own socket tier, not a managed service. I didn't change the goal, but you may want to confirm it still holds.

**Decision doc offer**
This choice will still look contestable to a future reader, since the alternatives trade against cost, latency, and operations burden. I can record it as a standalone decision doc at `docs/decisions/` and link it from the HLD row. Do you want that, or is the row enough?

Please review the HLD changes. Once you approve, I'll move on to the change-store, delivery, and browser-sync nodes.