# LID Coach — Shelfwise Review

## Executive Summary

**Bootstrapping — solid design foundation, implementation pending.**

**Scorecard**
- ✓ HLD discipline — clean architecture, no implementation bleed
- ✓ Decision capture — all Decisions & Alternatives rows complete and clear  
- ✓ Tenet quality — four real tie-breakers with defensible opposites
- ✓ Tenet cascade — designs honor every tenet
- ✓ Mutation hygiene — docs carry current intent, no history residue
- ⚠ Arrow completeness — Tests and Code phases missing (expected in bootstrapping)

**The arrow's design phases are real and coherent across two well-separated components; the fastest win is writing tests, then code, to close the arrow.**

## Findings (2 total · 0 high · 1 medium · 1 low)

- **F1 (medium):** Tests and Code phases missing for both components · *arrow completeness; canonical arrow shape*
- **F2 (low):** LLDs lack `prefix:` frontmatter to declare canonical spec namespaces · *effective intent-tree alignment*

## What Was Audited

- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs (hold-allocation, pickup-notices), both spec files
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs total (7 HOLDALLOC, 6 PICKUP)
- Checked: spec ID uniqueness, EARS format compliance, tenet-design alignment, decision-capture completeness
- Code/test sampling: none — no implementation exists yet

## Findings Detail

**F1 (medium) — Bootstrapping state: implementation phases missing**

The design arrow (HLD → LLDs → EARS) is complete and coherent, but Tests and Code phases don't exist yet. This is expected when design is finished but implementation hasn't started.

*Why it matters:* The arrow's value comes from the full cascade — specs drive tests, tests drive code. Until tests and code exist, the specs are declarations of intent but not yet verified, and there's no working system.

*Next step:* Write tests first (citing specs with `@spec` annotations), then write code to satisfy them. The *tests before code* principle preloads the use of the system into context before implementation details can distort the design.

**F2 (low) — Missing frontmatter in LLDs**

Neither LLD declares its canonical spec prefix in frontmatter (e.g., `prefix: HOLDALLOC` in hold-allocation-design.md). The prefixes are inferrable from the spec files and directory structure, but explicit frontmatter eliminates ambiguity.

*Why it matters:* When a component grows or the tree deepens, the `prefix:` frontmatter is authoritative for where the leaf path ends and any within-leaf facet begins. Without it, future sessions have to infer the boundary from naming alone.

*Consider:* Add frontmatter to each LLD naming its prefix — `prefix: HOLDALLOC` and `prefix: PICKUP` — so the design tree's namespace is explicit.

## What's Working

This is a cleanly executed design-first LID adoption. Strengths worth keeping:

- **Tenet-design alignment is tight.** Every mechanism in both LLDs leans the way the HLD's tenets say to lean — allocation uses oldest timestamp (tenet 1: waiting honored in sequence), failed deliveries route to staff exceptions (tenet 2: staff attention to exceptions), one notice with no reminder (tenet 3: patrons hear once), and hold records are deleted when closed (tenet 4: history not kept).

- **Decision capture is complete.** Both LLDs carry Decisions & Alternatives tables where every row names the choice, the rejected alternative, and the cost accepted. A cold reader can reconstruct what was given up and why — the tables pass the forward test (would a reader still question this, or does the landed choice now read as obvious?).

- **HLD stays architectural.** No schemas, no API shapes, no implementation detail — the HLD carries problem, approach, tenets, goals, and component boundaries, all of which live longer than any specific implementation.

- **No accumulation.** Docs carry current intent as if authored fresh today — no "was X, now Y" change-narration, no `[obsolete]` markers next to replacements, no conversation fossils defending against questions no longer asked.

- **EARS specs are well-formed.** Every spec follows the Event-Action (or Condition-Action) structure, IDs are unique and greppable, and no universal-sounding specs are secretly scoped.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.