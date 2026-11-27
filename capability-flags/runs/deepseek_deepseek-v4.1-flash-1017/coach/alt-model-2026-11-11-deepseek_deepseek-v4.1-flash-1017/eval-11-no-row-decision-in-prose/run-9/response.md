**LID Coach review — printfarm**

**Posture:** Solid intent, arrow stops at EARS. One tenet conflict and one unowned cross-node seam are the highest-value fixes.

**Scorecard**
- ✓ Design tree — two cleanly scoped LLDs (`QUEUE`, `REG`) matching the HLD's two nodes
- ✓ Mutation hygiene — docs read as current intent; no history residue, obsolete markers, or changelog text
- ⚠ Cascade — the in-memory queue quietly works against the HLD's "job is a promise" tenet
- ⚠ Decision capture — the durability trade-off lives in Architecture prose, not the Decisions table
- ⚠ Linkage — specs trace cleanly, but several LLD-stated behaviors have no spec
- ⚠ Arrow completeness — stops at EARS; no tests or code yet to close the loop

**Findings (9 total · 3 high · 4 medium · 2 low)**
- **F1 (high):** job-queue's in-memory queue drops accepted jobs on restart, directly against the HLD tenet "a submitted job is a promise: members should be able to upload and walk away," with no recorded exception · *tenet cascade* (design nodes should lean the way the HLD's tenets say to)
- **F2 (high):** the durability choice — in-memory queue, accepted jobs lost on restart, members resubmit — appears only as prose in `job-queue-design.md` §Architecture, never in Decisions & Alternatives; a cold reader would question it and cannot see what was traded · *decision capture* (live decisions need their trade-off on the record)
- **F3 (high):** the queue↔registry idle-reporting seam is contradictory and unowned — job-queue says "when the registry **reports** a printer idle" (push) while printer-registry says "the queue **asks** the registry" (pull); neither LLD designs the contract · *intent attaches at the lowest node that dominates it* (substance spanning both leaves belongs at their shared parent)
- **F4 (medium):** all eight specs are marked `[x]` with no legend and no code or tests, so a cold reader cannot tell whether that means authored, approved, implemented, or verified · *docs carry current intent, written to be read cold*
- **F5 (medium):** job-queue LLD states behaviors with no EARS spec — acceptance only when the class has a registered printer, content-hash file dedupe, and notifying members to resubmit after a restart · *effective intent-tree alignment* (LLD behaviors should have named intent)
- **F6 (medium):** "the printer is marked suspect" is undefined — what suspect changes about dispatch eligibility, how it clears, and how it relates to the registry's separate "unreachable" state are all open edges · *LLDs close enough of the solution space*
- **F7 (medium):** no tests-first or code phase yet; the specs have no consumers, so `@spec` linkage and spec-to-test coherence are unverified · *tests before code* (tests preload use and enforce interface discipline)
- **F8 (low):** HLD has tenets and goals but no success metrics or Key Design Decisions; "fair access to the popular printer classes" cannot be evaluated as written · *HLD is architecture and rationale*
- **F9 (low):** retiring a printer has a spec for heartbeats and dispatch eligibility, but nothing covers jobs already queued for that printer's class · *scope disambiguation / LLD sufficiency*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs, both spec files (all 6 non-git files)
- Enumerated: 2 LLDs, 2 spec files, 8 specs (5 `QUEUE`, 3 `REG`), 0 code files, 0 test files
- No `docs/arrows/` overlay present, so no arrow segments or index to sample
- Linkage metric: 0 `@spec` references (no code exists yet); all 8 spec IDs resolve to their declared `prefix:` frontmatter and to an HLD node

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.