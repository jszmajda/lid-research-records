# Shelfwise — LID Coach Report

## 1. Executive summary

**Posture:** Solid design core, thin configuration and coherence seams.

**Scorecard**
- ⚠ Configuration — `## LID` block declares Mode and Version, but carries no workflow directives
- ✓ HLD discipline — architecture-level only; no schemas, signatures, or API shapes
- ✓ LLD granularity — exactly one LLD per intent component, no lumping or fragmentation
- ⚠ Tenet cascade — the sequence tenet and the branch-first allocation rule disagree, unrecorded
- ⚠ Adjacent-level coherence — allocation-state rules conflict; the allocation→notice loop is open
- ⚠ Decision capture — one consequential choice (the hold cap's number) has no recorded source

**Headline:** Your design layer is genuinely well-shaped — clean HLD, real tenets, one LLD per component, EARS-shaped and collision-free specs, and two Decisions tables that already name accepted costs. The fastest wins are configuration reconciliation (`/update-lid`) plus a small set of coherence and decision-capture fixes in `docs/intent/`.

## 2. Findings (13 total · 2 high · 8 medium · 3 low)

- **F1 (high):** `CLAUDE.md` has a `## LID` block with only `- Mode: Full` / `- Version: 1.4.0` — no `linked-intent-dev` directive and no workflow text, so a fresh session has no instruction to walk the arrow · *modes are declared, not inferred* (the mode and the workflow are both declared in the instruction file; an unread mode is a default) — fix via `/update-lid`
- **F2 (high):** HLD tenet "Waiting is honored in sequence" is contradicted by the local-branch-first allocation rule (`docs/high-level-design.md:13` vs `docs/intent/hold-allocation/hold-allocation-design.md:11`, spec `HOLDALLOC-003`), and no Decisions row records the exception · *tenets capture forward-looking preference* (a tenet states which way to lean; a mechanism that works against one is a finding)
- **F3 (medium):** Goal 1's 4-hour notification target is defeated on the transit path — the courier runs once a day (`hold-allocation-design.md:11`) and the only Goal-1 acknowledgement in the docs covers the expiry path, not transit · *tenet cascade* (name the goal, the mechanism, the condition)
- **F4 (medium):** `HOLDALLOC-006` (a copy `allocated` is not reassigned) contradicts `HOLDALLOC-007` (re-run allocation for an in-transit copy whose hold was cancelled); no spec says a copy ever leaves the `allocated` state · *coherence is adjacency* (adjacent levels/specs must agree) — also `HOLDALLOC-003/004/005` don't scope on the copy's allocated state
- **F5 (medium):** Expiry closure diverges between levels — the LLD says the hold closes at window lapse (`pickup-notices-design.md:11`), but `PICKUP-004/005` close and reallocate only when staff scan the copy off the shelf · *coherence is adjacency*
- **F6 (medium):** The allocation→notification loop is never closed: allocation prints a slip, but the pickup window and ready notice start only on a separate shelf scan (`PICKUP-001`), and no spec obliges that scan or provides a fallback, so an unscanned copy never notifies and never expires · *intent leads; code is compiled output* (the spec set is the source of truth for what happens)
- **F7 (medium):** Hold cancellation is specified only in the in-transit case (`HOLDALLOC-007`); nothing says what a cancelled hold's record does, so the HLD tenet "Hold history is not kept" (`high-level-design.md:16`) is only half-pinned down · *intent-tree alignment* (LLD behaviors with no spec are unnamed intent)
- **F8 (medium):** Decision capture — the hold cap's number 15 has no source; the sibling rows in both Decisions tables explain *why their number was chosen* ("3 misses weekly visitors; 14 idles copies"), so a cold reader will ask "why 15?" · *docs carry current intent* (a live choice should survive a cold reader wanting to reverse it)
- **F9 (medium):** All 13 spec markers read `[x]` while the repository contains no tests and no code, and no marker convention is documented — a cold reader would conclude the system is built · *canonical arrow shape* (the arrow is HLD → LLD → EARS → Tests → Code) — plus *intent leads; code is compiled output*
- **F10 (medium):** Leaf prefixes are undeclared — neither LLD carries `prefix:` frontmatter, and `HOLDALLOC` diverges from the leaf path `hold-allocation`, so spec↔LLD resolution rests on string matching · *specs are grep-anchored linkage* (IDs whose prefix is the root-to-leaf path)
- **F11 (low):** No arrow-maintenance overlay installed (`docs/arrows/` absent) — fine today, but there's no index to guide structural audits · *minimum surface, maximum discipline* — add via `/update-lid`
- **F12 (low):** The HLD has no Target users, Non-goals, or Key Design Decisions section; the system boundary is carried implicitly by the two-component list · *HLD is architecture and rationale*
- **F13 (low):** Channel selection and "failed delivery" are undefined for the phone-dialer channel (`pickup-notices-design.md:5,13`) — is an unanswered call a failed delivery, and where is the chosen channel stored? · *scope disambiguation* (a spec that applies to only one variant must scope it)

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (both LLDs, both spec files) — 6 tracked files, the entire repository
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs, 4 HLD tenets, 2 goals, 7 Decisions rows, 1 mode marker
- Sampled: the whole repo for code and tests — `git ls-files` shows no source or test files and 0 `@spec` annotations, so linkage and test-first dimensions are not yet exercisable
- Overlay: not installed, so no `index.yaml` or arrow docs to read
- Verification: every spec ID is unique across the tree and namespaced per file; no `[obsolete]` markers, changelogs, or change-narration found in any doc

## 4. Defaults taken in this run

- **Mode:** Full (read from the `- Mode: Full` bullet); the `## LID Scope` section is not required in Full, so the out-of-scope section is omitted
- **Dispatch:** proceeded to a full review because the project is LID-shaped (HLD + two LLD/spec pairs) even though the instruction file lacks the directive block — F1 is surfaced rather than treated as a blocker
- **Sampling:** judged, not by rule — the repo is far below the 15-LLD / 200-annotated-file thresholds and has no overlay, so the full doc tree was read exhaustively and code/test sampling returned nothing
- **No files were changed and nothing was written to disk** — this skill is advisory (*user is always right — with warning*); fixes are yours to apply, via `/update-lid` for F1/F11, `/arrow-maintenance` if you want the structural enumeration behind F4/F5/F10, and direct edits for the rest

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.