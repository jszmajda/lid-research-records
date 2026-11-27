Updated `docs/high-level-design.md` for self-hosted WebSockets:

- **Approach** & **Architecture**: Set self-hosted WebSockets as the change-delivery approach and aligned the responsibilities of `change-store` (replayable revisions and reliable publication), `delivery` (WebSocket sessions and pushing committed revisions), and `browser-sync` (WebSocket subscription, reconnect, and revision catch-up).
- **Key Design Decisions**: Added **Self-hosted WebSockets for change delivery**, naming the rejected alternatives (five-second HTTPS polling and hosted realtime service) and the trade-off (fast updates without recurring vendor fees or provider coupling in exchange for owning connection capacity, session management, and reconnect/catch-up operations).

Note: `docs/intent/access/access-design.md` still refers to the "still-open change-delivery approach" in its Context section; I left that sibling segment untouched for now.

**Phase 1 review:**
1. Please review the updated `docs/high-level-design.md` and let me know if anything needs adjustment before we move to Phase 2 for `change-store`, `delivery`, and `browser-sync`.
2. Because this choice trades multiple credible options against competing criteria and sizes three downstream nodes, would you like me to record it as a full decision doc (`docs/decisions/change-delivery.md`), or is the entry in `## Key Design Decisions` sufficient?