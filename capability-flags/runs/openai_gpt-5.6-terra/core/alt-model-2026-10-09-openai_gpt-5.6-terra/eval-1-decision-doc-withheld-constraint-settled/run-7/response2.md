A full decision document would be overkill here.

The HLD already rules out the networked alternatives during normal kiosk operation, so the choice is mostly settled by an inherited constraint rather than a live architectural trade-off. The registry LLD's Decisions & Alternatives row preserves the remaining rationale: SQLite provides indexed local lookups while keeping snapshot validation and index lifecycle inside the registry.

A decision document would become appropriate if the project later permits networked kiosk operation or introduces a credible local alternative with materially different recovery, deployment, or performance characteristics.