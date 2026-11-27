2Q is now the preview cache's replacement policy. I ran Phases 1–4 as one consolidated pass (you'd authorized "go ahead and finish"), so here's the whole arrow state for review.

**What changed**

- `docs/high-level-design.md` — the Previews bullet no longer says the eviction policy is open; it now states 2Q.
- `docs/intent/previews/previews-design.md` — `Private Cache` now specifies the policy in full: a **cold queue** (requested once), a **hot queue** (requested more than once — the comparison set), and a **ghost list** (keys of cold-queue evictions, no preview bytes). Admission lands new sheets at the cold tail; a cold hit promotes to hot; a hot hit refreshes recency; a ghost-list key re-renders straight into hot. Eviction drains cold first (longest-held), then hot (LRU). Added a `Decisions & Alternatives` table (the 2Q choice vs LRU vs aged-frequency, the ghost list, hot-queue overrun) and `Open Questions` for the two things you said would need tuning.
- `docs/intent/previews/previews-specs.md` — added PREVIEW-006…013 (admission, promotion, recency refresh, ghost re-admission, eviction order, hot overrun, bookkeeping privacy).

The review-api segment needed no change: the preview interface, render queue, and 12 GiB bound are identical under 2Q, so no cross-boundary cascade. No spec IDs were renumbered.

**Five things I need from you**

1. **No landing target for Phases 5–6.** This repo contains only intent docs — no preview worker source, no test harness, no tooling. So I wrote no tests and no code, and every PREVIEW spec stays `[ ]` unimplemented. Does the worker live in another repo (which language/stack), or do you want me to build it plus its tests here?
2. **Hot-queue share** — I started it at 25% of the 12 GiB budget (3 GiB) and marked it "retune after the pilot". Keep that starting value, or set another?
3. **Ghost-list scope fork** — currently classic 2Q: only *cold-queue* evictions are recorded. A sheet evicted from the *hot* queue and later re-requested would therefore re-enter the cold queue, one step down from where it was. Should hot-queue evictions also be recorded as ghosts so it returns to hot?
4. **Hot-queue overrun** — I chose demotion (LRU hot sheet moved to the cold queue's tail) over outright eviction, so a twice-used sheet is recoverable but still flushable by a scan. Confirm, or prefer outright eviction?
5. **Decision doc?** This choice was contested across three meetings and a long thread, and the queue-size split will be re-litigated at tuning time. I'd suggest a short decision doc at `docs/intent/previews/decisions/` capturing the criteria (protect comparison sheets through a scan) and the alternatives — say the word and I'll write it; a Decisions row alone is the alternative.