Done. Created a full decision doc at `docs/decisions/delivery-approach.md` that a cold reader can use to re-run the judgment. It covers:

- **Gates** (vendor lock-in, load, recovery) — hosted service fails two
- **Weighted criteria** (operational burden, recurring cost, latency, implementation complexity, connection visibility) tied to HLD tenets
- **Three options** with honest strongest-representation descriptions and per-element verdicts
- **Selection** explaining why self-hosted WebSockets is the only option passing all gates and scoring strong on the tenet-driven major criteria

The HLD now links to it from Key Design Decisions.

**STOP for user review.** Approve to proceed to Phase 2 — drafting LLDs for change-store, delivery, and browser-sync?