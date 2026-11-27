Written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the **Decisions & Alternatives** table in `docs/intent/record-store/record-store-design.md`.

### Summary of `concurrent-visit-edits.md`

- **Context & Decision Elements:** Frames the decision around TidePlot's domain (24 workers, 12 shared offline tablets, ~6,000 visits/season, 2 coordinators, weekly Friday CSV export, scientifically coupled fields) and six weighted criteria tied to the HLD tenets and non-goals — including the criteria that cut *against* whole-visit revisions (coordinator review throughput and export readiness for disjoint edits).
- **Options in the Domain:** Gives both **Whole-visit revisions** and **Field-aware three-way merge** full descriptions, concrete demonstrations (disjoint and coupled edits), and clinical per-criterion fit verdicts (`strong` / `partial` / `weak`).
- **Selection & Cascades:** Records why **Whole-visit revisions** wins at current scale, names the exact condition under which **Field-aware three-way merge** would be revisited (concurrent disjoint edits growing frequent enough to bottleneck two coordinators before Friday export), and spells out the downstream obligations for `tablet-sync` (`baseRevisionId`, `idempotencyKey`, full visit payloads, surfacing `needs_review`) and `review-export` (comparison view over competing heads and base revision, exact-head resolutions with optimistic rejection handling, excluding `exportEligible: false` visits from the Friday CSV).

---

**Phase 2 review:** Please check `concurrent-visit-edits.md` and `record-store-design.md`, and let me know:
1. Any edits to either document.
2. How you want to triage the Phase 2 edge-case probe items (1–9 from above — fix in the LLD vs. defer).
3. Once those are settled, whether to proceed to Phase 3 (`record-store-specs.md`) and update the open-choice note in `docs/high-level-design.md`.