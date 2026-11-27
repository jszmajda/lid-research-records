Decision doc written at `docs/decisions/realtime-delivery-approach.md`. It details the three options (polling, self-hosted WebSockets, hosted service), the criteria (update latency, operational autonomy, implementation complexity, operating cost, failure mode simplicity), and why WebSockets wins — fast updates and cost predictability, accepting connection management complexity.

The HLD's Key Design Decisions row now links to the doc. The updated Approach and Architecture sections describe how the WebSocket choice shapes the three unwritten components (change-store, delivery, browser-sync).

Ready to proceed to those three LLDs, or changes needed here?