**Shelfwise — LID Coach Review**

**Posture:** Design arrow is clean and current, but it stops at specs — implementation is absent and a few load-bearing seams need tightening before they harden.

**Scorecard**
- ✓ Mutation hygiene — docs read as present intent; no changelog residue or `[obsolete]` markers
- ✓ LLD granularity — two clear intent components, neither lumped nor over-fragmented
- ⚠ Linkage — spec IDs are grep-friendly, but leaf boundaries live only in filenames
- ✗ Coherence & cascade — expiry timing differs between LLD and specs; allocation and deletion pull against the tenets/goals
- ✗ Arrow completeness — no tests or code exist, yet all 13 specs are checked `[x]`
- ⚠ Configuration — the mode marker is present but the LID directive block is absent

**Findings (12 total · 6 high · 3 medium · 3 low)**

- **F1 (high):** `CLAUDE.md:5–7` declares `## LID` / `- Mode: Full` but never references "linked-intent-dev" or "Linked-Intent Development" · *modes are declared, not inferred* — the declaration is half-present, so tooling that keys off the directive block will miss this project · consider `/update-lid`.
- **F2 (high):** no test or code phase exists anywhere in the repo, while every spec carries `- [x]` (`hold-allocation-specs.md:3–9`, `pickup-notices-specs.md:3–8`) · *tests before code* — tests are what pre-load how the system is used; marking specs complete with nothing exercising them makes the checkmarks claim something the arrow cannot back up.
- **F3 (high):** `pickup-notices-design.md:11` says the hold closes and the copy is reallocated when the window lapses, but `PICKUP-004:6` adds the copy to the pull list and `PICKUP-005:7` closes/reallocates only when staff scan it off the shelf · *coherence is adjacency* — two adjacent levels disagree on when reallocation happens; an implementer reading either alone would build a different system.
- **F4 (high):** the branch-local rule in `hold-allocation-design.md:11` gives a copy to a newer local hold before an older county-wide hold, which reads against the HLD tenet "nobody's wait is lengthened by a patron who asked after them" (`high-level-design.md:13`), and no Decisions & Alternatives row names the trade · *tenet cascade* — a mechanism that works against a tenet needs the exception recorded, or the tenet stops constraining anything.
- **F5 (high):** `hold-allocation-design.md:13` covers only cancellation of an in-transit copy; there is no design or spec for cancelling a waiting or allocated hold, including whether its record is deleted · *LLDs close enough of the solution space* — the agent will invent this edge in code, and it touches the "hold history is not kept" tenet directly.
- **F6 (high):** deleting a closed hold's record (`pickup-notices-design.md:10–11`, `PICKUP-003`, `PICKUP-005`) leaves no stated mechanism to compute Goal 1 (check-in→notice median) or Goal 2 (expiry rate) · *tenet cascade* — the deletion tenet defeats the success metrics unless aggregate counters are kept; no decision row records that exception.
- **F7 (medium):** neither `hold-allocation-design.md` nor `pickup-notices-design.md` declares a `prefix:` frontmatter, so the leaf-path boundary exists only in filenames · *specs are grep-anchored linkage* — the prefix is the authoritative resolution point for whether a spec ID is orphaned; make it explicit.
- **F8 (medium):** the HLD has Problem, Approach, Tenets, Goals, and Components but no target-users, non-goals, or architecture-level key-decisions section · *HLD is architecture and rationale* — those are the parts a cold reader needs to understand where the system deliberately stops.
- **F9 (medium):** `HOLDALLOC-002:4` and `hold-allocation-design.md:15` cap "open holds" at 15 but never say whether an `allocated` copy still counts as open · *scope disambiguation* — a cold reader cannot implement the cap unambiguously.
- **F10 (low):** prefix styles diverge — `HOLDALLOC` from `hold-allocation`, but `PICKUP` from `pickup-notices` · *semantic legibility as cheap linkage* — a grep for `PICKUP` matches, but the code surface no longer echoes the component name.
- **F11 (low):** four tenets are an unordered bullet list and at least one pair can conflict (record deletion vs. expiry-rate goal) · *tenets capture forward-looking preference* — ordering tells a future session which lean wins when they collide.
- **F12 (low):** `pickup-notices-design.md:9` says "scanning a copy" starts the window, while `PICKUP-001:3` restricts it to an "allocated copy" · *scope disambiguation* — a cold reader cannot tell whether scanning any returned copy starts a window.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs, both spec files (all 6 files outside `.git`).
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs (`HOLDALLOC-001`–`007`, `PICKUP-001`–`006`), 7 Decisions & Alternatives rows.
- No code, tests, or `docs/arrows/index.yaml` exist; no `@spec` linkage to sample.
- Coverage was exhaustive rather than sampled, given the project size.
- Defaults taken (non-interactive run): full review, advisory only, no files changed, report rendered inline and not persisted.

**Out-of-scope note:** none — Full mode covers the whole repo.

Want me to walk through the findings in detail, focus on a theme or priority (coherence first, or the tenet/goal conflicts), or work through a specific item together? You can also pick one finding to dig into.

If you have broader questions about using LID for Shelfwise — where implementation phases fit while specs are ahead of code, how to record a tenet exception, or how the arrow overlay would help enumerate these seams — I can help with those too.