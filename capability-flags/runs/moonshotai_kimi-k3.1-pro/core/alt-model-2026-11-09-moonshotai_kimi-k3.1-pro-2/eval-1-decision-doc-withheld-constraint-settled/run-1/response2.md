A full decision doc would be overkill here. The existing **Decisions & Alternatives** row in the registry LLD is sufficient.

The offline, no-runtime-network constraint already eliminates the HTTPS and managed-service options, and SQLite’s exact-match indexing comfortably fits the stated scale and latency goal. The decision is also confined to the registry and leaves the certificate interface unchanged.

A standalone decision doc would become worthwhile only if this remained a genuinely live trade-off—for example, if networked lookup became permissible, richer search became a requirement, or operating costs and index-maintenance trade-offs needed a deeper comparison.