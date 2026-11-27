Decision documented.

Created `docs/decisions/delivery-approach.md` with a full decision record that a new reader can re-run. It sets the context, gates and weighted criteria, describes each option with an honest strongest representation and analysis per element, and records the selection of self-hosted WebSockets with implications.

The HLD is updated:
- Approach now states committed changes are delivered over self-hosted WebSockets with server-side session management, replayable revisions, and reliable publication.
- Architecture notes for Change store, Delivery, and Browser sync are aligned to WebSocket delivery.
- Key Design Decisions references the decision doc: `docs/decisions/delivery-approach.md`.

The record explains why vendor independence and subsecond updates outweigh the accepted operational burden of connection capacity and reconnect handling, and it names the tenets the decision turns on.

Ready to proceed to Phase 2 — LLD check/draft for the three nodes: change-store, delivery, and browser-sync. Confirm you want to continue with those LLDs?