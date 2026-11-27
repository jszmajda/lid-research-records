It would be overkill—the **Decisions & Alternatives** row in `docs/intent/registry/registry-design.md` is the right weight.

A full decision doc is only warranted when a choice stays genuinely live for a cold reader of the landed design (credible options traded against multiple criteria, with other nodes sized around the result), regardless of how much back-and-forth it took to decide. Here, two things settle it once landed:

1. **Inherited constraints eliminate the alternatives.** `docs/high-level-design.md` already forbids runtime network access and cloud/remote services during kiosk operation, which rules out both the on-site HTTPS directory and the managed search service.
2. **The choice is private to `registry`.** `certificates` only sees `findBySerial(serial)` and its fixed `Found`/`NotFound` types, so no other node depends on the backend selection.

One table row in `registry-design.md` gives a future reader the full rationale without creating a standalone doc to maintain.

Ready to triage items 1–7 from the Phase 2 probe when you are, or let me know if you want to adjust anything in `registry-design.md` before moving to Phase 3 (EARS specs).