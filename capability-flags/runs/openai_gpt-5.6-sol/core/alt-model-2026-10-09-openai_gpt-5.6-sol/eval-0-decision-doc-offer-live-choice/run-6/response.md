**Phase 1: HLD Review**
Updated `docs/high-level-design.md` to establish self-hosted WebSockets as the delivery approach:

- Committed changes receive ordered event revisions and are pushed over WebSockets.
- The change store provides replayable revisions and reliable publication handoff.
- Delivery owns WebSocket sessions, publication, and connection capacity.
- Browsers own reconnect and revision catch-up behavior.
- The HLD records the accepted operational cost and rejected polling/hosted-service alternatives.
- The infrastructure tenet now prefers manageable self-hosting over provider fees and coupling.

The coherence pre-flight found `docs/intent/access/access-design.md:10` still calls delivery “still open.” I left it untouched at this HLD boundary.

This choice remains credible enough to re-litigate and sizes three downstream nodes, so it qualifies for a standalone decision document.

1. Do you approve the HLD update?
2. Should I add `docs/decisions/change-delivery.md`, or is the HLD decision entry sufficient?
3. When we proceed to the three nodes, may I also remove the stale wording from the Access node?