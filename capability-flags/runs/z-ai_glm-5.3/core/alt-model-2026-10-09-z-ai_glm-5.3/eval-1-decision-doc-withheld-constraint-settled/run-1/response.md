**Registry design updated (Phase 2 — LLD).** Summary of the changes:

- **LLD** (`docs/intent/registry/registry-design.md`): the lookup backend is now settled — a local embedded SQLite index on the kiosk disk. Added an **Index Build and Activation** section: full rebuild into a fresh index file, records inserted in a single transaction with a normalized lookup key + unique index (so validation's duplicate check and the lookup path share one normalization), snapshot date stored in the index file, activation by atomic file replacement after commit, previous index retained so a failed build leaves the last valid snapshot serving. Added the **Decisions & Alternatives** table (SQLite vs. HTTPS directory vs. managed search service — the HLD's no-network-lookup tenet rules out both networked options; the accepted cost is per-kiosk rebuilds on import) and a rebuild-strategy row. Open questions already deferred in the doc: corrupt-at-startup recovery, post-activation retention of the old index, import duration budget.
- **HLD**: the architecture line "private lookup backend remains open" is updated to name the local embedded SQLite index. Nothing else changed — the selection fits the existing tenets and the certificate interface is untouched.

**Edge-case probe** (delegated to a fresh reader given only the design doc). The genuine gaps it found, roughly by severity — please triage which to fix in the LLD now vs. defer:

1. In-flight lookup at the instant the active index file is atomically replaced — finish against the old file, fail, or torn state?
2. The atomic swap mechanism itself (rename vs. copy-then-swap vs. pointer), and power loss between build commit and swap (orphaned new index, old still active)?
3. The shape of the "useful error" on import failure — typed result vs. message; does it carry reason code / failing record / schema version per failure mode (bad signature, unsupported schema, duplicates, malformed JSON, truncated stream)?
4. Lookup on a kiosk where no snapshot has ever been imported — is `NotFound(snapshotDate)` even representable with no snapshot date?
5. Re-importing an older or same-dated snapshot — accepted and silently rolling the registry back, or rejected?
6. USB removed mid-stream during validation — same error path as validation failures?
7. A duplicate that validation's normalization misses but the SQLite unique index catches at build time — which check is authoritative?
8. Concurrency model for simultaneous lookups during a rebuild (locking, WAL, single-threaded assumption)?
9. Signature-key state (missing/rotated key) in the error model, and whether key provisioning belongs in this node?
10. Whitespace-only input normalizing to an empty key — `NotFound` or invalid-input; and does the 250 ms budget cover normalization + query or query only?

Note the interface result type is shared with the certificates node — if you want anything on that boundary changed (e.g., #4's no-snapshot state, which is currently not representable), that crosses a segment boundary and I'll flag it to cascade there.

Which of these should I fold into the LLD, and which go to Open Questions? After your triage I'll proceed to Phase 3 (EARS update for REG — REG-004 and possibly new specs for the index build/activation behavior).