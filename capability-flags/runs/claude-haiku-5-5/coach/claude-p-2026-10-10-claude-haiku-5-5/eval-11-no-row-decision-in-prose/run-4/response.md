**LID coach review: printfarm**

**Executive summary**

Posture: *Solid design layer, with one tenet-level tension to resolve.*

**Scorecard**
- ✓ Linkage: spec IDs are cleanly namespaced (`QUEUE-`, `REG-`), and each prefix matches its LLD's `prefix:` frontmatter.
- ✓ Mutation hygiene: no obsolete markers, changelog sections, or history residue.
- ✓ Mode fit: Full mode matches a single project with two design nodes.
- ✓ Configuration: the instruction file has the LID directive, the mode marker, and the navigation table.
- ⚠ Tenet cascade: one tenet is traded away under a condition the docs themselves describe.
- ⚠ Decision capture: the in-memory queue, the most consequential choice here, lives only in prose.

**Headline:** The arrow is clean for a two-node design: the HLD stays at the architecture level, the EARS specs are well-formed, and the Decisions rows name rejected alternatives and accepted costs. The most valuable next step is deciding whether the in-memory queue keeps the "submitted job is a promise" tenet, then recording that choice either way.

**Findings (9 total · 2 high · 5 medium · 2 low)**
- **F1 (high):** Accepted-but-undispatched jobs are lost on restart, which runs against the "submitted job is a promise" tenet and the "no member present" goal · *tenet cascade: a mechanism working against a tenet, with no record of the trade*
- **F2 (high):** The in-memory queue is a live decision with no Decisions row, so the cost accepted is not recorded · *decision capture: docs carry current intent*
- **F3 (medium):** The registry already persists to SQLite on the same mini-PC, so persisting the pending queue may be a small step. Worth weighing against the "service stays small" tenet · *design concern, separate from F2*
- **F4 (medium):** Cross-class ordering is unspecified. Strict staff-first could starve member jobs, which conflicts with the fair-access goal · *LLDs close enough of the solution space*
- **F5 (medium):** QUEUE-003 marks a printer "suspect," but the registry's state model (REG-002) has only idle, busy, and unreachable. What clears "suspect" is unstated · *coherence is adjacency; LLDs close enough*
- **F6 (medium):** Several LLD behaviors have no spec: the acceptance rule (a class needs a registered printer), FIFO-within-class ordering, slug job IDs, and printer registration (the registry's Context says staff register printers, but no REG spec covers it) · *coherence is adjacency: LLD behaviors with no specs*
- **F7 (medium):** The HLD tenets are unordered, though tenets 1 and 2 can conflict (a promise versus staff reordering) · *tenets capture forward-looking preference: ordered when they could conflict*
- **F8 (low):** "Six printers today" in the registry Context is time-bound; a fresh author would drop "today" · *docs carry current intent*
- **F9 (low):** The arrow is not yet walkable to tests or code: no test files, no `@spec` annotations, no code in this repo. This is normal at the design stage. If the implementation lives elsewhere, it wasn't visible to this review · *tests before code*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`job-queue-design.md`, `printer-registry-design.md`), and both spec files.
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (QUEUE-001–005, REG-001–003).
- Arrow-path sampled: none. The repo has no code or test files and no arrow overlay.
- `@spec` references: 0.
- Cold-read pass: every LID doc in the repo.

**Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.