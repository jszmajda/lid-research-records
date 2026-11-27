# LID Coach — Shelfwise

## Executive summary

**Posture:** Well-formed design layer with one tenet-level contradiction; the arrow stops at the specs.

**Scorecard**
- ✓ Design-tree shape — one HLD, two LLDs that map one-to-one onto the HLD's components, and one spec file per LLD with matching prefixes
- ✓ Mutation hygiene — every doc reads as current intent, with no changelog residue, obsolete markers or "as discussed" leftovers
- ✓ Decision capture in pickup-notices — the rows name what was given up, and two of them explicitly name the tenet or goal they trade against
- ✗ Tenet cascade — hold allocation's ordering rule works against the first tenet
- ✗ Arrow completeness — there are no tests or code in the repository, yet every spec is marked done
- ⚠ Configuration — `CLAUDE.md` declares the mode but carries no LID directives

**Headline:** The design docs are short, cold-readable and honest about their trade-offs — the pickup-notices Decisions table is a model of the form. The most valuable next step is to resolve the conflict between branch-first allocation and "Waiting is honored in sequence", in whichever direction you intend.

## Findings (10 total · 4 high · 3 medium · 3 low)

- **F1 (high):** Hold allocation serves the scanning branch's holds before the oldest hold county-wide, so a patron who asked first at another branch is passed over whenever copies are returned elsewhere (`hold-allocation-design.md:11`, HOLDALLOC-003/004). This works against the tenet "nobody's wait is lengthened by a patron who asked after them." · *tenet cascade* — leaf designs should lean the way the HLD's tenets say to lean, or record the exception.
- **F2 (high):** The branch-first choice has no Decisions & Alternatives row; its only rationale is a prose aside about the courier van. A cold reader can't tell whether the tenet was traded deliberately or missed. · *decision capture* — a choice a reader would still question needs its alternative and accepted cost on the page.
- **F3 (high):** All 13 specs are marked `[x]`, but the repository holds no tests, no code and no `@spec` annotations. Either the implementation lives somewhere the docs don't name, or the markers are ahead of reality. · *canonical arrow shape* — HLD → LLDs → specs → tests → code, each phase present and linked.
- **F4 (high):** `CLAUDE.md` has the `## LID` mode block but none of the linked-intent-dev directives, so future sessions aren't told to follow the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is where LID's foundation is made visible.
- **F5 (medium):** The pickup-notices design reads as the hold closing when the window lapses; PICKUP-004/005 close it only when staff scan the copy off the shelf. Whether a patron can still check out in between is undefined. · *coherence is adjacency* — specs agree with their LLD.
- **F6 (medium):** Hold cancellation has no spec of its own. Only the in-transit aftermath is covered (HOLDALLOC-007), not the cancel itself, a cancel while the copy is on the holds shelf, or deletion of the cancelled record that "Hold history is not kept" implies. · *LLDs close enough of the solution space* — two agents reading the doc should land on compatible implementations.
- **F7 (medium):** The four tenets are an unordered list, yet they can pull against each other and against the goals ("hear once" against the expiry goal, "in sequence" against courier efficiency). · *tenets capture forward-looking preference* — tie-breakers need an order when they can collide.
- **F8 (low):** Two cold-read gaps in pickup-notices: what counts as a failed delivery for the phone-dialer channel, and whether a patron is told when their hold expires. The tenet says "each event produces one message", but the design is silent on expiry. · *docs carry current intent, written to be read cold* — the page must stand without the conversation behind it.
- **F9 (low):** HOLDALLOC-004's trigger ("no open hold names the scanning branch") also matches HOLDALLOC-005's case of no open holds at all. Consider tightening 004 to "open holds exist, but none names the scanning branch." · *scope disambiguation* — a spec found by grep alone should be unambiguous.
- **F10 (low):** The HLD has no non-goals or target-users section. Consider adding non-goals in particular; they are cheap and narrow future decisions. · *HLD is architecture and rationale* — the HLD carries the project-level why.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` — all six tracked files.
- Enumerated: 2 LLDs, 2 spec files, 13 specs (HOLDALLOC-001–007, PICKUP-001–006), 7 Decisions rows.
- Code and tests: none in the repository, so nothing was sampled; 0 `@spec` references.
- Arrow overlay: `docs/arrows/` is not present, so no structural audit input.
- Dispatch: Full mode is declared. Because the directive text is missing but the project is clearly LID-shaped, I ran a full review and raised the gap as F4.
- This was an advisory review; no files were changed.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 are a natural pair.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.