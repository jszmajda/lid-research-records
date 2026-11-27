A separate decision doc would be overkill. The choice is private to the registry, and the existing offline constraint rules out both network-dependent alternatives during normal operation.

I’d record it in the registry design’s **Decisions & Alternatives** table: SQLite keeps lookup local and predictable, at the cost of validating and rebuilding an index on each kiosk.

Do you approve the HLD direction above? And should the project generally favor keeping verified data available over making newer data available as quickly as possible?