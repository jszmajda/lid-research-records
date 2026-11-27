Done. The HLD now has a thorough decision write-up covering:

1. **Three options considered** — polling, self-hosted WebSockets, hosted realtime — with each one's operational profile
2. **Why self-hosted WebSockets won** — meets the binding 15s freshness target, no recurring fees, no provider coupling, team has the ops capacity
3. **What we're explicitly accepting** — connection management (800 concurrent, bursts), reconnect complexity (exponential backoff, cursor catch-up on both sides), operational monitoring burden
4. **What we gain** — fast updates without vendor bill, protocol control, no SLA dependency, push matches the live-board UX
5. **Downstream cascade** — concrete implications for the three LLDs (change store outbox, delivery session lifecycle, browser sync reconnect/visibility)

A new reader can now reconstruct the judgment without needing conversation context. Ready for Phase 4 edge audit when you are.