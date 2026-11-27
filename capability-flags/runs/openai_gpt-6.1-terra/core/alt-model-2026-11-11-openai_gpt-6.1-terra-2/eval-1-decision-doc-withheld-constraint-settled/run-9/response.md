I’ve recorded the SQLite choice in `docs/high-level-design.md`. The network-backed options conflict with the existing offline requirement, so a separate decision document doesn’t appear necessary.

## HLD for review

### Problem

Six metrology kiosks help 35 technicians check calibration records before preparing inspection certificates. The equipment registry has approximately 90,000 serial numbers. Kiosks are inside an isolated production area, and technicians currently search a large spreadsheet copied in by USB.

### Approach

Accept signed registry snapshots from approved USB media. Expose a stable serial-number lookup interface to a certificate component that produces local PDF files. Registry records are read-only on the kiosk; the central inventory team remains responsible for corrections and new snapshots.

### Architecture

- **Registry:** `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup using a private local embedded SQLite index.
- **Certificates:** `docs/intent/certificates/certificates-design.md`, with `docs/intent/certificates/certificates-specs.md`. Uses the fixed registry result type and writes PDFs to a user-selected local directory.

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

The registry design still says its backend is open; I’ll update it after this HLD review.

**Do you approve the HLD change?** The existing “Tenets” are concrete operational constraints rather than general tie-breakers: is there a broader trade-off preference you’d like to add? For subsequent reviews, would you prefer to inspect each phase yourself or authorize an independent inspector?