Created `docs/decisions/change-delivery.md` and linked it from the `Key Design Decisions` entry in `docs/high-level-design.md`.

Summary of `docs/decisions/change-delivery.md`:
- **Decision Elements:** Update latency & burst responsiveness (**major**), vendor independence & predictable operating cost (**major**), operational simplicity (**moderate**), and read-path efficiency (**minor**).
- **Options in the Domain:** Five-second HTTPS polling, self-hosted WebSockets, and hosted realtime service, each analyzed against the criteria.
- **Selection:** Self-hosted WebSockets, trading stateful connection capacity and reconnect/catch-up engineering for fast updates without vendor coupling or recurring provider fees, with downstream obligations on `change-store`, `delivery`, and `browser-sync`.

Before moving to Phase 2:
1. Do `docs/decisions/change-delivery.md` and the updated `docs/high-level-design.md` look good to lock in?
2. Should we keep the existing four tenets in `docs/high-level-design.md` as-is?
3. `docs/intent/access/access-design.md` (line 10) still says `"still-open change-delivery approach"`. Should I update that reference in `access` before we start drafting the three new nodes (`change-store`, `delivery`, `browser-sync`), and which of the three would you like to tackle first?