**LID Coach — Shelfwise**

*Non-interactive run: dispatch found a `## LID` block with `Mode: Full` but no `linked-intent-dev` directive text in `CLAUDE.md`, alongside clearly LID-shaped artifacts (HLD + two leaf designs + two spec files). Per the skill's default I proceeded with a full review anchored on the artifacts and surfaced the missing directives as a finding (F1). No files were edited — the coach is advisory.*

---

## Executive summary

**Posture:** *Design-stage arrow, well-formed and residue-free; the tenets aren't yet holding the designs honest.*

**Scorecard**
- ✓ **HLD discipline** — problem, approach, tenets, goals, components, zero implementation detail bleeding upstream
- ✓ **Mutation hygiene** — no change-narration, no `[obsolete]` specs, no `[inferred]` backlog, no changelog residue anywhere
- ✓ **LLD granularity** — two leaves that genuinely are two things; one EARS segment each, no silent overlap
- ⚠ **Decision capture** — the strongest rows are excellent; the single most questionable choice has no row at all
- ✗ **Tenet cascade** — branch-local allocation works against the sequence tenet with nothing recording the trade
- ✗ **Arrow completeness** — specs are all marked `[x]` but Tests and Code phases don't exist yet
- ⚠ **Configuration** — `## LID` block present but the directive block that tells an agent what LID *is* is missing

**Headline:** The parts that are usually hardest are already right here — the HLD carries only architecture and *why*, the two leaves are correctly sized, and the docs are unusually clean of history residue (the pickup-window and expiry-handling rows are model Decisions entries, naming the rejected option, the reason, *and* the accepted cost against a named goal). The fastest wins are reconciling the instruction file, deciding what the `[x]` markers mean while Tests and Code are empty, and giving branch-local allocation the Decisions row its tension with your first tenet demands.

## Findings (10 total · 4 high · 4 medium · 2 low)

- **F1 (high):** `CLAUDE.md` has a `## LID` block but no `linked-intent-dev` directive text, so a fresh agent reads the mode without learning the methodology · *modes are declared, not inferred* — the foundation should be visible, not inferred → `/update-lid`
- **F2 (high):** Branch-local-first allocation (`HOLDALLOC-003` ahead of `HOLDALLOC-004`) lengthens an earlier patron's wait for a later local one, working against the tenet *"Waiting is honored in sequence… nobody's wait is lengthened by a patron who asked after them"* with no recorded exception · *tenets capture forward-looking preference* + *coherence is adjacency*
- **F3 (high):** That same branch-local priority — the choice a cold reader is most likely to question — survives only as one clause of body prose ("keeps most copies off the courier van"), with no Decisions & Alternatives row naming the rejected strict-FIFO alternative or the equity cost accepted · *docs carry current intent* — a live decision needs a reconstructable row
- **F4 (high):** Every spec in both files is marked `[x]` while the repo contains no tests and no code, so the status markers assert a Tests→Code arrow that isn't there · *tests before code*, *tests carry `@spec` annotations* — markers that run ahead of reality stop being a trustworthy signal of what is done
- **F5 (medium):** No spec covers a patron cancelling a hold, yet `HOLDALLOC-007` and the design prose both depend on cancellation existing · *LLDs close enough of the solution space* — an open edge an implementing agent will fill in by guessing
- **F6 (medium):** No spec covers an in-transit copy arriving with its hold still open (only the cancelled case is specified), leaving the transit leg's happy path implicit between the two leaves · *effective intent-tree alignment* — behavior described in design with no spec anywhere
- **F7 (medium):** The morning pull list and daily exceptions list hold patron-and-title pairs with no stated retention or purge, so the tenet *"Hold history is not kept"* has an unpoliced edge · *tenet cascade* + *scope disambiguation*
- **F8 (medium):** Neither spec file declares a `prefix:`, so `HOLDALLOC` and `PICKUP` resolve to their leaves only by directory-name resemblance · *specs are grep-anchored linkage* — prefix resolution should be authoritative, not inferred
- **F9 (low):** `HOLDALLOC-003`/`-004` select "the oldest" hold with no tie-break rule for identical placement timestamps · *LLDs close enough of the solution space*
- **F10 (low):** Goal 2 ("fewer than 10% expire uncollected") and the expiry-rate cost accepted in the pickup-notices Decisions table have no spec or design node that makes the rate observable · *effective intent-tree alignment*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both `*-design.md` leaves, both `*-specs.md` files — 6 files, the entire repository
- Enumerated: 1 HLD, 2 leaf designs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 6 Decisions & Alternatives rows, 4 tenets, 2 goals
- Arrow-path sampled: both segments walked end-to-end — HLD component → leaf design → specs → tests → code; both terminate at EARS (0 test files, 0 source files, 0 `@spec` annotations)
- Overlay: `docs/arrows/` absent, so cascade findings come from doc reads rather than index state
- Passes run: dimension sweep (19 dimensions), cold-read pass through all 5 LID docs, Decisions-table sweep across all 6 rows
- Residue screen: 0 hits for `[inferred]`, `[obsolete]`, changelog/"previously"/TODO patterns

---

Want me to walk through any of these in detail, focus on a theme (the tenet-cascade pair F2/F3 is where I'd start) or a priority band, or work through specific items together? Pick a finding and I'll go deep on it — including what the remedy would look like and which command to apply it with.

If you have broader questions about using LID on Shelfwise — when to promote a leaf to a sub-HLD as more branches' workflows land, what the `[x]` markers should mean before implementation starts, where a PRD for the circulation-system integration would fit, or whether Full is still the right mode once code arrives — I'm happy to talk those through too.