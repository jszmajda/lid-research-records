## Phase 1: HLD Updated

`docs/high-level-design.md` now selects self-hosted WebSocket delivery:

- The change store will retain replayable event revisions and reliably publish committed changes.
- Delivery will own WebSocket capacity, session lifecycle, and change delivery.
- Browser sync will reconnect and catch up from its last received revision.
- The Key Design Decisions section records why five-second polling and a hosted provider were rejected.

The HLD remains consistent with the existing authoritative-revision, visible-connectivity-failure, and server-authorized-command tenets.

Please review and approve this HLD revision before I draft the change-store node.