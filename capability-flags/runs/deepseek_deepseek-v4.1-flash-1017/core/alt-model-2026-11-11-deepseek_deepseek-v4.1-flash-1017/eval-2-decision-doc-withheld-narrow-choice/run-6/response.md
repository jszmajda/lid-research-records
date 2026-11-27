Phase 2 is drafted in `docs/intent/previews/previews-design.md`, and I closed the HLD's open-eviction note. The design is 2Q over JPEG bytes: A1in (FIFO, first stay, 3 GiB target) and Am (LRU, reused sheets, 9 GiB); new sheets enter A1in, a later request promotes them to Am, and admission drains A1in before Am. The draft also settles incoming-sheet byte counting, single-queue membership, dedup/cache ordering, delivery pinning, and promotion by the render-triggering request. The 25/75 split is recorded as an initial, tunable value.

The LLD edge-case probe surfaced three pre-existing gaps I did not settle on your behalf:

- **Renderer version:** the route has no version selector, while the cache key includes renderer version. Should the worker always render with its current version, with old-version entries simply aging out?
- **Failed render:** the interface has only 200/202/404. Should a failed job keep returning 202 on retry, or is there another intended outcome?
- **Job ticket:** should the ticket be specified as opaque and re-requested at the same URL, or left as an implementation detail?

Please confirm the LLD and answer those three. Also, should the 2Q-vs-LRU-vs-aged-frequency choice be recorded as a full decision doc in `docs/intent/previews/decisions/`, or kept as the Decisions & Alternatives row? Once you approve, I'll move to EARS.