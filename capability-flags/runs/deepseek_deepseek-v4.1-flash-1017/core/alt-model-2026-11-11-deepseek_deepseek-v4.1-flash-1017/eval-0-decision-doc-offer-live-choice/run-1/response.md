Updated `docs/high-level-design.md` to record the self-hosted WebSockets approach.

**Approach**

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSockets: the server holds a socket session for each connected browser and pushes each newly committed event revision to it. This gives fast updates without a realtime vendor or a polling cadence, at the cost of operating connection capacity and reconnect behavior in-house. Subsecond updates would be useful, but are not required.
>
> Delivery, change storage, and browser recovery are designed together. The change store retains replayable revisions and publishes each committed revision reliably, so no revision is lost between commit and delivery. Delivery owns socket sessions, connection capacity, and pushing revisions to connected browsers. Browser sync owns the socket subscription, reconnect, and catching up from the last-seen revision after a disconnect.

**Architecture**

- Access: unchanged.
- Change store: "Not written yet. Revision history, read indexes, and reliable publication of committed revisions to delivery."
- Delivery: "Not written yet. Owns socket sessions, connection capacity, and pushing committed revisions to connected browsers."
- Browser sync: "Not written yet. Owns the socket subscription, reconnect, and catch-up from the last-seen revision."

**Key Design Decisions** — added:

> **Self-hosted WebSockets for change delivery.** The server pushes each committed revision over a socket session per connected browser, giving fast updates without a realtime vendor. Accepted costs: the project operates connection capacity and reconnect behavior, and the change store must retain replayable revisions so a reconnecting browser can catch up. Five-second HTTPS polling was rejected: it repeats reads on a fixed cadence and adds a few seconds of lag. A hosted realtime service was rejected: it reduces connection operations but carries recurring fees and couples the board to a provider.

Problem, Tenets, Goals, and Non-Goals are unchanged; the existing tenets still hold.

Two questions before I go further:

1. Does this HLD revision read right — approve it as the basis for the three nodes (change store, delivery, browser sync)? Numbered feedback welcome.
2. This choice will stay live for a later reader and sizes three nodes around it, so it plausibly earns a full decision doc (`docs/decisions/websocket-delivery.md`) alongside the Key Design Decisions entry above. Want me to write that doc, or leave the entry alone?

One cascade note, not changed: `docs/intent/access/access-design.md:10` still describes "the still-open change-delivery approach." That's a sibling segment, so I've left it alone — say the word and I'll refresh that phrase.