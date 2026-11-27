I wrote up the decision doc at `docs/decisions/delivery-transport.md` and linked it from the HLD's Decisions row.

It lays out:
- **Context** — why the transport choice matters and what the store/delivery/browser-sync nodes are sized around.
- **Decision Elements** — a 15-second freshness gate (all three options pass), and four weighted criteria: burst latency and operational burden (major), recurring cost and vendor coupling (moderate), tying the ops-burden and vendor-coupling criteria back to the HLD's existing tenets.
- **Options in the Domain** — polling, self-hosted WebSockets, and the hosted service, each described on its own terms with a per-criterion verdict.
- **Selection** — WebSockets wins on the two major criteria (burst latency, no vendor on the critical path), explicitly naming the traded-away criterion (the team now owns connection/reconnect ops) and what it forecloses for the three downstream nodes.

This is still the Phase 1 stop — please review both the decision doc and the HLD's updated Decisions row before I move on to drafting the three LLDs (change store, delivery, browser sync).