Updated `docs/high-level-design.md` to select **self-hosted WebSockets**. The HLD now:

- Assigns replayable revisions and reliable publication to the change store.
- Assigns connection capacity, sessions, and reconnect handling to delivery.
- Assigns subscriptions, reconnects, and revision-based catch-up to browser sync.
- Records the polling and hosted-service alternatives and why they were rejected.
- Captures the preference for self-hosted realtime delivery over provider coupling.

This architecture choice could remain worth revisiting as connection capacity and operational costs become concrete. Would you like a full decision doc under `docs/decisions/`, or is the HLD’s Key Design Decisions entry sufficient?

Please review the HLD and confirm before I proceed to the three design nodes.