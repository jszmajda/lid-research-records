Now let me run the LLD-level edge-case probe and present the findings for your review.

---

## Phase 2 Complete — LLD Updated

I've updated the registry design and specs with the local SQLite index decision:

**Updated `docs/intent/registry/registry-design.md`:**
- Added Decisions & Alternatives table recording the SQLite choice with rationale
- Added Open Questions for deferred implementation details (index schema, pragma settings)

**Updated `docs/intent/registry/registry-specs.md`:**
- Added REG-005: Atomic index rebuild during snapshot import
- Added REG-006: 250 ms lookup performance target
- Added REG-007: Schema version handling with index rebuild

---

### LLD-Level Edge-Case Probe

| # | Edge Case | Gap in Current Specs |
|---|-----------|---------------------|
| 1 | Index rebuild fails mid-way (disk full, corruption, OOM) | REG-005 says "activate only after rebuild completes" but doesn't specify rollback/cleanup behavior |
| 2 | SQLite database file corrupted on disk | No spec for detection or recovery |
| 3 | Concurrent lookup during import | REG-004/005 imply atomic swap but don't specify reader/writer isolation |
| 4 | Malformed JSON records in snapshot (beyond duplicate serials) | REG-003 covers signature/schema/duplicates; silent on other record validation |
| 5 | Missing or malformed signature manifest | REG-003 covers invalid signature but not missing manifest |
| 6 | Initial state — no snapshot imported yet | No spec for lookup behavior before first import |
| 7 | Schema version migration (old index format → new) | REG-007 says rebuild on version change but doesn't address backward compatibility or migration path |

---

**STOP for your review.** 

Which of these gaps should be fixed in the LLD/specs now vs. deferred to implementation? Any other edge cases I missed?