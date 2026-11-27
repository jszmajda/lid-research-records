A standalone decision doc would be **overkill** here.

Under LID's earns-its-place test, a full decision doc is reserved for choices that stay genuinely live for a cold reader and shape other nodes—not ones that were simply hard to debate. Here:
1. **Inherited constraints settle it:** `docs/high-level-design.md` forbids runtime network access and cloud services on kiosks, which eliminates both the on-site HTTPS directory and the managed search service.
2. **It is local to one node:** `certificates` depends only on `findBySerial(serial)`, so no other design node is sized around the backend choice.

The row in `docs/intent/registry/registry-design.md`'s **Decisions & Alternatives** table is sufficient for a cold reader.

Whenever you're ready, let me know how you'd like to triage the Phase 2 edge-case questions (1–7) and whether to proceed to Phase 3 (`registry-specs.md`).