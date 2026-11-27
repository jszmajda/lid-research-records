A standalone decision doc would be **overkill**. The choice affects only the registry’s private backend, leaves the certificate interface unchanged, and its rationale fits in one row of the registry LLD’s **Decisions & Alternatives** table:

- **Chosen:** Local embedded SQLite index.
- **Alternatives:** On-site HTTPS directory; managed search service.
- **Rationale:** Preserves offline, predictable lookups without runtime credentials or network dependencies, at the cost of kiosk-side snapshot validation and index rebuilding.

I’ll record it there during Phase 2. Do you approve the HLD update so I can proceed with the registry LLD?