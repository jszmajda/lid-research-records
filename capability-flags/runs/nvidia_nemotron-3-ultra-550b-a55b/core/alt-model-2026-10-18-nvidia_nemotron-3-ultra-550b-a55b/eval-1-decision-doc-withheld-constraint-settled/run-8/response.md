**Phase 3 consistency verification passed.**  
**Phase 4 edge audit found 6 forks needing your resolution:**

1. **Registry interface third outcome** (REG-007 vs LLD + Certificates): `findBySerial` currently returns `Found` | `NotFound`. REG-007 adds a distinct "registry-unavailable" error. Certificates only handles Found/NotFound.  
   → Choose: (a) third result variant `Error(msg)`, (b) exception, (c) special `NotFound` with `snapshotDate=null`, (d) other.

2. **Atomic swap platform assumption** (REG-005): POSIX `rename()` is atomic; Windows is not. HLD implies Linux but doesn't mandate it.  
   → Choose: (a) POSIX rename is sufficient (kiosks are Linux), (b) specify cross-platform atomic swap mechanism.

3. **Duplicate serial scope** (REG-003): LLD says "within the snapshot"; spec text doesn't disambiguate.  
   → Choose: (a) clarify spec to "within the imported snapshot", (b) keep as-is (LLD resolves it).

4. **No-snapshot startup behavior** (REG-006 + REG-002): `findBySerial` when no active index exists — REG-002 requires snapshot date, but none exists. LLD says "require valid USB import before lookups succeed."  
   → Choose: (a) return `Error("no snapshot")`, (b) return `NotFound(snapshotDate=null)`, (c) other.

5. **Concurrent readers during swap** (REG-004 + REG-005): POSIX rename lets readers see old or new DB atomically; SQLite handles this. Is that sufficient for "no partial exposure"?  
   → Choose: (a) yes, POSIX rename semantics satisfy it, (b) add reader coordination.

6. **Performance specs in EARS** (REG-009, REG-010): They're targets, not unit-testable functional requirements.  
   → Choose: (a) keep in EARS as acceptance criteria, (b) move to a separate non-functional spec doc, (c) keep but mark as non-unit-testable.

Please resolve each (1–6) and I'll update the docs and proceed to tests.