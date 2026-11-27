I don't think it needs a full decision doc—the `Decisions & Alternatives` row in `docs/intent/previews/previews-design.md` is the right fit here:

- **Isolated to one node:** Replacement tracking is private to the preview worker (`high-level-design.md` and `review-api-design.md` both keep other nodes decoupled from it), so no other design node is sized around 2Q.
- **Forward-looking test, not debate length:** A long argument doesn't by itself earn a decision doc; the test is whether a cold reader of the landed design would need the full weighted criteria to avoid re-litigating it. Here, the single table row already explains why 2Q beats LRU (scan resistance for comparison sheets) and aged frequency (avoids stale retention and counter overhead).

If you'd still like one recorded at `docs/intent/previews/decisions/` anyway, say the word and I'll draft it. Otherwise, let me know how you'd like to triage the 7 Phase 2 probe items above so we can move on to **Phase 3 (EARS specs)**.