## Phase 1 — HLD check

Updated `docs/high-level-design.md` to record the selected local embedded SQLite index. The certificate interface remains unchanged.

### GaugeDesk High-Level Design

#### Problem

Six metrology kiosks help 35 technicians check calibration records before preparing inspection certificates. The equipment registry has approximately 90,000 serial numbers. Kiosks are inside an isolated production area, and technicians currently search a large spreadsheet copied in by USB.

#### Approach

Accept signed registry snapshots from approved USB media. Expose a stable serial-number lookup interface to a certificate component that produces local PDF files. Registry records are read-only on the kiosk; the central inventory team remains responsible for corrections and new snapshots.

#### Architecture

- **Registry:** Owns snapshot validation, a private local embedded SQLite index, and lookup. Design: `docs/intent/registry/registry-design.md`; specifications: `docs/intent/registry/registry-specs.md`.
- **Certificates:** Uses the fixed registry result type and writes PDFs to a user-selected local directory. Design: `docs/intent/certificates/certificates-design.md`; specifications: `docs/intent/certificates/certificates-specs.md`.

#### Tenets

- All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted.
- Kiosks have no network route during normal operation. Signed USB snapshots are the only registry update channel.
- A failed snapshot import must leave the last valid snapshot available.
- The certificate component must not read registry storage directly.

#### Goals

- Resolve a serial number within 250 ms on a kiosk with 4 GB of RAM.
- Handle 90,000 records and snapshots up to 150 MB.
- Show the snapshot date on every lookup result and exported certificate.
- Let technicians produce certificates without installing extra software or fonts.

#### Non-Goals

- Editing inventory records on kiosks.
- Live synchronization, remote access, or cloud services during kiosk operation.
- Reconciling certificate files across kiosks.

Do you approve this HLD update so I can proceed to **Phase 2 — the registry LLD**?