The HLD now selects self-hosted WebSockets for delivery. I haven't touched the three node docs yet; you said to do those next.

**What changed in `docs/high-level-design.md`:**
- **Approach** now describes the WebSocket design. Committed revisions are pushed to browsers over a connection the project operates. The paragraph on open options is gone.
- **Architecture** bullets for change store, delivery, and browser sync now state what each owns: replayable revisions and reliable publication; socket sessions, liveness, and fan-out; subscription, reconnect with backoff, and catch-up.
- **Key Design Decisions** has a new entry recording the choice. It names the polling and hosted alternatives, why each was rejected, and the accepted cost of self-hosting.

**Choices I made that you should check:**
1. **Catch-up fallback.** If a browser's missed revisions are no longer retained, it reloads the full board. I wrote this in the Approach as the reconnect rule. Replay means retained revisions, and the seven-day retention goal is the limit.
2. **Reliable publication.** I wrote that the change store publishes every committed revision to delivery reliably, so no edit is missing from the live stream. I did not pick a mechanism such as an outbox; that belongs in the change-store node.

**Decisions for you:**
- **Decision doc?** This choice trades several criteria against each other, and the three nodes will be sized around it. I can record it as a decision doc in `docs/decisions/` and link it from the Key Design Decisions entry. Say yes or no. If no, the entry stays as the only record.
- **Access node is now stale.** `docs/intent/access/access-design.md` line 10 says authorization is "independent of the still-open change-delivery approach." That is a sibling segment, so I left it alone. It should probably say the approach is settled. Should I update it now, or leave it for the access pass?
- **Tenet to review.** The tenet "Self-hosted and managed infrastructure are both permitted" is still accurate, but it no longer says which way to lean. Do you want a tenet that leans toward self-hosting, or should it stay as it is?
- **Pre-existing gap.** Full LID expects every HLD section to be filled. The HLD still has no Target Users, System Design, or Success Metrics sections. That predates this change, and I did not add them.

Nothing is committed. Once you've reviewed the HLD and answered the questions above, I'll move on to the change-store, delivery, and browser-sync nodes.