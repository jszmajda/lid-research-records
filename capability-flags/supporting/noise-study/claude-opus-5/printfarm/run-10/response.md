# LID Coach — printfarm

**Posture:** Strong design layer, arrow not yet walkable past EARS.

**Scorecard**
- ✓ Design-tree shape — two clean nodes, one EARS segment each, prefixes (`QUEUE`, `REG`) that resolve to real leaves
- ✓ Mutation hygiene — no change-narration, no obsolete markers, no planning residue in any doc
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures bleeding upstream
- ✗ Arrow completeness — the tests and code phases are absent, while every spec is marked done
- ⚠ Coherence — the queue's durability story works against the HLD's own tenet and overnight goal
- ⚠ Spec coverage — several named LLD behaviors, including prioritization, have no spec

**Headline:** The design layer here is genuinely good — the node split is clean, the Decisions tables on scheduling order and job identifiers are model entries that name what was rejected *and* what it cost, and the docs read cold without residue. The fastest wins are reconciling the `[x]` status markers with a repo that has no tests or code yet, and resolving the in-memory queue against the promise the HLD makes members.

---

**Findings (10 total · 4 high · 5 medium · 1 low)**

- **F1 (high):** All 8 specs carry `[x]` complete markers, but the repo holds no tests and no code — zero `@spec` annotations anywhere · *canonical arrow shape* — every phase exists for components in scope
- **F2 (high):** The queue held "entirely in process memory" works against the tenet *a submitted job is a promise*, given the same LLD names unattended OS updates and power blips · *coherence is adjacency* — each level agrees with the one above it
- **F3 (high):** The in-memory-vs-durable choice — the project's largest architecture decision — has no Decisions & Alternatives row · *docs carry current intent, written to be read cold*
- **F4 (high):** The LLD's two-class staff/member FIFO scheme has no spec, and QUEUE-002's "head job" is left undefined against it · *effective intent-tree alignment* — LLD behaviors with no spec are unnamed intent
- **F5 (medium):** `suspect` printer state and the idle-notification contract live in job-queue but appear nowhere in printer-registry's state model · *cascade within a segment, pause across* — the seam between two nodes disagrees
- **F6 (medium):** Two further job-queue behaviors have no spec: acceptance requiring a registered printer, and content-hash file reuse · *effective intent-tree alignment*
- **F7 (medium):** The registry's heartbeat polling interval (15 s, a Decisions row) has no spec; only the three-miss consequence is specified · *effective intent-tree alignment*
- **F8 (medium):** Tenet 2's "no silent reordering" is a triggered rule that already exists as QUEUE-005, and the three tenets are unordered though 1 and 3 can conflict · *tenets capture forward-looking preference* — a tenet is a lean, not a trigger
- **F9 (medium):** The HLD has no Key Design Decisions or Success Metrics sections; "fair access to the popular printer classes" carries no measurable · *HLD is architecture and rationale*
- **F10 (low):** "slugs recycle after 90 days" implies a job-retention policy that is stated nowhere else in the project · *docs carry current intent, written to be read cold*

---

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (both design nodes and both spec files) — the entire repository, 6 files
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), 2 Decisions & Alternatives tables totalling 5 rows
- Arrow-path attempted end-to-end on both segments: HLD Architecture → LLD → spec → **test (none found)** → **code (none found)**
- Linkage metric: 0 `@spec` references across the repository; no source or test files of any kind present
- Arrow-maintenance overlay: not installed (`docs/arrows/` absent), so the review draws on direct reads rather than `index.yaml` status fields
- Decisions-table sweep run over all 5 rows; 4 pass the cold-reader test, and the gap is a missing row rather than a thin one
- Mode: Full, declared in the `## LID` block — matches reality; the whole repo is LID-shaped

**Worth a second look:** I could not read the core skill's `references/capability-flags.md` — it sits outside this session's accessible directories — so per the skill's own guidance I am treating the flags as applying to me. The relevant one for this review is that models in my class tend to miss designs that quietly contradict the project's own tenets. I did surface one such case (F2), which makes me more rather than less inclined to ask: please re-read both leaf designs against your three HLD tenets yourself, particularly *the service stays small*, which the fix for F2 will push against.

---

Want me to walk through the findings in detail, focus on a theme or priority band, or work through specific items together? F2, F3, and F4 form one connected thread about durability and fairness if you'd like to start there, and F1 is a quick reconcile once you tell me where the implementation stands.

If you have broader questions about using LID on printfarm — when a node is ready to split, how to sequence tests-before-code from a design layer that's already written, where a product brief would sit relative to the HLD — I'm glad to think those through with you too.