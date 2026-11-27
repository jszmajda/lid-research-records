Decision doc written to `docs/decisions/realtime-change-delivery.md` and linked from the HLD's Key Design Decisions entry. Full text:

---

```markdown
---
node: high-level-design
---

# Decision: Realtime change delivery

## Context

MarketBoard commits every edit as one authoritative event revision (Key Design Decisions in `docs/high-level-design.md`) and must show those revisions to connected browsers well inside the 15-second freshness goal. Three delivery routes exist in this problem space: browsers poll the server, browsers hold self-hosted WebSocket connections, or a hosted realtime service relays commits. The choice sets what the change store, delivery, and browser-sync nodes must build, so it is settled before those nodes are designed. Getting it wrong leaves the project permanently paying in one of three currencies: seconds of lag on a busy board, a recurring vendor bill, or connection machinery it did not need to own.

## Decision Elements

All three routes can meet the 15-second freshness goal and the single-authoritative-revision tenet; those are background. The decision turns on:

- **Freshness margin** (major) — how promptly a committed revision reaches connected browsers beyond the 15-second floor. Opening-time bursts make near-instant push more valuable than the floor alone suggests.
- **Recurring cost and provider coupling** (major) — recurring fees, and how much the board's availability, authentication, and future evolution depend on a third party.
- **Operational burden owned by the project** (major) — stateless simplicity versus connection capacity, heartbeats, and reconnect storms versus delegating connection operations to a provider.
- **Load on the change store** (moderate) — repeated read amplification versus one push per commit versus one publish per commit.
- **Browser-side complexity** (moderate) — what the browser must implement to stay current after load.
- **Timeliness of connectivity-failure detection** (moderate) — engagement of the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*: how quickly and reliably does each route learn the connection is gone.

The tenet *Self-hosted and managed infrastructure are both permitted* is why all three routes are in the option set rather than one being excluded up front.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers hold no persistent connection. After fetching a snapshot, each browser re-requests revisions after its last cursor every five seconds; the server answers request/response and keeps no per-browser state. The store needs cursor (range) queries. Commands continue over HTTPS unchanged. At 800 browsers this is roughly 160 read requests per second whether or not anything changed.

**Analysis.**

- Freshness margin — **partial**: a commit appears at the browser's next tick; average lag is about half the interval, worst case a full interval plus request time. Inside the 15-second goal, but every change carries seconds of lag.
- Recurring cost and provider coupling — **strong**: no third-party service, no recurring fee, no provider dependency.
- Operational burden — **strong**: stateless handlers; no connection table, capacity plan, or session draining; a failed request is an ordinary request error.
- Load on the change store — **weak**: read amplification scales with browser count, not commit volume, so boards poll hardest when little is changing.
- Browser-side complexity — **strong**: a timer and a cursor.
- Failure detection — **partial**: a failed poll surfaces as a request error, but discovery waits for the next tick; visibility depends on that tick firing.

**Summary.** The simplest server, paid for in constant read traffic and seconds of lag on every change.

### Self-hosted WebSockets

**Description.** Browsers fetch a snapshot over HTTPS, then open a WebSocket to a server this project runs. On commit, the delivery component pushes the revision down subscribed sockets. The store keeps a replayable revision log so a reconnecting browser can catch up from its cursor, and publishes commits reliably so a committed edit is never lost between commit and push. Delivery owns connection capacity, heartbeats, and backpressure; the browser owns reconnect and catch-up. No realtime vendor is involved.

**Analysis.**

- Freshness margin — **strong**: push at commit time; no interval.
- Recurring cost and provider coupling — **strong**: runs on the project's own infrastructure; no recurring realtime fee and no provider to integrate with or migrate off.
- Operational burden — **weak**: the project owns the connection table, heartbeats (needed to detect half-open sockets), capacity and draining across deploys, and reconnect bursts when one blip drops many sockets at once.
- Load on the change store — **strong**: steady-state traffic is pushes, not polls; reads occur only for catch-up after a gap.
- Browser-side complexity — **partial**: reconnect with backoff and cursor-based catch-up (the 20-minute recovery goal) is real client logic.
- Failure detection — **partial**: socket close and error events are prompt, but a half-open connection looks healthy until heartbeats are implemented; visibility depends on those heartbeats.

**Summary.** Fast and vendor-free, paid for in connection operations on both ends.

### Hosted realtime service

**Description.** The server publishes each commit to a third-party realtime provider; browsers subscribe through the provider's SDK. The provider owns connection capacity and reconnection. The store must reconcile publication — confirm each commit actually reached the provider and retry until it did. Delivery wraps the provider API and brokers credentials; the browser follows the provider's subscription model.

**Analysis.**

- Freshness margin — **strong**: the provider pushes at publish, typically subsecond.
- Recurring cost and provider coupling — **weak**: recurring fees scale with connections and message volume; availability, auth token issuance, and the browser's subscription API all become the provider's to change; leaving later means a migration.
- Operational burden — **partial**: no connection fleet to run, but publication reconciliation, credential management, and provider-incident response remain ours.
- Load on the change store — **strong**: one publish per commit; no per-browser reads.
- Browser-side complexity — **partial**: the SDK handles reconnection, but application code follows the provider's model.
- Failure detection — **strong**: the SDK reports connection state, including provider-side outages.

**Summary.** Fastest to build and easiest on connection operations, paid for in recurring fees and provider dependence.

## Selection

**Self-hosted WebSockets.** On the major criteria each route is strong on two and weak on one, so the decision is which weakness to accept. The project accepts the operational burden of owning connection capacity and reconnect handling: at the pilot scale of 800 simultaneous browsers that machinery is bounded and concrete — a connection table, heartbeats, and reconnect handling for a known fleet — rather than an open-ended vendor bill or a permanent latency floor. Polling's weakness, seconds of lag on every commit plus constant read amplification, would be felt at every market opening and never goes away. Hosted delivery's weakness, recurring fees and provider coupling, would tie the board's realtime path, auth integration, and availability to a vendor indefinitely; given the tenet permitting managed infrastructure, declining that trade is a judgment about this decision, not a prohibition on vendors.

The decision names no single tenet as its driver: the authoritative-revision tenet is satisfied by all three routes, and the infrastructure-permission tenet deliberately leaves the choice open. The visibility tenet is engaged through the failure-detection criterion and binds whichever route is chosen.

Committing here obligates the downstream nodes: the change store must provide replayable revisions and reliable commit publication; delivery must size and operate WebSocket sessions (capacity, heartbeats, deploy-time draining); browser sync must implement reconnect and cursor catch-up for the 20-minute recovery goal, with heartbeat and close handling so connectivity failures stay visible. Switching routes later remains possible — nothing here locks the project to sockets — but those three nodes are built around this choice.
```

---

Still unanswered from last time: `access-design.md` calls the delivery approach "still-open" — shall I make that one-phrase cascade fix into the sibling Access segment?

Review the decision doc and confirm the Access fix, and we'll start the three nodes.