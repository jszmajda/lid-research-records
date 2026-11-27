# `/lid-coach` — Shelfwise

## Executive summary

**Posture:** *Clean intent, incomplete arrow.* The design tree is tidy, residue-free, and coherent from HLD down to specs — but the arrow stops at the EARS layer, and the instruction file never names LID.

**Scorecard**
- ✓ **Granularity** — clean 1:1 HLD components → LLDs → spec files; no lumping or fragmentation
- ✓ **Decision capture** — Decisions & Alternatives rows name the rejected alternative *and* the accepted cost
- ✓ **Mutation hygiene** — no history residue, obsolete markers, or changelog; docs read cold cleanly
- ✗ **Arrow completeness** — no Tests or Code phase in the repo, yet all 13 specs are marked done
- ⚠ **Configuration** — `CLAUDE.md` has no `linked-intent-dev` directive block
- ⚠ **Tenets** — two restate settled policy; one sits in tension with the allocation design

**Headline:** The intent layer is genuinely strong — a small, well-shaped tree with unusually good tradeoff capture and zero accumulation. The fastest wins are reconciling the instruction file (`/update-lid`) and closing the gap between "every spec checked" and "no tests or code exist."

## Findings (6 total · 2 high · 2 medium · 2 low)

- **F1 (high):** `CLAUDE.md` declares Mode/Version but has no LID directive block — the methodology is never named · *modes are declared, not inferred*
- **F2 (high):** The arrow terminates at the spec layer — no Tests or Code phase exists, yet all 13 specs are marked `[x]` complete · *canonical arrow shape* + *tests before code*
- **F3 (medium):** Branch-preferred allocation (`HOLDALLOC-003` before `-004`) sits against the "waiting honored in sequence" tenet, with no carve-out or Decisions row · *tenets capture forward-looking preference* + *decision capture*
- **F4 (medium):** Hold *cancellation* is assumed by `HOLDALLOC-007` and the "history is not kept" tenet but no spec defines the cancel action (close + delete) · *effective intent-tree alignment*
- **F5 (low):** Two tenets ("waiting honored in sequence," "hold history is not kept") restate settled policy rather than lean on undecided cases; the list is unordered though tenets could conflict · *tenets capture forward-looking preference*
- **F6 (low):** Spec files carry no `prefix:` frontmatter — the `HOLDALLOC`/`PICKUP` → leaf-LLD mapping rests on naming convention only · *specs are grep-anchored linkage*

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both LLD design docs, both `*-specs.md` files
- **Enumerated:** 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs (`HOLDALLOC-001`–`007`, `PICKUP-001`–`006`)
- **Searched:** no code or test files present; no `@spec` annotations anywhere; no `docs/arrows/` overlay installed
- **Config:** `## LID` block present — Mode: Full, Version: 1.4.0; no `linked-intent-dev` directive block; reviewed in Full mode (dispatch default for a LID-shaped project whose instruction file is missing directives)
- **Coherence spot-check:** every LLD behavior cross-read against its specs — allocation logic, hold cap, allocated-lock, transit re-run, pickup window, expiry, and failed-delivery paths all line up

## Worth a second look

I couldn't access the core skill's capability-flags reference from here, so I'm treating the flags as applying. Models in my class are known to miss designs that quietly contradict a project's own tenets — F3 is one I did catch, but please read the two leaf designs against your HLD tenets yourself to see if any others slipped past.

## Offer to help

Want me to walk through any of these in detail — the two high-priority items first, a specific theme (say, the tenet/allocation tension), or a particular finding you want to work through together? Pick any one and I'll go deep.

If you'd rather step back to broader LID questions — where a cancellation subsystem should live in the tree, how to handle the "specs done but no code yet" stage, or when this project might warrant the arrow overlay — I can help think those through too.