That would be **overkill** — the `Decisions & Alternatives` row in `docs/intent/registry/registry-design.md` is the right fit here:

1. **Settled by an inherited constraint:** The HLD tenets require all lookups to use local kiosk files with no runtime network access, which already eliminates the HTTPS directory and managed search service.
2. **Local to one node:** The storage backend is private to `registry`, and no other node (`certificates`) is sized around it.
3. **Clear from the landed state:** A cold reader seeing an offline kiosk with a local SQLite index only needs a single rationale line to know why, regardless of how close the options felt during deliberation.

Whenever you're ready, let me know your feedback on `docs/intent/registry/registry-design.md` and how you'd like to triage the edge-case probe items before we move to Phase 3.