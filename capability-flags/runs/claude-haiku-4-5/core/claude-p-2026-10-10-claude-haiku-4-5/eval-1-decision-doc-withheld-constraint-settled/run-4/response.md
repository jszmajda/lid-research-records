Now I'll run the Phase 2 edge-case probe to identify design gaps, then present both the updated LLD and specs for your review.

## Phase 2 — LLD Edge-Case Probe

I've identified these gaps in the SQLite-based registry design:

1. **Concurrent Import Handling**: What prevents two imports from running simultaneously and corrupting the index?
2. **Disk Space**: What happens if the new index requires more disk space than available?
3. **Empty State**: How does the system behave before any snapshot has been imported?
4. **Index Corruption Detection**: How does the system detect a corrupted SQLite database and recover?
5. **Schema Migration**: How are records versioned if the equipment table schema changes across snapshots?
6. **Index Retention**: How long should old indexes be kept, and when are they garbage-collected?
7. **Equipment Record Schema**: What fields does an equipment record contain, and what are their types?
8. **Snapshot Date Format**: What is the timestamp format and granularity for snapshot dates?
9. **Active Index Validation**: How is the active index validated on startup to detect corruption before serving lookups?
10. **Path/Location Strategy**: Where on the kiosk's filesystem are snapshots stored and active/inactive indexes located?

---

## Updated Registry Design (Phase 2)

I've updated the registry LLD (`docs/intent/registry/registry-design.md`) to detail the local SQLite index approach, including new sections on:
- **Backend Strategy**: Why SQLite was chosen and how it meets the 250ms latency goal
- **Indexing Strategy**: How indexes are built and what the performance model is
- **Snapshot Import** (detailed): Signature verification, schema checking, uniqueness validation, and index creation steps
- **Lookup Behavior** (detailed): Query normalization rules, result types, and error handling
- **Decisions & Alternatives** table: Recording the SQLite choice and alternatives considered

## Updated Registry Specs (Phase 3)

I've expanded the EARS specs to cover:
- **Snapshot Import & Validation** (REG-001 through REG-005): Signature, schema, uniqueness, index creation, and failure handling
- **Lookup Behavior** (REG-010 through REG-014): Normalization, query execution, result format, error fallback, and latency targets

---

## Next Steps

Please review the updated LLD and specs and let me know:

1. **Which edge-case gaps should be addressed in the LLD?** I can either add new sections to detail them or defer them as open questions.
2. **Are there any conflicts or inconsistencies** between the LLD and specs?
3. **Any feedback on the design itself** — the SQLite approach, the import flow, or the lookup behavior?

Once you approve, we'll move to Phase 4 (intent-narrowing edge audit of the specs) and then Phase 5 (tests).