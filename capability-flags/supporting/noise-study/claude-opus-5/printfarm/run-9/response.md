**LID Coach — printfarm**

## Executive summary

**Posture: Bootstrapping — the arrow is well-shaped through specs; tests and code haven't started, and two coherence seams are worth closing before they do.**

**Scorecard**
- ✓ Design-tree shape — HLD plus two leaf nodes with clean `prefix:` frontmatter; granularity fits a service this size
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, no `[obsolete]` residue, no planning text
- ✗ Arrow completeness — no tests and no code anywhere, yet all eight specs already carry `[x]` complete markers
- ⚠ Coherence — the in-memory queue works against the HLD's "a submitted job is a promise" tenet, and the "suspect" printer state exists in one node's vocabulary only
- ⚠ Spec coverage — prioritization, printer registration, and the accept-only-if-a-printer-exists rule are designed but unspecced
- ✓ Mode fit — Full mode matches a whole-repo, docs-first start

**Headline.** The design layer is genuinely good: the HLD stays at architecture and rationale, both leaf designs carry real Decisions & Alternatives rows (the FIFO row, with its rejected alternative *and* accepted cost, is a model of the form), and the EARS specs are well-formed and grep-anchored. The single most valuable next step is deciding — on the page — whether an accepted job survives a restart; that one decision reconciles the tenet conflict, fills the largest missing Decisions row, and sets what the first tests should assert.

## Findings (12 total · 5 high · 6 medium · 1 low)

- **F1 (high):** All eight specs are marked `[x]` complete, but the repo contains no tests and no code — the arrow stops at EARS · *intent leads; code is compiled output* — specs drive code, and status markers say what's true today
- **F2 (high):** The memory-only queue that drops accepted-but-undispatched jobs on restart pulls against the HLD tenet "a submitted job is a promise" — on hardware the same doc describes as taking unattended updates and power blips · *coherence is adjacency* — each level agrees with the one above it
- **F3 (high):** That volatility is a real decision but has no Decisions & Alternatives row in `job-queue-design.md` — no rejected durable-accept-log alternative, no accepted cost · *docs carry current intent* — a cold reader should be able to reconstruct the choice
- **F4 (high):** Designed behaviors with no EARS spec: the two priority classes and FIFO-within-class ordering, "accepted only if the class has a registered printer", staff printer registration, and the 15 s heartbeat poll · *effective intent-tree alignment* — designed behavior with no spec is unnamed intent
- **F5 (high):** "Marked suspect" appears in `job-queue-design.md` and QUEUE-003, but `printer-registry-design.md`'s state model has no such state and nothing says whether a suspect printer still receives dispatches · *coherence is adjacency* — sibling nodes sharing a vocabulary have to share a definition
- **F6 (medium):** The HLD goal "fair access to the popular printer classes" has no mechanism in either leaf node and no spec; FIFO plus staff reordering is the whole answer · *effective intent-tree alignment* — goals need a downstream owner
- **F7 (medium):** The member/staff web UI is named in the HLD Approach and referenced by QUEUE-005's "queue view", but the HLD declares only two design nodes and no node owns it · *one LLD per intent component* — a thing users would name deserves a node
- **F8 (medium):** Tenets are an unordered list, yet tenet 1 ("a promise") and tenet 3 ("the service stays small") conflict — and that conflict is exactly the one F2/F3 resolved silently · *tenets capture forward-looking preference* — order them when they can collide
- **F9 (medium):** "Printer class" is load-bearing across both nodes but never defined, and its relation to the three hardware models is left to the reader · *docs carry current intent* — in-conversation-only meaning
- **F10 (medium):** Cross-node edges left open: retiring the last printer of a class that still has jobs queued (REG-003 × the accept rule), and job terminal states after a mid-print failure · *LLDs close enough of the solution space*
- **F11 (medium):** QUEUE-005's "record the reordering visibly in the queue view" isn't pinned down enough for a test to cite it unambiguously · *intent leads; code is compiled output* — open spec edges get filled in by whoever implements
- **F12 (low):** No `docs/arrows/` overlay — fine today, but once tests and code land it would track segment status and drift instead of leaving `[x]` markers as the only signal · *canonical arrow shape*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (both design nodes and both spec files)
- Enumerated: 2 leaf LLDs, 2 spec files, 8 EARS IDs (`QUEUE-001`–`005`, `REG-001`–`003`), 5 Decisions & Alternatives rows
- Arrow-path sampling: not applicable below the tests/code levels — a repo-wide search found 0 `@spec` annotations, 0 source files, and 0 test files
- Configuration: LID directives present, `- Mode: Full`, version 1.4.0; `docs/arrows/` absent, so no `index.yaml` to read
- Passes run: dimension review, cold-read pass through all five LID docs, and the Decisions-table sweep (3 of 5 rows pass comfortably; the gap is the row that isn't there — F3)
- Defaults taken in this non-interactive run: dispatched as fully configured → full review; the core skill's `references/capability-flags.md` was outside this session's readable paths, so per the skill the flags are treated as applying

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets. F2 is one instance I did catch — please re-read both leaf designs against all three HLD tenets yourself, particularly "the queue explains itself — no silent reordering."

## Offer to help

Want me to walk through these in detail, focus on a theme (the coherence seams, or the spec-coverage gaps) or a priority band, or work through specific items together? You can also pick a single finding — F2/F3 together would be the highest-leverage place to start.

If you have broader questions about using LID here — when to add the arrow overlay, whether the web UI wants its own node or a sub-HLD, how to sequence tests-first from specs that are already marked done — I can help with those too.