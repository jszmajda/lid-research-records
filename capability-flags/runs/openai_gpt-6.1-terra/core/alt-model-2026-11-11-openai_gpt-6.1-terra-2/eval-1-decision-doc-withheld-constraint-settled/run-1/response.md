I updated `docs/high-level-design.md` to select the local embedded SQLite index. The certificate interface remains unchanged.

## High-level design for review

# GaugeDesk High-Level Design

## Problem

Six metrology kiosks help 35 technicians check calibration records before preparing inspection certificates. The equipment registry has approximately 90,000 serial numbers. Kiosks are inside an isolated production area, and technicians currently search a large spreadsheet copied in by USB.

## Approach

Accept signed registry snapshots from approved USB media. Expose a stable serial-number lookup interface to a certificate component that produces local PDF files. Registry records are read-only on the kiosk; the central inventory team remains responsible for corrections and new snapshots.

## Architecture

- Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup using a private local embedded SQLite index.
- Certificates: `docs/intent/certificates/certificates-design.md`, with `docs/intent/certificates/certificates-specs.md`. Uses the fixed registry result type and writes PDFs to a user-selected local directory.

## Tenets

- All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted.
- Kiosks have no network route during normal operation. Signed USB snapshots are the only registry update channel.
- A failed snapshot import must leave the last valid snapshot available.
- The certificate component must not read registry storage directly.

## Goals

- Resolve a serial number within 250 ms on a kiosk with 4 GB of RAM.
- Handle 90,000 records and snapshots up to 150 MB.
- Show the snapshot date on every lookup result and exported certificate.
- Let technicians produce certificates without installing extra software or fonts.

## Non-Goals

- Editing inventory records on kiosks.
- Live synchronization, remote access, or cloud services during kiosk operation.
- Reconciling certificate files across kiosks.

---

The existing registry specs cover some import failures but do not yet cover every failure implied by the design; I’ll address that during the registry design and specification phases.

1. Do you approve this high-level design?
2. For future tradeoffs, should GaugeDesk favor predictable lookup speed over minimizing local disk usage, or lean differently? Are there other tie-breakers you’d like recorded?