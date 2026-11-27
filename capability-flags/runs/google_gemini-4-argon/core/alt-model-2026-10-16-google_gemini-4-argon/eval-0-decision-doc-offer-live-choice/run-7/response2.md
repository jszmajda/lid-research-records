I have created `docs/decisions/change-delivery-transport.md` and linked it from `docs/high-level-design.md` under `## Key Design Decisions`.

Here is the decision doc:

```markdown
---
node: high-level-design
---

# Decision: Change-Delivery Transport

## Context

MarketBoard coordinates stall closures, late arrivals, and power issues across forty weekend markets, serving up to 800 simultaneous staff browsers with 10–25 active editors per busy market and opening-time bursts of up to 20 edits per second. Editors submit commands over HTTPS to a single authoritative board per event (`docs/high-level-design.md`).

Once an edit commits and receives an authoritative event revision, the system must deliver that revision to connected browsers within the 15-second freshness target and allow browsers to recover the latest board after disconnects lasting up to 20 minutes. The choice of delivery transport shapes three downstream design nodes simultaneously: `change-store` (how revisions are indexed and published), `delivery` (how client sessions or requests are served), and `browser-sync` (how clients subscribe, detect connectivity loss, and catch up after a gap). A reader inspecting the connection-management and replay machinery across those three nodes needs the criteria and trade-offs that justified owning a stateful transport rather than polling over HTTPS or delegating to a managed realtime provider.

## Decision Elements

- **Vendor independence and recurring cost** (**major** — derives from the tenet *Prefer owning operational work over recurring realtime vendor fees or external provider coupling when low-latency delivery is achievable in-house*). Avoids per-connection/per-message vendor billing across 800 simultaneous browsers and avoids coupling board delivery, authentication, and client sync semantics to a third-party realtime SDK.
- **Update freshness and read efficiency** (**moderate**). Delivers committed revisions to connected browsers well inside the 15-second goal (including during 20-edits/sec opening-time bursts) without generating high volumes of redundant read queries when boards are quiet.
- **Server and client operational simplicity** (**moderate**). Minimizes stateful connection capacity management, session lifecycle tracking, publication handoff plumbing, and client-side reconnect/replay state machines.
- **Disconnect recovery and connectivity visibility** (**minor** — derives from the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*). Provides clear signals when a browser is no longer receiving updates and a clean mechanism to reconcile missed revisions up to the 20-minute disconnect target.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers run a periodic timer that issues an HTTPS `GET` every five seconds carrying the event ID and the highest revision number the browser has applied (`?sinceRevision=N`). The delivery layer remains stateless request/response, querying `change-store` for revisions greater than `N` (or returning a full snapshot when `N` is too old) and returning them in a batch.

```text
Browser -- GET /events/{id}/revisions?since=42 (every 5s) --> Delivery --> Change Store
```

- **Vendor independence and recurring cost**: **strong** — uses standard HTTPS infrastructure with no third-party realtime vendor fees or SDK lock-in.
- **Update freshness and read efficiency**: **partial** — meets the 15-second ceiling under normal conditions, but introduces up to 5 seconds of baseline polling lag plus request overhead, and 800 browsers generate ~160 read requests per second even when no stall statuses are changing.
- **Server and client operational simplicity**: **strong** — servers remain stateless HTTP handlers; `change-store` only needs an indexed revision-range query; `browser-sync` runs a single polling loop where normal operation and catch-up after a disconnect use the exact same cursor request.
- **Disconnect recovery and connectivity visibility**: **partial** — catch-up after a disconnect naturally reuses the `since` cursor, but connectivity failure is only detected when the next poll times out or fails, delaying stale-board indication by at least one poll interval plus request timeout.

**Summary**: Minimizes server and client state machines by treating live delivery and catch-up as the same stateless cursor read, at the cost of multi-second lag and continuous idle read load.

### Self-Hosted WebSockets

Browsers open a persistent WebSocket connection to the `delivery` service and subscribe to their event starting from their last known revision. When a command commits, `change-store` records the authoritative revision and publishes it to `delivery`, which pushes the revision frame to all subscribed sockets for that event. On socket drop, `browser-sync` marks the board connection as degraded/disconnected, reconnects with backoff, and replays missed revisions from `change-store` (falling back to a full snapshot if the gap exceeds the replay window).

```text
Editor -- HTTPS POST --> Change Store (assign rev 43, persist & publish)
                               |
                               v
                         Delivery (WebSocket sessions) == push rev 43 ==> Browsers
```

- **Vendor independence and recurring cost**: **strong** — runs entirely on self-hosted infrastructure using standard WebSocket APIs, with zero per-connection or per-message vendor fees and no proprietary client SDK.
- **Update freshness and read efficiency**: **strong** — pushes committed edits immediately upon publication with subsecond latency and eliminates idle read polling across the 800 connected browsers.
- **Server and client operational simplicity**: **weak** — `delivery` must manage stateful socket capacity, heartbeats, and fan-out across server instances; `change-store` must guarantee reliable publication so committed revisions are never silently dropped between storage and socket push; `browser-sync` must coordinate live socket frames with reconnect replay and deduplication.
- **Disconnect recovery and connectivity visibility**: **strong** — socket close frames and missed heartbeats surface connectivity loss promptly, and explicit revision sequence numbers allow `browser-sync` to request an exact replay range on reconnect.

**Summary**: Delivers fast, vendor-free push updates and immediate disconnect visibility, at the cost of owning stateful connection management, reliable internal publication, and client reconnect/replay logic.

### Hosted Realtime Service

Browsers subscribe to event channels through a managed third-party realtime provider SDK. After `change-store` commits an edit, `delivery` mints scoped subscription tokens for browsers and publishes committed revisions to the provider's HTTP/realtime API, which handles connection termination, fan-out to 800 browsers, and socket reconnects.

```text
Change Store --> Delivery -- publish API --> Hosted Realtime Provider == push ==> Browsers (Provider SDK)
```

- **Vendor independence and recurring cost**: **weak** — introduces recurring charges scaled to peak concurrent connections (up to 800 browsers) and message fan-out during bursts, and couples `delivery` token minting and `browser-sync` subscription lifecycle to the provider's SDK and channel semantics.
- **Update freshness and read efficiency**: **strong** — provides subsecond push delivery without idle polling load on MarketBoard's own servers.
- **Server and client operational simplicity**: **partial** — offloads socket capacity and fan-out ops to the provider, but `change-store` and `delivery` still require an outbox/reconciliation path to handle provider API failures after local commits, and `browser-sync` still needs catch-up against `change-store` when disconnects exceed the provider's buffer.
- **Disconnect recovery and connectivity visibility**: **partial** — the provider SDK exposes connection state and short-window message history, but aligning the provider's ephemeral channel history with `change-store`'s authoritative 20-minute recovery window requires bridging two state models.

**Summary**: Offloads WebSocket connection scaling for fast push updates, but incurs recurring vendor fees, external provider coupling, and split state reconciliation between `change-store` and the provider.

## Selection

**Self-Hosted WebSockets** is chosen.

The decision turns on the tenet *Prefer owning operational work over recurring realtime vendor fees or external provider coupling when low-latency delivery is achievable in-house*, reinforced by *Connectivity failures must be visible, not mistaken for an unchanged board*. At MarketBoard's scale—800 simultaneous browsers and bursts of 20 edits per second—self-hosted WebSockets comfortably fit within modest server capacity without incurring a recurring realtime vendor bill or binding client sync to a proprietary SDK. Compared to five-second HTTPS polling, WebSockets eliminate continuous idle read load and multi-second delivery lag while giving browsers an immediate heartbeat/close signal when connectivity degrades.

Committing to self-hosted WebSockets forecloses a purely stateless delivery tier and obligates the three downstream nodes as follows:

- **`change-store`** must persist contiguous, replayable event revisions retained for seven days, serve revision-range and snapshot queries for reconnecting browsers, and provide reliable publication (such as a transactional outbox or ordered log tail) so every committed revision reaches `delivery`.
- **`delivery`** must authenticate and manage WebSocket sessions for up to 800 concurrent browsers, track event subscriptions, run connection heartbeats, and fan out published revisions to subscribed sockets.
- **`browser-sync`** must maintain the WebSocket lifecycle, transition the UI into a visible degraded state on socket loss or missed heartbeats, and execute reconnect catch-up from the browser's last applied revision (falling back to a full board snapshot when disconnected beyond the replay window).
```

Please let me know if you approve the updated HLD and decision doc (including the updated tenet), and whether you'd like to clean up the one-line open-approach reference in `docs/intent/access/access-design.md` before we start Phase 2 on `change-store`, `delivery`, and `browser-sync`.