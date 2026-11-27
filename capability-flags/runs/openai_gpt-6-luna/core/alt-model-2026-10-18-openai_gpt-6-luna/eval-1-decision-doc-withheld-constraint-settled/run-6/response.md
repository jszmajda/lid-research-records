I recorded the selected local SQLite index in the HLD and updated the architecture to reflect that the registry owns index preparation and activation. The former “Tenets” are now stated as constraints, since they describe fixed operating conditions and component boundaries. The backend choice is recorded in the HLD’s Key Design Decisions table; the existing offline constraint makes a separate decision document unnecessary.

## Updated HLD

```markdown
# GaugeDesk High-Level Design

## Problem

Six metrology kiosks help 35 technicians check calibration records before preparing inspection certificates. The equipment registry has approximately 90,000 serial numbers. Kiosks are inside an isolated production area, and technicians currently search a large spreadsheet copied in by USB.

## Approach

Accept signed registry snapshots from approved USB media. The registry validates each snapshot, builds a local embedded SQLite index, and activates the replacement only after it is fully prepared. A failed import leaves the last valid snapshot available. Expose a stable serial-number lookup interface to a certificate component that produces local PDF files. Registry records are read-only on the kiosk; the central inventory team remains responsible for corrections and new snapshots.

## Architecture

- Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation, local SQLite index preparation, activation, and lookup.
- Certificates: `docs/intent/certificates/certificates-design.md`, with `docs/intent/certificates/certificates-specs.md`. Uses the fixed registry result type and writes PDFs to a user-selected local directory.

## Constraints

- Kiosks have no network route during normal operation; lookups use files on the kiosk, and signed USB snapshots are the only registry update channel.
- The certificate component accesses registry data only through the registry lookup interface.

## Goals

- Resolve a serial number within 250 ms on a kiosk with 4 GB of RAM.
- Handle 90,000 records and snapshots up to 150 MB.
- Show the snapshot date on every lookup result and exported certificate.
- Let technicians produce certificates without installing extra software or fonts.

## Non-Goals

- Editing inventory records on kiosks.
- Live synchronization, remote access, or cloud services during kiosk operation.
- Reconciling certificate files across kiosks.

## Key Design Decisions

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Registry lookup backend | A local embedded SQLite index maintained by the registry on each kiosk | On-site HTTPS directory; managed search service | Kiosks have no runtime network route, so a local index keeps lookups available without a service dependency. The registry owns per-kiosk index validation and rebuilding when signed snapshots arrive; the lookup interface used by certificates remains unchanged. |
```

Please approve this HLD or provide numbered corrections. I’ll stop here for your review before drafting the registry LLD.