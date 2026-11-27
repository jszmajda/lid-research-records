# LID Coach — Shelfwise

**Posture:** *Bootstrapping — clean design tree, arrow stops at specs.*

**Scorecard**
- ✓ Mutation hygiene — no history residue, changelogs, or obsolete markers in any doc
- ✓ Linkage — spec IDs unique, zero-padded, and prefix-traceable to both LLDs
- ✓ Mode fit — Full mode matches a project that is wholly LID-shaped
- ⚠ Configuration — `## LID` block declares the mode, but the directive block itself is absent
- ⚠ Cascade coherence — the HLD's first tenet and the allocation LLD disagree on who gets a copy
- ✗ Arrow completeness — every spec is marked done, yet the repo holds no tests or code

The design tree is lean and cold-readable across both components, and each decision table names what was given up. The most valuable next step is deciding whether branch-local routing or strict wait sequence is the real intent, recording that at the HLD, and then running `/update-lid` so the instruction file carries the directives the mode marker implies.

**Findings (10 total · 3 high · 3 medium · 4 low)**
- **F1 (high):** `CLAUDE.md` has a `## LID` block but no LID directives; run `/update-lid` to reconcile · *modes are declared, not inferred* — the instruction file is the foundation every session reads first
- **F2 (high):** all 13 specs are marked `[x]`, but the repo contains no tests or code, so the arrow is not walkable past EARS; if implementation lives elsewhere, say where in the instruction file, otherwise mark them `[ ]` · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, with deviations documented rather than drifted into
- **F3 (high):** branch-local-first allocation (LLD §Design, HOLDALLOC-003/004) contradicts tenet "Waiting is honored in sequence… nobody's wait is lengthened by a patron who asked after them"; the exception belongs at the HLD, as a reworded tenet or a Key Design Decision · *intent attaches at the lowest node that dominates it* — substance that qualifies a parent's tenet rises to the parent
- **F4 (medium):** that same branch-local vs. county-wide FIFO choice has no Decisions & Alternatives row; its rationale (courier van runs once a day) lives only in body prose, and it is the row a cold reader would most pause at · *decision capture* — a fuller table row naming the rejected alternative and accepted cost; a decision doc is an option if the team wants the fairness-vs-courier tradeoff on record
- **F5 (medium):** hold cancellation is relied on (HOLDALLOC-007, LLD §Design) but never specified; a hold cancelled while its copy sits on the holds shelf leaves the copy `allocated` with nothing to release it · *LLDs close enough of the solution space* — edges left open are where the next session guesses
- **F6 (medium):** PICKUP-006 "fails to deliver" reads as universal, but the LLD defines failure only for email and SMS; the automated-dialer case is unstated · *scope disambiguation* — a universal-sounding spec must actually be universal
- **F7 (low):** tenet "Hold history is not kept" is phrased as a triggered rule already encoded by PICKUP-003/005; consider a Non-goals entry or the lean form ("knows who is waiting, never who has read what"), and consider ordering the tenets since sequence and courier cost now conflict · *tenets capture forward-looking preference* — tie-breakers, not rules
- **F8 (low):** neither LLD carries `prefix:` frontmatter, so HOLDALLOC ↔ `hold-allocation/` and PICKUP ↔ `pickup-notices/` are inferred rather than declared · *effective intent-tree alignment* — the leaf's prefix is the authoritative arrow boundary
- **F9 (low):** pickup-notices LLD says the hold closes when the window lapses; PICKUP-004/005 close it only when staff scan the copy off the shelf · *coherence is adjacency* — LLD and specs should agree on the seam
- **F10 (low):** "the circulation system", "the automated dialer", and channel choice "at signup" are referenced as known systems but never introduced anywhere; a one-line integrations note in the HLD would let a cold reader place them · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (the entire project: 6 files)
- Enumerated: 2 LLDs, 2 spec files, 13 spec IDs (7 HOLDALLOC, 6 PICKUP), 7 Decisions & Alternatives rows
- Arrow-path sampled: both segments HLD section → LLD → specs; no test or code files exist to extend either path
- Linkage metric: 0 `@spec` references (no code or tests present); no `docs/arrows/` overlay; not a git repository, so no commit-order evidence for tests-first
- Non-interactive run: no dispatch question arose, so no defaults were substituted; the capability-flags reference in the sibling skill was outside the permitted directories and could not be read, so its flags were treated as applying

**Worth a second look:** models in my class are flagged as prone to missing designs that contradict a project's own tenets. F3 is one such case I did catch, but please check both leaf designs against the HLD tenets yourself rather than relying on that one find.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.