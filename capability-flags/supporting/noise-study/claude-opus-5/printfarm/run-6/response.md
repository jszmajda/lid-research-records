## /lid-coach — printfarm

**Posture:** Clean, well-formed intent layer; the arrow stops at EARS and the queue's durability story disagrees with its own tenet.

**Scorecard**
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, no `[obsolete]` residue, no `[inferred]` backlog
- ✓ Spec form — tight EARS phrasing, stable `QUEUE-`/`REG-` IDs, `prefix:` frontmatter, LLD backlink in each spec file
- ✗ Arrow completeness — no tests and no code anywhere, yet all 8 specs carry `[x]`
- ⚠ Cross-node coherence — the queue↔registry seam ("suspect", "reports idle") is named on one side only
- ⚠ Decision capture — the biggest choice in the system (memory-only queue vs. persisted registry) has no Decisions row
- ✓ Mode fit — Full mode matches a two-node project where the whole repo is in play

**Headline:** The intent layer is genuinely good — two crisply separated design nodes, EARS specs that a cold reader can act on, and a `Scheduling order` decision row that is a model of the form (rejected alternative *and* accepted cost, on one line). The highest-value next moves are reconciling the in-memory queue with the tenet it contradicts, and getting the arrow's tests-and-code phases onto the page so the `[x]` markers mean something.

**Findings (11 total · 5 high · 5 medium · 1 low)**
- **F1 (high):** The memory-only queue drops accepted-but-undispatched jobs on restart — on a mini-PC the LLD itself says takes unattended updates and power blips — while HLD tenet 1 promises "upload and walk away" overnight · *coherence is adjacency* (each level agrees with the one above it)
- **F2 (high):** That durability choice appears nowhere in `job-queue-design.md`'s Decisions & Alternatives, though the sibling registry records choosing SQLite; a cold reader can't reconstruct why the two nodes differ · *docs carry current intent, written to be read cold* (decision capture)
- **F3 (high):** The arrow ends at EARS — no test or code files exist, and no `@spec` annotation appears in the repo — but all 8 specs are marked `[x]`, so the marker's meaning is unrecoverable · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code)
- **F4 (high):** Prioritization (staff/member classes, FIFO within class) and "a job is accepted only if its class has a registered printer" are designed behaviors with no spec · *effective intent-tree alignment* (LLD behaviors with no spec are unnamed intent)
- **F5 (high):** QUEUE-003 marks a printer "suspect", but the registry owns printer state (idle/busy/unreachable) and has no `suspect` state, no REG spec, and no exit condition · *intent attaches at the lowest node that dominates it* (the printer state model governs both nodes)
- **F6 (medium):** "Class" carries two meanings — printer class and priority class — and QUEUE-002/003 use it unqualified · *semantic legibility as cheap linkage* (names should give intent up for free)
- **F7 (medium):** The HLD's Approach names a member web UI, uploads, and staff reordering rights, but "Two design nodes" leaves the UI/API and member-vs-staff identity unowned · *one LLD per intent component* (arrow completeness)
- **F8 (medium):** Tenet 2 ("no silent reordering") is a triggered rule already fixed as QUEUE-005, and the list is unordered though tenet 1 (the job-is-a-promise) and tenet 3 (stay small) collide exactly at F1's decision · *tenets capture forward-looking preference* (a tenet is a tie-breaker lean, not a spec)
- **F9 (medium):** The HLD has no Key Design Decisions and no success metrics; "fair access to the popular printer classes" has nothing that would tell you whether it's being met · *HLD is architecture and rationale*
- **F10 (medium):** QUEUE-002 fires "when the registry reports a printer idle", but the registry design describes interval polling and no REG spec covers reporting idle to the queue · *coherence is adjacency* (the seam is specified from one side only)
- **F11 (low):** Content-hashed G-code files are kept on disk with no stated retention or cleanup, against a 64 MB limit chosen to keep that disk safe · *LLDs close enough of the solution space*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs (`QUEUE`, `REG`), 2 spec files, 8 EARS specs, 5 Decisions & Alternatives rows
- Swept: all spec IDs against leaf `prefix:` frontmatter (no collisions, no gaps, no renumbering); repo-wide grep for `@spec` (0 references), and for accumulation markers — `[obsolete]`, `deprecated`, changelog, `[inferred]` (0 hits)
- Arrow overlay: not installed (`docs/arrows/` absent), so no `index.yaml` segments or drift fields were available; cascade findings above come from reading adjacent levels directly
- Dispatch: directives + `- Mode: Full` + standard directories present → full review, whole project in scope

**Worth a second look:** I couldn't read the core skill's capability-flags reference in this run, so I'm treating the flags as applying to me. Models in my class are known to miss designs that contradict the project's own tenets — F1 and F8 are my attempt at exactly that, so please re-check both design nodes against your three HLD tenets yourself, particularly anywhere the "stays small" tenet has quietly won a call that tenet 1 should have taken.

Want me to walk through the findings in detail, focus on a theme (the durability thread — F1, F2, F8 — hangs together) or a priority tier, or work through specific items with you? You can also pick a single finding and we'll dig into it.

If you have broader questions about using LID here — when a seam like queue↔registry deserves its own node, whether the arrow overlay is worth installing at this size, where a PRD would fit ahead of the HLD, or what to do as the farm grows past six printers — I can help with those too.