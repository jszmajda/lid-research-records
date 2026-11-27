**Phase 1 — HLD check** (pre-flight + HLD update)

*Coherence pre-flight:* `PREVIEW-001…005` all still trace to sections of `docs/intent/previews/previews-design.md` (contract, dedup, 12 GiB cache bound). No drift. No implementation exists yet in this repo (docs only, no `src/`, no tests, no `docs/arrows/` overlay), so there is no code-side drift to detect and no arrow index to reconcile.

*HLD change made* — `docs/high-level-design.md:14`:
- was: "…a private 12 GiB cache. Its eviction policy remains open."
- now: "…a private 12 GiB cache. Its cache uses 2Q eviction, which keeps repeatedly reused sheets resident across long sequential screenings."

Architecture is unchanged: 2Q lives entirely inside the preview worker's private cache. The HTTP contract (200/202/404, two-second retry interval), the FIFO render queue with four active jobs, dedup semantics, and the 12 GiB bound are all untouched, and no other node reads cache files or policy metadata. The change therefore stays inside the previews segment — no cross-segment cascade, and the review API needs no change.

*Tenet elicitation* — one load-bearing lean surfaced for the HLD's `## Tenets`:
> "Repeatedly reused previews outrank one-off scans when the cache must evict."

Its reverse (protect fresh scans instead) is defensible, it is not a spec (no fixed trigger), and it governs a class of choices the specs don't anticipate (queue split, demotion policy, tuning). Approve, reword, or decline it.

**Two things I need from you before I continue:**

1. **Phase 5–6 target.** This repo contains only design docs — there is no preview worker code or test suite to modify. Options: (a) design-only — I finish the LLD and EARS specs and stop at the "no implementation target" point; (b) I build a standalone preview-cache module (2Q queues + eviction) with tests, as a self-contained implementation of the previews segment; (c) I build the whole preview worker (HTTP endpoint, render queue, dedup) from scratch. (b) and (c) are large and pick a language/framework I'd otherwise need you to name.

2. **The 2Q split parameter.** The policy needs a concrete first-use-queue capacity to be implementable. My recommendation: first-use queue capped at 25% of the cache budget (3 GiB), reused queue holding the remaining 9 GiB, with the reused queue evicting least-recently-used entries only after the first-use queue is drained. Confirm the 25% or give a different split.