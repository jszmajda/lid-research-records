# LID Coach — printfarm

**Posture: Solid design layer; the arrow stops at EARS and one load-bearing trade is unrecorded.**

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; tenets, goals, non-goals all present
- ✓ Linkage — 8 EARS specs, IDs unique, `QUEUE`/`REG` prefixes match each LLD's `prefix:` frontmatter and the HLD's two nodes
- ✓ Mutation hygiene — no history residue, no `[obsolete]`/`[inferred]` markers, no changelog sections anywhere
- ✗ Arrow completeness — no tests, no code; specs carry an undocumented `[x]`
- ⚠ Tenet cascade — the "submitted job is a promise" tenet meets a queue that forgets jobs on restart
- ⚠ Decision capture — the durability choice survives only in Architecture prose

**Findings (8 total · 4 high · 2 medium · 2 low)**
- **F1 (high):** the in-memory queue loses accepted jobs on restart — a condition the Context itself names ("unattended OS updates and the occasional power blip") — while the HLD's first tenet says a submitted job is a promise · *tenet cascade* (design nodes should lean the way the HLD's tenets say to lean)
- **F2 (high):** queue durability (in-memory, no persistence, members must resubmit) has no row in job-queue's Decisions & Alternatives — a cold reader can't reconstruct what persisting would have cost · *decision capture* (live decisions recorded in full)
- **F3 (high):** the queue↔registry seam is described as push by job-queue ("event-driven: when the registry reports a printer idle") and as pull by printer-registry ("the queue asks the registry which printers are idle") — two agents could build opposite interaction models · *coherence is adjacency* (each level agrees with its neighbor)
- **F4 (high):** the arrow ends at EARS — no tests or code exist, yet all 8 specs are marked `[x]`, a marker defined nowhere · *canonical arrow shape* (phases: HLD → LLD → EARS → Tests → Code) and *tests carry `@spec` annotations*
- **F5 (medium):** job-queue says a failed dispatch makes the *printer* "suspect," but printer-registry owns printer state and never defines suspect or who clears it — substance lodged in a leaf where it actually dominates a sibling · *intent attaches at the lowest node that dominates it* (consider raising the shared contract to the HLD or specifying it on the registry side)
- **F6 (medium):** open edges a reasonable agent would have to fill: how "staff" is established (QUEUE-005 presumes it), how printers get registered, and what happens to queued jobs when the last printer of a class is retired (REG-003) · *LLDs close enough of the solution space*
- **F7 (low):** three tenets in an unordered list, though "queue explains itself" and "the service stays small" can conflict — no stated precedence · *tenets capture forward-looking preference*
- **F8 (low):** CLAUDE.md's `Version: 1.4.0` doesn't say what it versions; a cold reader has to guess · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, and all 4 files under docs/intent/ (the entire repository — 6 files)
- Enumerated: 2 LLDs, 2 spec files, 8 spec IDs (QUEUE-001…005, REG-001…003)
- Sampled: 0 code and 0 test files — none exist in the repo
- Linkage metric: 0 `@spec` references; no `docs/arrows/` overlay present

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.