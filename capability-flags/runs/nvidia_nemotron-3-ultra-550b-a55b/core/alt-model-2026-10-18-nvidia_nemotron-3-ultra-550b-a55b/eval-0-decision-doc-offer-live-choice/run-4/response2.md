Created `docs/decisions/self-hosted-websockets.md` — a full decision doc that a cold reader can use to re-run the judgment. It covers:

- **Gates**: hard constraints that eliminated hosted realtime (recurring fees, provider lock-in)
- **Weighted criteria**: operational burden (major), latency (major), reconnect complexity (moderate), read amplification (moderate), credential surface (minor) — with tenet traceability
- **Three options** at their strongest honest representation: polling (simplest ops, weak latency/read-load), self-hosted WebSockets (strong latency/read-load, weak ops burden/reconnect), hosted realtime (strong latency/ops, eliminated by gates)
- **Selection rationale**: self-hosted WebSockets passes all gates and wins on both major criteria; the tradeoff is accepting the engineering work of connection management and replay logic
- **Cascaded obligations** to change-store, delivery, and browser-sync

The HLD now links to it from Key Design Decisions.

**STOP for your review.** Ready to proceed to Phase 2 — drafting the three leaf LLDs (change-store, delivery, browser-sync) with their WebSocket-specific responsibilities.