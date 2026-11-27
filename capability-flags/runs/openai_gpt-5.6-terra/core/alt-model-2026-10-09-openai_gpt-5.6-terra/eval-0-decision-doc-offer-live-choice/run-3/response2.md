Created and linked the project-level decision document: `docs/decisions/board-change-delivery.md`.

```markdown
---
node: high-level-design
---

# Decision: Board-Change Delivery

## Context

MarketBoard must deliver committed stall-status changes from its authoritative event board to as many as 800 simultaneously connected staff browsers. Markets normally make two changes per minute, with bursts of up to 20 edits per second at opening. Connected browsers must show changes within 15 seconds under normal connectivity, and a browser disconnected for up to 20 minutes must recover the current board.

Editors submit commands over HTTPS. Delivery must preserve the server-assigned revision order, make connectivity failures visible, and avoid treating browser state as authoritative.

## Decision Elements

- **Authoritative revision delivery** (major, supports the tenet that each committed edit has one authoritative event revision): a browser must be able to apply committed changes in revision order and recover after a missed connection.
- **Prompt delivery with bounded repeated reads** (major): connected browsers should receive changes promptly without every browser repeatedly requesting an unchanged board.
- **Operational ownership** (moderate): the pilot can operate its own infrastructure, but connection capacity and failure recovery must remain explicit responsibilities.
- **Provider independence** (moderate): board delivery should not require a third-party realtime service or its subscription model.

## Options in the Domain

### Five-Second HTTPS Polling

**Description.** Each browser periodically requests changes after the latest revision it has applied. The server returns revisions newer than that cursor or a current board snapshot when required for recovery.

**Analysis.**

- **strong** authoritative revision delivery: cursor-based reads can return ordered revisions and allow a disconnected browser to catch up.
- **weak** prompt delivery with bounded repeated reads: a committed change can wait nearly five seconds for the next request, and mostly unchanged boards still generate recurring reads from every browser.
- **strong** operational ownership: HTTPS request handling avoids persistent-session management and reconnect coordination.
- **strong** provider independence: no realtime provider is required.

**Summary.** Stateless delivery reduces connection operations at the cost of repeated reads and update delay.

### Self-Hosted WebSockets

**Description.** A MarketBoard-operated service holds WebSocket sessions for connected browsers and publishes each committed event revision to the relevant sessions. The change store retains revisions so a browser can request missed revisions after reconnecting.

**Analysis.**

- **strong** authoritative revision delivery: server-assigned revisions are published after commitment, while replay supports ordered catch-up after a disconnect.
- **strong** prompt delivery with bounded repeated reads: connected browsers receive publication without waiting for a polling interval or repeatedly reading an unchanged board.
- **partial** operational ownership: MarketBoard must provision connection capacity, detect and recover failed sessions, and make publication reliable.
- **strong** provider independence: the delivery protocol and connection operation remain under MarketBoard control.

**Summary.** Persistent sessions provide prompt updates while making connection and recovery operations a MarketBoard responsibility.

### Hosted Realtime Service

**Description.** MarketBoard publishes committed revisions through a third-party realtime provider, and browsers subscribe using that provider's client protocol. MarketBoard reconciles successful commits with provider publication and retains enough revision history for recovery.

**Analysis.**

- **strong** authoritative revision delivery: retained server revisions can support recovery, provided publication is reconciled with the committed event revision.
- **strong** prompt delivery with bounded repeated reads: provider subscriptions can push changes to connected browsers without polling.
- **strong** operational ownership: the provider operates connection capacity and much of session recovery.
- **weak** provider independence: delivery depends on provider credentials, pricing, availability, and subscription semantics.

**Summary.** Managed connections reduce operational work but introduce a realtime-provider dependency and recurring service cost.

## Selection

MarketBoard uses self-hosted WebSockets for board-change delivery. The option provides prompt push delivery and avoids repeated polling reads while keeping the board independent of a realtime vendor. It turns on the tenet that a committed edit has one authoritative event revision: a committed revision is the unit published to browsers and retained for replay.

This selection obligates the change store to retain replayable event revisions, the delivery component to reliably publish committed revisions and operate socket capacity, and browser synchronization to reconnect and catch up from its last applied revision. It forecloses the lower connection-management burden of polling and hosted delivery for the pilot.
```

The HLD now links this decision from its Key Design Decisions section. Please approve this Phase 1 artifact, or identify any tradeoff or criterion that should change, before I draft the change-store node.