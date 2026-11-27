# LID Coach — Shelfwise

**Posture:** Design layer is strong and genuinely intent-first; the arrow stops at EARS, and a couple of designs lean against the project's own tenets.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, no schemas or signatures bleeding upstream
- ✓ Mutation hygiene — no changelogs, no superseded docs, no `[obsolete]` residue anywhere; docs read as current intent
- ✓ Spec craft — EARS patterns used correctly, IDs stable and grep-clean, decision tables name rejected options and accepted costs
- ⚠ Tenet coherence — branch-local allocation leans against "waiting is honored in sequence"; no-history leans against both Goals
- ✗ Arrow completeness — every spec is checked off, but no tests or code exist to carry the last two phases
- ⚠ Configuration — the `## LID` block is present, but the instruction file never names LID itself

**Headline:** Two leaf designs with real rationale, 13 well-formed specs, and clean decision tables make this one of the more legible small LID projects to walk — the highest-value next moves are closing the arrow past EARS and reconciling the branch-priority design with the sequence tenet (or the tenet with the design).

**Findings (11 total · 5 high · 5 medium · 1 low)**
- **F1 (high):** All 13 specs are marked `[x]`, yet no test or code file exists in the repo and `@spec` appears nowhere — the arrow ends at EARS while the markers read as delivered · *intent leads; code is compiled output* — specs drive code, and status markers say which intent has landed
- **F2 (high):** Branch-local priority (hold-allocation design ¶2, `HOLDALLOC-003`/`004`) gives a later requester at the scanning branch a copy ahead of an earlier requester elsewhere, which the tenet "waiting is honored in sequence" explicitly rules out · *coherence is adjacency* — each level agrees with the one above it
- **F3 (high):** That branch-local tradeoff — the choice a cold reader is most likely to challenge — has no row in hold-allocation's Decisions & Alternatives table at all · *docs carry current intent* (decision capture) — a live decision needs the rejected option and accepted cost on the page
- **F4 (high):** Goals 1 and 2 are unmeasurable as designed: `PICKUP-003`/`005` delete the hold record on close and the tenet forbids history, so nothing survives to compute notification latency or expiry rate — while the reminders decision says it is "watched against Goal 2" · *coherence is adjacency*
- **F5 (high):** An in-transit copy arriving with a still-open hold has no spec — `HOLDALLOC-007` covers only the cancelled case, and `PICKUP-001` presumes a holds-shelf scan that nothing produces · *effective intent-tree alignment* — LLD behavior with no spec is unnamed intent
- **F6 (medium):** The hold lifecycle vocabulary (`open`, `allocated`, cancelled, closed) and the "re-run allocation as a check-in" contract are each defined in fragments inside both leaves, though they govern both · *intent attaches at the lowest node that dominates it* — substance spanning siblings belongs at the shared parent
- **F7 (medium):** Hold cancellation has no spec anywhere, though the hold-cap decision ("must cancel one") and `HOLDALLOC-007` both depend on it; clearing `allocated` on pickup or expiry is likewise unspecified · *effective intent-tree alignment*
- **F8 (medium):** Goal 1's clock and "business hours" are undefined across six branches, and the once-a-day courier makes the transit path structurally unable to hit 4 hours · *HLD is architecture and rationale* — goals a future session can act on need a stated measure
- **F9 (medium):** Three cold-read gaps: whether an allocated or on-shelf hold counts toward the 15-hold cap (`HOLDALLOC-002`), what time a 7-day window lapses, and who owns the patron's channel choice "at signup" · *docs carry current intent, written to be read cold*
- **F10 (medium):** The HLD has no Non-Goals and no Key Design Decisions section; "hold history is not kept" is an absolute constraint enforced by specs rather than a tie-breaker lean, and the four tenets are unordered although no-history and the Goals already collide · *tenets capture forward-looking preference*
- **F11 (low):** Neither spec file declares a `prefix:`, so `HOLDALLOC` → `hold-allocation` and `PICKUP` → `pickup-notices` resolve by convention only · *specs are grep-anchored linkage*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/` — all 6 files in the repo
- Enumerated: 2 leaf LLDs, 2 spec files, 13 specs (7 `HOLDALLOC`, 6 `PICKUP`), 4 tenets, 2 goals, 7 decision rows
- Arrow-path attempted end-to-end on both segments: HLD component → design → spec resolved cleanly; test and code levels are absent (0 `@spec` references project-wide)
- Cold-read pass run over all 4 LID docs; decisions-table sweep run over all 7 rows
- Dispatch: Mode read as **Full** from the `## LID` block; no `docs/arrows/` overlay, so `index.yaml` guidance did not apply. LID-shaped artifacts are present but the instruction file carries no LID directive block — per the skill this is a full review with the configuration gap surfaced (F-config, folded into the scorecard's Configuration line and reconcilable with `/update-lid`)

**Worth a second look:** I could not load the capability-flags reference from this session, so I am treating the flags as applying to me. Models in my class are known to miss designs that contradict the project's own tenets, and to miss incoherence at the seam between two leaves — please check the two leaf designs against your HLD tenets yourself (F2 and F4 are the ones I did catch), and re-read the hold-allocation ↔ pickup-notices handoff (F5, F6) with your own eyes.

Want me to walk through the findings in detail, focus on a theme or priority — the tenet-coherence cluster (F2, F4, F10) is the richest — or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on Shelfwise — how to carry the arrow into tests and code from here, where a PRD for the circulation-system integration would sit, whether a third component is warranted as this grows, or when to reach for the arrow-maintenance overlay — I am happy to work through those too.