## Phase 1: HLD Review

Added `docs/decisions/self-hosted-websocket-delivery.md` and linked it from `docs/high-level-design.md`.

The decision record lets a new reader re-evaluate the choice using the relevant criteria:

- Low-latency updates during market operations
- Provider independence
- Connection and recovery operations workload
- Repeated unchanged-state read load

It describes five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service in full, then records why self-hosted WebSockets are selected and the resulting obligations for change storage, delivery, and browser sync.

Please approve this Phase 1 HLD and decision-record update before I draft the change-store design node.