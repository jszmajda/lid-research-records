# LID Coach — printfarm

**Posture:** Design layer is clean and disciplined; the arrow stops at EARS, and the queue's durability story is the one place the design argues with the HLD.

**Scorecard**
- ✓ HLD discipline — architecture, tenets, and rationale only; no schemas, signatures, or pseudocode bleeding upstream
- ✓ Mutation hygiene — no changelogs, no "was X, now Y", no `[obsolete]` or unconfirmed `[inferred]` markers anywhere
- ✓ Mode fit — Full matches a two-node repo that is LID end to end; no scope section needed
- ✗ Arrow completeness — the Tests and Code phases are absent, while every spec carries a `[x]` done marker
- ⚠ Intent-tree alignment — specs cover roughly half of what the two LLDs describe; prioritization has none at all
- ⚠ Cross-node coherence & decision capture — the registry↔queue seam is under-specified, and the in-memory-queue choice has no Decisions row

**Headline:** The bones here are genuinely good — two design nodes that match the HLD's two architecture concepts exactly, `prefix:` frontmatter making the cascade boundaries explicit, spec files pointing back at their LLD, and Decisions tables that (where they exist) name the rejected alternative *and* the accepted cost, which is better decision capture than most LID projects ever reach. The fastest wins are writing specs for the behaviors the LLDs already describe, and settling whether an accepted-but-undispatched job survives a restart.

**Findings (9 total · 5 high · 3 medium · 1 low)**
- **F1 (high):** No tests or code exist in the repo, yet all 8 specs are marked `[x]` · *canonical arrow shape* — every phase exists for in-scope components; *tests before code*
- **F2 (high):** The in-memory queue drops accepted jobs on restart, which argues with the tenet "a submitted job is a promise" and the overnight-unattended goal · *tenets capture forward-looking preference* — a tenet is the lean a design should follow when no spec covers the call
- **F3 (high):** That durability choice — in-memory, resubmit-on-loss — has no Decisions & Alternatives row, though the sibling node persists to SQLite on the same box · *docs carry current intent* — a live decision a cold reader would still question needs its tradeoff on the page
- **F4 (high):** "Dispatch is event-driven: when the registry reports a printer idle" vs. "the registry polls each printer's status endpoint on an interval" — whether the registry pushes or the queue asks is left open · *LLDs close enough of the solution space* — two reasonable agents should land on compatible implementations
- **F5 (high):** LLD behaviors with no spec: the two-class FIFO prioritization, the accept-only-if-a-printer-is-registered precondition, content-hash upload dedup, printer registration (retire has REG-003), and the 15 s heartbeat interval · *effective intent-tree alignment* — LLD behavior with no spec is unnamed intent with nothing to test against
- **F6 (medium):** Printer-state vocabulary is split across the seam — QUEUE-003 writes a "suspect" state and QUEUE-004 reads a "current job" that the registry's state model (id, class, address, state) does not name · *intent attaches at the lowest node that dominates it* — printer state is registry territory
- **F7 (medium):** The HLD names a member/staff web UI ("members interact through a small web UI; staff see the same queue") but the design tree has two nodes, so upload and queue-view behavior (QUEUE-001, QUEUE-005) lands in job-queue by default · *one LLD per intent component*
- **F8 (medium):** Tenet 1 restates the Goals line rather than giving a lean, and the three tenets are unordered although 1 (a job is a promise) and 3 (the service stays small) pull against each other — which is the collision F2 walked into · *tenets capture forward-looking preference*
- **F9 (low):** The accepted cost "slugs recycle after 90 days" is captured but nothing downstream says what recycling affects · *specs are grep-anchored linkage*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes (`job-queue-design.md`, `printer-registry-design.md`), both spec files
- Enumerated: 2 leaf LLDs, 2 spec files, 8 EARS specs across 2 prefixes (`QUEUE`, `REG`), all marked `[x]`
- Arrow-path sampling: attempted end-to-end on both segments; both terminate at EARS — the repo contains no source or test files, so Tests→Code could not be walked
- Overlay: `docs/arrows/` absent, so no `index.yaml` status, `audited_sha`, or `drift` fields were available; cascade findings are inferred from doc content alone
- Decisions-table sweep: 5 rows reviewed; all 5 pass the cold-reader test (the scheduling-order and job-identifier rows are model examples), so F3 is a missing row, not a weak one
- Dispatch: Full mode read from the `## LID` block; non-interactive run, no defaults needed beyond the one noted below

**Worth a second look:** I could not read the core skill's `references/capability-flags.md` from this session's allowed directories, so per the skill's instruction I am treating the flags as applying. Models in my class are known to miss designs that contradict the project's own tenets — F2 and F8 are exactly that shape, so please check both LLDs against your HLD tenets yourself rather than taking my read as complete.

Want me to walk through the findings in detail, focus on a theme or priority (the spec-coverage gaps in F5 are the cheapest high-value pass), or work through specific items together? You can also pick a single finding to dig into — F2 and F3 are worth treating as one working session.

If you have broader questions about using LID for printfarm — where the web UI belongs in the design tree, whether the arrow-maintenance overlay is worth installing at two segments, how to sequence specs-then-tests-then-code from here, or when a node has outgrown one doc — I can help with those too.