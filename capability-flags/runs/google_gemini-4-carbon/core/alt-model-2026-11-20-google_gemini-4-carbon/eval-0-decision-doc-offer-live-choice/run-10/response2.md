I have written `docs/decisions/change-delivery-approach.md` and linked it from `Key Design Decisions` in `docs/high-level-design.md`.

### `docs/decisions/change-delivery-approach.md`

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Approach

## Context

MarketBoard maintains one authoritative board per event, with editors submitting commands over HTTPS (`docs/high-level-design.md § Key Design Decisions`). Once the server commits an edit and assigns its event revision, that change must reach up to 800 simultaneous staff browsers across forty weekend markets, where busy events have 10–25 active editors averaging two status changes per minute and peaking at 20 edits per second around opening time.

Every candidate delivery mechanism must satisfy the same baseline constraints: show committed edits in connected browsers within 15 seconds under normal connectivity, recover the latest board after disconnects up to 20 minutes, retain seven days of revisions, sustain 99.5 percent availability during published event hours, preserve a single authoritative revision sequence, surface connectivity loss visibly, and enforce server-side authorization. MarketBoard's tenets also permit both self-hosted and managed infrastructure because event updates carry stall IDs and operational statuses rather than customer records.

Because stateless polling, self-hosted sockets, and managed realtime services all clear those baseline constraints, the choice turns on competing engineering trades rather than a hard gate. It also sizes three coupled subsystems together—`change-store`, `delivery`, and `browser-sync`—making a later reversal expensive across storage indexing, server topology, and client recovery logic.

## Decision Elements

### Weighted Criteria

- **Vendor independence and cost predictability (major):** Keep board delivery, subscription authorization, and client sync independent of a third-party realtime provider's proprietary SDK, channel semantics, and connection- or message-metered pricing (an opening burst of 20 edits/second across 800 browsers produces up to 16,000 outbound fan-out deliveries per second).
- **Operational and connection-lifecycle simplicity (major):** Minimize stateful server machinery—persistent socket memory and file-descriptor sizing, heartbeats, rolling-deploy connection drains, cross-instance fan-out, and reconnect storm absorption—needed to maintain 99.5 percent availability during published event hours.
- **Authoritative publication and access fidelity (major):** Ensure browsers converge on the single committed revision sequence without dropped or out-of-order updates, and enforce server-side session expiry and event-assignment revocations across delivery. Derives from the tenets *"A committed edit has one authoritative event revision regardless of its delivery route"* and *"Commands use server-side authorization; browser state is not evidence of permission."*
- **Update responsiveness and steady-state load efficiency (moderate):** Propagate committed stall changes promptly during opening bursts without continuous idle database and HTTP read traffic during quiet stretches, while detecting dead links promptly. Engages the tenet *"Connectivity failures must be visible, not mistaken for an unchanged board."*
- **Tolerance of unstable market networks (moderate):** Recover cleanly across spotty outdoor cellular links, congested venue Wi-Fi, mobile IP handoffs, and restrictive intermediary proxies across disconnects up to 20 minutes.

## Options in the Domain

### Five-Second HTTPS Polling

**Description:** Browsers run a five-second timer loop issuing stateless HTTPS requests carrying their highest applied event revision (`since={revision}`). `change-store` indexes revisions by `(event_id, revision)` and serves current snapshots for initial loads or stale cursors; `delivery` exposes ordinary stateless HTTP handlers that check current session and event assignment on each poll; `browser-sync` advances its local revision cursor on each response and marks the board disconnected when poll requests time out or fail.

**Demonstration:**
```text
Browser -> GET /events/evt-42/changes?since=108  (every 5s)
Server  -> 200 OK { latestRevision: 110, changes: [rev 109, rev 110] }
```

**Analysis:**
- **Vendor independence and cost predictability — strong:** Uses standard HTTPS on MarketBoard's own application servers with predictable compute cost and zero third-party realtime dependencies.
- **Operational and connection-lifecycle simplicity — strong:** `delivery` remains stateless request/response; rolling deploys need no connection draining, and running multiple server instances requires no cross-node pub/sub coordination.
- **Authoritative publication and access fidelity — strong:** Every poll reads committed rows directly from `change-store` with no secondary publication pipeline that could lag or drop updates, and every request re-checks server-side session validity and event assignment.
- **Update responsiveness and steady-state load efficiency — weak:** Introduces ~2.5 seconds mean and ~5 seconds tail polling delay before network RTT, generates ~160 requests/second across 800 connected browsers even when no stalls change, and detects silent network loss only after a poll interval plus request timeout elapses.
- **Tolerance of unstable market networks — strong:** Each poll is an independent HTTPS exchange that traverses proxies cleanly and resumes automatically on the next tick after transient cellular packet loss or IP switching.

**Summary:** Trades continuous idle read traffic and multi-second propagation lag for stateless server operations and direct database cursor reads.

### Self-Hosted WebSockets

**Description:** `delivery` terminates persistent WebSocket connections from browsers on MarketBoard's own servers. `change-store` persists sequential event revisions (retained seven days) and pairs commits with a reliable publication mechanism (such as a transactional outbox or ordered log tailer) so `delivery` receives every committed revision in order; `delivery` authenticates socket handshakes against server-side sessions and event assignments, runs heartbeats, enforces session/assignment expiry, streams live revisions, and serves cursor catch-up or snapshot bootstrap; `browser-sync` maintains the socket, displays connectivity loss immediately on close or missed heartbeat, and reconnects with jittered backoff from its last applied revision.

**Demonstration:**
```text
Browser -> WS /events/evt-42/stream?since=108
Server  -> { type: "catchup", from: 109, to: 110, changes: [...] }
Server  -> { type: "revision", revision: 111, stallId: "B-14", status: "closed" }
```

**Analysis:**
- **Vendor independence and cost predictability — strong:** Built on the standard WebSocket protocol over MarketBoard-controlled compute, with flat capacity cost and no external vendor SDK or per-message fan-out charges.
- **Operational and connection-lifecycle simplicity — weak:** MarketBoard owns concurrent socket capacity, heartbeat timeouts, graceful deploy drains, multi-instance pub/sub fan-out to meet 99.5 percent availability, and reconnect rate limiting when a server restarts or venue Wi-Fi recovers.
- **Authoritative publication and access fidelity — partial:** Keeps revision streaming and permission checks inside MarketBoard's own server boundary, but requires reliable internal publication from `change-store` to `delivery`, deduplicated cursor handoff between catch-up and live frames, and active teardown when an eight-hour session expires or an event assignment is revoked.
- **Update responsiveness and steady-state load efficiency — strong:** Pushes committed revisions in subsecond latency, performs zero database reads while an event board is idle, and surfaces broken connections deterministically via close frames and heartbeat deadlines.
- **Tolerance of unstable market networks — partial:** Long-lived TCP connections drop on cellular handoffs, idle NAT timeouts, and congested venue Wi-Fi, requiring explicit client heartbeat checks, jittered backoff, and seamless cursor replay up to the 20-minute recovery target.

**Summary:** Achieves subsecond push and complete vendor independence in exchange for owning stateful socket operations, internal publication reliability, and reconnect catch-up mechanics.

### Hosted Realtime Service

**Description:** A managed realtime pub/sub provider terminates browser connections at its edge, manages heartbeats and fallback transports, and fans out published messages to event channels. `change-store` commits revisions alongside a transactional outbox; `delivery` mints short-lived provider capability tokens after checking server-side event assignments and runs an outbox publisher that forwards committed revisions to the provider API with idempotency keys; `browser-sync` embeds the provider's client SDK to subscribe, surface connection status, and rewind missed channel messages on reconnect.

**Demonstration:**
```text
Browser  -> POST /events/evt-42/stream-token -> signed provider capability token
Store    -> commits rev 111 + outbox row -> Publisher -> Provider publish(evt-42, rev 111)
Provider -> pushes rev 111 to 800 subscribed browsers
```

**Analysis:**
- **Vendor independence and cost predictability — weak:** Couples `delivery` token issuance, publication retries, and `browser-sync` state management to a vendor's channel model and SDK, and exposes peak opening bursts (up to 16,000 fan-out messages/second) and 800-browser weekend concurrency to metered connection and message pricing.
- **Operational and connection-lifecycle simplicity — strong:** Offloads socket scaling, edge termination, rolling-deploy connection survival, and multi-node fan-out to the provider while MarketBoard runs stateless HTTP and background worker processes.
- **Authoritative publication and access fidelity — partial:** Splits commit and fan-out across an external network boundary, requiring outbox retry reconciliation, idempotent message handling, and short token TTLs or provider revocation calls so external channels cannot drift from `change-store` or outlive revoked assignments.
- **Update responsiveness and steady-state load efficiency — strong:** Delivers subsecond push updates with no idle database read load and native SDK connection-state callbacks.
- **Tolerance of unstable market networks — strong:** Managed providers supply multi-edge termination, automatic HTTPS fallback transports when intermediaries block WebSockets, and battle-tested client reconnect and stream-resume libraries.

**Summary:** Offloads stateful connection infrastructure and mobile transport edge cases at the cost of recurring usage fees, cross-vendor outbox reconciliation, and provider lock-in.

## Selection

MarketBoard selects **Self-Hosted WebSockets**.

This choice prioritizes **vendor independence and cost predictability** (major) together with **update responsiveness and steady-state load efficiency** (moderate), deliberately accepting the engineering and operational burden under **operational and connection-lifecycle simplicity** (major) and **tolerance of unstable market networks** (moderate). At MarketBoard's pilot scale—800 simultaneous browsers and 20-edit/second bursts—a modest self-hosted footprint handles WebSocket fan-out comfortably without recurring per-message fees or binding three system boundaries (`change-store` publication, `delivery` session control, and `browser-sync` recovery) to a third-party realtime vendor. While the tenet *"Self-hosted and managed infrastructure are both permitted"* allows a hosted realtime provider, permission is not preference: keeping delivery in-house avoids vendor lock-in and keeps session expiry and assignment revocation inside MarketBoard's own server boundary (*"Commands use server-side authorization; browser state is not evidence of permission"*). Compared with five-second HTTPS polling, self-hosted WebSockets give coordinators subsecond awareness during hectic market openings, eliminate ~160/second idle polling reads, and provide crisp heartbeat-backed disconnect detection (*"Connectivity failures must be visible, not mistaken for an unchanged board"*).

Committing to self-hosted WebSockets forecloses purely stateless `delivery` deployments and obligates the three downstream nodes as follows:

- **`change-store`** must persist contiguous per-event revisions for seven days, support fast cursor range queries and board snapshots covering at least the 20-minute disconnect window, and guarantee that every committed revision reaches `delivery` without silent loss (*"A committed edit has one authoritative event revision regardless of its delivery route"*).
- **`delivery`** must authenticate WebSocket upgrades against server-side sessions and event assignments, enforce eight-hour session expiry and assignment revocations on active sessions, run heartbeats, fan out revisions across server instances if horizontally scaled for 99.5 percent event-hour availability, and drain sockets gracefully during deploys.
- **`browser-sync`** must treat missed heartbeats or socket closes as immediately visible stale/disconnected state, reconnect with jittered backoff to avoid thundering herds after venue Wi-Fi drops or deploys, and reconcile missed updates by revision cursor (falling back to a full snapshot when beyond the replay window) without gaps or duplicate application.

Revisit this decision if operating stateful WebSocket fan-out or venue-network socket churn threatens the 99.5 percent event-hour availability goal, or if staffing shifts make stateless polling lag or managed-provider fees cheaper than maintaining session infrastructure.
````

---

### Ready to finish Phase 1?

1. Does `docs/decisions/change-delivery-approach.md` (along with the updated `docs/high-level-design.md`) look good as written, or would you adjust any of the criteria, analysis, or selection framing?
2. Before moving into Phase 2 for `change-store`, `delivery`, and `browser-sync`, let me know if you also want to:
   - keep `Tenets` as-is or add a project-wide portable-protocols lean, and
   - update the stale `"still-open change-delivery approach"` wording in `docs/intent/access/access-design.md`.