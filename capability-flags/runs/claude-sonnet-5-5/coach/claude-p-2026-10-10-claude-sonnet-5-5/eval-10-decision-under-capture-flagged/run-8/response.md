## LID Coach report

**Posture:** Solid foundation, with one design choice worth revisiting before code lands.

**Scorecard**
- ✓ Configuration: `CLAUDE.md` has the LID directives, a declared `Mode: Full`, and the standard directories.
- ✓ Linkage: the `SYNC` prefix matches the LLD's `prefix:` frontmatter, and the spec IDs are unique and grep-friendly.
- ✓ Mutation hygiene: the docs carry no history residue, obsolete markers, or changelog sections.
- ✓ HLD discipline: it is short, architecture-level, and free of implementation detail.
- ⚠ Design vs. goals: the conflict rule works against the project's own problem statement under a condition the LLD itself describes.
- ⚠ LLD sufficiency and arrow completeness: several edges are left open, and the arrow stops at specs.

**Headline:** The doc tree is lean, cleanly linked from HLD to LLD to specs, and written in present tense with a real tenet. The most valuable next step is to look again at last-writer-wins by device wall-clock, given that the LLD says device clocks are often minutes off.

**Findings (5 total · 1 high · 3 medium · 1 low)**
- **F1 (high):** Conflict resolution by device wall-clock, in `sync-design.md` ("Conflict handling") and `SYNC-002`. The same LLD says clocks are "frequently wrong by several minutes". Under that condition the genuinely later edit can lose and be silently discarded, which undercuts the HLD's "No blocked capture in the field" and the Problem's reconcile-on-reconnect intent. · *intent attaches at the lowest node that dominates it* and the HLD's tenets and goals should be carried through to leaf designs (tenet cascade)
- **F2 (medium):** The Decisions row for conflict resolution says only "Simpler." It doesn't record what was given up (silent loss of a technician's edit, dependence on unreliable clocks) or the accepted cost. A cold reader would question this choice, and the row doesn't let them reconstruct the trade-off. · *docs carry current intent, written to be read cold* (decision capture)
- **F3 (medium):** The LLD leaves solution edges open: the unit of conflict (whole note or field), equal timestamps, non-conflicting edits to the same note, deletes, and whether a discarded edit is kept anywhere. Two reasonable agents would implement these differently. · *LLDs close enough of the solution space*
- **F4 (medium):** The arrow stops at specs. Both specs are marked `[x]`, but the repo has no tests or code, so nothing carries `@spec` annotations and the marker can't be checked. If the code lives elsewhere, a pointer in the LLD would help. · *canonical arrow shape*, *tests carry `@spec` annotations*
- **F5 (low):** The HLD goals ("Convergent state after reconnect", "No blocked capture") have no spec that expresses or tests them. `SYNC-001` and `SYNC-002` cover upload and conflict only. · *effective intent-tree alignment*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`.
- Enumerated: 1 HLD, 1 LLD, 1 spec file (2 specs), no arrow overlay (`docs/arrows/` absent), no code or test files.
- Cold-read pass: all four LID docs.
- Decisions-table sweep: 2 rows. The SQLite row passes, since the choice is evident from the HLD's "Boring over clever" tenet. The conflict-resolution row is F2.

**Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together?** You can also pick a specific finding to dig into, and F1 and F2 pair well.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.