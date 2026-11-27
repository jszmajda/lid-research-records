A standalone decision doc would be overkill here.

A row in the registry LLD’s **Decisions & Alternatives** table is enough: a future reader might reasonably ask “why SQLite?”, but the rationale fits in one line—offline kiosk operation is a hard constraint, and SQLite provides predictable local lookups without adding a service or external credentials.

The decision is also confined to the registry’s private backend; the certificate interface and other components stay unchanged. A full decision doc would become worthwhile only if this choice drove broader architecture or left a genuinely live, multi-criteria tradeoff that future maintainers would need to re-evaluate.