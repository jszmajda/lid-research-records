The HLD now commits to self-hosted WebSockets for committed-change delivery. I stopped at the HLD review, as the skill requires; the three nodes come next.

**What changed in `docs/high-level-design.md`:**
- **Approach:** rewritten to state the chosen route. The server commits each edit as one revision and pushes it to browsers over WebSockets. Browsers replay missed revisions after reconnecting. The "still open" language and the three-way comparison are gone. The text now records the accepted cost: the board owns connection capacity, session lifecycle, and reconnect handling.
- **Architecture:** each node's bullet now describes its role under this route.
  - Access authorizes commands and socket subscriptions.
  - Change store holds the seven-day replayable revision log, read indexes, and a publication outbox.
  - Delivery owns WebSocket sessions and fan-out.
  - Browser sync tracks the last applied revision and requests what it missed.
- **Key Design Decisions:** added a row for the delivery choice. It names the two rejected options and why, and the accepted cost.

The existing tenets, goals, and non-goals are unchanged. The 15-second freshness bound is kept as the required target, and "subsecond" is now the stated aim.

**Choices I made that you can redirect:**
- I kept the 15-second bound as the freshness requirement and described subsecond updates as the aim. The previous draft said subsecond was optional.
- I left the three design nodes' content for later, as you asked. Access is consistent with the new HLD as written.

**Questions for you:**
1. **Tenet?** Your reason for this choice was not tying the board to a realtime vendor. Should "prefer owned delivery over vendor coupling when other factors are even" become a tenet under `## Tenets`? I did not add one.
2. **Decision doc?** This choice will stay live for a cold reader, since it shapes the change store and browser sync. Do you want it recorded as a standalone decision doc in `docs/decisions/`, with the Key Design Decisions row as the pointer? I did not write one.

Before the delivery node is written, note that access says revoked users are denied their next command. Open WebSocket sessions also need a rule for revoked assignments. That belongs in the delivery node.