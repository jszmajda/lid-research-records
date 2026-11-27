## Phase 1: Decision Record Review

Added `docs/decisions/committed-change-delivery.md` and linked it from the HLD's Key Design Decisions section.

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSockets for Committed-Change Delivery

## Context

MarketBoard must deliver committed stall-status changes to connected staff browsers while maintaining one authoritative board revision per event. Delivery must also support recovery after a browser loses connectivity for up to 20 minutes. The delivery mechanism determines the store's revision and publication responsibilities, the server's operational responsibilities, and the browser's recovery behavior.

## Decision Elements

- **Low delivery latency (major).** Connected browsers should receive committed changes without waiting for a periodic polling interval.
- **Independence from a realtime provider (major).** The board should not require a hosted realtime vendor or its subscription model to deliver updates.
- **Operational burden (moderate).** The delivery mechanism should avoid unnecessary connection-management, scaling, and recovery operations.
- **Recovery from disconnection (moderate).** A browser must be able to recover the latest board after losing connectivity for up to 20 minutes.

## Options in the Domain

### Five-Second HTTPS Polling

**Description.** Each browser requests board changes at a fixed five-second interval. The server answers each request with revisions after the browser's cursor, and the browser applies them before the next request.

**Analysis.**

- **Weak** fit for low delivery latency: a committed change can wait nearly five seconds before the next browser request.
- **Strong** fit for independence from a realtime provider: delivery uses the board's HTTPS service without a realtime vendor.
- **Strong** fit for operational burden: the server handles independent request-response operations rather than persistent connections.
- **Strong** fit for recovery from disconnection: cursor queries can return revisions missed since the browser's last known revision.

**Summary.** Stateless delivery reduces connection operations but adds polling reads and bounded delivery lag.

### Self-Hosted WebSockets

**Description.** Each connected browser holds a WebSocket session to the MarketBoard server. After a command commits, the server publishes its event revision to relevant sessions. On reconnection, the browser uses its last known revision to catch up from replayable stored revisions.

**Analysis.**

- **Strong** fit for low delivery latency: the server can publish a committed revision immediately to active sessions.
- **Strong** fit for independence from a realtime provider: MarketBoard owns the connection service and publication path.
- **Weak** fit for operational burden: MarketBoard must operate connection capacity, session lifecycle handling, reconnection, and reliable publication.
- **Strong** fit for recovery from disconnection: replayable revisions allow a reconnecting browser to catch up from its last known revision.

**Summary.** Persistent server-managed connections provide low-latency delivery while making MarketBoard responsible for realtime operations.

### Hosted Realtime Service

**Description.** MarketBoard publishes committed changes through a managed realtime provider, and browsers use the provider's subscription and reconnection model. The application reconciles stored revisions with provider publication so reconnecting browsers receive a current board.

**Analysis.**

- **Strong** fit for low delivery latency: a managed subscription service can push committed changes to active clients.
- **Weak** fit for independence from a realtime provider: delivery depends on the provider's service, credentials, and client protocol.
- **Strong** fit for operational burden: the provider operates persistent connection capacity and most reconnect mechanics.
- **Partial** fit for recovery from disconnection: the application still needs reconciliation between its revision history and provider publication.

**Summary.** Managed subscriptions reduce connection operations but add recurring service cost and provider coupling.

## Selection

MarketBoard uses self-hosted WebSockets for committed-change delivery. This option satisfies the two major criteria: connected browsers receive committed changes without a polling interval, and the board retains control of its realtime delivery path. It is selected despite its weaker operational-burden fit because the project explicitly accepts connection capacity and reconnect operations in exchange for low-latency updates without a realtime vendor.

The selection requires the change store to retain replayable event revisions and to publish every committed revision reliably. It requires delivery to manage WebSocket sessions and capacity, and browser sync to reconnect and catch up from the last known revision. It forecloses using five-second polling as the primary connected-browser delivery route and using a hosted realtime service as the board's delivery dependency.
```

Please approve the Phase 1 HLD and decision record, or identify changes. After approval, I will draft the three affected design nodes one at a time.