Drafted the registry LLD in `docs/intent/registry/registry-design.md` with the selected local SQLite index:

- Each kiosk rebuilds a private SQLite database from an accepted signed snapshot.
- Imports build and validate a staging database, then atomically replace the active database so failed imports preserve the previous snapshot.
- Lookups are read-only local SQLite queries and distinguish an unavailable registry from `NotFound`.
- The LLD records why SQLite was selected over an on-site HTTPS directory and managed search service.

Please review the LLD and resolve these gaps before I draft the EARS specifications:

1. Should serials that become identical after trimming and ASCII uppercasing be rejected as duplicate records? How should empty, non-ASCII, or otherwise malformed serials be handled on import and lookup?
2. What exact snapshot schema is supported: required record fields and types, snapshot-date format, handling of malformed NDJSON, and whether unknown fields are accepted?
3. What registry-unavailable result should the certificate component receive when no active index exists, the index is corrupt, or an I/O/query failure occurs? Should it expose stable reason codes or only a generic unavailable result?
4. What should happen if power fails during activation, an old staging database is found at startup, or two imports are requested at once?
5. May an older or identical signed snapshot replace the active snapshot, or must imports be monotonically newer by snapshot date?

The SQLite decision remains sufficiently non-obvious that a future reader may reconsider it. I recorded a concise decision row in the LLD; would you like a full decision document preserving the option-by-option tradeoffs instead?