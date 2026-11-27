**Shelfwise — LID Coach Report**

## Executive summary

**Posture:** Healthy intent layer; arrow stops at specs, and one tenet conflict needs a decision.

**Scorecard**
- ✓ Intent-tree alignment — one HLD, two LLDs, one spec file each, prefixes trace cleanly
- ✓ Mutation hygiene — no changelogs, no `[obsolete]` markers, no planning residue anywhere
- ⚠ Decision capture — rows are strong where they exist; the biggest allocation choice has none
- ⚠ Tenet cascade — branch-first routing leans against "waiting is honored in sequence"
- ✗ Arrow completeness — specs marked done, but no tests or code phase exists yet
- ⚠ Configuration — the `## LID` block has Mode/Version but no directive text

**Headline:** The docs are genuinely good — the HLD stays at architecture, every decision row names its accepted cost (the expiry row even names Goal 1 as the price, which is exactly the move), and the specs read as clean EARS with stable IDs. The fastest wins are recording the branch-first routing decision against the sequencing tenet, and closing the gap between specs marked `[x]` and an empty tests/code layer.

## Findings (11 total · 4 high · 5 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block carries `Mode`/`Version` but no directive text naming linked-intent-dev, so the workflow rules aren't actually in the instruction file · *modes are declared, not inferred* — an unread mode is a default, and the rest of LID proceeds on it
- **F2 (high):** `HOLDALLOC-003`/`004` serve a later local requester ahead of an older county-wide hold, which is the thing the tenet "waiting is honored in sequence" forbids; no row records the trade · *tenets capture forward-looking preference* — an unrecorded exception reads as a bug to the next session
- **F3 (high):** the branch-first routing choice has no Decisions & Alternatives row; its rationale survives only as body prose ("keeps most copies off the courier van") · *docs carry current intent* — a cold reader would still question or try to reverse this one
- **F4 (high):** all 13 specs are marked `[x]`, but the repo has no tests and no code — the arrow ends at EARS · *canonical arrow shape*, *tests before code*
- **F5 (medium):** patron-initiated cancellation is referenced in `hold-allocation-design.md:13` and `HOLDALLOC-007` but never specified — nothing says the hold closes and its record is deleted · *effective intent-tree alignment*; the "hold history is not kept" tenet is only half-carried
- **F6 (medium):** reallocation-after-expiry exists only in `PICKUP-005`; hold allocation's design and specs never acknowledge that second entry point · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F7 (medium):** four tenets, unordered, at least two of which can meet head-on (sequencing vs. keeping copies off the van; "patrons hear once" vs. Goal 2) · *tenets capture forward-looking preference* — ordering is what makes a tie-breaker break ties
- **F8 (medium):** no doc states the system boundary — whether Shelfwise or the circulation system owns holds records, patron channel choice, and the dialer is left to inference · *docs carry current intent, written to be read cold*
- **F9 (medium):** spec files carry no `prefix:` frontmatter, so the leaf path isn't resolvable from the ID alone (`HOLDALLOC` / `PICKUP` vs. directories `hold-allocation` / `pickup-notices`) · *specs are grep-anchored linkage*
- **F10 (low):** the HLD has no Non-goals and no Key Design Decisions section · *HLD is architecture and rationale*
- **F11 (low):** the morning pull list and daily exceptions list have no lifecycle spec — records are deleted at close, list entries aren't addressed · *mutation, not accumulation*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 specs (7 `HOLDALLOC`, 6 `PICKUP`) — all IDs unique, none reused, none with non-grep-friendly characters
- Arrow-path sampled: both segments walked end-to-end (HLD component → LLD → spec → tests → code); the tests and code phases are empty, so no `@spec` annotations exist to sample
- Cold-read pass: all five LID docs, plus a Decisions-table sweep across all 7 rows
- Defaults taken in this non-interactive run: mode read as **Full** from the `- Mode:` bullet, so no out-of-scope section applies; no arrow overlay (`docs/arrows/`) is installed, so structural enumeration (orphans, reverse orphans, index drift) was not attempted — `/arrow-maintenance` would own that if you add the overlay

---

Want me to walk through the findings in detail, focus on a theme or priority (the tenet conflict in F2/F3 is the one I'd start with), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on Shelfwise — where the tests-and-code phase should start given the specs are already written, how to model the circulation-system boundary, or whether the two components will want a sub-HLD as they grow — I can help with those too.