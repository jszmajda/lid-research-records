I have authored the decision doc at `docs/decisions/change-delivery.md` and linked it from the HLD under **Key Design Decisions**.

The decision doc details:
- **Context & Problem Space**: Distributing committed event revisions and handling up to 20-minute disconnects across 800 concurrent staff browsers without vendor lock-in.
- **Decision Elements**: Evaluates gates (freshness target, authoritative ordering) and weighted criteria (operating cost predictability, vendor independence, operational overhead, implementation simplicity).
- **Options in the Domain**: Analyzes five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service with per-element fit verdicts.
- **Selection & Downstream Obligations**: Records the choice of self-hosted WebSockets and outlines the downstream responsibilities for `change-store`, `delivery`, and `browser-sync`.

---

### Phase 1 Review & Next Steps

With the HLD updated and the decision doc in place, we are ready to move to **Phase 2 (LLD check or draft)** for the three downstream nodes:
1. `change-store` (`docs/intent/change-store/change-store-design.md`)
2. `delivery` (`docs/intent/delivery/delivery-design.md`)
3. `browser-sync` (`docs/intent/browser-sync/browser-sync-design.md`)

Which node would you like to design first?