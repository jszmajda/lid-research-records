## printfarm: LID coach report

**Posture:** Solid design layer, but one load-bearing decision is under-captured and the lower arrow phases are missing.

**Scorecard**
- ✓ Configuration: `CLAUDE.md` has the LID directive and a declared `Full` mode, and the standard `docs/` layout is in place.
- ✓ Design tree and linkage: the HLD names two nodes, each with an LLD and specs file. `QUEUE` and `REG` prefixes match the `prefix:` frontmatter, and all 8 IDs are unique and zero-padded.
- ✓ Spec quality: every spec is EARS-shaped with a triggering WHEN clause, so none reads as falsely ubiquitous.
- ✓ Mutation hygiene: no changelog residue, no `[obsolete]` markers, and no "was X, now Y" narration.
- ⚠ Decision capture: the in-memory queue choice has no Decisions row, and it pulls against the first tenet.
- ⚠ Arrow completeness: no tests or code are in this tree, yet every spec is marked `[x]`.

**Headline:** The HLD, the two LLDs and the EARS specs are lean and cleanly linked, and the Decisions tables give real rejected alternatives and accepted costs. The most valuable next step is to record the in-memory queue decision and settle it against the "a submitted job is a promise" tenet.

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** The in-memory queue (jobs lost on restart) has no Decisions & Alternatives row, and it sits in tension with the first tenet, so it needs both a capture and a design look. · *docs carry current intent, written to be read cold* (the decision-capture keep-side: a live decision must be reconstructable from the page)
- **F2 (high):** Every spec is marked `[x]`, but the repo has no tests or code, so no `@spec` linkage can be checked. · *canonical arrow shape* (HLD → LLD → EARS → Tests → Code) and *tests carry `@spec` annotations*
- **F3 (medium):** The "suspect" printer state is written by the queue (QUEUE-003) but is not defined in the registry design or specs, so the registry's owner never sees the obligation. · *intent attaches at the lowest node that dominates it* (a cross-node obligation should cascade a note to the owning node)
- **F4 (medium):** LLD behaviors with no spec: acceptance only for classes with a registered printer, the two priority classes with FIFO within each, and 90-day slug recycling. · *effective intent-tree alignment* (LLD behaviors with no spec drift silently because nothing tests them)
- **F5 (medium):** The tenets are unordered even though "promise" and "stay small" can conflict, which is exactly what F1 shows. · *tenets capture forward-looking preference*
- **F6 (low):** Cold-read gaps. "Printer class" is never defined (the six printers span three models; are classes models?). Heartbeat cadence and "marked suspect" are left open, and it isn't stated whether suspect printers still receive dispatches. · *LLDs close enough of the solution space*
- **F7 (low):** The 64 MB limit lives in both the Decisions row and QUEUE-001, and the retry and dispatch behavior appears in both the design bullets and the specs. That is fine today, but the two copies can drift. · *coherence is adjacency*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files.
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 specs (5 `QUEUE`, 3 `REG`).
- Arrow-path sampling: not possible beyond the spec level, because the project has no test or code files.
- No `docs/arrows/index.yaml`, so the arrow-maintenance overlay is not installed. The `@spec` reference count is 0.
- Mode: Full. Because the run was non-interactive, I took the skill's defaults and asked no questions.

**Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.