Done — `docs/decisions/change-delivery-approach.md` is written (owned by the HLD, no EARS IDs, no status field) and linked from the HLD's Key Design Decisions row. It is drafted cold: present tense, the three options as options-in-the-domain with per-option verdicts, and the judgment confined to Selection. Here it is in full for your review:

```
---
node: high-level-design
---

# Decision: Change Delivery Approach

## Context

This decision builds on **Commands over HTTPS, one authoritative board per event** (see the High-Level Design's Key Design Decisions): editors submit commands over HTTPS and the server assigns each committed edit one event revision. What is decided here is only how committed revisions reach browsers. A committed edit has one authoritative event revision regardless of its delivery route, so delivery is a projection of the change store, never a second source of truth.

The board serves up to 800 simultaneous staff browsers across roughly 40 weekend markets, with opening-time bursts of 20 edits per second. Committed changes must appear in connected browsers within 15 seconds, a browser disconnected for up to 20 minutes must recover the latest board, and seven days of event revisions are retained for operational investigation. Connectivity failures must be visible, not mistaken for an unchanged board. Self-hosted and managed infrastructure are both permitted; event updates carry stall IDs and operational statuses, not customer records.

Three mechanisms exist in this problem space for carrying committed revisions to browsers: five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service. All three clear the 15-second freshness target and the 800-browser capacity, so no standing constraint eliminates any of them — the choice is a weighing, not a gate. The mechanisms differ in recurring cost and provider coupling, who owns connection operations, update-latency headroom, how directly they expose connectivity failures, and the obligations each imposes on the change store, the delivery component, and browser sync.

## Decision Elements

Constraints common to all three mechanisms — one authoritative revision, the 15-second freshness target, 800-browser capacity, 20-minute recovery, and seven-day retention — are background from the High-Level Design, not decision elements. Each element below discriminates among the options.

- **Recurring cost and provider coupling** — **major**. Whether the mechanism introduces a recurring vendor fee and binds the board to a realtime provider's API, SDK, and availability.
- **Connection operations burden** — **major**. Who owns connection capacity, session lifecycle, reconnects, and reliable publication: the project or a provider. This criterion cuts against the recommended option.
- **Update-latency headroom** — **major**. How promptly committed changes normally appear. All three clear the 15-second target, so the question is headroom and the value of fast updates during opening-time bursts, not compliance.
- **Connectivity-failure visibility** — **moderate**; derives from the tenet *"Connectivity failures must be visible, not mistaken for an unchanged board."* How directly the mechanism exposes a dropped or stale connection so the browser can surface it rather than quietly displaying a static board.
- **Downstream design footprint** — **minor**. The machinery each mechanism pushes into the change store, delivery, and browser sync: cursor queries, replayable revisions and publication, session management, reconnect and catch-up, or a provider subscription model.

## Options in the Domain

### Five-Second HTTPS Polling

**Description.** Browsers issue an HTTPS request every five seconds asking for board changes since a cursor; delivery stays request/response and the store serves cursor queries. It is the simplest stateless operation: no persistent connections, no server-side session state, and no publication infrastructure. Its cost is repeated reads — at 800 browsers, roughly 160 requests per second — and a few seconds of lag between a commit and the next poll.

**Analysis**
- Recurring cost and provider coupling: **strong** — no vendor is involved; cost is ordinary HTTPS serving.
- Connection operations burden: **strong** — stateless request/response; no connection capacity or reconnect logic to own.
- Update-latency headroom: **weak** — commits wait up to the five-second poll interval; lag is seconds, not subsecond.
- Connectivity-failure visibility: **partial** — a failed poll is a visible request error, but a browser that stops polling can look like an unchanged board unless staleness is surfaced explicitly.
- Downstream design footprint: **strong** — the store needs cursor queries, delivery stays request/response, and browsers run a polling loop; no replay or publication machinery.

**Summary.** Least machinery and no vendor, at the cost of repeated reads and seconds of lag.

### Self-Hosted WebSockets

**Description.** The server holds a persistent WebSocket connection per browser and pushes committed revisions as they are published. The store retains replayable revisions with a reliable publication path, delivery manages sessions and publication, and browsers reconnect and catch up from the last revision they hold. The project owns connection capacity, session lifecycle, reconnects, and publication reliability. There is no realtime vendor bill and no provider coupling.

**Analysis**
- Recurring cost and provider coupling: **strong** — self-hosted, with no recurring realtime fee and no provider SDK or API to bind to.
- Connection operations burden: **weak** — the project owns connection capacity for up to 800 sockets, session management, reconnects, and reliable publication; reconnect problems are ours to solve.
- Update-latency headroom: **strong** — committed revisions push immediately, giving subsecond delivery well inside the 15-second target.
- Connectivity-failure visibility: **strong** — a dropped socket is an explicit event; reconnect and catch-up from the last held revision surface the gap rather than masking it.
- Downstream design footprint: **partial** — the store needs replayable revisions and reliable publication, delivery needs session management, and browsers need reconnect/catch-up logic; more machinery than polling, all of it owned in-house.

**Summary.** Fast updates with no vendor, in exchange for owning connection and reconnect operations.

### Hosted Realtime Service

**Description.** A hosted realtime provider carries committed revisions to subscribed browsers; delivery wraps the provider's SDK, the store reconciles its publication with the provider, and browsers use the provider's subscription model. It is the quickest route to low-latency updates with the least connection operations owned by the project. It adds a recurring fee and couples the board to the provider's API, SDK, and availability.

**Analysis**
- Recurring cost and provider coupling: **weak** — recurring fees and binding to a provider's API, SDK, and uptime.
- Connection operations burden: **strong** — the provider owns connection capacity, reconnects, and session handling; the project wires the SDK rather than running the infrastructure.
- Update-latency headroom: **strong** — near-immediate delivery, comparable to self-hosted sockets.
- Connectivity-failure visibility: **partial** — the SDK exposes connection state, but reconnects are partly abstracted; surfacing a stale board requires deliberate wiring.
- Downstream design footprint: **partial** — the store needs publication reconciliation with the provider, delivery wraps the provider, and browsers adopt its subscription model; less in-house infrastructure but a provider contract to maintain.

**Summary.** Low-latency updates with the least connection ops, at a recurring fee and provider coupling.

## Selection

Self-hosted WebSockets.

No option dominates: each is strong on two of the three major criteria and weak on one. Polling is strong on cost/coupling and connection operations but weak on update latency; the hosted service is strong on connection operations and update latency but weak on cost/coupling; self-hosted WebSockets is strong on cost/coupling and update latency but weak on connection operations. The project keeps the two gains it values — no recurring realtime fee or provider coupling, and fast updates — and elects to carry the one weakness, connection operations burden. Polling is not chosen because the goal is fast updates and seconds of polling lag give that up; the hosted service is not chosen because it reintroduces the recurring fee and provider coupling the project declines. This is a deliberate trade against the **major** connection-operations criterion, not a judgment that the burden is small.

This selection turns on the tenet *"Connectivity failures must be visible, not mistaken for an unchanged board"*: the chosen approach's reconnect-and-catch-up obligation is where that tenet is satisfied, since a dropped socket and a replay gap are surfaced rather than shown as a static board. It is taken against no tenet — the standing position that "Self-hosted and managed infrastructure are both permitted" keeps the hosted option in contention; the decision simply does not exercise that permission. The two other major criteria, recurring cost/coupling and connection operations burden, are weighed on their own terms; no current tenet records the project's lean between them.

Committing to self-hosted WebSockets forecloses the stateless request/response delivery of polling and the provider-managed connections of a hosted service. It obligates three downstream nodes: the change store must retain replayable revisions and a reliable publication path, delivery must manage socket sessions and push published revisions, and browser sync must implement reconnect and catch-up from the last held revision. The project owns connection capacity for up to 800 simultaneous browsers and the reconnect behavior that keeps connectivity failures visible.
```

Before I treat this as final, one thing the decision-doc template requires is yours to supply, and three items from the Phase 1 stop are still open:

1. **Latent-criteria probe.** I built the Decision Elements from the tradeoffs named in the three sketched options and the HLD's goals — nothing invented. Is there any criterion a thoughtful critic would weigh that none of those named, especially one that cuts *against* self-hosted WebSockets (e.g. in-house operational expertise, time-to-pilot, or scaling headroom at 800 sockets)? If you name one that could move the decision, I'll add it to Decision Elements and re-run the per-option verdicts; if you're satisfied, I'll leave it as is.

2. **The tenet gap (from Q2, still open).** Writing the doc surfaced this directly: the two **major** criteria it turns on — recurring cost/provider coupling and connection operations burden — have no tenet recording the project's lean between them, which the template flags as a signal of a missing tenet. My earlier candidate: *"Prefer self-hosted operation over vendor coupling when it buys fast updates — accept the operational burden."* Add it under `## Tenets` as written, reword it, or leave the tenets as they are?

3. **Cross-segment cascade (from Q3).** `docs/intent/access/access-design.md:10` still says "independent of the still-open change-delivery approach." Access is a different segment, so I haven't touched it. Update that reference now, or fold it into the node work later?

4. **Approval.** Phase 1 output (HLD + this decision doc) is above — approve, or give numbered feedback. I'm still holding at the Phase 1 stop and won't start the three nodes (change-store, delivery, browser-sync) until you say go.