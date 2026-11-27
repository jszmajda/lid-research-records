**Phase 1: HLD Updated**

The HLD now selects self-hosted WebSockets for committed board-update delivery. It assigns downstream responsibilities:

- Change store retains replayable revisions.
- Delivery manages WebSocket sessions and reliable publication.
- Browser sync reconnects and catches up by revision.
- The decision records why polling and hosted realtime were rejected.

Please review `docs/high-level-design.md` and confirm Phase 1 before I draft the three leaf LLDs.

Two choices need your judgment before we continue:

1. Should the HLD add a tenet that favors operational control over minimizing connection-management work when the two conflict? The opposite is a reasonable project posture, so this would guide future design choices beyond WebSockets.
2. This delivery decision trades latency, operational work, recurring cost, and provider coupling, and will size three design nodes. Would you like a standalone decision document for it, or is the HLD’s Key Design Decisions entry sufficient?