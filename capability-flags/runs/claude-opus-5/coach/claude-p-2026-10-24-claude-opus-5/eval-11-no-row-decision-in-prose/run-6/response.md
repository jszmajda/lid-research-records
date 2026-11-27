## 1. Executive summary

**Posture:** *Solid small arrow, well-reasoned docs — the open edge is durability intent and the EARS layer under-covering the designs.*

**Scorecard**
- ✓ **HLD discipline** — architecture and rationale only; no schemas or signatures bled upstream
- ✓ **Decision capture (where rows exist)** — the FIFO and slug rows name the alternative *and* the accepted cost, which is the hard part
- ⚠ **Tenet cascade** — the queue's in-memory design works against "a submitted job is a promise" under a condition the LLD itself describes
- ⚠ **Intent-tree alignment** — two clean nodes with `prefix:` frontmatter, but several designed behaviors have no spec
- ⚠ **Node boundaries** — printer state (`suspect`, idle-reporting) is written from `job-queue` while `printer-registry` owns it
- ✗ **Arrow completeness** — all eight specs are marked `[x]`, with no tests or code in the repo

**Headline:** Two nodes, clean prefixes, specs that are genuinely EARS-shaped, and Decisions rows that record costs rather than just choices — this is a real arrow at a sensible size for the project. The highest-value next step is settling queue durability: it's the one place where a tenet, a goal, and an unrecorded design choice all meet.

## 2. Findings

**Findings (12 total · 5 high · 5 medium · 2 low)**

- **F1 (high):** `job-queue-design.md:14` holds the queue "entirely in process memory" and has members resubmit jobs lost to a restart — while the same Context names unattended OS updates and power blips, and the HLD's tenet "a submitted job is a promise" plus the goal "evening upload, overnight print, morning pickup — with no member present" both depend on a job surviving the night; no Decisions row records the trade · *tenet cascade* — leaf mechanisms should lean the way the HLD's tenets and goals say to lean, or record the exception
- **F2 (high):** that volatility choice appears only as Architecture prose — there is no Decisions & Alternatives row for it, so a cold reader can't tell what was given up (the registry persists to SQLite on the same box, so durability was clearly available) · *docs carry current intent* — a decision a reader would still want to reverse needs its reasoning on the page
- **F3 (high):** `QUEUE-003` marks a printer "suspect", but printer state is owned by `printer-registry`, whose state model and specs never define `suspect`, how it clears, or whether a suspect printer still receives dispatches · *intent attaches at the lowest node that dominates it* — substance governing both nodes belongs to the owner, not the caller
- **F4 (high):** the `## Prioritization` section (two priority classes, FIFO within class) and the acceptance precondition "accepted only if its target class has at least one registered printer" have no EARS specs at all · *effective intent-tree alignment* — designed behavior with no spec is unnamed intent with nothing to test against
- **F5 (high):** all eight specs carry `[x]` status, yet the repo contains no tests and no code — the arrow stops at EARS while the markers assert otherwise · *canonical arrow shape*, *tests carry `@spec` annotations*
- **F6 (medium):** `QUEUE-002` fires "when the registry reports a printer idle", but `printer-registry-design.md` only describes polling — it never specifies reporting idleness outward, so the event the queue consumes is unspecified on the producing side · *coherence is adjacency*
- **F7 (medium):** `QUEUE-004` has the queue poll every registered printer at startup, duplicating the registry's own heartbeat polling and reaching across the node boundary for state the registry already derives · *verticalize intent*
- **F8 (medium):** the registry specs cover retire (`REG-003`) but not registration, and the 15 s heartbeat interval lives only in a Decisions row with no spec fixing the behavior · *effective intent-tree alignment*
- **F9 (medium):** `QUEUE-005` asks that reordering be "recorded visibly in the queue view" — two reasonable agents would build different things (a log line? an attribution badge? a reason prompt?), while the tenet asks that the queue *explain itself* · *LLDs close enough of the solution space*
- **F10 (medium):** the HLD has no success metrics, and "fair access to the popular printer classes" has no definition a design could be checked against · *HLD is architecture and rationale*
- **F11 (low):** the three tenets are unordered, yet "a submitted job is a promise" and "the service stays small" pull opposite ways on exactly the durability question in F1 — ordering them pre-resolves it · *tenets capture forward-looking preference*
- **F12 (low):** "slugs recycle after 90 days" is an accepted cost whose consequence isn't on the page — a cold reader can't tell what a recycled slug collides with · *docs carry current intent*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), all marked `[x]`
- Arrow-path sampled: both segments walked end-to-end (HLD Architecture → LLD → specs → tests → code); the tests and code phases are absent repo-wide — `find` returned 6 files, all Markdown
- Linkage metric: 0 `@spec` annotations found; 2 of 2 leaves declare `prefix:` frontmatter and both resolve
- Configuration: LID directives present, `- Mode: Full`, version 1.4.0; no `docs/arrows/` overlay, so no structural index was available

---

Want me to walk through the findings in detail, focus on a theme (the durability thread in F1/F2/F11 hangs together, as does the node-boundary thread in F3/F6/F7), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on printfarm — when a node is ready to promote to a sub-HLD, how to handle status markers before implementation starts, where PRDs fit, or what the arrow-maintenance overlay would buy you at this size — I'm happy to get into those too.