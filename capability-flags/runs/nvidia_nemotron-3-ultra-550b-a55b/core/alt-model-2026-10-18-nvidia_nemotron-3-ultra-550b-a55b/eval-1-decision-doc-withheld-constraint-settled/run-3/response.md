Updated the registry design with the local SQLite index decision and completed the implementation details. The specs remain unchanged since the interface and behavior are the same — only the backend implementation is now specified.

**Phase 2 (LLD) complete** — updated `docs/intent/registry/registry-design.md` with:
- Decisions & Alternatives table recording the SQLite choice
- Index schema (equipment table + meta table)
- Index build process (temp DB, single transaction, atomic swap)
- Query path (prepared statement, read-only)
- Failure modes (corrupt index, I/O errors, schema mismatch)

The specs in `docs/intent/registry/registry-specs.md` still trace correctly — they specify the *what* (normalization, snapshot date in results, import validation, atomic activation) which the design now implements with the SQLite backend.

**STOP for review** — please confirm the design is complete and ready for EARS spec verification (Phase 3), or request changes.