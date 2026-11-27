Phase 1 (HLD check) is done. I'm stopping here for your review, as the workflow requires at each phase boundary. Phase 2 (LLD), Phase 3 (EARS), and the rest follow after your reply.

**Phase 1: HLD check**

- **Choice:** 2Q is the eviction policy for the preview worker's private cache. It sits inside the previews segment, and the review API and render queue are unchanged.
- **HLD edit (made):** `docs/high-level-design.md` said the eviction policy "remains open," which is no longer true. It now reads: "Owns rendering, pending jobs, and a private 12 GiB cache with its own replacement policy." The HLD doesn't name 2Q, because the policy's substance lives in the previews LLD.
- **Tenets and goals:** Nothing conflicts. 2Q keeps replacement bookkeeping private to the worker, keeps keys at clip revision plus renderer version, and returns the same 200/202/404 outcomes.
- **Recording the choice:** I'll add a row to the previews LLD's Decisions & Alternatives table, with the LRU and frequency-with-aging options and their rationale. I won't offer a decision doc, because the choice affects only the previews node.
- **Pre-flight:** The previews LLD still says the eviction policy is open, so it's stale until Phase 2 rewrites it. The repo has no code or tests yet, so there's nothing to check the specs against.

**Decisions for you before Phase 2**

1. **Queue split:** The design needs a probation-queue share and a size for the ghost list of recently evicted keys. Nothing in the docs settles these. I propose the standard 2Q values: probation holds 25% of the 12 GiB budget, and the ghost list tracks keys for about 50% of the resident entry count. Confirm these or give different numbers.
2. **Re-admission:** If a key is requested again after it was evicted from probation (a ghost hit), should it go straight to the protected queue? That is the standard 2Q rule, and it's what makes repeated comparison sheets survive a screening scan. I'd use it unless you say otherwise.

Reply with approval of the HLD edit and answers to 1 and 2, and I'll draft the previews LLD in Phase 2.