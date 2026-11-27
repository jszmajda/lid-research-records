Phase 1 and Phase 2 are drafted and the edge-case probe is back. Here is where the registry design stands, and where I need your calls.

**Phase 1 — HLD (edited, needs your approval)**

`docs/high-level-design.md` architecture bullet changed from "Its private lookup backend remains open" to: each kiosk keeps a local embedded SQLite index, rebuilt from the snapshot it imports, and serves lookups from that index alone. No other HLD change — the no-network tenet already covers the choice, so nothing in the tenet list or goals moved. The certificates segment is untouched: the registry interface is unchanged, so no cascade there.

**Phase 2 — Registry LLD (rewritten, needs your approval)**

`docs/intent/registry/registry-design.md` now specifies the design instead of naming candidates:

- **Storage layout** — one kiosk-local directory holding `active.json` (pointer: snapshot date, index file name, record count), `index-<snapshot date>.sqlite3`, and a `.building` file that exists only during an import.
- **Schema** — `records(serial_key PRIMARY KEY, serial, description, calibration_date, due_date)` plus a `metadata` table (snapshot date, schema version, record count). `serial_key` is the whitespace-trimmed, ASCII-uppercased serial, so a lookup is one indexed seek and duplicate detection covers exactly the serials a lookup can find. The original serial is kept for display.
- **Import** — signature, then schema version, then parse/validate, then build into the temp file in one transaction, then verify record count and a spot-check of serials, then rename the file, then swap the pointer, then delete the superseded index. Any failure before the pointer swap leaves the previous snapshot active.
- **Decisions & Alternatives table** added, recording the backend choice (with the on-site directory and managed service named as set aside, since kiosks have no network route and the managed service adds recurring cost for an unchanged certificate interface), full rebuild per snapshot, normalized primary key, pointer-swap activation, and deleting the superseded index.
- I did not open a decision doc for the backend choice: with the HLD's no-network tenet in place, a cold reader finds the local index the settled answer, so a Decisions row carries it.

**Phase 2 probe — gaps the LLD leaves open (your triage)**

A fresh reader with only the LLD produced these; they are the ones that could land two different ways:

1. *Result shape* — `findBySerial` has only Found/NotFound. What does it return when there is no `active.json` yet, when the pointer is malformed, when the index file it names is missing, or when the SQLite file is corrupt? Import failures have no stated surface either.
2. *Activation ordering* — the rename happens before the pointer swap, so if the new snapshot carries the same date as the active one, the rename overwrites the live index file and the "failure leaves the previous index untouched" invariant breaks.
3. *Crash between steps* — dying after the rename but before the pointer swap orphans a complete index file; dying before the cleanup leaves a superseded file. Neither has a defined cleanup path.
4. *Cleanup failure* — a superseded or leftover file that cannot be deleted: import failure, warning, or ignored?
5. *Concurrent imports* — two imports would collide on the same `.building` name.
6. *Lookup/import race* — the lookup reads the pointer and then opens the file; the "own read-only handle" claim only covers the window after the open. The text asserts the race is harmless without saying what makes it harmless.
7. *Signature coverage* — does the signature cover the record file only, or also the schema version and snapshot date? A tampered snapshot date would otherwise be trusted.
8. *Bundle shape* — the signature manifest's expected form, a missing manifest, a manifest naming a file outside the bundle, and a partially copied bundle.
9. *Record validation* — malformed NDJSON lines (which line is reported; blank line, BOM, invalid UTF-8, non-object JSON), and whether "required field" means present, non-empty, or non-null (a null calibration date would fail at the SQL constraint instead, with a different error shape).
10. *Date fields* — `calibration_date` and `due_date` are stored as text with no format rule; an empty string satisfies NOT NULL, and the certificate preview and overdue warning both read these fields.
11. *Normalization boundary* — "surrounding whitespace" is not pinned to a character set (tab, CR, non-breaking space), and the import-side and lookup-side rules are only stated to be the same by implication.
12. *Empty snapshot* — is a zero-record snapshot valid? If so, the step-6 spot check is vacuous and the count check compares 0 to 0.
13. *Pointer vs metadata* — the snapshot date is stored in both `active.json` and the index `metadata`; which is authoritative when they disagree, given the lookup path reads only the pointer?
14. *Limits* — 150 MB / 90,000 records is stated as reachable, not as a limit; nothing bounds what a snapshot may contain, and during a rebuild the old index, the new index, and the incoming snapshot all coexist on limited kiosk disk.

Which of these should I fix in the LLD now, and which do you want to leave as deferred open questions? I have not touched the EARS specs — they come next (Phase 3), and several of the specs the backend choice implies (index build, activation, lookup against the index) depend on your triage here. Note also that this repo currently holds only design docs, with no source tree or tests yet, so the tests-first and code phases will follow the specs.