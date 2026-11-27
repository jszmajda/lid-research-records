## Phase 3 — EARS Specs Updated

Added REG-005 through REG-009 for SQLite-specific behaviors (index build, atomic activation, corrupt fallback, performance, WAL concurrency, partial cleanup).

**Consistency verification**:
- **Coverage**: All LLD behaviors now have corresponding specs (9 specs total)
- **Contradiction**: None detected
- **Implicit scoping**: Each spec has explicit WHEN condition; no universal phrasing
- **Context-free**: Each spec line stands alone with concrete conditions

**STOP for user review** — Are the specs complete and correctly scoped, or do any need adjustment?

---

## Phase 4 — Intent-Narrowing Edge Audit

### Cross-spec forks (within registry segment)

| Spec Pair | Potential Divergence | Resolution Needed |
|-----------|---------------------|-------------------|
| REG-004 + REG-005 | REG-004 says "expose all records together without exposing partially imported snapshot"; REG-005 specifies "build in transaction + atomic rename". Does the rename happen *after* the transaction commits, or is the transaction the atomic unit? | Clarify: transaction commits → file is complete → rename activates. The "expose" in REG-004 means "visible to lookups", which happens at rename. |
| REG-006 + REG-003 | REG-003 covers import-time rejection; REG-006 covers runtime corrupt DB. If import succeeds but DB corrupts later, REG-006 applies. No conflict, but: does REG-006's fallback also re-validate the previous snapshot's signature? | The previous snapshot was already validated on its import. Fallback trusts it. If user wants re-validation, that's a new spec. |
| REG-007 + REG-008 | REG-007: 250ms lookup. REG-008: concurrent reads during import. Does the 250ms SLA apply during import? | REG-007 is the steady-state SLA. During import, WAL may add slight overhead; still expected <250ms but not a hard requirement. Add "under normal operation" to REG-007? |
| REG-005 + REG-009 | REG-005: atomic rename on success. REG-009: cleanup partial file on next import. What if import succeeds partially (transaction commits but rename fails)? | Rename failure after commit = partial file left. Next import cleans it (REG-009). The previous DB remains active. Acceptable. |

### Cross-segment (registry → certificates)

- **CERT-001/002/003** depend on `findBySerial` returning `Found`/`NotFound` with `snapshotDate`. REG specs guarantee this via REG-001/002. No fork.
- **CERT-004** (atomic PDF write) is independent of registry backend. No fork.

### Namespace/prefix ambiguity

- All specs use `REG-` prefix. No collision with `CERT-`. Clean.

### Sequencing ambiguity

- Import sequence: validate → build index (REG-005) → atomic rename → activate. Lookups see old DB until rename. Specified.
- No ambiguous ordering between REG specs.

### User latent intent narrower than specs?

- REG-007 says "within 250 ms on kiosk hardware with 4 GB RAM". Is "kiosk hardware" specific enough? The HLD says "on a kiosk with 4 GB of RAM" — matches.
- REG-008 says "without blocking". Does this mean zero blocking, or "no perceptible blocking"? SQLite WAL may have brief lock contention. "Allow concurrent reads without blocking" is the intent — WAL delivers this.

**STOP for user review** — Resolve the forks above (especially REG-004/005 timing, REG-007 during-import SLA, REG-006 re-validation). I'll incorporate resolutions into specs before Phase 5.

---

**Questions for you:**

1. **REG-004/005 timing**: Confirm — transaction commits → rename activates. "Expose" = visible to lookups at rename. Accept?
2. **REG-007 during import**: Add "under normal operation (not during snapshot import)" to REG-007, or keep as hard SLA always?
3. **REG-006 fallback**: Trust previous snapshot without re-validation. Accept, or add re-validation spec?
4. Any other forks you see?