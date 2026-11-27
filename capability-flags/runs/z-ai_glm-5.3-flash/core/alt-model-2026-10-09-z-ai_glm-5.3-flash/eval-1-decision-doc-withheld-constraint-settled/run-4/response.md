I've recorded your SQLite selection and finished the registry design. Both phase outputs are below for your review — this is the stop before any test or code work.

## What changed

**`docs/intent/registry/registry-design.md`** — the backend decision is closed in the LLD, which owns its substance:

- **Architecture**: lookup backend is a local embedded SQLite index per kiosk, built from each validated snapshot. `findBySerial` and its result types are untouched, so nothing changes for certificates.
- **Snapshot Import** is now three stages: validate (unchanged), build (validated records materialized into a *new* index file in a staging location), activate (atomic rename into place, then retire the old file). This makes the "no partially imported records" guarantee structural rather than procedural — a failed import just discards the staging file.
- **Lookup Behavior**: the snapshot date now comes from a metadata row inside the index, so a result always carries the date of the snapshot actually queried; in-flight lookups keep serving from the previous index until activation completes.
- **Decisions & Alternatives**: two rows — the backend choice (HTTPS directory rejected for lab-network dependence and timeout handling; managed service rejected for cost, credentials, and external connectivity — both conflict with the no-runtime-network tenet) and index-per-snapshot-over-in-place-updates. I did not offer a standalone decision doc: once landed, the no-network tenet makes the choice read as settled, so a table row is the right record.

**`docs/high-level-design.md`** — one line: the registry entry no longer says the backend "remains open."

## New specs (draft, Phase 3)

- **REG-005**: While a snapshot import is in progress, the system SHALL serve lookups from the previously active snapshot index or, where no previous snapshot has ever been activated, report that no registry snapshot is available.
- **REG-006**: If the active registry snapshot index cannot be opened, the system SHALL report a lookup error rather than returning a Found or NotFound result.

REG-001 through REG-004 are unchanged — they were deliberately backend-neutral and still hold verbatim.

## Consistency report

- **Coverage**: the staged-build/atomic-rename mechanism now backs REG-003/REG-004 directly; no LLD behavior lacks a spec except the two probe gaps below.
- **Contradiction**: none — new specs are additive to the existing four.
- **Implicit scoping**: REG-005 explicitly names the never-imported case so it can't be read as assuming a prior snapshot exists.
- **Context-free reading**: the specs don't mention SQLite at all — they hold even if the backend ever changed, which matches the fixed-interface intent.

## Edge-case probe — please triage

1. **Disk-full during index build**: staging fails, previous snapshot stays active — I'd treat this as already covered by the import design, but it could earn its own spec if you want it tested.
2. **Retention of retired index files**: keep-one vs. keep-several — recorded as a deferred decision; say the word if you want it pinned now.
3. **REG-006 scope**: should an unreadable active index also surface a repair/re-import prompt to the kiosk operator, or is a plain lookup error enough?

**Please review the updated LLD and the two new specs** — approve as-is, or give me numbered changes. On your approval I'll continue with the intent-narrowing edge audit, then tests-first, before any code.