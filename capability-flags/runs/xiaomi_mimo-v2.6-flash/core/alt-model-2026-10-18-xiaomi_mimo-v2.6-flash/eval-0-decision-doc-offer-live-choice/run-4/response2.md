Decision record written at `docs/decisions/self-hosted-websockets.md` and linked from the HLD's Key Design Decisions entry. Full document:

```markdown
---
node: high-level-design
---

# Decision: Self-hosted WebSockets for change delivery

## Context

MarketBoard delivers committed board changes to up to 800 simultaneous browsers during published event hours, with bursts around opening time. Three delivery mechanisms are viable: five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service. All three meet the 15-second freshness goal, so freshness is a background constraint rather than a tie-breaker.

The choice sizes three design nodes at once — the change store's revision model, the delivery component's session machinery, and the browser's recovery behavior — so a wrong choice means reworking all three. The project's tenets permit both self-hosted and managed infrastructure and require one authoritative revision per committed edit regardless of delivery route; policy eliminates no option. The decision turns on how the three mechanisms trade against speed, coupling, operating burden, cost, and simplicity.

## Decision Elements

All three options clear the standing constraints — the 15-second freshness goal, one authoritative revision per commit, and visible connectivity failures — so no gate eliminates an option. The decision turns on these weighted criteria:

- **Update speed for connected browsers** (major) — how soon a committed revision appears in open boards after the server commits it.
- **Vendor coupling** (major) — the degree to which the board's realtime path depends on a third party's availability, pricing, credentials, and API model.
- **Operating burden owned by the team** (major) — connection capacity, session state, reconnect handling, and realtime incidents the team carries during event hours.
- **Availability exposure during event hours** (moderate) — how much new availability surface the choice adds beyond the HTTPS command tier, against the 99.5 percent goal.
- **Recurring operating cost** (moderate) — ongoing fees or incremental infrastructure cost at 800 always-connected browsers.
- **Implementation simplicity** (moderate) — the size of the machinery added across store, delivery, and browser to make delivery correct.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers re-request board state over ordinary HTTPS every five seconds. The server answers reads statelessly; no connections persist between requests. The change store needs cursor queries so each poll can ask what changed since the browser last looked. Delivery stays plain request/response, and the browser runs a polling loop on a timer. A committed edit appears at the next poll.

**Analysis.**

- **Update speed (major): weak.** Each revision waits up to five seconds plus request latency; every browser adds a steady read request on top of edit bursts.
- **Vendor coupling (major): strong.** No third party; delivery rides the same HTTPS infrastructure as commands.
- **Operating burden (major): strong.** No connection state to capacity-plan, no reconnect storms, no session cleanup; failures are ordinary HTTP failures the stack already handles.
- **Availability exposure (moderate): strong.** Delivery adds no new subsystem — it reuses the HTTPS tier the command path already requires to be available.
- **Recurring cost (moderate): strong.** No new services or fees; repeated reads add modest load to existing infrastructure.
- **Implementation simplicity (moderate): strong.** The smallest machinery: stateless reads, one cursor query in the store, a timer in the browser.

**Summary.** Simplest and cheapest to run; every change pays a few seconds of lag and every browser pays constant read traffic.

### Self-hosted WebSockets

**Description.** A server the project operates holds one WebSocket connection per connected browser, and committed revisions publish over those connections as they commit. The change store keeps replayable revision history — every revision numbered and retained — plus a reliable publication path that hands committed changes to delivery without loss, including across restarts. Delivery manages connection capacity, heartbeats, and reconnection. On reconnect, the browser reports the last revision it saw and catches up by replaying the gap.

**Analysis.**

- **Update speed (major): strong.** Publication happens on commit; connected boards update in well under a second.
- **Vendor coupling (major): strong.** The protocol, infrastructure, and availability are the project's own; no provider credentials, quotas, or pricing sit on the delivery path.
- **Operating burden (major): weak.** The team owns capacity for 800 concurrent sockets, reconnect handling (including reconnect bursts after a deploy or network blip), and the correctness of the publication path. This is the cost this option asks the team to carry.
- **Availability exposure (moderate): weak.** A persistent-connection tier is added alongside the command tier, and the team must engineer it to the 99.5 percent goal; transient drops fall back on browser reconnect and replay to recover.
- **Recurring cost (moderate): partial.** Concurrent-socket capacity is modest infrastructure the project already runs; there are no per-message fees.
- **Implementation simplicity (moderate): weak.** The largest machinery of the three: session lifecycle in delivery, replayable revisions and a loss-free publication handoff in the store, and reconnect and catch-up in the browser.

**Summary.** Fastest option without a vendor; pays in connection operations and in owning the most machinery.

### Hosted realtime service

**Description.** A managed realtime provider performs the fan-out. The server publishes committed revisions through the provider's API; browsers subscribe using the provider's subscription model, typically its SDK. The delivery component wraps the provider, manages credentials, and reconciles publication — confirming every committed revision was accepted and broadcast. The store owes its publication obligation to the provider rather than to connections the project runs.

**Analysis.**

- **Update speed (major): strong.** Provider fan-out delivers committed revisions to subscribers well inside the freshness target.
- **Vendor coupling (major): weak.** The realtime path runs on the provider's availability, pricing, credential model, and subscription API; an outage, price change, or API change lands directly on the board, and browser code follows the provider's model.
- **Operating burden (major): partial.** Connection capacity and socket reconnect become the provider's problems, but the team still owns publication reconciliation, credential rotation, quota monitoring, and the response to provider degradation.
- **Availability exposure (moderate): partial.** The provider operates the realtime tier as its specialty, but its incidents become the board's incidents, mediated by the provider's own status and support process.
- **Recurring cost (moderate): weak.** Fees scale with 800 always-connected browsers and message volume during bursts, for every published event hour.
- **Implementation simplicity (moderate): partial.** Session and reconnect machinery disappears from delivery and the browser, replaced by provider wrapping, reconciliation, and SDK integration.

**Summary.** Quickest route to low-latency updates with the least connection operations, at the price of recurring fees and provider coupling.

## Selection

**Self-hosted WebSockets.**

The decision turns on update speed and vendor coupling — the major criteria where self-hosted sockets win outright: polling is inherently slow, the hosted service couples the board to a realtime vendor, and self-hosted sockets are strong on both. On operating burden — the criterion where this option loses — the trade is accepted deliberately: at 800 concurrent browsers the connection work is bounded, and owning reconnect and capacity is judged a better cost than seconds of lag or provider coupling. Availability exposure loses the same way and is mitigated in the design itself: reconnect plus revision replay turns transient disconnects into recoverable gaps rather than stale boards, which is why browser catch-up is part of the approach rather than an afterthought. Implementation simplicity loses again for the same reason — more machinery, owned on purpose.

Tenets engaged: "Self-hosted and managed infrastructure are both permitted" leaves this choice open rather than forcing it, and this decision records which way the project leans for the delivery path — own it. The one-authoritative-revision tenet constrains what may be published — server-committed revisions, never browser-merged state — but every option satisfies it, so it does not separate them.

Implications of committing: the change store must provide replayable revisions and a loss-free publication path; delivery must plan connection capacity and reconnection; the browser must reconnect and catch up. Polling or a hosted service remain reachable later — this choice sizes the first design of these nodes, not an irreversible lock-in — but switching later reworks all three, which is why the tradeoff is recorded at this resolution.
```

Three things for you:

1. **Decision record** — numbered feedback on the doc, or approve it?
2. **Cascade (still open from last stop)** — `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach." May I fix that one line when we start the three nodes, or leave access untouched?
3. **Optional** — the lean "own the operations rather than accept vendor coupling" currently lives only in this decision record. If you want it to govern future infrastructure choices too (not just delivery), it can be promoted to a one-line HLD tenet; otherwise the record and the existing permissive tenet stand as-is.

Approve the HLD + record (item 1) and answer 2–3, and we'll move to Phase 2: LLD drafts for change store, delivery, and browser sync.