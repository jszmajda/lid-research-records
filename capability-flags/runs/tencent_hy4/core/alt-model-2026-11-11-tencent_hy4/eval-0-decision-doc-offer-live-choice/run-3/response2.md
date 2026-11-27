Written the full decision doc at `docs/decisions/change-delivery-approach.md` (project-level, owned by the HLD, no EARS IDs) and linked it from the HLD's Key Design Decisions row. Here it is in full:

```markdown
---
node: high-level-design
---

# Decision: Change-delivery approach

## Context

Builds on the decision to accept edit commands over HTTPS with one authoritative event revision per committed edit; this decision fixes how those committed revisions reach browsers.

A busy market shows its board to up to 800 simultaneous staff browsers, with opening-time bursts of 20 edits per second. Committed changes must appear within 15 seconds, a browser disconnected for up to 20 minutes must recover the latest board, and the service must hold 99.5 percent availability during published event hours. Three delivery approaches exist in this problem space: five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service.

No inherited constraint eliminates any of them. All three meet the 15-second freshness target, preserve one authoritative event revision regardless of delivery route, keep connectivity failures visible rather than reading as an unchanged board, and carry event updates that contain stall IDs and operational statuses rather than customer records. The tenet "Self-hosted and managed infrastructure are both permitted" leaves managed delivery admissible, and the absence of customer records means no data-sensitivity rule rules it out. The choice is therefore a genuine judgment among live options, which is why the reasoning is recorded here rather than left implicit.

## Decision Elements

No gate eliminates an option; every approach clears the hard constraints above. Selection rests on graded criteria, each marked by importance:

- **Vendor coupling and recurring cost** (major). The weight here comes from the operating preference to keep the board's delivery path independent of a third party. The tenet "Self-hosted and managed infrastructure are both permitted" leaves this as a preference to be weighed rather than a constraint already applied.
- **Propagation latency and headroom** (moderate). Derived from the 15-second freshness goal and the stated usefulness of subsecond updates. Every option clears the goal, so this grades how much headroom each leaves beyond it.
- **Implementation and ongoing operational effort** (moderate). Covers connection capacity, reconnect handling, reliable publication, and browser catch-up logic. The tenet "Connectivity failures must be visible, not mistaken for an unchanged board" raises the cost of owning the connection tier: whoever owns delivery must build the reconnect and catch-up path that surfaces disconnects.
- **Availability risk from owned connection capacity** (moderate). Derived from the 800-simultaneous-browser and 99.5-percent-availability goals; grades how much connection-tier risk each option leaves the team to carry.
- **Read load and request volume at scale** (minor). Grades the efficiency of the delivery path against the store under 800 browsers.

## Options in the Domain

### Five-second HTTPS polling

Browsers issue an HTTPS request every five seconds for changes since a cursor; delivery stays stateless request/response, the store serves cursor queries, and no persistent connections are held. A committed edit is read on the next poll. This is the simplest option to operate: no long-lived connection state, no session management, and no vendor. Its cost is repeated reads against the store and a few seconds of lag.

- **strong** — *Vendor coupling and recurring cost* (major): no third-party service and no recurring realtime fees; delivery runs on the existing HTTPS path.
- **weak** — *Propagation latency and headroom* (moderate): a committed edit waits up to five seconds for the next poll; the 15-second target is met with little headroom and no subsecond path.
- **strong** — *Implementation and ongoing operational effort* (moderate): stateless operation, no connection capacity or reconnect logic; browsers run a polling loop and the store adds cursor queries.
- **strong** — *Availability risk from owned connection capacity* (moderate): no persistent connections to hold; load is roughly 160 requests per second at 800 browsers, handled by stateless request/response.
- **weak** — *Read load and request volume at scale* (minor): every browser polls on a fixed interval regardless of change rate, producing repeated cursor queries even when the board is idle.

Summary: Simplest to operate with no vendor dependency, at the cost of repeated reads and a few seconds of lag.

### Self-hosted WebSockets

Delivery holds a persistent WebSocket session per browser and publishes each committed revision as it lands. The store retains replayable revisions and a publication outbox for reliable publication, and browsers run reconnect and catch-up logic to recover edits missed during a disconnect. Updates are fast and no realtime vendor is involved; the market operates and monitors the connection tier itself.

- **strong** — *Vendor coupling and recurring cost* (major): no provider and no recurring realtime fees; the delivery path is self-operated.
- **strong** — *Propagation latency and headroom* (moderate): committed revisions are pushed on commit, giving subsecond propagation and wide headroom over the 15-second target.
- **weak** — *Implementation and ongoing operational effort* (moderate): the team owns connection capacity for up to 800 sessions, reconnect handling, reliable publication, and browser catch-up logic — the most operational work of the three.
- **weak** — *Availability risk from owned connection capacity* (moderate): 800 persistent connections and opening-time reconnection bursts are capacity the team must provision and keep healthy to hold 99.5 percent availability; this is a failure mode the managed options absorb.
- **strong** — *Read load and request volume at scale* (minor): revisions are pushed once on commit rather than re-read on a fixed interval; no idle polling traffic.

Summary: Fast, vendor-independent updates in exchange for owning connection capacity and reconnect behavior.

### Hosted realtime service

A managed realtime provider carries committed revisions to subscribed browsers; delivery wraps the provider, reconciles publications, and holds provider credentials, while browsers use the provider's subscription model. Low-latency updates come with the connection tier operated by the provider. The store needs publication reconciliation and the integration introduces a third-party dependency.

- **weak** — *Vendor coupling and recurring cost* (major): recurring fees and coupling to the provider's subscription model and SDK; the board's delivery path depends on a third party.
- **strong** — *Propagation latency and headroom* (moderate): low-latency push comparable to self-hosted sockets.
- **strong** — *Implementation and ongoing operational effort* (moderate): the provider handles connection capacity and reconnects; less connection operations, though delivery must reconcile publications and manage credentials.
- **strong** — *Availability risk from owned connection capacity* (moderate): the provider absorbs connection capacity and reconnection load, so this risk is largely delegated.
- **strong** — *Read load and request volume at scale* (minor): revisions are pushed through the provider rather than re-read on an interval.

Summary: Quickest route to low-latency updates with less connection operations, at the cost of recurring fees and provider coupling.

## Selection

Self-hosted WebSockets is selected. Against the major criterion — vendor coupling and recurring cost — polling and self-hosted sockets both clear it while the hosted service does not; between those two vendor-independent options, self-hosted sockets are strong on propagation latency where polling is weak. The decision accepts weak fits on implementation and ongoing operational effort and on availability risk from owned connection capacity, both moderate, as the price of fast, vendor-independent updates: the major criterion and the latency advantage outrank the two moderate weaknesses. The hosted service matches on latency and effort but fails the major coupling-and-cost criterion, so it is not selected despite being the lightest to operate.

The choice preserves "A committed edit has one authoritative event revision regardless of its delivery route" — replayable revisions and reliable publication keep a single revision authoritative across reconnects — and "Connectivity failures must be visible, not mistaken for an unchanged board," which the owned reconnect and catch-up path must surface explicitly. "Self-hosted and managed infrastructure are both permitted" is the standing permission within which the choice is made: managed infrastructure was admissible and event updates carry no customer records, so declining it is a preference on coupling and cost, not a constraint that was applied.

The decision forecloses polling's stateless simplicity and the hosted provider's managed connection tier. It obligates the change store to retain replayable revisions and a publication outbox, delivery to manage WebSocket sessions and reliable publication, browser sync to own subscription, reconnect, and catch-up, and the team to provision and monitor connection capacity for up to 800 simultaneous browsers and opening-time reconnection bursts. These responsibilities fall to the change-store, delivery, and browser-sync nodes.
```

We're still at the Phase 1 stop — I have **not** written the three node LLDs (`change-store`, `delivery`, `browser-sync`). Writing the doc surfaced three things that need your ruling; I've not settled any of them:

1. **Latent-criteria probe.** I deliberately surfaced criteria that cut *against* the recommendation — owned-capacity availability risk, implementation/operational effort, and read load — and recorded them with their real weights rather than hiding them; selection still turns on the major coupling-and-cost criterion plus the latency advantage. If a thoughtful critic should weigh something else, or a weighting/verdict is wrong, give numbered feedback and I'll revise the doc.

2. **Tenet gap (item 3 from before, now concrete).** The doc makes the tradeoff legible, but it also exposes that the decisive criterion — avoid vendor coupling, accept the operations work — is a preference the project has **not** recorded as a tenet. The existing "Self-hosted and managed infrastructure are both permitted" reads as neutral, so a cold reader could reasonably re-litigate the choice. Should I record that lean as a one-line tie-breaker (e.g., "Lean toward self-hosted infrastructure over vendor coupling, accepting added operational work") and reconcile the neutral line, or leave the Tenets as they stand? I won't add a tenet without your call.

3. **Still open from the stop:** (a) your explicit approval of the HLD before I proceed to Phase 2; (b) the cross-segment flag — `docs/intent/access/access-design.md` still says "independent of the **still-open** change-delivery approach," now stale; should I fix that wording now or fold it into the node work? I haven't touched it across the segment boundary.

Please reply with your ruling; I'm stopping here.