The SQLite backend choice is **already properly captured** in the registry LLD's Decisions & Alternatives table — that's the right level. A decision doc would be overkill.

The forks from the edge audit are **implementation details** that will be resolved in code with tests. If any become live questions during implementation (e.g., fork #4 about auto-rebuild from last good snapshot), a table row can be added then.

**Earns-its-place test applied:**
- Backend choice: table row ✓ (cold reader sees three candidates + rationale, choice reads as natural)
- Fork #1 (atomic swap): implementation detail, not a design decision
- Fork #4 (auto-rebuild): could go either way; if it stays ambiguous during implementation, a row — not a doc

No decision doc needed for any of these. Shall we proceed to Phase 5 (tests first)?