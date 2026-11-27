Decision recorded so a new reader can reconstruct the trade-off.

Created `docs/decisions/delivery-approach-self-hosted-websockets.md` with frontmatter `node: high-level-design` and the full Decision Elements / Options / Selection analysis.

Key points captured:
- Gates: ≤15s freshness, replayable revisions for 20-min catch-up, visible connectivity failures.
- Major criteria: vendor independence / cost predictability and update latency under burst load.
- Options analyzed with honest strongest representation:
  * Five-second HTTPS polling – simplest stateless, more repeated reads, lag.
  * Self-hosted WebSockets – fast updates, no vendor bill, needs connection capacity/reconnect work, replayable revisions and reliable publication.
  * Hosted realtime service – quick low-latency, less connection ops, recurring fees and provider coupling.
- Selection: self-hosted WebSockets passes all gates, strong on vendor independence and latency, accepts weaker operational burden for connection management and reconnects. Turns on the tenet that self-hosted and managed infrastructure are both permitted and the preference for vendor independence. Obligates change store to provide replayable revisions and publication outbox, delivery to own session management / reconnect / reliable publication, and browser sync to implement subscription / reconnect-catch-up / connectivity visibility.

HLD `Key Design Decisions` now references the doc: `docs/decisions/delivery-approach-self-hosted-websockets.md`.

Phase 1 HLD is stable with the approach and decision documented.

Approve to move to Phase 2 and draft the three leaf LLDs — change-store, delivery, browser-sync — for the self-hosted WebSockets approach?