A **Decisions & Alternatives row is enough here**.

The deciding factor isn’t how long you debated it, but whether a future reader would need the full comparison to understand the result. GaugeDesk already requires kiosk-local lookups with no runtime network access, so the HTTPS directory and managed service don’t satisfy the existing constraints. The choice also stays private to the registry.

The row captures the useful rationale: SQLite provides indexed local lookup without a service, at the cost of validating and rebuilding on each kiosk.

A standalone doc would earn its place if we were choosing among several viable offline approaches with substantial competing tradeoffs—or reconsidering the offline constraint itself.