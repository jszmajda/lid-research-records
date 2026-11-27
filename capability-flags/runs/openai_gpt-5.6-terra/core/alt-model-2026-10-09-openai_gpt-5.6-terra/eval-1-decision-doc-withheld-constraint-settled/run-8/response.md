## Phase 1: HLD Check

The selected local embedded SQLite index is coherent with the existing HLD. It remains an internal Registry implementation choice: the HLD already requires kiosk-local lookup, USB-only updates, atomic preservation of the prior snapshot on failed imports, and a storage boundary between Registry and Certificates. No HLD change is needed.

The Registry LLD will record the backend selection and its alternatives:

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Registry lookup backend | Local embedded SQLite index rebuilt and validated on each signed snapshot import | On-site HTTPS directory; managed search service | Provides predictable local lookup without a service, network dependency, credentials, recurring cost, or a change to the certificate-facing registry interface. |

Please approve the Phase 1 HLD check so I can draft the Registry LLD update in Phase 2.