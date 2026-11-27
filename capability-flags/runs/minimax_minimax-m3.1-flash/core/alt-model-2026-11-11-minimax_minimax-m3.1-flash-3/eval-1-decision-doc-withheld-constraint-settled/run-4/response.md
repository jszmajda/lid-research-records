Phase 1 and Phase 2 are done. Here's where things stand and what I need from you.

## What changed

**`docs/high-level-design.md`** — the Architecture bullet no longer says the backend is open; it now records that the registry builds a local embedded index on the kiosk from each accepted snapshot and that no lookup crosses a network. The HLD's existing tenet ("All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted") already ruled out the HTTPS directory and managed search service, so this choice was the only admissible one under the current HLD. That also means it isn't a live choice for a cold reader, so I recorded it as a Decisions row in the registry LLD rather than a standalone decision doc.

**`docs/intent/registry/registry-design.md`** — rewritten around the SQLite index: `records` (normalized serial as primary key, plus raw serial, description, calibration date, due date) and `snapshot_meta` (snapshot date, schema version, record count) in one file per snapshot; a pointer file naming the active index; publish-by-atomic-rename with the previous index retained until the replacement is published; lookups served from the active index while a new one builds. A Decisions & Alternatives table records the backend, index lifecycle, lookup key, snapshot-date storage, and the failed-index-read rule.

## One fork I need you to settle before I write the specs

The lookup interface is fixed as `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, but a missing or unreadable index is neither. Two readings:

- **(a) The interface grows a third variant** (e.g. `Unavailable(snapshotDate, reason)`). The certificate node consumes this interface, so this is a cross-segment change — it ripples into `CERT-001`/`CERT-002`, which currently assume Found or NotFound only.
- **(b) The interface stays two-variant and an unreadable index surfaces as a thrown error** the kiosk shell catches and displays, distinct from a NotFound result.

I wrote the LLD to read (b) for now, but I don't want specs and code landing against either reading without you choosing. (b) keeps the certificate interface untouched, which is what your selection implied.

## Edge-case probe — triage needed

The probe found 15 gaps inside the registry LLD. My lean on each is in parentheses; tell me which to fold into the LLD now and which to defer as open questions.

| # | Gap | My lean |
|---|---|---|
| 1 | Uniqueness checked on raw serials or the normalized form — `AB-1` vs `ab-1` | Judge on the normalized form, since lookup normalizes (fix now) |
| 2 | Is a signed, schema-valid snapshot with zero records a valid import that replaces a populated index? | Accept — the signature attests to the inventory state (fix now) |
| 3 | A lookup in flight when the pointer switches — old record or new? | Completes against the snapshot it opened; the pointer is read once per lookup (fix now) |
| 4 | Pointer file missing, empty, or naming a nonexistent index | Error, not NotFound — same rule as an unreadable index (fix now) |
| 5 | Rename succeeds, pointer write then fails (disk full) | Old pointer survives, old snapshot stays active, report the error (fix now) |
| 6 | Power loss mid-publish — can the pointer be left half-written? | Pointer written by temp-file + rename, so it is old or new; startup validates the pointer names an existing index (fix now) |
| 7 | Parsing details: blank lines, CRLF, byte-order mark, trailing newline | Tolerate all four; a genuinely malformed line aborts the build (fix now) |
| 8 | Record schema: required fields, date format, due date earlier than calibration date | State required fields and ISO-8601 dates; a due date before calibration is accepted — overdue is a certificate concern (fix now) |
| 9 | Snapshot date: format, source, what if absent or conflicting | ISO-8601 date from the manifest, required; a conflicting or missing date invalidates the snapshot (fix now) |
| 10 | Is the snapshot copied to kiosk storage before indexing, or read straight off the USB? | Copy to local staging first, so removal of the device mid-read doesn't abort the import (fix now) |
| 11 | An imported snapshot older than the active one | **Your call** — reject it, or activate it and move the displayed snapshot date backwards? |
| 12 | Free-space requirement, and disk filling mid-build | Check free space before building; report the error, keep the old snapshot (fix now) |
| 13 | First lookup after activation, index pages not yet in page cache | Budget applies to lookups against the active index; cold-cache timing verified at implementation (defer) |
| 14 | Bundled public key missing or unreadable; a snapshot signed by a rotated key | Missing key → import error; unknown signer handled as an invalid signature (fix now) |
| 15 | Records with fields beyond the ones indexed — are unknown fields preserved? | Not preserved; the index holds only the indexed columns (fix now) |

Once you answer #11 and the error-shape fork, and confirm the triage, I'll write the Phase 3 EARS specs for the registry (covering the new index lifecycle, activation atomicity, and the error behavior) and then run the intent-narrowing edge audit across the registry and certificate segments.