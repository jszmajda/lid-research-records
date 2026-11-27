I wrote the decision doc at `docs/decisions/committed-change-delivery.md`, and the HLD's Key Design Decisions row now links to it.

The doc covers:
- **Context:** why the delivery route matters and why it is decided at the HLD, before the three nodes exist.
- **Criteria:** latency, vendor coupling and cost, read load, recovery after a 20-minute disconnect, and operational burden, each weighted major or moderate.
- **Options:** polling, self-hosted WebSockets, and a hosted realtime service, each described as its advocate would describe it and scored against the criteria.
- **Selection:** WebSockets, and why. The doc says plainly that the team accepts the connection operations work.
- **Consequences:** what the choice rules out, what the change store, delivery, and browser sync nodes must now do, and the conditions that would reopen the decision.

Three things to check:
- **Revocation gap:** access denies a user's next command after their assignment is revoked, but says nothing about open WebSocket subscriptions. The doc lists this as a gap for the delivery design to close.
- **Tenet still open:** the main driver, vendor independence, is not a tenet yet. The doc says so. Your answer to the earlier tenet question would settle it.
- **Staged file:** `git status` shows `docs/high-level-design.md` as staged. I did not stage anything, so check that before committing.