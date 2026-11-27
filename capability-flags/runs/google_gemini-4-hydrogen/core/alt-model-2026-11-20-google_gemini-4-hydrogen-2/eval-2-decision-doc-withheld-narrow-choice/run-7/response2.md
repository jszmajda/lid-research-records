By LID's **earns-its-place** heuristic, a **Decisions & Alternatives** row is the right fit here rather than a full decision doc:

- **Debate length isn't the test.** A long argument can still settle into a single table row; the test is forward-looking from the landed design—whether a cold reader would re-litigate the choice and whether other design nodes are sized around it.
- **It affects only its own node.** The Review API and the external preview contract don't depend on the replacement policy, and all 2Q state stays private to the preview worker. The table row in `docs/intent/previews/previews-design.md` already captures why 2Q won over LRU and aged frequency (scan resistance for comparison sheets vs. extra bookkeeping and tuning).

That said, if you expect future maintainers to re-open 2Q vs. LRU/aged-frequency without seeing the criteria weighed in full, I can write `docs/intent/previews/decisions/eviction-policy.md` and link it from the Decisions row—your call.

Whenever you're ready, let me know:
1. Keep the Decisions row as-is, or add `docs/intent/previews/decisions/eviction-policy.md`?
2. How you'd like to triage the Phase 2 edge-case probe items (fix in `previews-design.md` vs. defer) before we move to Phase 3 (EARS specs).