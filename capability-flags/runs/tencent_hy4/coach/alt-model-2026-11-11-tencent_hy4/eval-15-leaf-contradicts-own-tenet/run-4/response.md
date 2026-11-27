# LID Coach — Shelfwise

**Posture:** Healthy, well-specified design layer — with configuration drift and a couple of load-bearing decisions left implicit.

**Scorecard**
- ✓ HLD discipline & LLD granularity — a clean architecture-only HLD, one LLD per component, and LLDs that close the solution space without reproducing code.
- ✓ EARS linkage & alignment — 13 unique, zero-padded IDs; every spec WHEN/IF-claused; prefixes trace cleanly to the two LLDs.
- ✓ Verticalize intent — a single HLD → LLD → EARS tree, no second index/tag axis, no changelog or `[obsolete]` residue.
- ⚠ Configuration — `CLAUDE.md` has the `## LID` mode/version block but no `linked-intent-dev` directive block.
- ⚠ Decision capture & tenet cascade — branch-local-first leans against Tenet 1 with no recorded exception; its rationale lives only in prose.
- ⚠ Docs carry current intent — two defensive asides in the pickup-notices body read as rebuttals, not current intent.

**Headline:** The HLD, two LLDs, and thirteen specs form a clean, well-linked, well-specified arrow — and the "Reminders" and "Expiry handling" rows even model good capture by naming the tenet/goal traded against and the accepted cost. The single most valuable next step is reconciling `CLAUDE.md` with `/update-lid`; right behind it, recording the branch-local-first allocation exception so the next session doesn't re-derive why a local hold can jump the queue.

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** `CLAUDE.md` carries the `## LID` mode/version block but no `linked-intent-dev` directive prose, so future sessions aren't told to consult the workflow · *modes are declared, not inferred* — configuration lives explicitly in the instruction file, never assumed. → `/update-lid`.
- **F2 (high):** Branch-local-first allocation (`hold-allocation-design.md:11`) lets a newer local hold overtake an older county-wide one, working against HLD Tenet 1 "waiting is honored in sequence"; the courier-van reason sits in prose with no exception recorded · *tenets capture forward-looking preference* — tenets are tie-breakers downstream designs should lean with, or explicitly trade against.
- **F3 (medium):** That same branch-local-first choice — arguably the LLD's most consequential — survives only in design prose with no Decisions-table row, so a cold reader can't reconstruct the rejected alternative or the cost (older patrons wait longer); contrast the "Expiry handling" row, which does capture its Goal 1 trade-off · *docs carry current intent* — live decisions must be reconstructable from the page, not the chat that produced them.
- **F4 (medium):** "No reminder follows" and "does not trigger a fallback channel" (`pickup-notices-design.md:9,13`) are defensive asides rebutting rejected alternatives already held in the Decisions table · *docs carry current intent* — docs read as current intent, not as answers to past discussions (the Decisions-table rows are the right home; the inline asides are the residue).
- **F5 (medium):** The "Failed delivery" row justifies the staff-call exception with "Patrons chose their channel deliberately," yet the mechanism reaches email/SMS patrons by phone — a channel they didn't choose, and a second contact for one event — without reconciling that against Tenet 3 "on the channel the patron chose" · *docs carry current intent* — decision capture.
- **F6 (low):** Several HLD tenets read as triggered *when X, do Y* rules that duplicate EARS specs (e.g. "Each event produces one message, on the channel the patron chose"), and the four tenets are an unordered list · *tenets capture forward-looking preference* — a tenet is a lean between two defensible answers, not a rule or a value.
- **F7 (low):** The arrow currently stops at EARS — no tests, code, or `@spec` annotations — while all 13 specs are marked `[x]`; when implementation lands, tests-first plus entry-point `@spec` annotations are what make the lower half walkable · *tests carry @spec annotations* — each behavior-citing test names the spec it protects.

**What was audited**
- Read fully (the entire repo, 6 files): `CLAUDE.md`, `docs/high-level-design.md`, both design LLDs, both spec files.
- Enumerated: 1 HLD · 2 LLDs · 2 spec files · 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`) · 7 Decisions-table rows (3 + 4) · 4 tenets · 2 goals.
- Cold-read pass and decisions-table sweep across every LID doc.
- Sampling was judgment-based skim (2 LLDs, 0 `@spec` files, no `docs/arrows/` overlay — the `references/sampling.md` thresholds were not met). No code, test, or arrow-overlay files exist, so the Tests→Code seam, `@spec` placement, and cascade health could not be verified; git history is a single commit ("fixture").

**Defaults taken (non-interactive):** (1) Full review at the skill's stated default Full mode — a LID-shaped project with a missing directive block is coached, not refused, and the declared `- Mode: Full` agrees. (2) Inline report only — nothing written to disk or to project files (advisory posture; no persist was requested, and the coach never edits). (3) No `docs/arrows/index.yaml` exists, so the overlay-corruption choice never arose, and the two closing invitations are handed to you rather than acted on — the coach does not iterate.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding — say F2/F3 — to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.