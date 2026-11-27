The HLD now names self-hosted WebSockets as the delivery approach. I stopped at the Phase 1 review; the three design nodes (change store, delivery, browser sync) are not drafted yet.

**Changes to `docs/high-level-design.md`**

- **Approach:** the server commits each edit as one revision and pushes committed revisions to browsers over self-hosted WebSockets. Browsers resume from their last applied revision after a reconnect. The doc records the accepted cost (the project operates connection capacity, reconnect handling, and replay) and the two rejected options with their reasons.
- **Architecture:** the three unwritten nodes now have concrete responsibilities:
  - Change store: replayable per-event revisions within the seven-day retention window, with every committed revision published to delivery without loss.
  - Delivery: WebSocket sessions, fan-out per event, authentication through the access component, and capacity for 800 browsers.
  - Browser sync: per-event subscription, last-applied-revision tracking, reconnect with backoff, and replay for disconnects up to 20 minutes.
- **Key Design Decisions:** a new entry for the WebSocket choice, with rationale and rejected alternatives.
- **Tenets and Goals:** unchanged.

**Decisions for you at this stop**

1. **Revoked access on open sockets.** `ACCESS-004` denies a revoked user's next command, but nothing says what happens to an open socket subscription to that event. Options: close the socket on revocation, or let it stay open for reads until it reconnects. I have not chosen one. It belongs with the Access and Delivery specs.
2. **Session expiry on long-lived sockets.** Sessions expire after eight hours (`ACCESS-003`), but a socket can stay open longer. Should delivery close the socket when the session expires, or keep it until the browser reconnects and re-authenticates?
3. **Decision doc.** This choice is still live: it trades cost, operations, vendor coupling, and latency, and the three nodes are sized around it. Do you want it recorded as a standalone decision doc under `docs/decisions/`, with the Key Design Decisions entry linking to it? If not, the entry stands alone.

Once you've answered these and approved the HLD, I'll draft the three node LLDs and their EARS specs, one stop at each.