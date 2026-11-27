# LID Coach — printfarm

**Posture: Bootstrapping with a clean design layer — the arrow stops at specs, and one architecture choice is fighting your own tenets.**

**Scorecard**
- ✓ Spec & linkage hygiene — 8 IDs, unique, grep-friendly, prefixes match each leaf's `prefix:` frontmatter
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures bleeding upstream
- ✓ Mutation hygiene — no changelog residue, no obsolete markers, docs read as current intent
- ✗ Arrow completeness — no tests and no code anywhere, yet every spec is marked `[x]`
- ⚠ Coherence across levels — the job-queue architecture contradicts an HLD tenet and headline goal
- ⚠ Decision capture — the queue's biggest decision isn't in its Decisions & Alternatives table

The design layer is genuinely well built — a tight HLD, two leaf LLDs that map one-to-one onto its architecture nodes, and EARS specs that trace cleanly to both; the most valuable next step is deciding whether the in-memory queue really honors "a submitted job is a promise," then building the test and code phases the `[x]` markers currently promise.

**Findings (7 total · 2 high · 3 medium · 2 low)**

- **F1 (high):** All 8 specs are marked `[x]` but the repo contains no tests and no code — the arrow isn't walkable below EARS · *coherence is adjacency* — each arrow level must agree with the level next to it
- **F2 (high):** The in-memory queue loses accepted jobs on restart, on a mini-PC the LLD itself says takes unattended OS updates and power blips — colliding with the tenet "a submitted job is a promise" and the evening-upload goal · *coherence is adjacency* (HLD ↔ LLD seam)
- **F3 (medium):** The in-memory-vs-persisted queue decision appears only as architecture prose; a cold reader would ask "why not SQLite, like the registry?" and can't reconstruct the answer · *docs carry current intent* — decision capture: name the rejected alternative and the accepted cost in the Decisions & Alternatives table
- **F4 (medium):** "Suspect" printer state is marked by the queue but unknown to the registry, which owns printer state (idle/busy/unreachable); nothing says what suspect means, who clears it, or whether a suspect printer receives dispatches · *intent attaches at the lowest node that dominates it* — substance affecting both siblings rises to the shared parent, plus *LLDs close enough of the solution space*
- **F5 (medium):** LLD behaviors with no spec: job acceptance requires ≥1 registered printer in the class (job-queue "Dispatch behavior"), and staff registering a printer (registry covers only retirement in REG-003) · *effective intent-tree alignment* — unnamed intent drifts silently because nothing tests it
- **F6 (low):** The three tenets are unordered and do conflict — "job is a promise" vs. "the service stays small" is exactly the tension F2 fell into; ordering them pre-adjudicates it · *tenets capture forward-looking preference*
- **F7 (low):** The project isn't a git repository — LID's "delete, don't accumulate" discipline leans on git preserving history, so today deletion destroys the only copy · *docs carry current intent* — git, not the docs, carries history

**What was audited**
- Read fully: `CLAUDE.md` (LID block: Full mode, v1.4.0 — well-formed), `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`
- Enumerated: 2 design nodes, 8 EARS specs (QUEUE-001–005, REG-001–003), all traced to their leaf LLDs and back to HLD architecture nodes
- Searched project-wide for code, tests, and `@spec` annotations: none exist (this is the basis for F1, not a sampling gap)
- Arrow overlay: `docs/arrows/` not present, so no index to guide sampling — at this size, everything was read, not sampled

**Worth a second look:** I couldn't load the capability-flags reference this session, so I'm treating its flags as applying to me — notably that models in my class can miss designs that contradict a project's own tenets. F2 is my read of that seam, but please check both leaf designs against your HLD tenets yourself.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F2/F3 (the queue-durability decision) and F1 (getting tests and code in place, likely via `/linked-intent-dev`) are where I'd start.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.