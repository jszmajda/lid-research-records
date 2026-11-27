**LID Coach — Shelfwise**

## Executive summary

**Posture:** Well-authored design layer; the arrow stops at specs, and one tenet is quietly out of step with the design.

**Scorecard**
- ✓ Spec craft — clean EARS forms (event / state / unwanted), every spec trigger-scoped, IDs unique and grep-friendly
- ✓ HLD discipline — problem, approach, tenets, goals, component links; no schemas or signatures bleeding upstream
- ✓ LLD granularity — two leaf designs matching the HLD's two components, each owning one spec segment
- ⚠ Tenet coherence — allocation's branch-first rule leans against "waiting is honored in sequence"
- ⚠ Decision capture — the branch-first-vs-strict-order tradeoff isn't recorded anywhere
- ✗ Arrow completeness — tests and code phases aren't present yet, though all 13 specs are marked done
- ⚠ Configuration — `CLAUDE.md` has the `## LID` mode/version block but no LID directive block

**Headline:** The design layer here is genuinely good — the HLD stays at architecture altitude, both leaf designs carry real Decisions & Alternatives tables with accepted costs named, and the EARS specs are the cleanest part of the project. The highest-value next steps are reconciling the instruction file, resolving the branch-first allocation rule against your own sequencing tenet (and recording that tradeoff), and walking the first arrow segment down through tests into code while the tests-first window is still open.

## Findings (15 total · 5 high · 8 medium · 2 low)

- **F1 (high):** `CLAUDE.md` declares `Mode: Full` and `Version: 1.4.0` but carries no LID directive block — nothing names linked-intent-dev or the workflow · *modes are declared, not inferred* — the mode and the methodology hookup both live in the instruction file, not in inference → `/update-lid`
- **F2 (high):** `HOLDALLOC-003`/`004` give a later local-branch hold priority over an older cross-branch hold, which reads against the tenet "nobody's wait is lengthened by a patron who asked after them" · *coherence is adjacency* — each level agrees with the one above it
- **F3 (high):** neither Decisions & Alternatives table records branch-first allocation vs. strict county-wide order, its courier-cost motive, or what the older cross-branch patron gives up · *docs carry current intent* — a cold reader would still question this choice
- **F4 (high):** the arrow stops at EARS — no tests and no code anywhere, yet all 13 specs carry `[x]` completion markers · *canonical arrow shape* (`HLD → LLDs → EARS → Tests → Code`) and *tests before code*
- **F5 (high):** hold cancellation is referenced in `hold-allocation-design.md` but has no spec and no clear owning behavior — only the in-transit case (`HOLDALLOC-007`) exists, leaving a shelved-copy cancellation with no defined path · *effective intent-tree alignment* — design behavior with no spec drifts silently
- **F6 (medium):** `pickup-notices-design.md` says the hold closes when the window lapses; `PICKUP-004`/`005` close it only when staff scan the copy off the shelf · *coherence is adjacency* — adjacent-level drift between design prose and specs
- **F7 (medium):** no spec covers an in-transit copy arriving at its destination with the hold still intact — the transit-slip → holds-shelf-scan seam between the two segments is implicit · *effective intent-tree alignment*
- **F8 (medium):** hold and copy state vocabulary (`open`, `allocated`, closed/deleted) is used across both designs but enumerated in neither · *LLDs close enough of the solution space* — two agents would model the lifecycle differently
- **F9 (medium):** Goals 1 and 2 are cited as live constraints ("watched against Goal 2") but no spec or design node owns measuring notification latency or expiry rate · *effective intent-tree alignment*
- **F10 (medium):** tenets 3 and 4 carry spec-shaped second sentences (one message per event; delete the record on close — already `PICKUP-002`/`003`), and the list is unordered though sequencing and courier efficiency can conflict · *tenets capture forward-looking preference* — a tenet is a lean, not a triggered rule
- **F11 (medium):** the HLD has no Non-Goals section and no explicit target-users line (patrons vs. desk staff are inferred) · *HLD is architecture and rationale*
- **F12 (medium):** `PICKUP-006` turns on "fails to deliver" without defining failure per channel — especially the automated dialer, where no-answer, busy, and voicemail all differ · *scope disambiguation*
- **F13 (medium):** window lapse produces a pull-list entry and a silent hold closure — the patron is never told, though tenet 3 reads as though each event produces a message · *coherence is adjacency*
- **F14 (low):** spec files carry no `prefix:` frontmatter, so `HOLDALLOC` → `hold-allocation` and `PICKUP` → `pickup-notices` resolve by convention only · *specs are grep-anchored linkage*
- **F15 (low):** no arrow overlay (`docs/arrows/`) — at two segments it isn't needed, but installing it before the code layer lands would give you cascade status and drift tracking from the start · *minimum surface, maximum discipline*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/hold-allocation/{hold-allocation-design.md,hold-allocation-specs.md}`, `docs/intent/pickup-notices/{pickup-notices-design.md,pickup-notices-specs.md}` — the entire project is 6 files
- Enumerated: 1 HLD, 2 leaf designs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 7 Decisions & Alternatives rows, 4 tenets, 2 goals
- Arrow-path sampled: both segments attempted end-to-end; both terminate at the EARS level — 0 test files, 0 code files, 0 `@spec` annotations, no `docs/arrows/` overlay
- Cold-read pass: all 5 LID docs, plus the decisions-table sweep across both tables
- Dispatch: ran as a **full review** — `CLAUDE.md` lacks the directive block but the project is clearly LID-shaped (populated HLD, two leaf designs, two spec files), which is the coach's default for that state; this non-interactive run took that default without prompting

## Worth a second look

I could not read the core skill's `references/capability-flags.md` from this session, so per the coach's own instruction I treat the flags as applying: models in my class are known to miss designs that contradict the project's own tenets. F2 is one such case and F13 may be another — please check both leaf designs against all four HLD tenets yourself, particularly "staff attention goes to exceptions" and "patrons hear once, clearly," which I read as satisfied.

## Offer to help

Want me to walk through these findings in detail, focus on a theme (the tenet/allocation tension, the missing tests-and-code layer, the spec gaps) or a priority tier, or work through specific items together? You can also pick a single finding — F2 and F3 are tangled and would make a good joint working session.

If you have broader questions about using LID on Shelfwise — how to sequence the first tests-first segment, whether cancellation wants its own design node, where a reporting/metrics component would sit relative to these two, or when the arrow overlay starts paying for itself — I can help with those too.