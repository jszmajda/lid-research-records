Now I'll run Phase 4 — the intent-narrowing edge audit — to probe for divergences between the specs and your latent intent.

## Phase 4: Intent-Narrowing Edge Audit

I've identified plausible divergent readings of the updated specs. Here are the genuine forks for your resolution before tests are written:

### Divergence 1: Snapshot Date on NotFound
**Spec**: REG-LOOKUP-002 says "include the active snapshot date in the result regardless of whether a record was found."

**Divergence**: 
- **Reading A**: Return the snapshot date *of the record* when found; return the date of the *active* database when not found (may be stale).
- **Reading B**: Always return the date of the active database, regardless of whether the lookup succeeds (guarantees the date reflects what was actually queried).

**Question for you**: When a technician gets a NotFound result, should they see the date of the database that was actually queried (Reading B), or the most recent date we have (even if that database didn't contain the serial)? This affects whether a NotFound result plus an old date signals a stale index to the technician.

### Divergence 2: Atomicity Scope During Concurrent Operations
**Spec**: REG-IMPORT-004 says the active pointer "atomically" switches.

**Divergence**:
- **Reading A**: Atomic at the file-system level (rename, symlink swap) — concurrent lookups may see old *or* new database, but never corruption or partial state.
- **Reading B**: Atomic with respect to the entire system — no lookup begins before activation completes, enforcing a strict serialization.

**Question for you**: Can a lookup that starts during import see the old database, or must all lookups wait until import activation finishes? If the kiosk is used while snapshots are being imported, this determines whether concurrent access is safe.

### Divergence 3: Error Reporting Granularity
**Spec**: REG-IMPORT-002 says "report a specific error" for invalid signature, schema, or duplicates.

**Divergence**:
- **Reading A**: One error message per problem category (e.g., "Invalid signature" or "Duplicate serials").
- **Reading B**: Per-record granularity — report which serial is duplicated, or which lines failed schema validation, to help the operator debug their snapshot.

**Question for you**: How specific should error reports be? Should the operator get "Snapshot rejected: 3 duplicate serials" or a list of the duplicates with their serial numbers?

---

**Stop here.** Please resolve these three divergences, and I'll refine the specs accordingly, then present them for another review before moving to tests. Where should the snapshot date come from on NotFound? How should concurrent import/lookup behave? How detailed should errors be?