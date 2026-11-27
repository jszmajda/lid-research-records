## Phase 1: Decision Record

Added `docs/decisions/committed-change-delivery.md` and linked it from the HLD.

The record documents:

- The operational context: 800 simultaneous browsers, 20 edits per second during opening bursts, reconnect recovery, and seven-day revision retention.
- The selection criteria: prompt delivery, provider independence and predictable cost, and operational feasibility.
- The strongest form of all three options: five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service.
- The selected trade-off: self-hosted WebSockets provide prompt updates and avoid provider coupling and recurring vendor fees, while requiring MarketBoard to own connection capacity, reconnection, revision replay, and reliable publication.

Please approve this Phase 1 HLD and decision record, or request changes. Also confirm whether I should update the stale “still-open change-delivery approach” wording in the separate `ACCESS` segment before drafting the change-store, delivery, and browser-sync nodes.