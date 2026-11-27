**LID Coach — printfarm**

**Posture:** Well-formed intent layer; the arrow stops at specs, and the two nodes don't yet agree at their seam.

**Scorecard**
- ✓ Mutation hygiene — no history residue, no `[obsolete]` or stale `[inferred]` markers; both docs read as current intent
- ✓ Mode fit — Full mode matches a two-node project of this size; `prefix:` frontmatter makes the leaf boundaries explicit
- ⚠ Intent-tree alignment — every spec traces to a leaf, but several load-bearing LLD behaviors have no spec
- ⚠ Decision capture — the strongest rows name the rejected option and its cost; the biggest design choice has no row at all
- ✗ Arrow completeness — no tests or code exist yet, while all 8 specs carry `[x]`
- ✗ Cross-node coherence — job-queue and printer-registry describe their integration in opposite directions

**Headline:** The design layer is genuinely good — two clean nodes, grep-anchored IDs, EARS specs that actually say *when X, do Y*, and a Decisions table that already models best practice ("SJF rejected: members game it by splitting prints; accepted cost: one long job can hold a class for hours"). The fastest win is settling the dispatch contract between the two nodes and getting the queue's durability decision onto the page before any code is written against either.

**Findings (11 total · 4 high · 5 medium · 2 low)**
- **F1 (high):** All 8 specs are marked `[x]` but the repo contains no tests and no code · *coherence is adjacency* — each arrow level agrees with the one next to it
- **F2 (high):** job-queue describes dispatch as push ("when the registry reports a printer idle"), printer-registry describes it as pull ("the queue asks the registry which printers are idle"); neither side has a spec for the handoff · *coherence is adjacency*
- **F3 (high):** The in-memory queue drops accepted-but-undispatched jobs on restart, on a mini-PC that "takes unattended OS updates and the occasional power blip" — during the overnight window the tenet "a submitted job is a promise" protects · *tenets capture forward-looking preference* — a tenet is the lean a design should follow when no spec covers the call
- **F4 (high):** Central LLD behaviors carry no EARS spec — staff/member priority ordering and FIFO, accept-only-if-the-class-has-a-registered-printer, content-hash file storage, job loss on restart, printer registration (only retirement has one), the 15 s heartbeat interval · *effective intent-tree alignment* — behaviors without specs are unnamed intent with nothing to test against
- **F5 (medium):** The choice to hold the queue in memory and rebuild by polling printers on startup isn't in job-queue's Decisions & Alternatives, though the registry's neighboring SQLite row shows persistence was on the table · *docs carry current intent* — decision capture; a cold reader can't reconstruct what was traded away
- **F6 (medium):** QUEUE-003 has the queue mark a printer "suspect", but printer state lives in the registry, whose model is idle/busy/unreachable — "suspect" has no home · *intent attaches at the lowest node that dominates it*
- **F7 (medium):** QUEUE-001 scopes the 64 MB limit to "a member" while the LLD states it per G-code file; staff uploads are the second variant that makes it ambiguous · *scope disambiguation* — a spec must name its scope or truly be universal
- **F8 (medium):** The HLD goal "fair access to the popular printer classes" has no downstream owner; the queue's FIFO explicitly accepts one long job holding a class, mitigated only by staff reordering · *effective intent-tree alignment*
- **F9 (medium):** "class" means both printer class and priority class inside job-queue-design.md, and "heartbeat" names a registry-initiated poll · *semantic legibility as cheap linkage* — names should echo intent so an agent doesn't have to reload docs to recover it
- **F10 (low):** Tenet 2 ("no silent reordering") is phrased as a triggered rule and is already fixed by QUEUE-005; the tenet list is unordered though tenets 1 and 3 (durability vs. staying small) pull against each other in F3 · *tenets capture forward-looking preference*
- **F11 (low):** The HLD has no key-design-decisions section and no success metrics for its two goals · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (2 design nodes, 2 spec files)
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs across 2 prefixes (`QUEUE`, `REG`); 6 files in the repo total
- Linkage check: 0 `@spec` annotations found — no test or source files exist in the repo yet
- Arrow overlay: `docs/arrows/` is absent, so no `index.yaml` segment/drift data was available; no `/arrow-maintenance` cross-check
- Passes run: dimension review, cold-read pass through all five LID docs, and a row-by-row Decisions & Alternatives sweep (5 rows across both nodes)

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets, and I couldn't load the capability-flags reference in this session, so I'm assuming the flags apply. F3 is one such contradiction I did catch — please read both leaf designs against your three HLD tenets yourself, particularly "the service stays small," which is the tenet most likely to be quietly overridden as behavior accretes.

Want me to walk through the findings in detail, focus on a theme or priority (the cross-node seam in F2/F6 is the tightest cluster), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on printfarm — when to split a node, where the web UI's intent should live, how to handle the pre-implementation `[x]` convention, or whether the arrow-maintenance overlay is worth installing at this size — I can help with those too.