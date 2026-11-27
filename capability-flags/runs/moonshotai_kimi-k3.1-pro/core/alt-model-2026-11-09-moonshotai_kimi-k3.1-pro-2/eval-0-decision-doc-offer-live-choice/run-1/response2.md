Created `docs/decisions/self-hosted-websockets.md` and linked it from the HLD’s Key Design Decisions.

The decision doc gives a new reader:

- The context and stakes behind the delivery choice.
- The weighted criteria used to compare options.
- A full, good-faith analysis of polling, self-hosted WebSockets, and hosted realtime.
- The reason we accepted extra connection and reconnect operations in exchange for fast updates, no recurring realtime fees, and no provider coupling.
- The resulting obligations for the change-store, delivery, and browser-sync nodes.

Please review the decision doc. Once approved, we can proceed to the three downstream nodes.