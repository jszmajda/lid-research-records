**LID Coach — Field Notes**

## 1. Executive summary

**Posture:** Bootstrapping — arrow in place and cleanly shaped, with one live design risk in the sync decision.

**Scorecard**
- ✓ Mutation hygiene — no history residue, no `[obsolete]` markers, docs read as current intent
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures bleeding upstream
- ✓ Linkage form — `SYNC-NNN` IDs are grep-clean and trace to the leaf's declared `prefix: SYNC`
- ⚠ Arrow completeness — specs are marked `[x]` but no tests or code exist in the repo
- ⚠ Decision capture — the conflict-resolution row records the choice without what it gave up
- ⚠ Tenet cascade — the sync merge works against the HLD's convergence goal under a condition the LLD itself names

**Headline:** For a two-doc project the arrow is unusually well-formed — parent/prefix frontmatter, specs that each carry a real WHEN clause, an HLD that stays at architecture altitude. The most valuable next step is the conflict-resolution decision: as written it discards field edits precisely in the clock-skew condition the LLD describes, and the Decisions row doesn't carry enough for a future session to know that was accepted on purpose.

## 2. Findings

**Findings (8 total · 3 high · 3 medium · 2 low)**

- **F1 (high):** `sync-design.md:17` resolves conflicts by device wall-clock, while `sync-design.md:9` states those clocks are wrong by several minutes — under that described condition the later edit can be discarded, working against the HLD goal *Convergent state after reconnect*; no Decisions row records the trade · *tenet cascade / keep the arrow coherent*
- **F2 (high):** `sync-design.md:23` captures last-writer-wins with the rationale "Simpler." — a cold reader holding the clock-skew paragraph would still want to reverse this, and can't see which alternative was weighed or that silent edit loss was the accepted cost · *decision capture — docs carry current intent*
- **F3 (high):** `SYNC-001`/`SYNC-002` are marked `[x]` but the repo contains no tests and no code, so the arrow currently stops at EARS and the status markers assert a phase that isn't there · *canonical arrow shape*; *tests carry `@spec` annotations*
- **F4 (medium):** The LLD leaves solution edges open — what becomes of the discarded edit (logged? surfaced to the technician?), equal-timestamp tie-breaking, how the NTP resync in Context interacts with merge ordering — two reasonable agents would land on incompatible implementations · *LLDs close enough of the solution space*
- **F5 (medium):** Behaviors the LLD names carry no spec: merging uploads into the canonical store (`:13`) and SQLite device storage (`:24`) are intent with nothing to test against · *effective intent-tree alignment*
- **F6 (medium):** The HLD has no target users, key design decisions, or success metrics sections, and *Architecture* (`:13`) is a single clause — the convergence goal has no metric for a future session to check a design against · *HLD is architecture and rationale*
- **F7 (low):** One tenet, and it doesn't cover the tie-break this project keeps meeting — when simplicity and preserving captured field data pull apart, nothing pre-narrows the lean, so each session samples its own answer (F1 is one such sample) · *tenets capture forward-looking preference*
- **F8 (low):** The clock-skew constraint is load-bearing for the whole sync design but lives only in the LLD's Context prose; consider whether it belongs in the HLD as a constraint the architecture answers to · *intent attaches at the lowest node that dominates it*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the entire repo (4 files)
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs, 1 design-tree segment (`SYNC`), 2 Decisions & Alternatives rows
- Arrow-path walked: 1 segment end-to-end (HLD *Approach/Goals* → sync LLD → `SYNC-001/002` → tests → code); the tests and code phases are empty
- Linkage metric: 0 `@spec` references found across the repo; 0 code or test files present
- Cold-read pass: both LID docs; decisions sweep: both rows (the SQLite row passes — it reads as the natural choice under *boring over clever*)
- No `docs/arrows/` overlay, so no structural audit was available; dispatch defaults applied with no questions needed (Full mode declared, directives present)

## 4. Offer to help

Want me to walk through any of these in detail, focus on a theme or priority, or work through specific items together? F1 and F2 are the pair I'd start with — they're the same choice seen from the design side and the capture side, and fixing one makes the other easy.

If you have broader questions about using LID on this project — when to promote `sync` to a sub-HLD, how to get the tests-and-code phases moving, where status markers should sit before implementation lands, or how PRDs fit alongside the HLD — I can help with those too.

*Advisory only — I haven't changed any files. Configuration changes go through `/update-lid`; a structural enumeration would come from `/arrow-maintenance` once the overlay is installed.*