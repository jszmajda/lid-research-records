## LID Coach — printfarm

**Solid bootstrapping; the arrow is well-shaped upstream but thins out downstream, and a couple of intent seams need attention.**

**Scorecard**
- ✓ Design tree & granularity — two clean leaf LLDs (`job-queue`, `printer-registry`) with matching `prefix:` frontmatter
- ✓ Mutation hygiene — docs read as current intent; no changelog residue or obsolete markers
- ✓ HLD discipline — architecture/rationale only; no schema or code detail bleeding upstream
- ⚠ Arrow completeness — specs are present, but there are no tests and no code to close the arrow
- ⚠ Tenet cascade — the "upload and walk away" promise is undercut by an in-memory queue
- ⚠ Spec craft — an undefined status legend and a cross-node "suspect" state

**Findings (8 total · 3 high · 3 medium · 2 low)**
- **F1 (high):** No tests and no code exist anywhere, yet every spec is marked `[x]` — the tests-first and code phases are unrepresented · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code) and *coherence is adjacency*
- **F2 (high):** The tenet "a submitted job is a promise: upload and walk away" is defeated by `job-queue-design.md:14` — the queue is in process memory and "jobs accepted but not yet dispatched before a restart are gone," under Context that lists power blips — and no Decisions row records the exception · *tenet cascade* (design nodes should lean the way the tenets say)
- **F3 (high):** "Suspect" is minted by `QUEUE-003` and `job-queue-design.md:21` but never defined or owned — the registry models only idle/busy/unreachable, so what a suspect printer is, whether it still receives dispatches, and how it clears are all unstated · *LLD sufficiency* and *effective intent-tree alignment* (substance spanning both nodes belongs at their shared parent)
- **F4 (medium):** The in-memory queue choice — the one a cold reader would most want to reverse — has no Decisions & Alternatives row; only the consequences are narrated in prose · *decision capture* (docs carry current intent, keep-side)
- **F5 (medium):** The HLD omits Success Metrics and Key Design Decisions; Goals exist but nothing states how "overnight print" or "fair access" are measured · *HLD discipline* (HLD carries why)
- **F6 (medium):** The `[x]` marker on every spec has no legend; a cold reader can't tell whether it means "accepted" or "implemented" — and combined with F1, either reading is misleading · *docs carry current intent, written to be read cold*
- **F7 (low):** Two spec-craft nits — `QUEUE-001` scopes the 64 MB limit to member uploads only (staff uploads are unaddressed), and `QUEUE-005`'s "record the reordering visibly" leaves "visibly" undefined · *scope disambiguation*
- **F8 (low):** The three tenets are unordered though they can conflict (the "promise" leans toward durability, "stays small" toward simplicity), and the first tenet restates a goal rather than acting as a tie-breaker · *tenets capture forward-looking preference*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes, both spec files
- Enumerated: 1 HLD, 2 LLDs, 8 EARS specs (5 `QUEUE`, 3 `REG`)
- No `docs/arrows/` overlay present; no source or test files exist to sample
- Sampling depth: exhaustive — the project is docs-only

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — where tests-first fits when the code doesn't exist yet, how to model a state like "suspect" that spans two nodes, mode transitions, or where decisions like the in-memory queue should be recorded — I can help with those too.