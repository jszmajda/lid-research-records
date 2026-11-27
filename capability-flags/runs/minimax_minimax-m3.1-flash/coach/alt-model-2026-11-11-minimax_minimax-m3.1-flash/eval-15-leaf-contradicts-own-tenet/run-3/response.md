# Shelfwise — LID Coach Report

**Posture:** Healthy design tree, with cascade and configuration drift.

**Scorecard**
- ✓ Design tree — HLD → 2 LLDs → 13 specs, clean hierarchy, one LLD per intent component
- ✓ HLD discipline — architecture and rationale only; no schemas, signatures, or pseudocode
- ✓ Mutation hygiene — no change-narration, obsolete markers, or changelog residue
- ⚠ Linkage — spec leaves are inferential; no tests or code exist yet, so the arrow stops at EARS
- ⚠ Cascade health — one leaf mechanism cuts against an HLD tenet, and one LLD/spec seam disagrees
- ⚠ Configuration — mode is declared, but the instruction file carries no LID directive block

The arrow is real and internally legible across both components; the fastest wins are reconciling the instruction file, resolving the branch-vs-sequence conflict, and closing one LLD/spec seam.

**Findings (12 total · 3 high · 6 medium · 3 low)**
- **F1 (high):** `CLAUDE.md:6-8` has the `## LID` block with `- Mode: Full` but no `linked-intent-dev` / "Linked-Intent Development" directive — a future session sees the mode marker without the workflow that consumes it · *modes are declared, not inferred* → run `/update-lid` to reconcile the instruction file
- **F2 (high):** `docs/intent/hold-allocation/hold-allocation-design.md:11` allocates branch-first, so a later hold at the scanning branch outranks an earlier county-wide hold — this contradicts the HLD tenet "Waiting is honored in sequence" (`docs/high-level-design.md:13`) with no recorded trade-off · *tenets capture forward-looking preference* + *intent attaches at the lowest node that dominates it*
- **F3 (high):** `docs/intent/pickup-notices/pickup-notices-design.md:11` closes the hold and re-runs allocation when the window *lapses*, while `PICKUP-004`/`PICKUP-005` close it only when staff *scan the copy off the shelf* — an adjacent-level contradiction about when a hold ends · *coherence is adjacency* (the specs read as the coherent side, since the copy is still on the shelf at lapse)
- **F4 (medium):** all 13 specs are marked `- [x]` (complete) although the repository contains no implementation and no tests — status markers currently assert something the arrow cannot support · *tests before code* + *arrow completeness*
- **F5 (medium):** the branch-first rule's rationale ("keeps most copies off the courier van, which runs once a day") lives in body prose, not in a Decisions row — a cold reader would still question or want to reverse the routing choice and cannot see what was given up · *docs carry current intent* (decision capture)
- **F6 (medium):** the patron's chosen channel is named in `pickup-notices-design.md:5` and in the HLD tenet "Patrons hear once, clearly", yet no spec records or consumes it — the channel decision is load-bearing but unnamed in EARS · *effective intent-tree alignment*
- **F7 (medium):** patron cancellation of a hold before pickup has no spec (only `HOLDALLOC-007`, cancellation while in transit), and the HLD tenet "A closed hold's record is deleted" has no spec on that path · *effective intent-tree alignment*
- **F8 (medium):** the HLD has Problem, Approach, Tenets, Goals, Components — but no non-goals and no key-design-decisions section; the two load-bearing trade-offs (branch routing, no hold history) are leaf-level only, where a project-global reader will not find them · *HLD is architecture and rationale*
- **F9 (medium):** neither LLD declares its spec prefix or leaf boundary, so resolving `HOLDALLOC-*` to hold-allocation and `PICKUP-*` to pickup-notices is inferential rather than declared · *specs are grep-anchored linkage*
- **F10 (low):** tenet quality — "Staff attention goes to exceptions" reads close to a platitude that narrows little, and "Hold history is not kept" states a constraint rather than a forward-looking tie-breaker; the list is also unordered although routing choices can pull against the sequence tenet · *tenets capture forward-looking preference*
- **F11 (low):** no `docs/arrows/` overlay is installed — optional, but `/arrow-maintenance` would enumerate the LLD/spec seam in F3 and any reverse orphans precisely · *coherence is adjacency*
- **F12 (low):** `PICKUP-002` requires naming the "last pickup date" but never states whether the 7th day is inclusive — a cold reader picks one arbitrarily · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all 4 files under `docs/intent/` (2 design docs, 2 spec files)
- Enumerated: 2 LLDs, 2 spec files, 13 specs (`HOLDALLOC-001..007`, `PICKUP-001..006`)
- Code/test sampling: none possible — the repository contains only documentation (0 implementation files, 0 test files, 0 `@spec` annotations)
- Overlay: absent (`docs/arrows/` does not exist); cold-read pass performed over every LID doc

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

**Defaults taken (non-interactive run):** dispatched to a full review per the declared `Mode: Full` in `CLAUDE.md:7`; no out-of-scope section applies; the coach's advisory posture was honored, so **no project files were created, edited, or deleted** — the report is inline only. No user question was answered on your behalf beyond those defaults; for F1 the recommended path is `/update-lid`, and for F11 it is `/arrow-maintenance`.