# LID Coach review — Shelfwise

*Healthy, well-authored intent layer; the arrow stops at EARS, with one tenet trade left unrecorded.*

**Scorecard**
- ✓ EARS & LLD quality — 13 well-formed triggered specs; designs specific enough to implement, with disciplined Decisions tables
- ✓ HLD discipline — architecture-level Problem/Approach/Tenets/Goals, real tie-breakers, no implementation bleed
- ✓ Mutation hygiene — no changelog, obsolete, or planning residue anywhere in the docs
- ✗ Arrow completeness — no Tests or Code phases, yet every spec is marked `[x]`
- ⚠ Configuration — Mode/Version declared, but CLAUDE.md carries no linked-intent-dev directive block
- ⚠ Tenet cascade — local-branch allocation leans against "Waiting is honored in sequence" with no recorded exception

The intent layer is unusually clean — well-formed EARS, specific LLDs, real tenets, and a standout Decisions row that already names the Goal-1 cost of expiry handling — so the most valuable next step is small and surgical: record the allocation rule's trade against "Waiting is honored in sequence," which currently lives only in prose; the quick `/update-lid` reconciliation of the missing directives is the other fast win.

**Findings (7 total · 3 high · 3 medium · 1 low)**
- **F1 (high):** CLAUDE.md has a `## LID` block (Mode, Version) but no directive block referencing `linked-intent-dev` · *modes are declared, not inferred* — LID configuration, including the workflow directives, belongs explicitly in the instruction file so every future session reads it cold (→ `/update-lid`)
- **F2 (high):** the arrow stops at EARS — there are no Tests or Code phases for either component · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code is what makes the arrow walkable end-to-end
- **F3 (high):** scanning-branch holds get priority over earlier county-wide holds, so when a copy is checked in at a branch with a later local hold while an earlier hold waits elsewhere, the later patron is served first — this works against the "Waiting is honored in sequence" tenet, and no exception is recorded (contrast: pickup-notices' expiry row names its Goal-1 cost cleanly) · *tenets capture forward-looking preference* — design nodes should lean the way the HLD's tenets say, and name any trade they make against one
- **F4 (medium):** the local-branch-priority choice is a live decision a cold reader would question, yet it sits only in design prose with no Decisions row naming the rejected alternative (strict county-wide FIFO) and its cost · *docs carry current intent, written to be read cold* — a load-bearing choice needs its given-up option and accepted cost on the page
- **F5 (medium):** all 13 specs are `[x]` with no legend and no tests/code behind them — a cold reader can't tell what `[x]` asserts, and the marked-complete specs disagree with the empty adjacent level · *coherence is adjacency* — each level of the arrow should agree with the one next to it
- **F6 (medium):** `HOLDALLOC-` / `PICKUP-` IDs have no `prefix:` frontmatter on their LLDs, so spec→LLD traceability runs on folder-name convention rather than a declared anchor · *effective intent-tree alignment* — each spec's leaf prefix should resolve declaratively to a leaf LLD
- **F7 (low):** "No reminder follows" and "does not trigger a fallback channel" read as answers to old discussion questions, though both choices are already captured cleanly in the Decisions table · *docs carry current intent, written to be read cold* — prose should read as fresh intent, not rebuttals to a past debate; consider trimming the inline negatives

**What was audited**
- Read fully: CLAUDE.md, `docs/high-level-design.md`, and all four design/spec files under `docs/intent/` (hold-allocation, pickup-notices) — 6 project files.
- Consulted the skill's `references/` files (follow-up-turns, sampling, conversational-guidance, lid-faq); the sampling thresholds (>15 LLDs, >200 `@spec` files, `index.yaml` present) were not met, so a complete read replaced arrow-path sampling. Cold-read pass and Decisions-table sweep done across all LID docs.
- Enumerated: 1 HLD, 2 LLDs, 2 EARS files, 13 spec IDs (7 `HOLDALLOC`, 6 `PICKUP`), 7 Decisions rows, 2 components / arrow segments.
- Found: 0 code files, 0 test files, 0 `@spec` annotations, 0 `prefix:` frontmatter, 0 `[inferred]` markers, 0 `[obsolete]` markers; no `docs/arrows/` overlay.
- Git: a single "fixture" commit, so no commit-date evidence for tests-first or cascade activity.
- Rendered inline (not persisted to disk); no files changed — the coach is advisory.

---
*Non-interactive run — defaults taken:* proceeded with a **full review** (the dispatch default for "directives missing but LID-shaped artifacts present") in the declared **Full** mode; used a **complete read** rather than arrow-path sampling since the sampling thresholds weren't met; **rendered inline, not persisted**; **made no file edits** (advisory posture — none were warranted); **omitted the out-of-scope section** (Full mode, by rule); and **stopped after the report** without iterating on the two follow-up invitations below.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.