A full decision doc would be overkill. 

Under the earns-its-place heuristic, we evaluate the landed state looking forward:
1. **Inherited constraints settle it**: The HLD already mandates that kiosks operate without network access and resolve all lookups from local files, which eliminates remote services by definition.
2. **Local blast radius**: The choice affects only the internal implementation of the registry node; the interface consumed by `certificates` remains unchanged.
3. **The table row suffices**: A cold reader wondering why SQLite was chosen has the rationale right in the LLD's Decisions & Alternatives table. Full decision docs are reserved for choices that remain genuinely contested across criteria and across nodes.