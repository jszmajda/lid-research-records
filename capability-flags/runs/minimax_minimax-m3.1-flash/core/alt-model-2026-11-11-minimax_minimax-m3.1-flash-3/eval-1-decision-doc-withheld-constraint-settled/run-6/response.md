The registry design is finished on the local embedded SQLite index. Changed: `docs/high-level-design.md:13` (backend named, no network service), `docs/intent/registry/registry-design.md` (rewritten), `docs/intent/registry/registry-specs.md` (REG-001…REG-020).

**What the design now says**
- One SQLite index per kiosk, built by that kiosk from the snapshot it activates; it is the only read path, and the registry never touches the lab network.
- Import = validate (signature covering record content → schema version → snapshot date → records → canonical duplicates) → build to a temp path in one transaction → atomic rename over the active index → old index and superseded snapshot removed. Any failure, including power loss or full disk, leaves the previous snapshot and index serving.
- Lookups: canonical form (trim, uppercase ASCII A–Z only) on both import and query, exact-match primary-key point query, snapshot date stored in the index and taken from the snapshot rather than the kiosk clock, 250 ms at 90,000 records.
- Recorded as Decisions & Alternatives rows: backend, atomic activation, canonicalization, retained snapshot on kiosk. I did not write a standalone decision doc — the "no runtime network access" tenet already excludes the network options, so a table row settles it. Say the word if you want the full doc instead.

**Two forks the edge audit left open — I need your call before touching the certificates segment**
1. "No snapshot available" (kiosk never imported, or index missing/unreadable): a third `findBySerial` result variant, a distinct error raised by the registry, or a certificates-side "blocked, no snapshot imported" state? REG-008 is deliberately shape-neutral until you pick.
2. Index loss recovery: rebuild automatically from the retained snapshot at kiosk start, an operator-triggered rebuild action, or wait for a fresh import (retained snapshot then only archival)?

One default I chose that you may want to reverse: the serial in a returned record is the canonical (uppercase) form, not the snapshot's original spelling.

**Certificates segment findings I did not touch** (cross-segment, needs your go-ahead): the exported PDF's required content is unpinned (the HLD goal "snapshot date on every exported certificate" has no spec behind it), overdue is judged against the kiosk clock while the rest of the system distrusts that clock, and the tenet "the certificate component must not read registry storage directly" has no test or spec enforcing it.

Phases 5–6 are not started: the repo holds design docs only, so tell me the kiosk runtime/language for the registry implementation and I'll run the tests-first pass against REG-001…REG-020.