Phase 1 — HLD updated for the self-hosted WebSockets choice. Nothing downstream touched yet.

**`docs/high-level-design.md § Approach`** (rewritten, the open-choice framing removed):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are pushed to browsers over **self-hosted WebSocket connections** that the project operates itself, with no realtime vendor in the path. Subsecond updates are useful but not required; the board must stay within the 15-second freshness goal.
>
> Delivery, change storage, and browser recovery are designed together around that choice. The change store keeps a replayable revision history per event and publishes committed revisions reliably enough that a connected browser is not left behind a commit. Delivery owns the socket sessions: accepting connections, authorizing them against the access component, fanning committed revisions out to the sessions subscribed to an event, and shedding or refusing connections when capacity is exhausted rather than silently dropping updates. Browsers hold one connection per board, detect its loss, reconnect, and catch up from their last known revision before resuming live updates.
>
> Operating the connection tier is accepted cost: connection capacity, reconnect storms after a restart or network blip, and socket-level observability are ours to run. Low update latency without vendor coupling was worth that burden.

**`§ Architecture`** — the three unwritten nodes now name socket-shaped ownership instead of "depends on the approach": change store owns per-event revision history, replay-from-revision reads, and the publication path into delivery; delivery owns WebSocket session lifecycle, per-event subscription fan-out, and connection capacity limits; browser sync owns the browser-side connection, disconnection visibility, reconnect, and catch-up from the last applied revision. The access bullet is unchanged.

**`§ Key Design Decisions`** — new entry, with both rejected options and their rationale:

> **Self-hosted WebSockets for change delivery.** Committed revisions are pushed over WebSocket connections the project runs itself. Five-second HTTPS polling was rejected: it is the simplest stateless operation and meets the freshness goal, but costs repeated reads across 800 browsers and leaves a few seconds of lag on every change. A hosted realtime service was rejected: it would remove most connection operations, but adds recurring fees and couples the board's delivery semantics to a provider's subscription model. Self-hosting trades owned connection capacity and reconnect handling for fast updates with no vendor in the delivery path. The consequence is accepted deliberately: connection capacity, reconnect behavior, and socket observability are the project's own operational burden.

**`§ Goals`** — one wording change: "800 simultaneous browsers" → "800 simultaneous browser **connections**", since the number is now a connection-capacity figure the delivery node will be sized against. Tenets and Non-Goals are unchanged; the existing tenets all still hold under this choice.

Four things need your call before I move to Phase 2:

1. **Decision doc?** This choice stays live for a cold reader — three credible options traded against latency, cost, ops burden, and vendor coupling, and all three remaining nodes get sized around the result. Someone arriving in six months may well ask "why not just poll?". I can record it as a full decision doc at `docs/decisions/`, or leave it as the Key Design Decisions entry above. The entry is sufficient if you'd rather not carry the doc.
2. **A tenet to elicit.** Push immediacy and catch-up correctness can conflict: when a browser reconnects and the live stream has moved on, do we replay every missed revision in order, or jump it to the current board state and drop the intermediate revisions? Both are defensible — replay keeps every revision observable, snapshot-ahead is faster after a long outage. I'd record your lean as a one-line tenet so the three nodes don't each decide it separately. Which way, or leave it to the nodes?
3. **Cascade flag into `access` (different segment, so I'm not touching it).** The Approach now has delivery authorizing socket connections against the access component, but access is written entirely around per-command HTTPS authorization with eight-hour session expiry. A long-lived socket raises a question access doesn't answer: does a session expiring mid-connection close the socket, or only block subsequent commands? Want me to cascade into `access-design.md` when we get there, or keep it in delivery's court?
4. **Node order.** I'd do change store → delivery → browser sync, since the revision/replay contract constrains the other two. Say if you'd rather start elsewhere.

Reply with numbered feedback or approve, and I'll start Phase 2 on the first node.