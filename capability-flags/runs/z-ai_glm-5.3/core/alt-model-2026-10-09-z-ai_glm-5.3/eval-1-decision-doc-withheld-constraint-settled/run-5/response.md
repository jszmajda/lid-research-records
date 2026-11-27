Phase 2 (Registry LLD) is complete — here's the stop for your review.

**What changed**

- **HLD** (`docs/high-level-design.md`): replaced the stale "lookup backend remains open" note — it now records the local embedded SQLite index.
- **Registry LLD** (`docs/intent/registry/registry-design.md`): finished the design around the SQLite backend. Key points:
  - **Import**: verify signature → check schema version → build a fresh index in a staging file (`registry.staging.db`) in one transaction → atomically rename over the active file (`registry.db`). Rename is the activation point; any failure deletes staging and leaves the active index untouched. Staging orphans are cleaned at startup, never read.
  - **Index**: `records` table keyed on the normalized serial (punctuation significant, whitespace/ASCII-case folded — same normalization at import and query), plus a one-row `snapshot_meta` table carrying schema version and snapshot date. Uniqueness is enforced on the normalized key, so two raw spellings that fold to one key are rejected as duplicates.
  - **Lookup**: read-only (`mode=ro`) connection per call, exact point query; snapshot date returned on Found and NotFound alike.
  - **Decisions & Alternatives** table records the backend choice (networked options eliminated by the HLD's no-runtime-network tenets; SQLite also gives predictable lookups inside the 250 ms budget) plus activation, uniqueness-scope, and read-path rows.

**Edge-case probe** — I dispatched a blind probe at the drafted LLD; it found these gaps. Please triage: which should I fix in the LLD now, and which go to Open Questions as deferred?

*Lookup correctness / data safety:*
1. What does `findBySerial` return when no active index exists yet (first boot)? The result type has no "no registry" variant.
2. What guarantees the active file is a complete database after power loss during/right after the rename (fsync of staging file + directory is unspecified)?
3. Which SQLite journal mode does the build use — WAL sidecars would be lost at rename, potentially activating an empty index.
4. What does a lookup do when the active index is corrupt or unreadable (vs. NotFound)?
5. Does staging live on the same filesystem as the active file? Rename isn't atomic across filesystems.
6. A lookup in flight during the rename keeps reading the old inode — is per-call snapshot consistency the invariant, or are old-snapshot answers during the window acceptable?

*Import mechanics:*
7. Second import while one is in progress — no mutual exclusion on the fixed staging path is stated.
8. USB removed mid-read — no per-stage error shapes are defined.
9. Startup cleanup vs. an import in flight at restart — ordering unspecified.
10. Is a zero-record snapshot valid? It passes every stated check and would activate an empty index.
11. No record-level validation beyond serial uniqueness (missing fields, malformed dates).
12. Nothing enforces `snapshot_meta` being exactly one row.
13. Where the supported schema-version set lives, and behavior on downgrade (newer index than the code supports).
14. Non-ASCII case folding is unspecified — intended to stay distinct?

*Ambiguities flagged:*
- "Atomic rename is the activation point" — syscall return vs. durability after fsync.
- "Report a useful error" — no error type/shape defined (exception vs. result, interface or internal).
- "Open read-only per call" — strictly per invocation, or is a shared read handle acceptable?

Which gaps do you want folded into the LLD, which deferred, and — with that triage done — do you approve the LLD so I can cascade to the EARS specs (Phase 3)?