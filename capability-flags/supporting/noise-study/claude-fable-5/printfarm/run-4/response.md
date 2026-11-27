**LID Coach Review — printfarm**

*Posture: clean, well-shaped intent layer; the arrow currently stops at the specs.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas or API shapes bleeding upstream
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, obsolete markers, or planning residue
- ✓ LLD granularity — two leaf nodes matching the HLD's two architecture concepts, prefixes (`QUEUE`, `REG`) resolving cleanly
- ✗ Arrow completeness — all 8 specs are marked `[x]` implemented, but the repo contains no tests or code phases at all
- ⚠ Tenet coherence — the job-queue's loss-on-restart design leans against the "a submitted job is a promise" tenet
- ⚠ Spec coverage — a couple of LLD behaviors carry no spec ID

**Headline:** The design layer is genuinely good — a tight HLD with real tenets, two well-scoped LLDs, and clean EARS specs; the most valuable next step is reconciling the `[x]` status markers with the missing tests/code phases so the arrow can actually be walked end-to-end.

**Findings (7 total · 3 high · 3 medium · 1 low)**

- **F1 (high):** All 8 specs are marked `[x]`, yet the repository contains no code and no tests — no `@spec` annotation exists anywhere for the arrow to land on · *coherence is adjacency* — each arrow level must agree with its neighbor; specs claiming implementation with no implementation is the seam at its widest. If code lives in another repo, say so in the instruction file; otherwise consider flipping the markers to unimplemented, or building the tests-then-code phases forward (`/linked-intent-dev` with the change you want is the right entry point).
- **F2 (high):** The job-queue holds accepted jobs only in process memory, and the LLD itself notes the mini-PC "takes unattended OS updates and the occasional power blip" — an accepted-but-undispatched evening upload can vanish overnight, in tension with the tenet "a submitted job is a promise: members should be able to upload and walk away" and the evening-upload/morning-pickup goal · *coherence is adjacency* — downstream design should agree with the declared upstream intent. Worth deciding deliberately: persist the queue (the registry already has SQLite), or soften the tenet.
- **F3 (high):** `job-queue-design.md` marks a failing printer "suspect," but no doc defines what suspect means — does it still receive dispatches? how does it recover? — and printer state is the registry's territory, defined there as unreachable/idle/busy · *intent attaches at the lowest node that dominates it* — a state concept both nodes depend on belongs where both can see it. Consider defining suspect in the registry LLD (or the HLD if it truly spans both) and having job-queue reference it.
- **F4 (medium):** The in-memory-queue durability choice — the very decision F2 turns on — has no row in Decisions & Alternatives; a cold reader can't reconstruct what persistence option was rejected or what loss rate was accepted · *decision capture* — live decisions a reader would still question need the tradeoff on the page. An expanded table row naming the rejected alternative and accepted cost is enough; this stands whether or not you revisit the design in F2.
- **F5 (medium):** Two LLD behaviors have no spec: the acceptance rule (reject a job whose class has no registered printer) and staff-before-member dispatch ordering · *effective intent-tree alignment* — LLD behavior with no spec is unnamed intent with nothing to test against. Consider adding `QUEUE-006`/`QUEUE-007` rather than renumbering.
- **F6 (medium):** Tenet 2's second clause ("no silent reordering") is a triggered rule already captured as QUEUE-005, and the three tenets are unordered even though tenets 1 and 3 genuinely conflict — F2 is that conflict being resolved silently toward "the service stays small" · *tenets capture forward-looking preference* — tenets are tie-breakers, and ordering them pre-decides exactly this kind of collision. Consider trimming tenet 2 to its lean and ranking the list.
- **F7 (low):** "Printer class" is load-bearing (queues, acceptance, dispatch all key off it) but never defined — a cold reader can't tell whether class means hardware model, bed size, or something staff assign · *docs carry current intent, written to be read cold*. One sentence in the registry LLD would settle it.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (8 EARS specs: 5 `QUEUE`, 3 `REG`)
- Searched the whole repo for tests, code, and `@spec` annotations: none present (6 files total, all docs)
- Arrow-maintenance overlay (`docs/arrows/`): not installed — optional, not flagged
- Configuration: LID directives present, `Mode: Full` declared and matching project reality

**Worth a second look:** I couldn't load the capability-flags reference in this run, so I'm treating its flags as applying — models in my class are known to miss designs that contradict a project's own tenets. Please check both leaf designs against your HLD tenets yourself, especially the job-queue durability choice (F2).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F2/F4 make a natural pair — to dig into.

If you have broader questions about using LID for your project — where the future web UI should live in the design tree, when a node like job-queue should split, mode transitions, multi-repo setups — I can help with those too.