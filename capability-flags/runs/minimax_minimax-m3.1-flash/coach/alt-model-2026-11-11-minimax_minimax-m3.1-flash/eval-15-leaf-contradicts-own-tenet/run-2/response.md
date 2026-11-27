# LID Coach — Shelfwise

## 1. Executive summary

**Posture:** *Bootstrapping — arrow in place, content sparse.* The design side of the arrow is real and reads well; the compiled side (tests, code) is absent, and one design decision silently contradicts a stated tenet.

**Scorecard**
- ✓ **Mutation hygiene** — docs read as current intent; no changelog residue, no `[obsolete]` markers, no planning prose
- ⚠ **Configuration** — the `## LID` block declares Mode and Version but carries no LID directives
- ✗ **Arrow completeness** — HLD → LLD → EARS exist; the Tests and Code phases do not
- ⚠ **Linkage hygiene** — spec IDs are clean and unique, but nothing in the repo cites them
- ⚠ **Tenet quality** — four real tie-breakers, one of which the allocation design contradicts
- ⚠ **Decision capture** — the branch-local priority choice has no Decisions row

**Headline:** The design layer of the arrow is unusually clean for a bootstrap — the docs carry current intent, the specs are precise and grep-friendly, and the specs/LLD/HLD all agree on what the system does. The two fastest wins are adding the missing LID directives to `CLAUDE.md` and resolving the one tenet-versus-design conflict in hold allocation; the bigger structural question is whether to build out the remaining arrow phases (tests, code) or mark the specs as not-yet-compiled.

## 2. Findings inventory

**Findings (10 total · 3 high · 4 medium · 3 low)**

- **F1 (high):** `CLAUDE.md` declares Mode and Version but contains no LID directives — no agent will know to walk the arrow · *modes are declared, not inferred* + *minimum surface, maximum discipline* → run `/update-lid`
- **F2 (high):** every spec is marked `[x]` (complete) yet no test and no code file exists in the repo — the arrow stops two phases short and the status markers assert a compiled state that isn't there · *intent leads; code is compiled output* + *canonical arrow shape*
- **F3 (high):** the HLD tenet "Waiting is honored in sequence" is contradicted by branch-local allocation priority, and no Decisions row records the trade · *tenet cascade* + *docs carry current intent* (decision capture)
- **F4 (medium):** three behaviors described in the design have no owning intent node — patron contact channels (email/SMS/automated dialer), the staff morning pull list and daily exceptions list, and the once-daily courier · *one LLD per intent component* (LLD gap)
- **F5 (medium):** `PICKUP-005` and `HOLDALLOC-007` both state the reallocation mechanism without a recorded dependency between the two segments — divergence risk when allocation changes · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F6 (medium):** the copy's state transition from `allocated` to holds-shelf is unspecified — `HOLDALLOC-006` ends the state at "until picked up or expired" with no spec for the shelf-scan that ends it, and no spec for transit arrival · *LLDs close enough of the solution space*
- **F7 (medium):** the HLD has no non-goals and no target-user section; scope limits like "hold history is not kept" appear only as a tenet · *HLD is architecture and rationale*
- **F8 (low):** no rule for equal placement timestamps — "the one with the oldest timestamp" is undefined when two holds share a timestamp · *LLDs close enough of the solution space*
- **F9 (low):** spec prefixes (`HOLDALLOC`, `PICKUP`) don't echo their leaf names (`hold-allocation`, `pickup-notices`), so a grep doesn't reveal the mapping without opening the docs · *specs are grep-anchored linkage*
- **F10 (low):** the single-notice choice "watched against Goal 2" names no owner, measurement, or threshold that would trigger a change · *tenet cascade* + *decision capture*

## 3. What was audited

- **Read fully:** `CLAUDE.md`; `docs/high-level-design.md`; `docs/intent/hold-allocation/hold-allocation-design.md`; `docs/intent/pickup-notices/pickup-notices-design.md`; both `*-specs.md` files
- **Enumerated:** 2 LLDs, 13 specs (7 `HOLDALLOC-*`, 6 `PICKUP-*`), 0 arrow segments
- **Arrow-path sampling:** none possible — the repo contains no test directory and no source files, so no path could be traced end-to-end (HLD → LLD → spec → test → code). This is F2.
- **Linkage metric:** 0 `@spec` references across the repo; 0 files carrying `@spec` annotations
- **Overlay:** `docs/arrows/` absent — `docs/arrows/index.yaml` not present, so no index-driven sampling
- **Repo shape:** 6 tracked files total, one commit (`fixture`); no history available to assess tests-before-code ordering
- **Not assessed:** semantic legibility, tests-first ordering, cascade timing across segments — all require code or history that doesn't exist yet

### Detail on the three high findings

**F1 — the instruction file is a mode marker without directives.** `CLAUDE.md:6-8` reads:

```
## LID
- Mode: Full
- Version: 1.4.0
```

There's no directive block: nothing tells an agent to read the HLD first, treat specs as source of truth, or cite `@spec` annotations. The mode is declared, but the *method* isn't. This is exactly the case `/update-lid` reconciles — the coach shouldn't hand-edit the instruction file.

**F2 — status markers outrun the arrow.** All 13 specs are marked `[x]`. In LID, that marker means the behavior is implemented and covered by tests. Nothing in the repo implements or tests anything. Two honest options: build the missing phases (tests, then code) so the markers become true, or change the markers to a pending state so the docs stop claiming a compiled result. Leaving it as-is trains the opposite lesson — that markers are decorative.

**F3 — a tenet and the design disagree.** The HLD tenet states:

> **Waiting is honored in sequence.** Whoever asked for a title sooner receives it sooner; nobody's wait is lengthened by a patron who asked after them.
> — `docs/high-level-design.md:13`

But the allocation design states:

> It first considers holds whose pickup branch is the branch where the copy was scanned; if any exist, the one with the oldest timestamp receives the copy… Only when the scanning branch has no one waiting does the copy go to the oldest hold county-wide
> — `docs/intent/hold-allocation/hold-allocation-design.md:11`

A hold placed earlier at a different branch is passed over for a later hold at the scanning branch — exactly the "wait lengthened by a patron who asked after them" the tenet rules out. `HOLDALLOC-003` and `HOLDALLOC-004` encode the branch-first behavior faithfully, so the specs are coherent; it's the HLD tenet that no longer describes the system. The hold-allocation Decisions table has rows for hold granularity, allocation trigger, and the hold cap — but nothing for branch priority, so a cold reader who notices the conflict has nowhere to find the resolution. Two ways to close it: add a Decisions row naming the tenet traded against and why (branch-local delivery keeps most copies off the daily courier — a real cost, and one the design already leans on), or amend the tenet to read "sequence is honored within a pickup branch" and treat county-wide sequence as the fallback. Either is a live decision — which is why it belongs on the page.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Defaults taken: none of the skill's defaults required a choice — the project was dispatchable as a full review (LID-shaped artifacts present, `## LID` block with `- Mode: Full`, no `## LID Scope` needed), and no `docs/arrows/index.yaml` existed to parse. Per the skill's advisory posture, no files were modified; F1 is directed at `/update-lid` and structural enumeration at `/arrow-maintenance`.*