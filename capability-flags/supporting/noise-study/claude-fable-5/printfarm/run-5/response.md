I've read the skill, the project's CLAUDE.md, the HLD, both LLDs, and both spec files. The project is fully configured (LID directives present, Mode: Full, standard directories), so per the dispatch table I ran a full review. No user-input points arose (the only ask-the-user branch is a corrupted `docs/arrows/index.yaml`, and no overlay is installed). One note: the sibling skill's `references/capability-flags.md` was not readable in this run, so per the skill's conservative default I treated the flags as applying.

# LID Coach — printfarm

**Posture: Bootstrapping — a clean, well-shaped intent layer; the arrow currently stops at specs.**

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas or API shapes bleeding upstream
- ✓ Mutation hygiene — every doc reads cold and current; no changelog residue or conversational fossils
- ✓ Linkage naming — spec IDs are unique, zero-padded, and anchored by each leaf's `prefix:` frontmatter
- ✗ Arrow completeness — no tests or code exist anywhere, yet every spec is marked `[x]`
- ⚠ Cross-node coherence — the two design nodes disagree quietly about printer state, and one design sits in tension with an HLD tenet
- ⚠ Spec coverage — several behaviors the LLDs commit to have no spec naming them

The intent layer here is genuinely good for a project this young — a tight HLD with real tenets, two well-scoped design nodes, and clean EARS specs. The single most valuable next step is closing the arrow below the spec layer (tests and code carrying `@spec`, or an honest note about where implementation lives), and deciding on purpose whether losing queued jobs on restart is compatible with "a submitted job is a promise."

**Findings (8 total · 2 high · 4 medium · 2 low)**
- **F1 (high):** Tests and Code phases are absent while all 8 specs carry `[x]` done-markers — either implementation lives outside this repo (worth stating where) or the markers are ahead of reality · *canonical arrow shape* — missing phases should be explicit choices, not drift
- **F2 (high):** job-queue's in-memory queue drops accepted-but-undispatched jobs on restart, on a mini-PC the LLD itself says takes unattended updates and power blips — in tension with the HLD tenet "a submitted job is a promise: upload and walk away" · *coherence is adjacency* — each level should agree with the one above it
- **F3 (medium):** the in-memory-queue/job-loss choice lives only in `job-queue-design.md` Architecture prose, not in Decisions & Alternatives — a cold reader would question it, and no rejected alternative (e.g., persisting the queue in the registry's SQLite file) or accepted cost is on record · *decision capture* — the smallest fix is one fuller table row
- **F4 (medium):** QUEUE-003 marks a failing printer "suspect," but printer state is the registry's territory and its state model (idle/busy/unreachable) has never heard of "suspect" — substance shared by two siblings should rise to their shared parent or be coordinated across the boundary · *intent attaches at the lowest node that dominates it*
- **F5 (medium):** several LLD-committed behaviors have no spec: the accept-only-if-class-has-a-printer rule, staff-before-member priority ordering, and content-hash upload dedup · *effective intent-tree alignment* — unnamed intent drifts silently because nothing can test against it
- **F6 (medium):** "class" is overloaded — printer class vs. priority class — so QUEUE-002's "dispatch the head job of that printer's class" is ambiguous the moment priority ordering applies · *scope disambiguation* — a spec found by grep must be unambiguous out of context
- **F7 (low):** staff/member identity (who counts as staff, how the system knows) is behavior both nodes rely on but neither designs — consider naming its owner before implementation starts · *one LLD per intent component*
- **F8 (low):** the three tenets are unordered, and tenets 1 ("a job is a promise") and 3 ("the service stays small") pull opposite ways on exactly the queue-durability question in F2 — consider ranking them · *tenets capture forward-looking preference*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`
- Enumerated: 2 design nodes, 2 spec files, 8 EARS specs (QUEUE-001–005, REG-001–003)
- Linkage metric: 0 files carrying `@spec` annotations — no test or code files exist in the project, so no arrow-path sampling below the spec layer was possible
- Arrow-maintenance overlay: not installed (no `docs/arrows/`)

**Worth a second look:** I could not load the capability-flags reference this run, so I'm treating its flags as applying — models in my class can miss designs that contradict a project's own tenets. F2 is where I looked, but please check both leaf designs against your HLD tenets yourself.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.