# LID Coach — Shelfwise

**Posture:** Solid, well-specified design layer — with one load-bearing tenet/design contradiction and a configuration gap to reconcile.

**Scorecard**
- ✓ HLD discipline — one clean HLD; tenets, goals and components carry the *why*; no schema/code detail bleeding upstream
- ✓ LLD granularity & sufficiency — one tightly-specified LLD per HLD component, with real Decisions & Alternatives tables
- ✓ EARS hygiene — clean triggered *When/While/If-then* specs, 13 unique namespaced IDs, consistent `[x]` status markers
- ⚠ Configuration — `Mode: Full` is declared, but the directive block linking to `linked-intent-dev` is absent
- ✗ Tenet cascade — "Waiting is honored in sequence" is contradicted by local-first allocation, with no recorded exception
- ⚠ Decision capture & cold-read — one live decision has no Decisions row; a couple of conversational fossils in body prose

**Headline:** The HLD, two LLDs, and 13 EARS specs form a clean, well-linked arrow with genuinely useful Decisions tables; the fastest win is reconciling the "waiting is honored in sequence" tenet with the local-first allocation (and capturing that trade-off), then restoring the instruction-file directives via `/update-lid`.

**Findings (8 total · 3 high · 4 medium · 1 low)**
- **F1 (high):** `CLAUDE.md` has the `## LID` block (`Mode: Full`, `Version`) but no LID directive block pointing to `linked-intent-dev` / the six-phase workflow, so a cold session has nothing telling it to walk the arrow · *modes are declared, not inferred* (the instruction-file LID block is the foundation every session reads). Recommended: `/update-lid`.
- **F2 (high):** The "Waiting is honored in sequence" tenet ("nobody's wait is lengthened by a patron who asked after them") is contradicted by hold-allocation's local-first rule — a later local hold beats an earlier remote one, and HOLDALLOC-003/004 encode exactly that · *tenet cascade* (mechanisms must lean with the HLD's tenets and goals, or record the exception). No Decisions row names the trade-off.
- **F3 (high):** That local-first choice is a live decision a cold reader would question, yet it has no Decisions & Alternatives row — only a body-prose aside ("keeps most copies off the courier van") with neither the tenet traded against nor the cost accepted · *docs carry current intent, written to be read cold* (live decisions must be reconstructable from the doc tree). Reported alongside F2.
- **F4 (medium):** Goal 1 (check-in → notification < 4 business hours) is strained by transit copies: notice waits until a copy reaches a holds shelf, and the courier "runs once a day" — the same day-of-latency the "Allocation trigger" row rejected the nightly batch for · *tenet cascade* (goals count; name the goal and mechanism, and record the exception). The pickup-notices "Expiry handling" row is a good model of how to capture it.
- **F5 (medium):** `## Tenets` is an unordered four-item list and the tenets can conflict (sequence vs. keeping copies off the van / staff-on-exceptions), with no precedence — that ambiguity is what let F2 land unresolved · *tenets capture forward-looking preference* (real tie-breakers, ordered when they could conflict). Consider ordering them.
- **F6 (medium):** The repo is docs-only — no tests, no code, no `@spec` annotations — yet all 13 specs are `[x]`. If Shelfwise is already live, the *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code) has no walkable bottom two phases and *tests carry @spec annotations* can't hold · consider whether `[x]` means "authored" or "implemented," and add the lower phases as implementation starts.
- **F7 (medium):** `pickup-notices-design.md` body prose carries defensive asides — "No reminder follows", "does not trigger a fallback channel" — that rebut proposals not on the page; the rejected alternatives are already held correctly in the Decisions & Alternatives rows (keep those) · *docs carry current intent, written to be read cold* / *mutation, not accumulation* (conversational fossils are residue; the Decisions rows are the right home).
- **F8 (low):** The HLD carries Problem, Approach, Tenets, Goals, Components but is light on target users, non-goals, and explicit key design decisions — the architecture-level *why* leans almost entirely on four tenets and two goals · *HLD is architecture and rationale*. Consider filling those at the next architecture decision.

**What was audited**
- Read fully — all 7 files in the repo: `CLAUDE.md`, `docs/high-level-design.md`, 2 LLDs (`hold-allocation-design.md`, `pickup-notices-design.md`), 2 spec files (`hold-allocation-specs.md`, `pickup-notices-specs.md`), plus all 4 skill `references/` files.
- Enumerated: 1 HLD, 2 LLDs, 2 EARS spec files, 13 spec IDs (HOLDALLOC-001–007, PICKUP-001–006), all `[x]`; 7 Decisions & Alternatives rows across 2 tables; 0 `@spec` annotations; 0 test/code files; no `docs/arrows/` overlay; no `prefix:` frontmatter; no LID directive string in the instruction file.
- Cold-read pass over every LID doc (read context-free); decisions-table sweep over all 7 rows against the HLD and the docs above them.
- Sampling: below the `sampling.md` thresholds (2 LLDs, 0 `@spec` files, no `index.yaml`), so a judgment-based full read — every file read rather than arrow-path sampling.

**Offer to help**
Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Defaults taken (non-interactive run): proceeded with a **full review** — the dispatch default for an artifacts-present / directives-missing project — rather than declining to coach, and honored the declared **Full** mode (no Scoped scope, so no out-of-scope section); rendered the report **inline and made no file edits** (advisory default — nothing persisted to disk); used **judgment-based full reading** instead of `sampling.md`'s arrow-path sampling (below its 15-LLD / 200-`@spec` / overlay thresholds); and left both offer-to-help invitations **open without entering a follow-up turn or the FAQ**.*