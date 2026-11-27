The full decision record is in `docs/decisions/realtime-delivery.md` and linked from `docs/high-level-design.md`.

It documents:

- Scale, freshness, recovery, and authoritative-revision context.
- The weighted criteria: provider independence, routine latency, ongoing cost, and operational burden.
- The strongest case and tradeoffs for polling, self-hosted WebSockets, and hosted realtime.
- Why self-hosted WebSockets win despite their operational burden.
- Obligations for change-store, delivery, and browser-sync.
- The distinction between low-latency benefit and the formal 15-second goal.

`git diff --check` passes. No tests were run because this phase changes design documentation only.

Please approve Phase 1 if this captures the decision correctly. After approval, we can begin the three downstream nodes.