It would be overkill—the **Decisions & Alternatives** row in `docs/intent/registry/registry-design.md` is the right fit.

Under the decision-doc bar, a standalone doc is for choices that stay *live* for a cold reader (multiple credible options traded across criteria, with other design nodes sizing around the result). Here, two things settle it once landed:

1. **Inherited constraints eliminate the alternatives:** `docs/high-level-design.md` mandates zero runtime network access and local-file-only lookups, which rules out both the on-site HTTPS directory and the managed search service.
2. **Scope stays inside one node:** The SQLite backend is encapsulated behind `findBySerial(serial)`, so `certificates` and the rest of the system do not depend on it.

Even when a choice takes effort to weigh in conversation, a cold reader of the landed design won't re-litigate it—the table row settles why SQLite was chosen.

Whenever you're ready at this **Phase 2 stop**, let me know which of the 8 edge-case probe items to resolve in `registry-design.md` versus defer, and whether to proceed to Phase 3 (`registry-specs.md`).