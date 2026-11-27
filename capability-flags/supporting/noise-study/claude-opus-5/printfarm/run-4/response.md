**LID Coach — printfarm**

## Executive summary

**Posture: Design layer in good shape; the arrow stops at EARS.**

**Scorecard**
- ✓ Configuration — LID directives, `Mode: Full`, and the two-node layout under `docs/intent/` are all in place
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, no `[obsolete]` residue, no "was X, now Y"
- ✗ Arrow completeness — all eight specs carry `[x]` but no tests or code exist in the repo to satisfy them
- ⚠ Intent-tree alignment — several designed behaviors (prioritization, restart loss, registration) have no spec
- ⚠ Seams — the queue↔registry contract lives implicitly in two leaf docs and is owned by neither
- ⚠ Tenet fit — the in-memory queue runs against "a submitted job is a promise"

**Headline.** The foundations here are genuinely good — a tight, jargon-free HLD, two cleanly separated nodes with authoritative `prefix:` frontmatter, grep-anchored IDs with no collisions, and a Decisions table (`job-queue-design.md:31-32`) whose scheduling and identifier rows are models of the form: rejected alternative named, accepted cost named. The highest-value next step is reconciling what the `[x]` markers claim against what exists, and giving the queue's durability choice the same treatment the scheduling choice already got.

## Findings (11 total · 4 high · 6 medium · 1 low)

- **F1 (high):** all eight specs are marked `[x]` (done), but the repo holds no tests, no code, and zero `@spec` annotations · *coherence is adjacency* — each arrow level agrees with the one next to it
- **F2 (high):** the queue held "entirely in process memory" on a mini-PC that "takes unattended OS updates and the occasional power blip" runs against the HLD tenet "a submitted job is a promise: members should be able to upload and walk away" · *tenets capture forward-looking preference*
- **F3 (high):** that durability choice appears only as Architecture prose — no Decisions & Alternatives row names the rejected persistence option or the accepted cost, while the sibling node documents exactly that for SQLite · *docs carry current intent, written to be read cold*
- **F4 (high):** designed behaviors with no EARS spec — the whole Prioritization section (staff/member classes, FIFO), the acceptance precondition, restart job loss and member resubmission, printer registration (REG-003 covers only retirement) · *effective intent-tree alignment* — LLD behaviors with no spec are unnamed intent
- **F5 (medium):** the queue↔registry contract is asserted from both sides and owned by neither — QUEUE-002 fires "when the registry reports a printer idle" while the registry design only polls, and QUEUE-003's "suspect" state has no home in the registry's state model · *intent attaches at the lowest node that dominates it* — substance spanning siblings rises to the shared parent
- **F6 (medium):** "class" carries two meanings in one doc — printer class and priority class — including in the spec text an agent will find by grep · *specs are grep-anchored linkage*
- **F7 (medium):** the HLD names a web UI and staff-vs-member rights, but the Architecture section declares "two design nodes" and neither owns the member-facing surface or the identity/role distinction the tenets lean on · *one LLD per intent component*
- **F8 (medium):** three tenets, unordered, where tenet 1 ("a submitted job is a promise") and tenet 3 ("the service stays small") pull opposite ways on precisely the decision in F2 · *tenets capture forward-looking preference* — ordering is what makes them tie-breakers
- **F9 (medium):** the HLD carries no success metrics and no key-design-decisions section, so "fair access to the popular printer classes" has no measure and the cross-node choices have no home · *HLD is architecture and rationale*
- **F10 (medium):** G-code files "kept on disk under a content hash" have no stated lifecycle, while the 64 MB row justifies itself by keeping "the mini-PC disk safe" · *LLDs close enough of the solution space*
- **F11 (low):** "slugs recycle after 90 days" implies a retention rule that nothing else in the design or specs states · *LLDs close enough of the solution space*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs, 2 spec files, 8 EARS IDs (QUEUE-001…005, REG-001…003), 0 sub-HLDs
- Prefix check: `QUEUE` and `REG` frontmatter both resolve to their leaf design docs; no ID collisions, no reuse, consistent zero-padding
- Searched for downstream arrow phases: 0 non-Markdown files in the repo, 0 `@spec` references, no `docs/arrows/` overlay present
- Cold-read pass and Decisions-table sweep run over all four design/spec docs (5 decision rows reviewed; 3 pass cleanly, the missing durability row is F3)

## Worth a second look

I could not read the capability-flags reference from here, so I am treating the flags as applying to me: models in my class are known to miss designs that contradict the project's own tenets, and to under-weight cross-node seams. F2, F5, and F8 are exactly those dimensions — please sanity-check the leaf designs against your HLD tenets yourself, particularly the durability story.

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F2 and F3 are the pair I would start with, and they read differently side by side.

If you have broader questions about using LID for printfarm — when to write specs versus start implementing, how much to spec before the first dispatch path exists, whether the arrow overlay is worth installing at this size, or where a decision doc earns its keep — I can help with those too.