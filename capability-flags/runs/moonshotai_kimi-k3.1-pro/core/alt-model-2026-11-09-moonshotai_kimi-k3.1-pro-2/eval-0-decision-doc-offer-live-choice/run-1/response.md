Updated `docs/high-level-design.md` to select **self-hosted WebSockets**. The HLD now records:

- Replayable revisions and reliable publication in the change store.
- WebSocket sessions and connection-capacity ownership in delivery.
- Reconnect and revision-based catch-up in browser sync.
- The trade-off rationale, including why polling and hosted realtime were rejected.

The three downstream nodes remain untouched as requested.

Please review the HLD update. Since this architectural choice shapes all three nodes, would you like a standalone decision doc, or is the new **Key Design Decisions** entry sufficient? Once you approve, we can proceed to the three nodes.