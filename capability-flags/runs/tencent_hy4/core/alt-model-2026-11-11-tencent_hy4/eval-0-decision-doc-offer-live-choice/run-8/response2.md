Done. I wrote `docs/decisions/realtime-delivery-approach.md` (project-level, `node: high-level-design`, no EARS IDs) and added the link to the HLD's Key Design Decisions entry:

`- **Self-hosted WebSockets deliver committed changes.** … as its own operational work. See [the decision doc](decisions/realtime-delivery-approach.md) for the full analysis.`

**The decision doc, in full:**

```markdown
---
node: high-level-design
---

# Decision: Self-hosted WebSockets for change delivery

## Context

MarketBoard keeps one authoritative event revision per committed edit, but that revision has to reach up to 800 staff browsers within 15 seconds, survive a browser disconnect of up to 20 minutes, and leave connectivity failures visible rather than looking like an unchanged board. The tenet "A committed edit has one authoritative event revision regardless of its delivery route" means the delivery route cannot affect correctness — it only decides how a committed revision travels and who carries the cost of moving it.

Several delivery routes satisfy those constraints, so the choice is not forced by a requirement; it is a decision about which cost profile the project accepts. The route fixes who owns connection capacity at opening-time bursts, how a dropped connection surfaces, whether the board's core update path depends on a third-party provider, and how much operational work the coordinator team carries during event hours. Event updates contain stall IDs and operational statuses, not customer records, and the tenet "Self-hosted and managed infrastructure are both permitted" allows a hosted provider — so avoiding a vendor is a live preference here, not a constraint. Choosing wrong either couples the board to a provider it cannot easily leave, burdens a small team with infrastructure it cannot reliably run, or leaves stale boards that look unchanged.

## Decision Elements

No option is eliminated by a gate. All three clear the standing constraints (15-second freshness, 800 browsers, one authoritative revision, operational-only data), so the decision is made on graded criteria.

- **Vendor coupling** — *major*. How much the board's core update path depends on a third party: recurring fees, SDK/API lock-in, and continued operation if the provider changes terms or has an outage. This is a preference, not a gate: the "Self-hosted and managed infrastructure are both permitted" tenet allows managed infrastructure, so coupling is priced rather than forbidden.
- **Update-latency headroom** — *moderate*. How quickly a committed change appears in a connected browser. All three meet the 15-second goal, so this criterion is about headroom above the SLA, not compliance with it.
- **Failure visibility and disconnect recovery** — *major*. Whether the route exposes connection state and lets a browser catch up deterministically from a known revision, consistent with the tenet "Connectivity failures must be visible, not mistaken for an unchanged board" and the 20-minute recovery and seven-day retention goals.
- **Operational and implementation burden** — *major*. The work the project owns to build and run the route: connection capacity, reliable publication and fan-out, reconnect handling, on-call expertise, and browser-side catch-up logic.
- **Availability ownership and blast radius** — *moderate*. Where the 99.5 percent availability goal rests and what absorbs opening-time bursts of 20 edits per second; relevant because a route we operate concentrates that risk on our own infrastructure.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers issue an HTTPS request every five seconds for changes since a cursor (their last-seen revision). Delivery is plain request/response and the server stays stateless, with no long-lived connections; the change store needs cursor-ordered queries. A reconnecting browser simply resumes polling from its cursor.

**Demonstration.** `GET /events/{id}/changes?since=REV-142` returns the revisions after `REV-142`; the browser advances its cursor.

**Analysis.**
- Vendor coupling — **strong**: no third-party realtime provider; delivery is HTTPS the project already runs.
- Update-latency headroom — **partial**: a commit waits up to one poll interval (a few seconds) to appear, comfortably inside 15 seconds but no faster.
- Failure visibility and disconnect recovery — **partial**: a failed poll is indistinguishable from "no new changes" without separate staleness detection, though catch-up itself is trivial (poll again with the cursor).
- Operational and implementation burden — **strong**: stateless reads, no sessions, no publication fan-out, no reconnect protocol; the simplest route to build and run.
- Availability ownership — **strong**: stateless reads behind a load balancer; 800 browsers are ordinary periodic requests and bursts are ordinary request load.

**Summary.** Simplest and vendor-free, but a few seconds of lag and failures that can look like an unchanged board.

### Self-hosted WebSockets

**Description.** The delivery component holds a long-lived WebSocket session per connected browser. When a command commits a revision, the server reliably publishes it to the relevant sessions; the change store exposes revisions in commit order so a browser that disconnects can replay everything since its last-seen revision. The browser owns subscription, reconnect, and catch-up. No realtime vendor is involved — the project runs the socket tier itself.

**Demonstration.** A browser reconnecting after a three-minute drop sends its last-seen revision `REV-142`; the server replays `REV-143`…`REV-147` before resuming the live stream, so the board is neither stale nor silently frozen.

**Analysis.**
- Vendor coupling — **strong**: delivery runs on our own infrastructure; no provider SDK, fees, or terms.
- Update-latency headroom — **strong**: committed revisions push on commit, well inside the 15-second goal.
- Failure visibility and disconnect recovery — **strong**: connection state is explicit, so a drop is visible; replay from the last-seen revision gives deterministic catch-up within the retention window.
- Operational and implementation burden — **weak**: we own connection capacity for up to 800 concurrent sockets, reliable publication and fan-out, reconnect handling, and the on-call expertise to keep long-lived connections healthy during event hours; the browser needs reconnect/catch-up logic too.
- Availability ownership — **partial**: the 99.5 percent goal now rests on stateful socket infrastructure we operate, and opening-time bursts fan out to every connected session as load we must size and absorb.

**Summary.** Fast, vendor-free updates with clean failure semantics, paid for with connection operations and reconnect engineering.

### Hosted realtime service

**Description.** A third-party realtime provider carries updates. The delivery component wraps the provider's publish/subscribe API, including reconciliation between our committed revisions and what the provider actually published; browsers use the provider's subscription SDK, which handles connection and reconnect. The change store reconciles committed revisions with published messages.

**Demonstration.** The command handler commits `REV-148` and publishes it to a provider channel; browsers subscribed to that channel receive it through the provider's SDK.

**Analysis.**
- Vendor coupling — **weak**: the provider is the core update path — recurring fees, SDK/API lock-in, and no live updates during a provider outage or unfavorable terms change.
- Update-latency headroom — **strong**: low-latency push is the provider's product, comfortably inside 15 seconds.
- Failure visibility and disconnect recovery — **partial**: SDKs surface connection state and often reconnect, but catch-up depends on the provider's replay and retention guarantees, which sit outside our control and may not meet the 20-minute and seven-day recovery goals without extra reconciliation.
- Operational and implementation burden — **strong**: the provider owns connection capacity, fan-out, and most reconnect handling; no socket fleet to run.
- Availability ownership — **strong** on the connection layer (the provider's SLA covers fan-out to 800 browsers), but the board's live-update availability is contingent on a third party rather than met by our own infrastructure, tying this criterion back to vendor coupling.

**Summary.** Fast updates with the least connection operations, at the price of recurring fees, provider coupling, and publication reconciliation.

## Selection

**Self-hosted WebSockets.** In short: the project trades the low-operations paths — stateless polling or a hosted provider — for fast, vendor-free updates, and accepts connection capacity, reliable publication, and reconnect handling as work it owns. It is the only option strong on both vendor coupling and update-latency headroom while also strong on the tenet-linked failure-visibility criterion. Polling is equally vendor-free and cheaper to run, but only partial on latency and on failure visibility — a missed poll can masquerade as an unchanged board, which the tenet "Connectivity failures must be visible, not mistaken for an unchanged board" rules against. The hosted service is fast and low-operations, but weak on vendor coupling and only partial on recovery fidelity; because the "Self-hosted and managed infrastructure are both permitted" tenet leaves managed infrastructure allowed, declining it is a judgment about which cost to carry, not a constraint.

The decision turns on that visibility tenet more than on raw latency: push delivery with explicit connection state and replay-from-last-seen-revision satisfies it more directly than polling, and keeps it under our control rather than a provider's. The decision accepts the weak operational-burden and partial availability fits above rather than optimizing for them. Because the 15-second freshness goal is a floor all three options clear, the latency benefit is headroom, not a required capability: the project is deliberately taking on connection and reconnect work to avoid a realtime vendor and keep failures visible. The lean underneath — low vendor coupling and low update latency are worth carrying connection-operations work for — is the rationale recorded in the HLD's Key Design Decisions entry.

**What it forecloses.** The simplest stateless operation (polling), and the lowest connection-operations path and a provider SLA for the connection layer (hosted).

**What it obligates downstream.** Three design nodes are sized around it: the change store must expose ordered, replayable revisions and reliable publication of committed revisions; delivery must manage WebSocket sessions and fan-out and make disconnects visible; browser sync must implement subscription, reconnect, and catch-up from the last-seen revision. Operationally, the project owns capacity for 800 concurrent sockets and on-call responsibility for the socket tier during published event hours. The committed freshness goal remains "within 15 seconds"; low latency is headroom above that SLA, not a tightened requirement.
```

A cold reader can now re-run the judgment: the criteria, each option's strongest honest representation, and the selection (which tenet it turns on, what it forecloses, what it obligates in the three upcoming nodes) are all on the page.

One new thing I need from you, plus the still-open rulings:

1. **Latent-criteria probe.** Before finalizing the criteria I probed for ones that cut *against* self-hosted WebSockets and weren't in the original option sketches; two survived and are in the doc — *availability ownership* (the 99.5% goal now rests on stateful socket infra we run) and *implementation burden* (sessions, publication, and reconnect/catch-up must be built, not bought). Is there another criterion a thoughtful critic would weigh here that could move the selection — team on-call capacity, time-to-live, cost at 40 markets, anything else? If one belongs, I'll add it and re-check the Selection; if not, the criteria stand.
2. **Still open from my last message** (unchanged, I haven't answered any of them for you): Q2 — "fast updates" vs. the 15-second freshness goal (tighten the goal, or keep it as SLA with low latency as preference?); Q3 — record the revealed lean as a one-line tenet and reconcile with "both permitted"?; Q4 — refresh the one stale phrase in `access-design.md:10` (crosses a segment boundary)?; Q5 — approve the HLD.
3. **STOP.** We're still at the Phase 1 gate. I have not started the three nodes (change-store, delivery, browser-sync) and won't until you approve the HLD and say go.