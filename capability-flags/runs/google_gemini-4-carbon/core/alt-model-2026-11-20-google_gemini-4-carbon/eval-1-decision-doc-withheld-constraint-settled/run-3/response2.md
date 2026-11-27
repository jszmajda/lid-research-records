It would be overkill—the `Decisions & Alternatives` table row in `registry-design.md` is the right level here.

In LID, the test for a standalone decision doc looks forward from the landed design rather than back at how much deliberation it took: *would a future cold reader find the choice genuinely live and be tempted to re-litigate it without the full criteria and option breakdown?* Here, three things settle it without a separate doc:

1. **Inherited HLD constraints eliminate the networked options:** `docs/high-level-design.md` prohibits runtime network access, remote services, and non-USB update channels on kiosks, which rules out both the on-site HTTPS directory and the managed search service as hard gates.
2. **One option dominates what remains locally:** Against a 90,000-record / 150 MB dataset, 4 GB RAM ceiling, and 250 ms lookup target with zero extra services to install, an embedded SQLite index clearly beats scanning raw NDJSON, so a single line of rationale answers "why SQLite?"
3. **The choice stays private to `registry`:** `certificates` consumes only `findBySerial(serial)`, so no sibling design node is sized around this backend choice.

A decision doc in `docs/intent/registry/decisions/` would only earn its place if kiosk network isolation itself might be relaxed later and you wanted a ready-made evaluation to re-run then (or if you still want one recorded regardless, I can draft it).

Assuming we keep it as the table row, let me know how you'd like to handle the Phase 2 `registry-design.md` review and any of the 7 edge-case questions above before we move to `registry-specs.md`.