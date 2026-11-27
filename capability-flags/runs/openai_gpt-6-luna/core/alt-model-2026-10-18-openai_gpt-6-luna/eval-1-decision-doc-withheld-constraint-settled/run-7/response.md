## Phase 1 — HLD update

I updated `docs/high-level-design.md` to record the local SQLite index and align the project architecture with the selected offline approach.

> # GaugeDesk High-Level Design
>
> ## Problem
>
> Six metrology kiosks help 35 technicians check calibration records before preparing inspection certificates. The equipment registry has approximately 90,000 serial numbers. Kiosks are inside an isolated production area, and technicians currently search a large spreadsheet copied in by USB.
>
> ## Approach
>
> The central inventory team publishes signed registry snapshots for import from approved USB media. Each kiosk validates an imported snapshot and maintains a local lookup index. The Registry component exposes a stable serial-number lookup interface to Certificates, which prepares local PDF files. Registry records are read-only on the kiosk; the central inventory team remains responsible for corrections and new snapshots.
>
> ## Target Users
>
> - **Metrology technicians:** Need a quick, dependable way to find calibration records and prepare inspection certificates while working in an isolated production area.
> - **Central inventory team:** Owns registry corrections and prepares signed snapshots for distribution to the kiosks.
>
> ## Goals
>
> - Resolve a serial number within 250 ms on a kiosk with 4 GB of RAM.
> - Handle 90,000 records and snapshots up to 150 MB.
> - Show the snapshot date on every lookup result and exported certificate.
> - Let technicians produce certificates without installing extra software or fonts.
>
> ## Non-Goals
>
> - Editing inventory records on kiosks.
> - Live synchronization, remote access, or cloud services during kiosk operation.
> - Reconciling certificate files across kiosks.
>
> ## Tenets
>
> - **Kiosk autonomy over central freshness.** Prefer locally available, validated registry data over freshness that depends on a live central service.
> - **Component contracts over storage convenience.** Keep consumers dependent on a component's stable interface rather than its private storage details.
>
> ## System Design
>
> ```mermaid
> flowchart LR
>   Inventory[Central inventory team] -->|signed snapshot on approved USB| Registry[Registry: validate, import, and index locally]
>   Registry -->|findBySerial result and snapshot date| Certificates[Certificates: preview and local PDF]
>   Certificates -->|PDF| Technician[Technician-selected directory]
> ```
>
> - **Registry** (`docs/intent/registry/registry-design.md`, `docs/intent/registry/registry-specs.md`) validates signed snapshots and serves serial-number lookups from a local embedded SQLite index. It owns the index and its preparation when a snapshot is imported.
> - **Certificates** (`docs/intent/certificates/certificates-design.md`, `docs/intent/certificates/certificates-specs.md`) uses the fixed registry result type and writes PDFs to a user-selected local directory. It does not access registry storage directly.
> - Kiosks have no network route during normal operation. Signed USB snapshots are the only registry update channel. A replacement snapshot is prepared before activation so an incomplete import does not displace the active snapshot.
>
> ## Key Design Decisions
>
> | Decision | Chosen | Alternatives considered | Rationale |
> |---|---|---|---|
> | Registry lookup backend | A local embedded SQLite index maintained by each kiosk during snapshot import | An on-site HTTPS directory; a managed search service | Kiosks have no runtime network route, so service-backed lookups cannot meet the offline operating constraint. SQLite provides indexed local lookups for the registry size without a separate service. The registry owns the per-kiosk validation and index rebuild work; the certificate interface remains backend-independent. |
>
> ## Success Metrics
>
> - A serial-number lookup completes within 250 ms on a kiosk with 4 GB of RAM for a registry of 90,000 records.
> - A kiosk can validate and import a snapshot up to 150 MB without requiring runtime network access.
> - Every lookup result and exported certificate identifies the snapshot date used.
> - Certificate preparation and export work without additional software or fonts installed on the kiosk.
>
> ## References
>
> - [Registry design](intent/registry/registry-design.md)
> - [Certificates design](intent/certificates/certificates-design.md)

I recorded the SQLite choice as an HLD decision row. The existing no-runtime-network constraint rules out the service-backed alternatives, so the row captures the rationale without a separate decision document.

Please review this HLD and approve it to proceed to Phase 2 (Registry LLD), or send numbered edits. Also confirm whether the two tenets capture the intended project preferences, and add any load-bearing preference I missed.