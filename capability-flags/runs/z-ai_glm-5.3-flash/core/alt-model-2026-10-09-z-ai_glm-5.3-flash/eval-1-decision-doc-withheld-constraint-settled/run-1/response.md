The registry design is finished around your SQLite choice. Here's what changed and where you come in.

**Changes made**

- `docs/high-level-design.md` — the registry line no longer says "lookup backend remains open"; it now names the local embedded SQLite index.
- `docs/intent/registry/registry-design.md` — rewritten with the backend settled:
  - **Architecture**: SQLite index lives beside the active snapshot, entirely inside this node; validation, index build, and lookup all stay here; certificates still only see `findBySerial`.
  - **Snapshot Import**: validate (signature, schema version, serial uniqueness) → build index from validated records only → activate snapshot + index together atomically; failure leaves the previous pair active.
  - **Lookup Behavior**: normalization unchanged; added two pins — the index is built with the same normalized form used at query time, and a missing/unreadable index is an **error, not `NotFound`** (so a broken import can't fake "no such serial").
  - **Decisions & Alternatives table**: backend row recording the HTTPS-directory and managed-service rejections with the reasons you weighed, plus an index-activation row (atomic swap vs. incremental updates).
- **Specs unchanged** (`REG-001`–`REG-004`): they were already backend-agnostic, and the new behavior pins above are design details, not new requirements. Say the word if you'd rather see any of them promoted to EARS.

**Edge-case probe — triage for me**

I ran a blind probe against the finished LLD. These gaps are real; which should I close in the design now, and which defer to implementation?

1. Lookup in flight during a swap — guaranteed to complete against the old pair?
2. Crash mid-import — is the half-built index file ever cleaned up?
3. Records with empty/non-string serials or null dates — rejection condition, and at which stage?
4. Active snapshot corrupted on disk *after* activation — self-healing, or permanent error?
5. Schema field changes between snapshots — what does `Found(record)` return for a field the active snapshot lacks?
6. Empty or whitespace-only serial passed to `findBySerial` — error, `NotFound`, or undefined?

(Pings 2 and 8 in the raw list overlapped the atomicity I'd already pinned; the six above are the survivors. The backend choice affects only this node, so I recorded it as a Decisions row rather than offering a decision doc — per the usual bar.)

**Please review the revised `registry-design.md` and tell me: (a) does the design read right, especially the error-not-NotFound pin, and (b) which probe gaps to fix now vs. defer?**