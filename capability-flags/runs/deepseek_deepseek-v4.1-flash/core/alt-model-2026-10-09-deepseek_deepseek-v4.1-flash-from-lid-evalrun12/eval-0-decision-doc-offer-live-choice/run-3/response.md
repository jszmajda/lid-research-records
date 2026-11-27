Phase 1 — HLD check complete. The delivery approach was the open architectural choice, so I revised the HLD to land it. Rejected alternatives moved out of the Approach prose into Key Design Decisions, per the docs-carry-current-intent rule.

**Approach** (revised)
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSockets, which keeps delivery independent of a realtime vendor and delivers updates in well under a second. The team accepts responsibility for socket connection capacity and reconnect handling in exchange for that independence. The freshness goal stays at 15 seconds; subsecond delivery is a benefit of this approach, not a requirement.
>
> Delivery, change storage, and browser recovery are designed together. The change store keeps replayable event revisions and reliably publishes every committed change; delivery manages socket sessions; browser sync reconnects dropped sockets and catches up to the latest revision.

**Architecture** (revised)
- Access — written below the stable HTTPS command boundary (unchanged).
- Change store — not written yet. Owns revision history, read indexes, and reliable publication of committed revisions for socket replay.
- Delivery — not written yet. Owns WebSocket sessions, connection capacity, and the push of committed changes to connected browsers.
- Browser sync — not written yet. Owns reconnect and catch-up to the latest board revision.

**Key Design Decisions** (new entry)
- **Self-hosted WebSockets for change delivery.** Committed changes are pushed to browsers over sockets the service hosts itself, keeping delivery independent of a realtime vendor and giving subsecond updates; the team accepts connection-capacity and reconnect work in exchange. Five-second HTTPS polling and a hosted realtime service were the alternatives. Polling was the simplest stateless route but lagged by seconds and multiplied reads; the hosted service removed connection operations but added recurring fees and provider coupling.

Tenets, Goals, and Non-Goals are unchanged. Access needs no cascade — it sits below the HTTPS command boundary and its spec does not reference the delivery route.

Two things before I run the next phase:

1. **Approve this HLD update?**
2. **Decision doc or row?** This choice stayed genuinely live — three credible options traded against cost, latency, and provider coupling, and the change-store, delivery, and browser-sync nodes will all be sized around it next. I'd suggest recording it as a full decision doc under `docs/decisions/`, linked from the Key Design Decisions entry, so a future reader can re-run the judgment. The alternative is leaving the entry as written. Which do you want?