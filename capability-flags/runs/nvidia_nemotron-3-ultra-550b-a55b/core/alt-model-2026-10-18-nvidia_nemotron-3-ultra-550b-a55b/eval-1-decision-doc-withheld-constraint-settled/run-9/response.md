**Phase 4 — Intent-narrowing edge audit**

I've analyzed the updated registry design and specs. Here are the genuine forks needing your resolution:

---

### 1. REG-005: "validate it" — what validation exactly?
**Divergent readings:**
- A) Row count matches input + all serials queryable + schema version recorded + snapshot date present + indexes created
- B) Row count matches + all serials queryable only
- C) Full re-verify: signature, schema, uniqueness, row count, queryability

**Design implies A** (build-time validation, not re-verifying signature). Confirm?

---

### 2. REG-006: "report an error identifying the failure stage" — what format?
**Divergent readings:**
- A) Typed exception hierarchy: `SignatureError`, `SchemaError`, `DuplicateSerialError`, `BuildError`, `ValidationError`, `SwapError`
- B) Single `ImportError` with `stage` field enum
- C) Result object `{ ok: false, stage: string, message: string }`

**Registry is a library component** — exceptions (A) or Result (C) are idiomatic; (B) is Java-style. Preference?

---

### 3. REG-007: "within 250 ms for 90,000 records" — cold or warm?
**Divergent readings:**
- A) Every lookup ≤ 250 ms (cold start included) — requires pre-warming or very fast cold open
- B) Steady-state lookups ≤ 250 ms; first lookup after startup may exceed
- C) P95 ≤ 250 ms; outliers allowed

**HLD goal** says "Resolve within 250 ms on a kiosk with 4 GB RAM" — sounds like steady-state (B). Confirm?

---

### 4. REG-008: metadata missing/corrupt — what happens?
**Divergent readings:**
- A) Lookup fails with `CorruptSnapshotError` — snapshot is unusable
- B) Fallback to file mtime, log warning — degrade gracefully
- C) Return `SnapshotDateUnknown` sentinel in result — caller decides

**Tenet**: "A failed snapshot import must leave the last valid snapshot available" — suggests active DB should always be valid. But corruption could happen post-import (bit rot). Preference?

---

### 5. REG-005 atomic swap on Windows
**Fork**: POSIX `rename()` is atomic; Windows `MoveFileEx` with `MOVEFILE_REPLACE_EXISTING` is atomic *only if* destination doesn't exist, or requires transactional NTFS.
- A) Use platform-specific atomic replace; document Windows caveat
- B) Write new file, update symlink/junction atomically (works cross-platform)
- C) Accept non-atomic on Windows; add "import in progress" lock file

Kiosks — what OS?

---

### 6. Cross-segment: certificates node expects `snapshotDate` always present
REG-002 + REG-008 cover this, but if #4 resolves to A (fail lookup), certificates gets an error instead of `NotFound(snapshotDate)`. Is that acceptable? Certificates specs CERT-001/002 only handle `Found`/`NotFound`.

---

Please resolve each (numbered replies fine). I'll narrow the specs accordingly before Phase 5.