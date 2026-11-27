Done. Here's what landed:

**`docs/intent/previews/decisions/cache-eviction-policy.md`** — full decision doc with:
- **Context:** the two workload patterns pulling in opposite directions (screenings vs. comparison sessions)
- **Decision Elements:** one gate (bookkeeping stays private — all options pass) and four criteria: scan resistance (major), bookkeeping cost (moderate), adaptation speed after a project switch (moderate), operational simplicity (minor)
- **Options in the Domain:** LRU, frequency-based with aging, 2Q — each described at full strength with per-element analysis verdicts
- **Selection:** 2Q wins on the major criterion (scan resistance) and the tenet driving it; the other two options' failure modes are stated plainly; downstream obligation on the 25/75 split is named

The LLD's Decisions table row now points to the doc instead of duplicating the reasoning.

Four edge-case probe questions from the Phase 2 stop are still open. Ready to triage those and move to Phase 3 (EARS specs) whenever you are — or if you want to review the decision doc first, go ahead.