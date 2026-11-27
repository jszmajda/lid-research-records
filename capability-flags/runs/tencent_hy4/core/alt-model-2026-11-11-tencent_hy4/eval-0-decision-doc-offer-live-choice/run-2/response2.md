Written up. The decision doc is at `docs/decisions/change-delivery-approach.md` (project-level, `node: high-level-design`), and the HLD's Key Design Decisions entry now links to it.

It's written to be read cold — present tense, domain rationale only, no trace of how or when the choice was made. Full structure: Context (why the choice is live: all three options meet the 15s target, so nothing forces it, and what a wrong choice costs across the three nodes), Decision Elements (no eliminating gate survives; four weighted criteria), per-option Options in the Domain with verdict-led analysis, and Selection. Tenets are engaged — "Connectivity failures must be visible…" sets the failure-visibility criterion's importance and is named again in Selection as the tenet the decision turns on; "Self-hosted and managed infrastructure are both permitted" is named as why no constraint settled it. I probed for criteria cutting against the recommendation; the one that survives is the socket's silent-disconnect risk — the cost you accepted — stated plainly, not smoothed over.

Full doc for your review:

```
---
node: high-level-design
---

# Decision: Self-hosted WebSockets as the change-delivery mechanism

## Context

This decision builds on the choice to accept editor commands over HTTPS into one authoritative board per event; it concerns only how committed event revisions reach connected browsers.

Coordinators run boards for up to 800 simultaneous staff browsers, with bursts of 20 edits per second around opening time. Committed changes must appear in connected browsers within 15 seconds, and a browser disconnected for up to 20 minutes must recover the latest board. Five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service all meet those hard targets, so no binding requirement settles the choice — it is a genuine trade among acceptable mechanisms.

What is at stake is a long-lived cost, because the delivery mechanism is cross-cutting: the change store, the delivery component, and browser sync are each shaped by it. Choosing a mechanism commits those three components to a particular shape of revision storage, publication, session handling, and recovery, and reversing the choice later reworks all three. The recurring costs in play are a standing few seconds of lag and repeated reads (polling), self-operated connection capacity and reconnect logic (sockets), or recurring fees and dependence on a single vendor (hosted).

Standing constraints that every candidate respects are background, not points of selection: a committed edit has one authoritative event revision regardless of its delivery route; connectivity failures must be visible rather than mistaken for an unchanged board; and both self-hosted and managed infrastructure are permitted, since event updates carry only stall IDs and operational statuses. Nothing in the project's constraints forbids a managed realtime vendor — avoiding one is a preference, not a compliance requirement.

## Decision Elements

No gate eliminates a candidate: all three meet the freshness and recovery targets, preserve one authoritative revision, can surface connectivity failures, and are permitted infrastructure. The choice therefore rests on weighted criteria.

- **Update latency** (major) — how promptly a connected browser sees a committed change, beyond the 15-second ceiling. Although every candidate meets that ceiling, promptly-visible changes are valued during opening-time bursts, so lower standing lag is weighted heavily here.
- **Vendor independence** (major) — freedom from recurring per-update fees, a provider-specific subscription model, and coupling the board's availability to one external vendor.
- **Failure visibility** (major) — how directly a broken connection presents itself as a failure rather than as an unchanged board. Its importance derives from the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*: a mechanism that goes quiet on disconnect must be made to speak by added machinery.
- **Operational simplicity** (moderate) — how much connection and session machinery the project must own, capacity-plan, and operate at 800 browsers and opening bursts.

A criterion that cuts against the natural pull toward fast push delivery is failure visibility: a persistent socket can fail silently, and the tenet demands that it not. It survives as a genuine cost of the self-hosted option and is carried into the weighing below.

## Options in the Domain

### Five-second HTTPS polling

**Description.** The simplest stateless design. Each browser issues an HTTPS request every five seconds asking for changes since a cursor; the change store answers from a cursor-queryable revision log. Delivery stays ordinary request/response — no persistent connections, session registry, or reconnect protocol. At 800 browsers this is roughly 160 cheap reads per second, and the store scales with read indexes rather than connection capacity. Freshness is bounded by the polling interval, comfortably inside the 15-second target.

**Demonstration.** `GET /events/42/changes?since=481` returns `[{"revision":482,"stall":"B7","status":"closed"}]`.

**Analysis.**
- Update latency — **weak**: a committed change waits up to one interval plus request time before appearing; a standing lag of a few seconds.
- Vendor independence — **strong**: request/response over the project's own HTTPS, with no third-party service or recurring fees.
- Failure visibility — **strong**: a failed poll is an explicit HTTP error; there is no persistent connection that could present as an unchanged board.
- Operational simplicity — **strong**: stateless reads against cursor queries; no connection state to hold, scale, or recover.

**Summary.** Meets every hard requirement with the least machinery; the price is a standing lag and repeated reads.

### Self-hosted WebSockets

**Description.** Fast updates without a vendor bill. The delivery component holds one WebSocket session per connected browser and pushes each committed event revision the moment it is published from the store's reliable outbox. The change store keeps replayable revisions so a reconnecting browser can catch up; browser sync owns subscription, reconnect, and catch-up. Latency is bounded by commit-to-publish rather than a poll interval. The price is that the project operates the connection tier itself.

**Demonstration.** `ws://board/ws?event=42` receives `{"revision":482,"stall":"B7","status":"closed"}` on each commit; after a drop, the client reconnects with `since=481` and receives the missed revisions.

**Analysis.**
- Update latency — **strong**: committed revisions are pushed over an open socket as published, with no poll wait.
- Vendor independence — **strong**: project-run socket servers, no external provider, no recurring fees, no provider-specific client model.
- Failure visibility — **weak**: a dropped socket can present as an unchanged board unless heartbeat, reconnect, and catch-up are explicitly built; the tenet is met only through that added machinery.
- Operational simplicity — **weak**: the project owns connection capacity (up to 800 simultaneous sockets and opening bursts), a session registry, and reconnect/catch-up logic across delivery and browser sync.

**Summary.** Best freshness and full independence, at the cost of operating a connection tier and building reconnect/catch-up.

### Hosted realtime service

**Description.** The quickest route to low-latency updates with the least connection operations. A hosted realtime provider maintains fan-out to browsers; delivery wraps the provider's publication API, and browsers use its subscription model. The change store reconciles committed revisions against what the provider has published so gaps are detectable. Recurring fees buy managed connection capacity and mature client SDKs. The cost is an ongoing bill and a dependency on one vendor's API and availability.

**Demonstration.** `realtime.channel("event-42").subscribe(...)`; delivery calls `publish("event-42", revision 482)` and reconciles against the outbox.

**Analysis.**
- Update latency — **strong**: provider-managed push delivers committed changes with low latency.
- Vendor independence — **weak**: recurring fees, provider coupling, and a provider-specific subscription model in delivery and browsers.
- Failure visibility — **partial**: provider SDKs surface disconnects and reconnects, but the project must still wire those events into a visible failure state and catch-up; a silently stale subscription remains possible if unhandled.
- Operational simplicity — **partial**: connection capacity and most reconnect handling are the provider's, but the project takes on publication reconciliation between the store's outbox and the provider's publication path.

**Summary.** Low-latency push with the least self-operated connection machinery, in exchange for recurring fees and provider coupling.

## Selection

Self-hosted WebSockets is selected. It is the only candidate strong on both heavily-weighted criteria — update latency and vendor independence — and those two together are the declared priority: fast updates without coupling the board to a realtime vendor. Polling is strong on independence, failure visibility, and simplicity but weak on latency; the hosted service is strong on latency and fairly simple to operate but weak on independence. Neither combines the two priorities.

The selection is a weighing, not a dominance, and it does not claim otherwise. Self-hosted WebSockets is weak on the major, tenet-derived failure-visibility criterion: the tenet *Connectivity failures must be visible, not mistaken for an unchanged board* is exactly what makes the socket path costly, because a dropped connection must be made to announce itself. That weakness is the cost this decision accepts, and satisfying the tenet becomes a downstream obligation — heartbeat, reconnect, and catch-up — rather than a reason to reject the option. The option is also weak on the moderate operational-simplicity criterion, since the project takes on the connection tier. These are judged worth paying for fast, vendor-independent updates; a standing few-seconds lag (polling) and recurring fees plus provider coupling (hosted) each carry a worse long-lived cost. The decision turns on the failure-visibility tenet and is taken within the tenet that self-hosted and managed infrastructure are both permitted — nothing in the project's constraints forced or forbade this direction, so it rests on stated preference, not compliance.

The choice forecloses the stateless, no-connection-tier simplicity of polling and the managed-connection convenience of a hosted provider. It obligates three downstream components: the change store must keep replayable revisions and a reliable publication outbox; delivery must manage socket sessions and publication; browser sync must own subscription, reconnect, and catch-up. The connection tier must be capacity-planned for 800 simultaneous browsers and opening-time bursts.
```

We're still at the Phase 1 STOP — I have not started the three nodes. Two items from my last message are still open (you answered the decision-doc question, not these), and I won't settle them for you:

1. **Cross-boundary cascade into `access`.** `docs/intent/access/access-design.md:10` still calls the change-delivery approach "still open." Should I update that line now, or leave the `access` segment for its own pass? (Its specs carry no approach reference.)
2. **Tenet.** The "Self-hosted and managed infrastructure are both permitted" tenet versus the lean toward low latency and no vendor coupling over minimal ops burden. The decision doc now carries that rationale cold-readably, but I've left the tenets unchanged, since tenets are elicited, not assumed. Want me to add/adjust a one-line tenet, or leave the tenets as-is?

Give me your review of the doc (numbered feedback welcome) and your calls on 1–2; on your explicit approval I'll move on to the three nodes.