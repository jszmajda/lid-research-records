Written to `docs/decisions/delivery-transport.md` and linked from the HLD's Key Design Decisions entry. The doc lays out:

- **Context** — why the transport choice governs the downstream nodes (store must retain replayable revisions, delivery owns publication, browser sync owns reconnect/catch-up), and why freshness doesn't eliminate anything (all three clear 15s).
- **Decision elements** — no gates; five weighted criteria (independence, operating cost, operational burden major; read load/statelessness moderate; latency minor), with independence tied to the *self-hosted and managed infrastructure are both permitted* tenet.
- **Options in the domain** — polling, self-hosted WebSockets, hosted service, each with a described strongest-case and verdict-led analysis.
- **Selection** — self-hosted WebSockets wins by choosing the two major criteria it can hold (independence, no recurring fees) and accepting the third (owning connection capacity and reconnect) as the work the project takes on; names why polling and the hosted service lose, and records the downstream obligations.

That closes Phase 1 for this change. Confirm the HLD and the decision doc as written, and I'll consider the approach settled — the three nodes (change-store, delivery, browser-sync) stay for the follow-up as you said.