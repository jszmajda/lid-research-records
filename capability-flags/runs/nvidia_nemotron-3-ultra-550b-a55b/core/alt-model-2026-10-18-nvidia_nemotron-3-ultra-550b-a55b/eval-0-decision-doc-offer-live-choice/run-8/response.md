Updated the HLD to record the self-hosted WebSockets decision. The Approach, Architecture, and Key Design Decisions sections now reflect this choice.

**Phase 1 — HLD check complete.** The HLD now records:
- **Approach**: Self-hosted WebSockets for subsecond updates, accepting connection/reconnect complexity to avoid vendor fees
- **Architecture**: Three downstream nodes (change-store, delivery, browser-sync) with clarified responsibilities
- **Key Design Decision**: Self-hosted WebSockets chosen over polling and hosted realtime

Ready for your review. Approve to proceed to Phase 2 — drafting LLDs for the three nodes (change-store, delivery, browser-sync).