The architectural decision is now documented in [`docs/decisions/committed-change-delivery.md`](docs/decisions/committed-change-delivery.md) and linked from the HLD.

It records:

- The scale, freshness, recovery, and authority constraints.
- The weighted criteria: latency, provider independence, operational burden, recurring cost, and request efficiency.
- Full comparisons of five-second polling, self-hosted WebSockets, and hosted realtime.
- Why provider independence and low-latency delivery outweigh the additional socket operations.
- The resulting obligations for change storage, delivery, and browser synchronization.

`git diff --check` passes.

Please approve this HLD decision so I can proceed to the three nodes. Also, may I correct the stale “still-open change-delivery approach” wording in `docs/intent/access/access-design.md` during that cascade?