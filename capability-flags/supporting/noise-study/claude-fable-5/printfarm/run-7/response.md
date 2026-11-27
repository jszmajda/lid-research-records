**LID Coach — printfarm**

**Posture: Bootstrapping — the intent layer is clean and real; the arrow stops at specs.**

**Scorecard**
- ✓ Configuration — LID directives, Full-mode marker, and standard layout all in place
- ✓ Mutation hygiene — every doc reads as current intent; no history residue anywhere
- ✓ Spec hygiene — grep-friendly, prefix-namespaced IDs with properly scoped WHEN clauses
- ✗ Arrow completeness — no tests or code exist in the repo, yet all 8 specs are marked `[x]`
- ⚠ Cross-node coherence — the two LLDs disagree at their shared seam (idle signaling, "suspect" state)
- ⚠ Decision capture — the queue-durability choice is nowhere in the Decisions table

**Headline:** The intent layer is genuinely well-built — a tight HLD with real tie-breaker tenets, one LLD per component, exemplary Decisions & Alternatives rows, and clean EARS specs; the single most valuable next step is making the arrow tell the truth about where the project stands, by reconciling the `[x]` status markers with the absent tests and code.

**Findings (8 total · 2 high · 5 medium · 1 low)**
- **F1 (high):** All 8 specs are marked `[x]`, but the repo contains no tests and no code — the Tests and Code phases of the arrow don't exist yet while the status markers claim completion · *coherence is adjacency* — each arrow level must agree with its neighbor, and *tests before code*. If the implementation lives elsewhere, say so in the docs; if it doesn't exist yet, reset the markers so future sessions don't trust a finished arrow that isn't.
- **F2 (high):** The job-queue holds accepted jobs only in process memory and accepts losing undispatched jobs on restart — on a mini-PC the same LLD says takes unattended OS updates and power blips — which sits in tension with the HLD tenet "a submitted job is a promise: upload and walk away" and the evening-upload/overnight-print goal · *coherence is adjacency* — the LLD should agree with the HLD above it. Consider persisting the queue (SQLite is already in the stack next door) or narrowing the tenet.
- **F3 (medium):** The memory-only-queue choice from F2 appears nowhere in job-queue's Decisions & Alternatives table — a cold reader would question and likely try to reverse it · *decision capture*. An expanded row naming the rejected alternative (persist to SQLite) and the accepted cost (resubmission after restarts) is the right size; this stays a finding even if the design itself changes.
- **F4 (medium):** The two LLDs disagree on the idle-signal interface: job-queue and QUEUE-002 say the registry *reports* a printer idle (push), while printer-registry's Context says the queue *asks* the registry (pull) · *LLDs close enough of the solution space* — two reasonable agents reading these would build incompatible halves. Pick one direction and state it in both nodes.
- **F5 (medium):** "Marked suspect" (job-queue's dispatch-failure behavior, QUEUE-003) is a printer state the registry — which owns printer state (idle/busy/unreachable) — never models · *intent attaches at the lowest node that dominates it* — substance affecting a sibling should rise to the shared parent or land in the node that owns it. Decide whether "suspect" is a registry state and document it there, or in the HLD if it spans both.
- **F6 (medium):** A few job-queue behaviors have no spec: the acceptance rule ("a job is accepted only if its target class has at least one registered printer") and staff registration of printers on the registry side · *effective intent-tree alignment* — LLD behavior with no spec is unnamed intent with nothing to test against.
- **F7 (medium):** "Two priority classes: staff and member. Within a class, first-in-first-out" leaves open how the classes interleave — strict staff-first? can members starve? · *LLDs close enough of the solution space* — this is exactly the edge an implementing agent would fill in with a guess.
- **F8 (low):** The tenets are strong (each has a defensible opposite), but they're unordered though they can conflict ("the queue explains itself" vs. "the service stays small"), and the second tenet's tail ("no silent reordering") is a triggered rule already living correctly as QUEUE-005 · *tenets capture forward-looking preference* — consider ordering them and trimming the tenet back to the lean.

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs and both spec files under docs/intent/ (all 6 files in the project)
- Enumerated: 2 design nodes, 8 EARS specs (QUEUE-001–005, REG-001–003)
- Searched for tests, code, and `@spec` annotations project-wide: none found
- Arrow-maintenance overlay: not installed (no docs/arrows/), so no index to sample from

**Worth a second look:** I wasn't able to load the capability-flags reference in this environment, so per its fallback I'm treating its flags as applying to me. Design-vs-tenet contradiction (the area behind F2) is exactly the kind of judgment call those flags cover — please check the leaf designs against your HLD tenets yourself rather than taking F2 on my word alone.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.