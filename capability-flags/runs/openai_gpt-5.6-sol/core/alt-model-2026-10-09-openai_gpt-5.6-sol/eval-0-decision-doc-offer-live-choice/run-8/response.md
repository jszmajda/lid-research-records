Updated `docs/high-level-design.md` to:

- Select self-hosted WebSockets for committed change delivery.
- Preserve HTTPS for editor commands.
- Require replayable revisions and reliable post-commit publication.
- Assign WebSocket session and capacity ownership to delivery.
- Assign reconnect and revision catch-up behavior to browser sync.
- Record the polling and hosted-service alternatives and the accepted operational tradeoff.

The three downstream nodes remain untouched pending this Phase 1 review.

This is a consequential project-level choice that future readers may re-litigate. Please reply with:

1. Any HLD changes, or approval to proceed to the three nodes.
2. Whether to keep the concise HLD decision entry or add a full decision document under `docs/decisions/`.