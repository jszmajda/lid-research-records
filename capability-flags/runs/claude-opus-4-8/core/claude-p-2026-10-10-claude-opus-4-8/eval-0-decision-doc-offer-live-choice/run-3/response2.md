Done. The decision doc is at `docs/decisions/delivery-transport.md`, written to be read cold — present tense, no chronology of our discussion, each option given its strongest honest form:

- **Context** — why the transport choice exists and why it's expensive to reverse (it sizes all three downstream nodes).
- **Decision Elements** — no eliminating gate (all three meet freshness, recovery, and throughput); five weighted criteria: vendor independence (major), operational burden (major), recurring cost (moderate), update latency (moderate), connection fan-out at scale (moderate).
- **Options in the Domain** — polling, self-hosted WebSockets, hosted realtime service, each with a per-criterion strong/partial/weak analysis.
- **Selection** — self-hosted wins on the two things the choice turns on (vendor independence + no recurring fee) plus the fast updates polling can't give; the accepted cost is operational burden and owning fan-out. Closes with the downstream obligations each node inherits and what the choice forecloses (no managed provider in the pilot).

The HLD's Key Design Decisions row is now trimmed to a one-line summary that links out to the doc.

**Still open — your call on question 2 (the tenet).** Writing the doc actually sharpened it. The Selection says plainly that the decision *turns on valuing vendor independence above minimum operational burden — a lean no current tenet states*. Per the template, a project-level decision that leans hard on a criterion citing no tenet is the signal that either the decision is purely local (it isn't — it shapes all three nodes) or the project is missing a tenet. So I'd lean toward adding a tenet like *"Prefer self-hosted infrastructure over a managed vendor when both meet the goal"* and pointing the doc's major criterion at it. But it narrows your existing neutral "both permitted" tenet, so it's yours to decide:

- **(a)** Add the vendor-independence tenet (I'll update the Tenets list and have the decision doc's criterion turn on it), or
- **(b)** Keep it as a local lean — the doc stands as written and the neutral tenet stays.

Once you pick (a) or (b), Phase 1 is settled and we move to the nodes. I still suggest **change-store first**, since its revision-history + outbox contract is what delivery and browser-sync build against — but say the word if you'd rather sequence differently.