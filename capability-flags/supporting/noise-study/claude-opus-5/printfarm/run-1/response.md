**Posture: clean head of the arrow, unbuilt tail — well-written docs with two unresolved cross-node seams and one load-bearing decision that never made it onto the page.**

**Scorecard**
- ✓ Mutation hygiene — both design nodes read as current intent; no changelog residue, no `[obsolete]` markers, no planning text
- ✓ Linkage IDs — `QUEUE-`/`REG-` prefixes match each node's `prefix:` frontmatter, zero-padded, unique, grep-clean
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures bleeding upstream
- ✗ Arrow completeness — the arrow stops at EARS; no tests, no code, though every spec is checked off
- ⚠ Cross-node coherence — the registry→queue idle contract and the "suspect" printer state have no owner
- ⚠ Decision capture — the in-memory-queue choice, the one a cold reader would question first, isn't in any Decisions table

**Headline:** For a two-node project this is genuinely well-shaped — the HLD carries real tenets rather than platitudes, the design nodes map cleanly onto the architecture section, the Decisions tables already name rejected alternatives and accepted costs (the FIFO and base32-slug rows are models of the form), and nothing has accumulated. The highest-value next step is settling the durability question in `job-queue`: write the in-memory-queue decision into its Decisions & Alternatives table, since it currently sits against your own "a submitted job is a promise" tenet and everything downstream — including the code you haven't written yet — will be built on whichever way it lands.

**Findings (11 total · 5 high · 5 medium · 1 low)**
- **F1 (high):** every spec in both files is marked `[x]`, but the repo has no tests and no code for them to describe · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code; *tests before code*
- **F2 (high):** `job-queue` drops accepted-but-undispatched jobs on restart, on hardware its own Context section says takes unattended updates and power blips — against the tenet "a submitted job is a promise" and the goal "evening upload, overnight print, morning pickup" · *coherence is adjacency* — each level agrees with the one above it
- **F3 (high):** that persistence choice appears nowhere in `job-queue`'s Decisions & Alternatives — a cold reader can't tell what was given up or what cost was accepted · *docs carry current intent* — the page must stand without the conversation that produced it
- **F4 (high):** QUEUE-002 fires "when the registry reports a printer idle," but the registry's design only polls on an interval and no REG spec covers reporting or notifying a transition · *effective intent-tree alignment* — behaviors named in a design need a spec somewhere
- **F5 (high):** QUEUE-003 marks a printer "suspect," a state the registry's state model (id, class, address, state / idle, busy, unreachable) never defines · *intent attaches at the lowest node that dominates it* — printer state governs both nodes, so it belongs to the registry
- **F6 (medium):** `job-queue` behaviors with no spec — the "accepted only if its class has a registered printer" rule, the whole Prioritization section (staff/member, FIFO), and content-hash dedupe · *effective intent-tree alignment*
- **F7 (medium):** `printer-registry` behaviors with no spec — staff *registering* a printer (only retire, REG-003, is covered) and the 15 s heartbeat interval · *effective intent-tree alignment*
- **F8 (medium):** the three tenets are an unordered list, yet "a submitted job is a promise" and "the mini-PC is modest; the service stays small" pull opposite ways on exactly the open durability question · *tenets capture forward-looking preference* — order them when they can conflict
- **F9 (medium):** tenet 2's "no silent reordering" is a triggered *when X, do Y* rule already carried by QUEUE-005, rather than a lean · *tenets capture forward-looking preference* — lean, not trigger
- **F10 (medium):** the on-disk content-hash G-code store has no retention or eviction edge, and "slugs recycle after 90 days" implies a job-history window described nowhere · *LLDs close enough of the solution space* — open edges are where agents guess
- **F11 (low):** the HLD has no success metrics, and target users appear only in the Problem prose · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (`job-queue-design.md`, `job-queue-specs.md`, `printer-registry-design.md`, `printer-registry-specs.md`)
- Enumerated: 2 leaf design nodes, 2 spec files, 8 EARS specs (5 QUEUE, 3 REG), all marked `[x]`; 5 Decisions & Alternatives rows swept
- Linkage metric: 0 `@spec` annotations — no code or test files exist in the repository
- Not present: `docs/arrows/` overlay (not required; at two nodes the index would be thin), sub-HLDs, `[inferred]` markers
- Sampling: exhaustive, not sampled — the project is well under the arrow-path sampling thresholds. Cold-read pass run over all five LID docs
- Dispatch: Full mode, read from the `## LID` block; the project is fully configured, so no dispatch question arose and no defaults had to be assumed

**Worth a second look:** I couldn't read the core skill's `references/capability-flags.md` (it sits outside this session's reachable directories), so per the skill's own instruction I treat the flags as applying. Models in my class are known to miss designs that contradict the project's own tenets — that is exactly the territory of F2 and F8, so please read both leaf designs against your HLD tenets yourself rather than taking my read as complete.

Want me to walk through the findings in detail, focus on a theme (the cross-node seams, say, or the tenet set) or a priority band, or work through specific items together? You can also pick a single finding — F2/F3 are a natural pair to start with, since the design question and the capture question are separable and both are cheap to settle before any code exists.

If you have broader questions about using LID on printfarm — when a node should split, where a PRD for the member-facing UI would fit, whether the arrow overlay is worth installing at this size, or how much to write down before implementation starts — I can help with those too.