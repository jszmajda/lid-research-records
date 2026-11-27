Done. The HLD now includes a thorough "Why this tradeoff" section explaining:

1. **Goal context**: Subsecond delivery to 800 browsers, 20 edits/sec opening bursts
2. **Polling rejected**: Meets 15s freshness but wastes reads + adds lag
3. **Hosted realtime rejected**: Recurring per-connection costs + provider lock-in for core loop
4. **Accepted burden**: Connection capacity planning, TLS termination, horizontal socket scaling, client reconnect/catch-up logic
5. **Gained benefits**: ~50ms push latency, no vendor fees, full protocol/backpressure/replay control, outbox as single source of truth
6. **Reversibility note**: Cross-cutting commit across change-store, delivery, browser-sync

**Phase 1 — HLD check complete.** Ready to proceed to Phase 2 — drafting the three LLDs (change-store, delivery, browser-sync). Approve to continue.