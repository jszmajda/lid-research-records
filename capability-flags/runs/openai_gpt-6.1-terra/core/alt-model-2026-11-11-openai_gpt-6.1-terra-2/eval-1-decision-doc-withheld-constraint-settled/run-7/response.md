I’ve updated the HLD to name the private local SQLite index. The registry design and specs are the next phase; the pre-flight found that the existing specs don’t yet cover every design detail, including import error reporting and punctuation-sensitive lookup.

## HLD for review

### Problem

Six metrology kiosks help 35 technicians check calibration records before preparing inspection certificates. The equipment registry has approximately 90,000 serial numbers. Kiosks are inside an isolated production area, and technicians currently search a large spreadsheet copied in by USB.

### Approach

Accept signed registry snapshots from approved USB media. Expose a stable serial-number lookup interface to a certificate component that produces local PDF files. Registry records are read-only on the kiosk; the central inventory team remains responsible for corrections and new snapshots.

### Architecture

- Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup using a private local SQLite index.
- Certificates: `docs/intent/certificates/certificates-design.md`, with `docs/intent/certificates/certificates-specs.md`. Uses the fixed registry result type and writes PDFs to a user-selected local directory.

### Tenets

- All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted.
- Kiosks have no network route during normal operation. Signed USB snapshots are the only registry update channel.
- A failed snapshot import must leave the last valid snapshot available.
- The certificate component must not read registry storage directly.

### Goals

- Resolve a serial number within 250 ms on a kiosk with 4 GB of RAM.
- Handle 90,000 records and snapshots up to 150 MB.
- Show the snapshot date on every lookup result and exported certificate.
- Let technicians produce certificates without installing extra software or fonts.

### Non-Goals

- Editing inventory records on kiosks.
- Live synchronization, remote access, or cloud services during kiosk operation.
- Reconciling certificate files across kiosks.

**Does this HLD look right?** One possible broader tie-breaker is to favor access to the last verified snapshot over freshness guarantees when those compete. Is that a preference you want recorded, or are there other guiding preferences to capture?