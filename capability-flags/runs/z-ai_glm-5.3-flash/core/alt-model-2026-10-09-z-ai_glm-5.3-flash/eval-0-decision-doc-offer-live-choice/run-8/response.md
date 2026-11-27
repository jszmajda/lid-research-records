Updated `docs/high-level-design.md` to record the self-hosted WebSockets approach:

- **Approach** — delivery is self-hosted WebSockets; delivery owns socket sessions, browsers reconnect and catch up. The rejected alternatives (polling's repeated reads and lag, hosted realtime's fees and provider coupling) and the trade-off accepted (connection/reconnect operations we own) are recorded so the section reads context-free.
- **Architecture** — the three pending nodes now state their roles under this approach: change store keeps replayable revisions, delivery owns WebSocket sessions and reliable publication, browser sync owns subscription/reconnect/catch-up.
- **Key Design Decisions** — added a decision entry alongside the HTTPS-command decision.

A few things for you to check before we move to the three nodes:

1. **Decision doc offer** — this choice clears the bar for one: three credible options traded across several criteria (latency, cost, ops burden, vendor coupling), and the store/delivery/browser nodes are about to be sized around it, so a cold reader could plausibly re-litigate self-hosting. Want a full decision doc under `docs/decisions/` with the sketched options and criteria, or is the Key Design Decisions entry enough?
2. The freshness goal is still "within 15 seconds" — WebSockets can beat that, but I left it unchanged since you only said "fast updates." Confirm or raise it?
3. I kept the "Self-hosted and managed infrastructure are both permitted" tenet — still right given we've now leaned self-hosted for delivery?

Once you confirm, I'll walk the store → delivery → browser-sync nodes in order, stopping for review at each.