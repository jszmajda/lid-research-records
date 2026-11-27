**Phase 1 (HLD) complete — awaiting your review.**

`docs/high-level-design.md` now records the self-hosted WebSocket choice:

- **Approach** (`docs/high-level-design.md:9`): committed changes reach browsers over WebSocket sessions we operate; HTTPS carries recovery and catch-up. Explicitly accepts the operational cost (sizing capacity for 800 browsers, reconnect/catch-up in the client).
- **Architecture** (`:18`): change-store owns the replayable revision stream; delivery owns socket sessions, subscriptions, and publication; browser-sync owns the socket client, reconnect, and HTTPS catch-up.
- **Tenets** (`:24`): added "Own the realtime path" — prefer infrastructure we operate over a managed realtime vendor, and accept the operational cost. The existing infrastructure tenet was rescoped to hosting/storage/operations so the two don't contradict.
- **Key Design Decisions** (`:47`): new decision recording why polling and a hosted realtime service were rejected and what the chosen path costs us.

Coherence fix (one line, outside the three nodes): `docs/intent/access/access-design.md:10` said authorization is independent of the "still-open change-delivery approach" — now "the change-delivery approach". No access scope, spec, or behavior changed. Revert if you'd rather I hadn't touched that segment.

Three things for you:

1. **Tenet wording** — is "Own the realtime path" the lean you want, and is the rescoped infrastructure tenet right? It's the load-bearing tenet the delivery decision turns on.
2. **Decision doc** — this choice stays live for a cold reader (three credible options, several criteria, and three nodes get sized around it). Want it recorded as `docs/decisions/self-hosted-websocket-delivery.md`, or is the HLD decision row enough?
3. **Next** — confirm the node order for the three unwritten nodes: change-store → delivery → browser-sync, starting with change-store's LLD and EARS.