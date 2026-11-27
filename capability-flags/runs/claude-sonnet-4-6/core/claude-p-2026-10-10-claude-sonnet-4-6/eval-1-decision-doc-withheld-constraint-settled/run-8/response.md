Now let me compose the Phase 2 stop with the LLD, HLD change summary, and the edge-case probe.

---

## Phase 2 stop — Registry LLD

**Coherence pre-flight**: existing REG-001–004 trace to current LLD behaviors (normalization, snapshot date in result, import rejection, atomic activation). No drift detected. HLD tenets (files-only lookup, USB-only update channel, failed import leaves prior snapshot active) are all satisfied by SQLite.

---

### HLD update (minor)

Removed the "Its private lookup backend remains open" note from `docs/high-level-design.md`. Replaced with "Uses a local embedded SQLite index."

---

### Updated registry LLD — `docs/intent/registry/registry-design.md`

The full doc is on disk. Summary of what changed from the sketch:

**Index Structure** — Two-table schema: `equipment` (serial_normalized PK, serial_original, description, calibration_date, due_date) and `snapshot_meta` (snapshot_date, schema_version). WAL mode for non-blocking reads.

**Snapshot Import** — Three stages: validate (signature + schema version + duplicate serial_normalized + required fields), build into `snapshot.db.staging`, activate via rename. Crash before rename leaves the previous snapshot active; crash after leaves the new one active. Staging file cleaned up at the start of the next import.

**Lookup Behavior** — Normalize on ingest (stored as primary key), so `findBySerial` is a direct primary-key scan joining `snapshot_meta` for the date. Non-ASCII characters and punctuation left as-is.

**Decisions & Alternatives** — Records the SQLite selection and its rationale against the alternatives, the staging rename strategy, normalized-at-ingest choice, WAL mode, and required-field validation at import.

---

### LLD-level edge-case probe

Four genuine gaps found in this LLD. These are for your triage — fix in LLD, defer, or add a spec:

1. **No-snapshot startup state.** `findBySerial` returns `NotFound(snapshotDate)`, but when no `snapshot.db` exists yet (first kiosk setup, factory reset), there is no snapshot date to return. The interface type doesn't cover this. Options: a third result variant (`NoSnapshot`), an initialization gate that rejects calls until a snapshot is imported, or a documented sentinel value for the date.

2. **Concurrent import guard.** Two simultaneous imports both write to the single path `snapshot.db.staging`. The LLD says nothing about whether concurrent imports are prevented or how they interact. Is this process-level (single process, serial queue) or does the registry need an explicit lock?

3. **Rename failure cleanup boundary.** The LLD says staging is deleted "if anything fails *before* the rename." What if the rename itself fails (permissions error, cross-device path)? That is neither "before" nor "after" — `snapshot.db.staging` could be left with no cleanup path described. Does a rename failure count as "import failed, delete staging"?

4. **Required-fields enumeration.** "Any record missing a required field" is used as a rejection criterion, but the five required fields aren't named. An implementer could reasonably treat `due_date` as optional (some equipment has no calibration expiry). Is every column in `equipment` required, or are any nullable?

I ran this probe in-context; a subagent read from only the LLD text would have been slightly less biased, but the LLD is tight enough that I'm confident the above are the real gaps. Let me know if you want me to confirm with a blind pass.

---

Ready for your review. How would you like to resolve the four gaps, and does the LLD otherwise look right to you?