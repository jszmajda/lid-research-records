**LID Coach — Field Notes**

## 1. Executive summary

**Posture:** Bootstrapping — arrow is well-formed down to EARS; the sync design carries one live correctness-and-capture gap.

**Scorecard**
- ✓ Configuration — `CLAUDE.md` carries the LID directives, `- Mode: Full`, version 1.4.0; dispatch was unambiguous
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` markers, no planning residue anywhere in the docs
- ✓ Linkage shape — `SYNC-001/002` are stable, zero-padded, grep-anchored, and `prefix: SYNC` resolves cleanly to `sync-design.md`
- ⚠ Arrow completeness — the arrow ends at EARS; no tests and no code exist yet, but both specs are marked `[x]`
- ✗ Decision capture — the conflict-resolution row is the project's most consequential choice and its rationale is one word
- ⚠ Tenet/goal cascade — the conflict mechanism works against *Convergent state after reconnect* under a condition the LLD itself describes

**Headline:** The skeleton is genuinely clean — tenet is a real tie-breaker, specs are properly anchored, docs are free of accumulation — and the fastest win by far is reopening the last-writer-wins decision and writing down what it costs, before tests and code harden it.

## 2. Findings

**Findings (8 total · 3 high · 4 medium · 1 low)**

- **F1 (high):** `sync-design.md:17` resolves conflicts by device wall-clock while `:9` states device clocks are wrong by several minutes until reconnect — a fast-clocked device wins every conflict regardless of real edit order, and the other technician's note is discarded; nothing in the HLD or LLD records that trade · *tenets capture forward-looking preference* + *coherence is adjacency* — leaf mechanisms should lean the way the HLD's goals say to lean (here, *Convergent state after reconnect*), or record the exception
- **F2 (high):** `sync-design.md:23` — "Conflict resolution | Last-writer-wins by device wall-clock | Simpler." A cold reader holding this row plus the clock-skew sentence above it would immediately want to reverse the choice, and cannot reconstruct what was weighed (server-assigned receipt time? logical clocks? keep both edits?) or what cost was accepted · *docs carry current intent, written to be read cold* — the keep-side: a decision still live once landed needs its alternative and its cost on the page
- **F3 (high):** both specs are marked `[x]` though the repo contains no tests and no code, and `grep @spec` returns nothing — the status marker currently asserts a phase of the arrow that does not exist · *canonical arrow shape* + *tests carry `@spec` annotations*
- **F4 (medium):** `sync-design.md:14` — "merges them into the canonical store" leaves the non-conflict path open: per-note vs. per-field merge, ordering of multiple pending edits from one device, behavior on a partially completed upload. Two agents would land on incompatible implementations · *LLDs close enough of the solution space*
- **F5 (medium):** the "Note storage | SQLite on device" row sits in the sync LLD, but device-local storage is a sibling concept in the HLD's own Architecture line — the decision is lodged below the node that dominates it · *intent attaches at the lowest node that dominates it*
- **F6 (medium):** `SYNC-002` fixes "discard the other" as behavior, but no spec covers what the user or the service sees when an edit is dropped — silent loss is specified, its observability is not · *effective intent-tree alignment* — LLD behavior with no spec is unnamed intent
- **F7 (medium):** the HLD has no Key Design Decisions section and no Success Metrics, and Goals (`:21`) are prose rather than checkable — "Convergent state after reconnect" is the sentence F1 turns on, and it carries no definition of convergent · *HLD is architecture and rationale*
- **F8 (low):** `high-level-design.md:13` Architecture is a three-noun list; the clock-skew constraint that drives the sync design appears only in the LLD, though it conditions any component that timestamps · *HLD is architecture and rationale*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the entire LID surface of the project
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 specs, 1 design-tree leaf (`SYNC`), 1 tenet
- Arrow-path walked: 1 segment, HLD → LLD → EARS; tests and code phases are empty
- Linkage metric: 0 `@spec` references across the repo (no source or test files present)
- Cold-read pass: run over all three LID docs; no accumulation residue found. No arrow overlay (`docs/arrows/`) is installed, so no structural enumeration was attempted — if you want orphan/coherence counts, `/arrow-maintenance` is the precise tool once it is in place
- Dispatch: directives + `- Mode: Full` + standard directories present, so the full review ran with no defaults assumed

## 4. Offer to help

Want me to walk through any of these in detail, focus on a theme or a priority tier, or work through specific items together? F1 and F2 are the same choice seen from two angles and are worth taking first — I can lay out the alternatives and what each one costs you.

If you have broader questions about using LID on this project — when the device-local store earns its own LLD, how to sequence tests-first from here, where a PRD would fit, or when to install the arrow-maintenance overlay — I can help with those too.