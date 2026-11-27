Created `docs/decisions/change-delivery-transport.md` and linked it from the **Key Design Decisions** entry in `docs/high-level-design.md`.

The decision doc captures:
- **Context**: The 40-market / 800-browser / 20-edits-per-second burst workload and how the transport choice shapes `change-store`, `delivery`, and `browser-sync`.
- **Decision Elements**: Four weighted criteria—vendor independence and cost predictability (major), update freshness and burst efficiency (moderate), operational simplicity of connection management (moderate), and alignment with authoritative revisions and visible failure (moderate, turning on the HLD tenets).
- **Options in the Domain**: Full descriptions, criterion-by-criterion verdicts (`strong`/`partial`/`weak`), and trade summaries for five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service.
- **Selection & Implications**: Why self-hosted WebSockets wins and what it forecloses and obligates for `change-store`, `delivery`, and `browser-sync`.

Before moving to Phase 2:
1. Do `docs/high-level-design.md` and `docs/decisions/change-delivery-transport.md` look good to lock in Phase 1?
2. Should I update the stale phrase in `docs/intent/access/access-design.md` ("still-open change-delivery approach") to match the HLD?
3. Which of the three nodes (`change-store`, `delivery`, or `browser-sync`) would you like to draft first?