# LID Coach — printfarm

**Posture:** Well-formed arrow, design-layer content ahead of a live implementation; the sharpest gaps are between the HLD's promises and the job-queue's design.

**Scorecard**
- ✓ Linkage & ID hygiene — clean `QUEUE-`/`REG-` namespacing, `prefix:` frontmatter, every spec file naming its LLD
- ✓ Mutation hygiene — docs read as current intent throughout; no history residue, no `[obsolete]` markers
- ✓ HLD discipline — architecture and rationale only, no schemas or signatures bleeding upstream
- ⚠ Intent-tree alignment — several LLD behaviors, including prioritization, carry no spec
- ⚠ Cascade coherence — the job-queue design trades against an HLD tenet and a goal without saying so
- ✗ Arrow completeness — all eight specs are marked done, but no tests or code exist in the repo

**Headline:** Two clean design nodes, disciplined specs, and an HLD with real tenets mean the arrow is genuinely walkable from the top — the highest-value move now is reconciling the job-queue's in-memory design (and its `[x]` spec markers) with what the HLD promises members.

---

**Findings (11 total · 4 high · 5 medium · 2 low)**
- **F1 (high):** All 8 specs carry `[x]`, yet the repo holds no tests and no code — the arrow stops at EARS · *canonical arrow shape* + *tests before code* (each phase exists for components in scope; tests lead implementation)
- **F2 (high):** The in-memory queue drops accepted-but-undispatched jobs on restart, against the tenet "a submitted job is a promise" — on the overnight, member-absent path the project exists to serve · *coherence is adjacency* (each level agrees with the one above it)
- **F3 (high):** That volatility choice appears nowhere in job-queue's Decisions & Alternatives — no rejected persistence option, no accepted cost — while the sibling registry persists to SQLite in the same service · *docs carry current intent* (a cold reader should be able to reconstruct the choice)
- **F4 (high):** Prioritization — two priority classes, FIFO within a class — is the core of the HLD's fair-access goal and has no EARS spec, so nothing downstream can test it · *effective intent-tree alignment* (LLD behaviors with no spec are unnamed intent)
- **F5 (medium):** `QUEUE-003` marks a printer "suspect", a state the printer-registry LLD neither defines nor clears · *intent attaches at the lowest node that dominates it; pause across boundaries* (substance spanning siblings belongs at the shared parent, with a note cascaded across)
- **F6 (medium):** `QUEUE-004` has the queue poll printers directly at startup, duplicating the registry's ownership of printer communication · *one LLD per intent component* (silently overlapping scopes hide the seam)
- **F7 (medium):** Staff reordering is spec'd (`QUEUE-005`, "record visibly") but has no design in the job-queue LLD — whether a reorder outranks a staff-class job, or survives the next dispatch, is left open · *LLDs close enough of the solution space* (open edges are where agents fill in intent)
- **F8 (medium):** Three more LLD behaviors carry no spec: the accept-only-if-a-printer-is-registered precondition, content-hash file storage, and the 90-day slug recycle · *effective intent-tree alignment*
- **F9 (medium):** The FIFO row accepts "one long job can hold a class for hours, mitigated by staff reordering" — a mitigation unavailable during the unattended overnight window the HLD targets · *coherence is adjacency* (a leaf decision quietly trading an HLD goal)
- **F10 (low):** The three tenets are unordered, though "a submitted job is a promise" and "the service stays small" pull opposite ways — and the queue's design reads as an unstated resolution of exactly that conflict · *tenets capture forward-looking preference* (ordering is what makes a tenet a tie-breaker)
- **F11 (low):** The HLD names "fair access to the popular printer classes" as a goal with no success metric, so nothing downstream can tell whether the queue achieves it · *HLD is architecture and rationale*

---

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes (`job-queue`, `printer-registry`) and both spec files — every LID doc in the project
- Enumerated: 1 HLD, 2 leaf LLDs, 2 EARS segments, 8 specs (5 `QUEUE-`, 3 `REG-`), all marked `[x]`
- Arrow-path attempted end-to-end on both segments: HLD § → LLD → spec resolves cleanly; test and code phases found empty (repo contains 6 files, all Markdown)
- Linkage metric: 0 `@spec` references found anywhere in the project
- Cold-read pass over all five docs, plus the decisions-table sweep across all 5 Decisions & Alternatives rows
- No `docs/arrows/` overlay present; at 8 specs, structural audit tooling isn't yet earning its keep
- Dispatch: Full mode per `CLAUDE.md`, directives and mode marker present — full review, no configuration reconciliation needed

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets, and I could not load my capability flags this run, so I'm assuming they apply. F2, F9, and F10 all live in that area — please check the two leaf designs against your HLD tenets and goals yourself.

---

Want me to walk through the findings in detail, focus on a theme or priority (the job-queue design cluster — F2, F3, F9 — is the densest), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on printfarm — when to promote a node to a sub-HLD, how to sequence specs and tests ahead of the first implementation, or when the arrow overlay starts paying for itself — I'm glad to work through those too.