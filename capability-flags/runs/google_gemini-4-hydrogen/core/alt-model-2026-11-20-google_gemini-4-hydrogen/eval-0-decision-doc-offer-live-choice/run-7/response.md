Updated `docs/high-level-design.md` for Phase 1 to commit to self-hosted WebSockets:

### Updated sections in `docs/high-level-design.md`

- **Approach**: Commits to pushing committed changes to connected browsers over self-hosted WebSockets, with `change-store` owning replayable event revisions and reliable publication, `delivery` owning WebSocket sessions and connection capacity, and `browser-sync` owning subscription, reconnects, and revision catch-up.
- **Architecture**: Updates the `Change store`, `Delivery`, and `Browser sync` summaries to reflect their WebSocket responsibilities.
- **Key Design Decisions**: Adds **Self-hosted WebSockets for change delivery**, naming 5-second HTTPS polling and a hosted realtime service as alternatives considered and capturing the tradeoff (fast updates without vendor fees or provider coupling vs. owning 800-browser connection capacity, reliable publication, and reconnect/catch-up).

### Review & Questions

1. **HLD review**: Does the updated `docs/high-level-design.md` match your intent?
2. **Decision doc offer**: Because a cold reader seeing a 15-second freshness target could reasonably re-litigate why 5-second polling or a hosted realtime service was not chosen—and `change-store`, `delivery`, and `browser-sync` are all being sized around this choice—would you like me to record this as a standalone decision doc in `docs/decisions/` (linked from `Key Design Decisions`), or keep just the `Key Design Decisions` entry?
3. **Stale reference in `access`**: `docs/intent/access/access-design.md` still refers to the "still-open change-delivery approach." Should I update that line to match the HLD before we move on?

Once you confirm, let me know which of the three nodes (`change-store`, `delivery`, or `browser-sync`) you want to draft first in Phase 2.