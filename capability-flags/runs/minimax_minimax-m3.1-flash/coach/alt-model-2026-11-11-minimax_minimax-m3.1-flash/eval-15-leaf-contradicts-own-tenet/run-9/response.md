# LID Coach — Shelfwise

**Posture:** Well-shaped design docs, with an incomplete arrow and one live tenet conflict.

**Scorecard**
- ✓ Design hygiene — HLD, LLDs, and specs carry current intent; no history residue, no obsolete markers
- ✗ Arrow completeness — HLD → LLD → EARS are present; the Tests and Code phases are absent while every spec is checked off
- ⚠ Decision capture — pickup-notices captures its trade-offs well; hold-allocation's loadiest rule has no row
- ⚠ Tenet coherence — branch-first allocation cuts against "Waiting is honored in sequence"
- ⚠ Linkage — spec ID prefixes are contractions of their leaf path, so the tree isn't one grep away
- ⚠ Configuration — mode is declared, but the instruction file carries no LID directives

**Headline:** The design layer is genuinely good — two clean LLDs with real Decisions tables, coherent EARS, disciplined mutation hygiene — and the fastest wins are reconciling the instruction file and capturing (or retiring) the branch-first allocation rule.

---

**Findings (9 total · 4 high · 4 medium · 1 low)**

- **F1 (high):** `CLAUDE.md` has the `## LID` block (`- Mode: Full`, `- Version: 1.4.0`) but no LID directives — nothing states that `docs/` holds the arrow, that specs live in `docs/intent/`, or that specs lead code · *modes are declared, not inferred* (the instruction file states how LID is used here) — recommend `/update-lid`
- **F2 (high):** the arrow stops at EARS: all 13 specs are marked `[x]` (complete) but the repo contains no test files and no source files, so the Tests and Code phases are missing entirely · *canonical arrow shape* (`HLD → LLDs → EARS → Tests → Code`) — either the implementation lives outside this repo (worth saying in the instruction file) or the checkmarks overstate completion
- **F3 (high):** the branch-first allocation rule (`hold-allocation-design.md:11`) — scanning-branch holds win over an older county-wide hold — has no Decisions & Alternatives row, so a cold reader sees the behavior with none of its rationale · *decision capture* (a live choice is recorded where a future reader can see it, with what was given up)
- **F4 (high):** the same rule conflicts with the HLD tenet "Waiting is honored in sequence — nobody's wait is lengthened by a patron who asked after them" (`docs/high-level-design.md:13`), since an older county-wide hold loses to a newer local one · *tenet cascade* (design nodes lean the way the HLD's tenets say to lean) — the prose rationale ("keeps most copies off the courier van") exists, but no row records the tenet traded against
- **F5 (medium):** expiry handling makes staff pull lapsed copies from the shelf and scan them off (`pickup-notices-design.md:11`, PICKUP-005) — a routine manual step against the tenet "Staff attention goes to exceptions" · *tenet cascade* — the Expiry-handling row names Goal 1's cost but not the tenet being traded
- **F6 (medium):** how Shelfwise learns a transit copy has arrived is left open — HOLDALLOC-007 and PICKUP-005 both hinge on "arrives at a branch" and on a staff off-shelf scan, but no mechanism (arrival scan? courier feed?) is stated · *LLDs close enough of the solution space* (two reasonable implementers would land on different designs)
- **F7 (medium):** spec ID prefixes are contractions of their leaf path — `HOLDALLOC-` for `docs/intent/hold-allocation/`, `PICKUP-` for `pickup-notices/` · *specs are grep-anchored linkage* (the ID prefix is the root-to-leaf path, so one grep walks the tree) — as written, grepping the directory name finds no spec and grepping the prefix finds no file
- **F8 (medium):** the HLD has no Non-goals and no Key Design Decisions section, so architecture-level choices — title-level holds, event-driven check-in trigger, no hold history, courier transit routing — appear only in the two LLD Decisions tables · *HLD is architecture and rationale* (why the system is shaped this way belongs at the top level)
- **F9 (low):** wording drift between design and specs on the same object — "a daily exceptions list" (`pickup-notices-design.md:13`) vs "that day's exceptions list" (PICKUP-006); "the morning pull list" vs "the next morning's pull list" (PICKUP-004) · *docs carry current intent* (one phrasing, one meaning)

---

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both `docs/intent/*/*-design.md`, both `docs/intent/*/*-specs.md` — the entire repository (6 files, 1 commit)
- Enumerated: 2 LLDs, 2 spec files, 13 specs (7 `HOLDALLOC-*`, 6 `PICKUP-*`), 0 `@spec` annotations, 0 test files, 0 source files
- Code/test sampling: not applicable — no code or tests exist in this repository
- Arrow overlay: `docs/arrows/` is not installed, so no `index.yaml` was read and no structural enumeration (orphans, reverse orphans) was attempted
- Sampling guidance (`references/sampling.md`) not required — the project is well under the size thresholds

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Defaults taken (non-interactive run):* reviewed in Full mode as declared in `CLAUDE.md:7`; produced the report inline and did not persist it to disk, per the skill's advisory posture; made no file edits (the skill's advisory posture reserves changes for you, `/update-lid`, or `/arrow-maintenance`); no questions were asked, so F3/F4 and F5 were reported as separate findings — the same choice can be both an unrecorded decision and a tenet conflict, with the remedies left as your call.