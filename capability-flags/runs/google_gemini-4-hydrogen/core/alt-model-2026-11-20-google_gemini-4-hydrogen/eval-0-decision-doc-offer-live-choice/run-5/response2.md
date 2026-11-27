Added `docs/decisions/change-delivery.md` and linked it from `## Key Design Decisions` in `docs/high-level-design.md`.

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

MarketBoard maintains one authoritative board per event for up to 800 simultaneous staff browsers across 40 weekend markets, with opening-time bursts reaching 20 edits per second. Editors submit commands over HTTPS, and connected browsers must show committed changes within 15 seconds under normal connectivity and recover the latest board after disconnects of up to 20 minutes.

The delivery mechanism shapes three downstream components that must be designed together: `change-store` (how committed revisions are indexed, retained, and published), `delivery` (how updates are served or pushed to browsers), and `browser-sync` (how clients subscribe, detect dropped connections, and catch up on missed revisions). Choosing a mechanism that fits the operational profile and architectural boundaries is necessary before specifying those three nodes.

## Decision Elements

All candidate approaches can meet the 15-second freshness goal and comply with the HLD tenet permitting both self-hosted and managed infrastructure; those shared capabilities are background rather than selection drivers. The choice turns on four weighted criteria:

- **Vendor independence and recurring cost (major):** Avoiding ongoing per-connection or per-message vendor fees and keeping core board delivery decoupled from a third-party realtime provider's subscription model, API semantics, and outage modes.
- **Update latency and read efficiency under burst load (moderate):** Delivering committed edits promptly without continuous read amplification across 800 idle or active browsers during opening-time bursts.
- **Operational simplicity of connection and reconnect handling (moderate):** Minimizing the in-house operational burden of scaling long-lived connections, managing session capacity, and recovering from network drops.
- **Authoritative revision continuity across disconnects (moderate):** Deriving from the tenets *one authoritative event revision regardless of its delivery route* and *connectivity failures must be visible, not mistaken for an unchanged board*, the delivery path must preserve strict revision ordering and surface connection loss cleanly across 20-minute disconnects without silent staleness or split-brain state.

## Options in the Domain

### Five-second HTTPS polling

- **Description:** Browsers poll an HTTPS endpoint on a 5-second interval carrying their last seen event revision. `change-store` supports indexed cursor queries (`sinceRevision`), `delivery` remains stateless request/response handlers behind standard HTTP caching/load balancing, and `browser-sync` runs a polling loop that surfaces errors when consecutive polls fail.
- **Analysis:**
  - Vendor independence and recurring cost: **strong** — uses standard self-hosted or commodity HTTP infrastructure with no realtime vendor fees or provider coupling.
  - Update latency and read efficiency under burst load: **weak** — introduces up to 5 seconds of polling lag and generates roughly 160 read queries per second at 800 browsers even when no edits occur.
  - Operational simplicity of connection and reconnect handling: **strong** — stateless request/response requires no long-lived connection capacity planning or socket session state; reconnects are indistinguishable from the next poll.
  - Authoritative revision continuity across disconnects: **strong** — cursor queries against `change-store` naturally preserve revision ordering, and failed polls directly indicate connectivity loss.
- **Summary:** Simplest stateless operation and zero vendor coupling, at the cost of continuous read traffic and multi-second update lag.

### Self-hosted WebSockets

- **Description:** The server pushes committed revisions to connected browsers over self-hosted WebSocket connections. `change-store` persists replayable event revisions and provides a reliable publication mechanism; `delivery` owns WebSocket session lifecycle, event-scoped subscription routing, and fan-out; `browser-sync` maintains the socket, surfaces disconnects visibly, and requests revision catch-up from its last seen revision upon reconnect.
- **Analysis:**
  - Vendor independence and recurring cost: **strong** — runs entirely on self-hosted infrastructure with no recurring realtime vendor bill or third-party protocol coupling.
  - Update latency and read efficiency under burst load: **strong** — pushes committed edits immediately in subsecond time without idle polling reads across 800 browsers.
  - Operational simplicity of connection and reconnect handling: **weak** — requires owning WebSocket connection capacity, sticky or coordinated session state, backpressure during 20 edits/sec bursts, and explicit reconnect/catch-up coordination.
  - Authoritative revision continuity across disconnects: **partial** — preserves authoritative revision order when paired with replayable storage and revision-gap checks, but requires explicit catch-up logic on reconnect so dropped messages are never mistaken for an unchanged board.
- **Summary:** Fast push updates without vendor lock-in or recurring fees, in exchange for owning stateful connection capacity and reconnect/catch-up operations.

### Hosted realtime service

- **Description:** Committed edits are published to a managed third-party realtime service (such as a hosted pub/sub or WebSocket provider), and browsers subscribe directly to the provider's channels. `change-store` requires publication reconciliation (such as an outbox) so database commits and provider broadcasts stay consistent; `delivery` wraps provider authentication and channel publication; `browser-sync` uses the provider's client SDK and subscription model.
- **Analysis:**
  - Vendor independence and recurring cost: **weak** — introduces recurring vendor fees and couples `delivery` and `browser-sync` to a specific provider's SDK, token model, and availability.
  - Update latency and read efficiency under burst load: **strong** — delivers subsecond push updates without polling read load on the application store.
  - Operational simplicity of connection and reconnect handling: **partial** — offloads WebSocket scaling and edge connection management to the provider, though `delivery` and `change-store` still own publication reconciliation and provider credential management.
  - Authoritative revision continuity across disconnects: **partial** — requires bridging provider-assigned message delivery with MarketBoard's authoritative event revisions and handling provider-specific reconnect gaps via catch-up queries.
- **Summary:** Offloads connection scaling for fast updates, at the cost of recurring vendor fees, provider coupling, and publication reconciliation.

## Selection

**Self-hosted WebSockets** is selected.

It satisfies the major criterion of **vendor independence and recurring cost** while delivering **strong** update latency and read efficiency during opening-time bursts. Five-second HTTPS polling avoids stateful connection ops, but its continuous read amplification across 800 browsers and multi-second lag are less suited to bursty live coordination; a hosted realtime service avoids connection scaling, but ties core delivery and browser behavior to a third-party provider and recurring fees.

This choice accepts the **weak** fit on operational simplicity of connection and reconnect handling. It turns on the HLD tenets that *self-hosted and managed infrastructure are both permitted*, *a committed edit has one authoritative event revision regardless of its delivery route*, and *connectivity failures must be visible, not mistaken for an unchanged board*.

Committing to self-hosted WebSockets forecloses stateless request/response-only delivery and imposes explicit obligations on three downstream nodes:
- `change-store` must persist replayable event revisions and provide reliable publication to `delivery`.
- `delivery` must manage WebSocket sessions, authorization-checked subscriptions, and fan-out capacity for 800 simultaneous browsers.
- `browser-sync` must surface connection loss visibly and perform revision-based catch-up after disconnects of up to 20 minutes.
```

Please confirm before we proceed to Phase 2 (`change-store`, `delivery`, `browser-sync`):

1. Do you approve the Phase 1 artifacts (`docs/high-level-design.md` and `docs/decisions/change-delivery.md`)?
2. Should I update the stale `"still-open change-delivery approach"` wording in `docs/intent/access/access-design.md`, or leave `access` untouched?