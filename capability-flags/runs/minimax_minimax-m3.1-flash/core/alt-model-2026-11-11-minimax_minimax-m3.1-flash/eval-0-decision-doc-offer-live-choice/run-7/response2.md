Decision doc written at `docs/decisions/self-hosted-websocket-delivery.md`, with the HLD decision bullet now linking to it.

It reads cold: context and stakes (why the choice sits at the root and sizes three nodes), two inherited gates (no recurring third-party realtime fees, from the non-goal; the update path is one we operate, from the tenet), seven weighted criteria (vendor independence and latency major; operating cost, operational burden, read amplification, failure blast radius moderate; long-disconnect recovery minor), each of the three options with its strongest honest description and per-element analysis, then Selection stating why the hosted service is eliminated on gates rather than on criteria, why WebSockets beat polling on latency and read amplification, and the accepted weak fits — connection capacity, session lifecycle, reconnect and catch-up, and the wave reconnect after a delivery-tier restart — with implications for change-store, delivery, and browser-sync.

Two items still open from the Phase 1 stop:

1. **Tenet wording** — "Own the realtime path" plus the rescoped infrastructure tenet (`docs/high-level-design.md:24`, `:28`). Confirm or reword; the decision doc cites the tenet by name, so it needs to stay accurate.
2. **Node order** — proceed with change-store → delivery → browser-sync, starting with change-store's LLD and EARS?