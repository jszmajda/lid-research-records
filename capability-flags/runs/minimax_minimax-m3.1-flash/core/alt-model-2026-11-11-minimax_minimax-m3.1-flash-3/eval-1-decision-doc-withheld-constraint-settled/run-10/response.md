**Phase 1 + Phase 2 done — review needed before I write the EARS specs.**

**HLD** (`docs/high-level-design.md:13`): registry now reads "Owns snapshot validation, the local lookup index, and serial-number lookup… served from a local embedded SQLite index the registry builds and maintains on the kiosk."

**Registry LLD** (`docs/intent/registry/registry-design.md`) — rewritten around the SQLite choice:

- **Storage**: `active` pointer file (single atomically replaced state), content-addressed `payload/<digest>.snapshot` and `index/<digest>.sqlite`, plus a build file swept at startup.
- **Import**: signature → schema version → streamed NDJSON validation → build index (records, then `meta`, commit, fsync) → retain payload → one atomic pointer replacement. Any failure leaves the previous snapshot fully active.
- **Startup recovery**: rebuild the index from the retained payload when the index is missing/unreadable/format-mismatched; no USB needed.
- **Lookup**: normalize (trim, ASCII-uppercase) → open the index read-only → one primary-key query → return the snapshot's own date, even for NotFound.
- **Decisions table**: 11 rows (backend, activation, retention, uniqueness on normalized serials, normalization, ISO dates, snapshot-date source, streaming build, index-format version, per-lookup connection, local SHA-256 digest) with the rejected alternatives and rationale.

The edge-case probe (delegated, clean reader) returned ~70 gaps. I closed the one-answer ones myself: crash/fsync ordering, temp-file sweeping, file-naming conventions, malformed-record and date validation, serial type/whitespace/non-ASCII rules, single shared normalization across write/rebuild/read, disk-space pre-check, import serialization, `meta`-row ordering, stream parsing, and required-field enumeration.

**Five calls are yours:**

1. **No active snapshot yet (or unusable index) — what does `findBySerial` return?** (a) add `Unavailable(reason)` to the result type — certificates must then distinguish it from NotFound, so this crosses into the certificates segment and I'd pause there to cascade; (b) keep the two-variant result type and surface unavailability as an error outside it; (c) return NotFound (misleading — a technician would think the serial doesn't exist). I recommend (a).
2. **A snapshot older than the active one:** reject it (protects against a stale USB stick rolling the kiosk back) or accept any validly signed snapshot (the central team is authoritative)? I recommend rejecting, with an error naming both dates.
3. **A snapshot with zero records:** reject as malformed, or accept as "everything retired"? I recommend rejecting.
4. **Performance envelope:** I plan a spec that a lookup returns within 250 ms and that imports don't degrade lookups beyond that. Should the index build also have a time bound (e.g. ≤ 60 s for 90,000 records), or is it left unbounded?
5. **Caps:** I plan to reject snapshots above 90,000 records or 150 MB (the HLD's stated capacity). Confirm, or set looser limits?

On your answer I'll write the EARS specs (roughly REG-005 onward: atomic activation, payload retention, startup rebuild, local-only lookup, 250 ms lookup, normalized-uniqueness rejection, failed-import retention) and then the tests.