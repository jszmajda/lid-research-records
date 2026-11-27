# /lid-coach review — printfarm

**Posture:** Solid design skeleton; the arrow stops before Tests and Code.

**Scorecard**
- ✓ Linkage & alignment — spec prefixes (`QUEUE`, `REG`) match their leaf LLDs and the HLD's two nodes; IDs are clean and grep-friendly
- ✓ HLD discipline — the HLD stays at architecture + rationale; no schema or signature bleed
- ⚠ Arrow completeness — HLD → LLD → EARS are present; Tests and Code phases are absent entirely
- ⚠ Spec status coherence — all 8 specs are marked implemented with nothing to implement them
- ⚠ Tenet discipline — a tenet restates a spec, and the tenets are unordered
- ⚠ Decision capture — the queue's restart behavior drives a tenet-level trade but has no Decisions row

*What's working:* the two-node architecture is clean and the design docs are genuinely cold-readable — I could reconstruct the system from them without the conversation that produced them. The fastest wins are reconciling the specs' declared status with the missing Tests/Code phases and recording the restart-loss decision.

**Findings (7 total · 3 high · 3 medium · 1 low)**
- **F1 (high):** Tests and Code phases are entirely absent — the repo holds only docs — yet all 8 specs carry `[x]` "implemented" status · *canonical arrow shape* + *coherence is adjacency* (serves as the entry-point convention; implement the spec's `@spec` annotation there)
- **F2 (high):** Holding the queue in process memory drops accepted jobs on restart, defeating the "a submitted job is a promise / upload and walk away" tenet under the power-blip condition the LLD itself names · *tenets capture forward-looking preference* (tenet cascade)
- **F3 (high):** That restart-loss choice is described only in Architecture prose, with no row in the job-queue Decisions & Alternatives · *docs carry current intent* (decision capture)
- **F4 (medium):** Tenet 2 ("staff override members, but the queue explains itself — no silent reordering") restates spec QUEUE-005 rather than acting as a forward-looking tie-breaker · *tenets capture forward-looking preference*
- **F5 (medium):** The three tenets are an unordered list though "promise" and "staff override" can pull against each other · *tenets capture forward-looking preference*
- **F6 (medium):** Specs reference cross-file concepts ("that printer's class", "idle", "the system") without inline context, and "the system" is ambiguous across a two-service project · *scope disambiguation*
- **F7 (low):** job-queue currently owns upload, ordering, dispatch, and prioritization in one node — a promotion candidate to a sub-HLD if dispatch grows its own design · *one LLD per intent component*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files — the entire repository (6 files)
- Enumerated: 2 LLDs, 2 spec files, 8 specs, 0 arrow segments, 0 code/test files
- No `docs/arrows/` overlay present, so no `index.yaml` and no structural enumeration attempted
- Linkage metric: 0 `@spec` annotations (no code/tests exist); 8 unique spec IDs, all `[x]`
- Sampling: not required — project is below the sampling thresholds

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.