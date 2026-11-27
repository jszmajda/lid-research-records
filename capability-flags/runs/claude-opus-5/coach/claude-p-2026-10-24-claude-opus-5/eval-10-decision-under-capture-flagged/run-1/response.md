**LID Coach — Field Notes**

## 1. Executive summary

**Posture:** Bootstrapping — the arrow is cleanly configured and well-linked as far as it goes; the sync decision is the thing to look at.

**Scorecard**
- ✓ Configuration — `## LID` block, `Mode: Full`, and directives all present and well-formed
- ✓ Linkage — `prefix: SYNC` / `parent: high-level-design` frontmatter and the spec→LLD pointer make the one segment walkable by grep
- ✓ Mutation hygiene — no change-narration, no obsolete markers, no planning residue anywhere
- ⚠ Tenet cascade — the sync mechanism leans against the HLD's own goals under a condition the LLD itself describes
- ⚠ Decision capture — the two Decisions rows record the choice but not what was traded for it
- ⚠ Arrow completeness — specs are marked `[x]`, but there are no tests or code in the repo

**Headline:** For a project this young, the structure is genuinely good — one HLD with real tenets and non-goals, one LLD per component with proper frontmatter, two EARS specs that both carry WHEN clauses and trace cleanly to their leaf. The highest-value next step is revisiting last-writer-wins-by-wall-clock against the clock skew your own LLD names, and capturing whatever you decide in the Decisions table.

## 2. Findings (8 total · 2 high · 4 medium · 2 low)

- **F1 (high):** `sync-design.md:17` resolves conflicts by device wall-clock, while `sync-design.md:9` says those clocks are routinely wrong by minutes and resync NTP only on reconnect — under that described condition the newer field note is silently discarded, working against the HLD's "notes must reconcile" problem and its "convergent state after reconnect" goal · *tenets capture forward-looking preference* + *keep the arrow coherent* — leaf mechanisms should lean the way the HLD's goals say to lean
- **F2 (high):** the "Conflict resolution → Last-writer-wins by device wall-clock" row's rationale is "Simpler." — a cold reader holding the Context paragraph would still question or try to reverse this choice, and can't reconstruct what was given up (edit loss) or what cost was accepted (skewed-clock winners) · *docs carry current intent* — a decision that stays live once landed needs its reasoning on the page
- **F3 (medium):** both specs carry `[x]` complete markers, but the repo contains no tests and no code citing `SYNC-001` / `SYNC-002` · *coherence is adjacency* — each arrow level should agree with its neighbor
- **F4 (medium):** the "Note storage → SQLite on device" row sits in the sync LLD, though device-local storage is a sibling architecture concept in the HLD (`high-level-design.md:13`) with no design node of its own · *intent attaches at the lowest node that dominates it* — substance governing a sibling should rise to the shared parent
- **F5 (medium):** the HLD names three architecture concepts and two goals; only the sync/reconciliation path has specs — local capture and "no blocked capture in the field" have no spec anywhere · *effective intent-tree alignment* — LLD/HLD behaviors with no specs are unnamed intent
- **F6 (medium):** "Boring over clever" is a real tenet (defensible opposite, a lean not a trigger), but it's the only one — and the tradeoff this project keeps meeting, correctness-under-unreliable-inputs vs. simplicity, has no tie-breaker, so F1's call was made by default · *tenets capture forward-looking preference*
- **F7 (low):** the HLD has no Key Design Decisions section and no success metrics, and `## Approach` and `## Architecture` largely restate each other · *HLD is architecture and rationale*
- **F8 (low):** the LLD points up (`parent:`) and the spec file points up (`**LLD**:`), but the HLD names its components in prose without pointing down to `docs/intent/sync/` · *specs are grep-anchored linkage* — cheap downward pointers keep the arrow walkable in both directions

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the entire project
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 EARS specs, 1 arrow segment (`SYNC`)
- Arrow-path walked: 1 segment end-to-end — HLD *Architecture* → `sync-design.md` → `SYNC-001/002` → (no tests) → (no code)
- Linkage metric: 0 `@spec` annotations across 0 source or test files; no `docs/arrows/` overlay installed, so no structural index was available
- Cold-read pass: all 4 files, read without conversation context
- Dispatch: directives, `Mode: Full`, and the standard directories are all present, so this ran as a **full review**; no configuration questions needed answering

## 4. Offer to help

Want me to walk through any of these in detail, focus on a theme or priority, or work through specific items together? F1 and F2 are the same choice seen from two angles — the design question and the record of it — and are probably the best place to start.

If you have broader questions about using LID on this project — when to add the second LLD, where tests fit before there's code, how `[x]` status markers are meant to track implementation, or whether the arrow-maintenance overlay is worth installing at this size — I can help with those too.