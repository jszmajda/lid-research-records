Phase 1–4 design work for the previews segment is complete and the artifacts are updated.

**Phase 1 – HLD check**
`docs/high-level-design.md` Architecture now reads:
- Previews … Eviction uses 2Q to protect reused comparison sheets during sequential screenings.
Coherence pre-flight passed: HLD → LLD → EARS are mutually coherent for the segment.

**Phase 2 – LLD update**
`docs/intent/previews/previews-design.md` Private Cache now specifies 2Q:
- First access → queue A1; second access moves entry to A2 then to B as a reused item.
- Eviction removes from A1 first, then B.
- Queue size split between A1/A2 and B is tunable.
- All replacement bookkeeping stays private; external API, render queue concurrency and disk budget are unchanged.

Decisions & Alternatives added:
| Decision | Chosen | Alternatives Considered | Rationale |
| Cache eviction policy | 2Q | LRU; frequency-based eviction with aging | Protects comparison sheets reused across screening sessions from eviction during long sequential scans. Accepts extra bookkeeping for two queues and a size split. |

Open Questions & Future Decisions deferred:
1. Queue size split values and tuning procedure per production.
2. Atomicity guarantees when moving entries between queues under concurrent access.
3. Metrics to observe hit rate for reused vs one-use entries to signal retuning.

LLD-level edge-case probe surfaced: queue split tuning, concurrent moves, admission at exact 12 GiB bound, and project-switch lag for entries in B. These are recorded as deferred questions above.

**Phase 3 – EARS**
`docs/intent/previews/previews-specs.md` reviewed:
- PREVIEW-001 … PREVIEW-005 remain coherent with the LLD.
- Coverage: eviction is covered by PREVIEW-004 “evict entries before admission so cache remains within limit”; policy details are internal and not observable via the preview API.
- No contradictions, scope is explicit, specs read context-free. No spec changes required.

**Phase 4 – Intent-narrowing edge audit**
No cross-spec forks found. Specs describe only observable API outcomes; 2Q is an internal replacement strategy. The divergence probe for each spec returned no genuine alternative readings that would change external behavior.

STOP for user review.
Please confirm the HLD and LLD updates and the decision to record queue split tuning, atomicity and metrics as deferred open questions. On approval I will proceed to Phase 5 tests-first for the previews segment.