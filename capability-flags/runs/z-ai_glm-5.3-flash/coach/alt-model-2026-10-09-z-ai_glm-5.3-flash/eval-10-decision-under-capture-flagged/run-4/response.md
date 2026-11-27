# LID Coach — Field Notes

## Executive summary

**Posture:** Bootstrapping — arrow in place, content sparse; one live design tension worth capturing.

**Scorecard**
- ✓ Configuration — `CLAUDE.md` has the LID block, Full-mode marker, and a coherent directive (`modes are declared, not inferred`)
- ✓ HLD discipline — architecture and rationale only; no implementation detail has crept upstream
- ✓ Linkage — `SYNC-001`/`SYNC-002` prefix cleanly matches the leaf's `prefix: SYNC`; grep-anchored and unambiguous
- ⚠ Arrow completeness — HLD → LLD → EARS exists, but no tests or code yet; the back half of the arrow is unwalked
- ⚠ Decision capture / tenet cascade — the conflict-handling choice works against your stated goal and its rationale is under-captured

**Headline:** The arrow's front half is real, clean, and correctly configured; the most valuable next step is resolving the conflict-resolution tension before tests and code get built on top of it.

## Findings inventory

> **Findings (5 total · 2 high · 2 medium · 1 low)**

- **F1 (high):** Last-writer-wins by device wall-clock works against the goal "Convergent state after reconnect," given your own Context note that field clocks are wrong by several minutes — two devices with skewed clocks resolving the same note means a *later-written but actually older* edit silently wins, and the loser is discarded, so devices and the canonical store can hold genuinely divergent views · *tenet cascade — check each mechanism against the HLD's tenets and goals under operating conditions the docs describe*
- **F2 (high):** No tests or code exist for `SYNC-001`/`SYNC-002` yet — fine for a bootstrapping project, but build the tests first when you get there so the specs preload the API shape, rather than bolting tests on after · *tests before code — tests preload the use of the target system*
- **F3 (medium):** The conflict-resolution Decisions row's rationale is just "Simpler." — a cold reader holding your clock-skew Context would absolutely still question this choice; either capture what "simpler" was traded against (and why data loss is acceptable) or reconsider the choice · *decision capture — a live decision should record what was given up and what cost was accepted*
- **F4 (medium):** Both specs carry `[x]` (complete) status markers while nothing is implemented; consider `[ ]` until tests and code exist, so status markers stay trustworthy · *mutation, not accumulation — docs reflect current state, not intended state*
- **F5 (low):** `sync-specs.md` opens with a lowercase `# sync specs` header and omits the leaf-title style used elsewhere (`# LLD: Sync`); a small consistency touch · *minimum surface, maximum discipline — small conventions stay uniform*

**Worth a second look:** models configured like me have no recorded evidence either way in this area, so the default flags apply — please check F1 (design contradicting your own goals) yourself against the HLD's Goals section.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs, 1 tenet, 2 Decisions rows
- Code/test sampling: skipped — no code or test files exist in the repository
- Arrow paths sampled end-to-end: 1 of 1 (partial — HLD → LLD → spec only)

## Defaults taken (non-interactive run)

- Advisory posture held — no files were edited; all findings are surfaced for you to apply
- Dispatch resolved to **full review** (directives present, Full mode, HLD + intent docs in place; no arrow overlay, which is optional)
- Empty tests/code layer treated as **bootstrapping posture**, not a violation — flagged as F2 rather than blocking

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.