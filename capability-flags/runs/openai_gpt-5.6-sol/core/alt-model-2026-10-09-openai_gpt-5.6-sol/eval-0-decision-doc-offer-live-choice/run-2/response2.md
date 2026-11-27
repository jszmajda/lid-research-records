**Phase 1: Decision Record**
Created `docs/decisions/change-delivery.md` and linked it from the HLD.

The record explains:

- Why change delivery affects the store, delivery service, and browser together.
- The recovery requirement as a non-negotiable gate.
- Freshness, provider independence, operational burden, recurring cost, and implementation complexity as selection criteria.
- How polling, self-hosted WebSockets, and hosted realtime compare against each criterion.
- Why 800 simultaneous browsers makes self-hosting a bounded operational trade.
- The accepted obligations: connection capacity, session health, reconnect behavior, replay, and a race-free transition from catch-up to live delivery.
- Why polling’s simplicity and hosted realtime’s lower operational burden did not outweigh low latency, provider independence, and avoiding recurring vendor fees.

The selection concludes:

> MarketBoard uses self-hosted WebSockets for committed-change delivery. This option best combines low-latency updates with provider independence and avoids both repeated idle polling and a recurring realtime-service dependency. The expected scale of 800 simultaneous browsers makes owning connection capacity a bounded trade rather than an open-ended platform commitment.

`git diff --check` passes.

Do you approve the completed HLD and decision record so I can proceed to the change-store node? Also, may I remove the access node’s stale statement that delivery is “still-open” as part of that cascade?