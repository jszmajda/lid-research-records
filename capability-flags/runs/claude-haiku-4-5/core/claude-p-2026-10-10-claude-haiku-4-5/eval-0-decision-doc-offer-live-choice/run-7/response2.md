**Decision doc complete.** I've created `docs/decisions/change-delivery-approach.md` laying out:

- **Context:** Why the choice matters and what's at stake.
- **Decision Elements:** Gates (all three options pass) and weighted criteria — operational burden, vendor independence, browser complexity, and storage requirements.
- **Options in the Domain:** Each of the three approaches (polling, self-hosted WebSockets, hosted service) with detailed analysis showing how each trades off against the criteria.
- **Selection:** Why WebSockets wins — it balances operational burden (connection management is well-studied), vendor independence, and freshness, and aligns with the project's infrastructure posture.

The HLD now links to this decision doc from the Key Design Decisions section.

---

**Phase 1 ✓ — HLD approved and ready for cascade.**

You're ready to move to Phase 2: the three leaf LLDs (change-store, delivery, browser-sync). Each will own design and specs for that component, with the WebSocket choice now fixed upstream. Ready to start the first one?