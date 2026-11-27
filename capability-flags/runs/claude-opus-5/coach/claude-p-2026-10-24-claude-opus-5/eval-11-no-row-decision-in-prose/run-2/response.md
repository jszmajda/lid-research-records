# LID Coach — printfarm

## Executive summary

**Posture:** *Design layer is real and unusually clean; the arrow stops at EARS, and one load-bearing durability choice is unrecorded.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, no schemas or signatures bleeding upstream
- ✓ Linkage shape — `prefix:` frontmatter matches spec IDs cleanly in both nodes; specs name their LLD
- ⚠ Decision capture — the queue's durability model is the biggest choice in the project and has no row
- ⚠ Tenet cascade — the in-memory queue works against "upload and walk away" under conditions the docs themselves describe
- ⚠ Intent-tree alignment — prioritization and several LLD behaviors have no specs
- ✗ Arrow completeness — no tests, no code, no `@spec` annotations, yet every spec is marked `[x]`

**Headline:** Two design nodes, clean prefixes, non-trivial Decisions rows that already name the alternative *and* the accepted cost — that's better decision hygiene than most projects reach. The fastest win is writing down the queue-durability decision, because the current design quietly contradicts your first tenet.

## Findings (11 total · 4 high · 5 medium · 2 low)

- **F1 (high):** the in-memory queue drops accepted-but-undispatched jobs on a restart, while the same doc names unattended OS updates and power blips — that defeats *"a submitted job is a promise"* and the evening-upload/morning-pickup goal · *tenet cascade / keep the arrow coherent*
- **F2 (high):** that durability choice has no Decisions & Alternatives row anywhere, even though the registry next door already persists to SQLite · *docs carry current intent — decision capture*
- **F3 (high):** prioritization (staff/member, FIFO within class) is designed but has no EARS spec · *effective intent-tree alignment*
- **F4 (high):** `QUEUE-002`'s "head job of that printer's class" reads universal but is ambiguous once two priority classes exist · *scope disambiguation*
- **F5 (medium):** `QUEUE-003` mints a "suspect" printer state, but printer state is the registry's territory and `printer-registry-design.md` defines no such state and no spec for it · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F6 (medium):** every spec carries `[x]` but the repo holds no tests and no code · *coherence is adjacency*
- **F7 (medium):** no tests and zero `@spec` annotations in the project · *tests before code; tests carry `@spec` annotations*
- **F8 (medium):** the HLD's web UI and the staff-vs-member distinction it depends on have no design node · *one LLD per intent component*
- **F9 (medium):** four LLD behaviors have no specs — accept-only-if-class-has-a-registered-printer, content-hash upload dedupe, the 15 s heartbeat interval, and staff *registering* a printer (only retirement is specced) · *effective intent-tree alignment*
- **F10 (low):** tenets 1 ("upload and walk away") and 3 ("the service stays small") can pull opposite ways — exactly the tension under F1 — and the list is unordered · *tenets capture forward-looking preference*
- **F11 (low):** two cold-read gaps — "slugs recycle after 90 days" implies a job-retention policy nothing else describes, and `QUEUE-004`'s startup rebuild doesn't say what becomes of a job found already running · *docs carry current intent, written to be read cold*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (2 design nodes, 2 spec files)
- Enumerated: 2 leaf LLDs, 8 EARS specs (`QUEUE-001`–`005`, `REG-001`–`003`), 5 Decisions & Alternatives rows, 3 tenets
- Arrow-path sampled: both segments walked end-to-end (HLD §Architecture → design node → specs → tests → code); both terminate at the spec layer
- Linkage metric: 0 `@spec` references across the repo; 0 test files; 0 source files
- Overlay: `docs/arrows/` absent, so no `index.yaml` cross-check was available — structural questions (orphans, reverse orphans) were not enumerated

---

Want me to walk through the findings in detail, focus on a theme (the durability thread F1/F2/F10 hangs together), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on printfarm — when to add a third design node, whether the arrow overlay is worth installing at this size, or how to get the test and code phases started from specs that are already written — I can help with those too.