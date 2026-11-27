I'd recommend keeping it as the `## Decisions & Alternatives` row in `docs/intent/previews/previews-design.md` rather than adding a decision doc.

- **Scope is local to `previews`**: No other node is sized around 2Q—the HTTP contract, render queue, and 12 GiB cap are unchanged, and replacement bookkeeping stays private to the preview worker.
- **Forward-looking bar, not debate length**: A long debate doesn't by itself earn a decision doc; the existing table row already tells a cold reader why 2Q beat LRU (scan resistance for comparison sheets) and aged frequency (no stale-retention lag on project switches).

That said, if you want a full doc at `docs/intent/previews/decisions/cache-eviction-policy.md` so no one re-opens the trade-off later, say the word and I'll write it. Otherwise, let me know how you'd like to triage the edge-case probe items above and whether we're ready for Phase 3 (`previews-specs.md`).