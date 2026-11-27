**LID Coach — printfarm**

### 1. Executive summary

**Posture:** Healthy design layer; traceability overstates reality.

**Scorecard**
- ✓ Design layer — one HLD, two clean leaf LLDs, sensible split, no lumping
- ✓ Linkage — spec IDs match their leaf `prefix:`; LLD and spec agree on every shared value (64 MB, three heartbeats, dispatch failure)
- ✓ Tenet quality — three genuine tie-breakers, each with a defensible opposite
- ⚠ Status markers — all 8 specs claim implemented; the repo has no code and no tests
- ⚠ Cross-node coherence — the "suspect" printer state isn't owned anywhere; durability decided per leaf
- ⚠ Spec coverage — several behaviors the LLDs state outright have no spec to pin them

**Headline:** The design layer here is genuinely well-shaped and tightly cross-linked — the arrow is real from HLD through EARS. The fastest win is making the status markers honest; the highest-value structural work is resolving how the two nodes disagree about printer state and durability.

### 2. Findings (9 total · 3 high · 4 medium · 2 low)

- **F1 (high):** All 8 specs are marked `[x]` (implemented) but the repo contains no code and no tests — the marker convention means "code and tests exist," so the arrow claims a traceability that isn't there · *intent leads; code is compiled output*
- **F2 (high):** The in-memory queue (accepted jobs vanish on restart, members resubmit) works against the HLD tenet "A submitted job is a promise" and the goal "evening upload, overnight print, morning pickup" under exactly the condition the LLD names — unattended OS updates and power blips — with no Decisions row recording the trade · *tenets capture forward-looking preference*
- **F3 (high):** QUEUE-003 has the queue mark a printer "suspect," but the registry LLD defines printer state as derived solely from heartbeats (idle/busy/unreachable) and owns it — the two nodes describe different state models, and one writes into the other's field · *coherence is adjacency*
- **F4 (medium):** LLD-stated behaviors with no spec anywhere: staff/member priority classes with FIFO within a class, acceptance only when the class has a registered printer, loss of accepted jobs on restart, printer registration, G-code dedup by content hash — unnamed intent drifts silently · *effective intent-tree alignment*
- **F5 (medium):** Durability is decided separately in each sibling leaf (SQLite registry vs in-memory queue) with no shared rationale at a parent level; this substance governs both siblings and would live higher in the tree · *intent attaches at the lowest node that dominates it*
- **F6 (medium):** "Three consecutive heartbeats" appears in LLD prose and in REG-001, but no Decisions row records why three — a cold reader would ask, and the answer lives only in a bullet · *docs carry current intent*
- **F7 (medium):** The HLD has no Key Design Decisions and no Success Metrics sections; the most consequential architecture choices (in-memory queue, heartbeat polling, single-service mini-PC) live only in leaf docs, where the project-global view can't see them · *HLD is architecture and rationale*
- **F8 (low):** The 64 MB upload limit's derivation is asserted ("covers the largest bed at 0.1 mm layers") but never quantified — a cold reader can't reconstruct where the number came from · *decision capture*
- **F9 (low):** The 90-day slug recycling is recorded as an accepted cost with no mitigation (contrast the FIFO row, which names one) — nothing states what stops a stale slug from being read as a current job · *decision capture*

### 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf LLDs, both spec files
- Enumerated: 2 LLDs, 2 spec files, 8 spec IDs (`QUEUE-001…005`, `REG-001…003`), 0 duplicate IDs, 0 `[inferred]` markers, 0 obsolete markers
- Repository-wide: 6 tracked files, 1 commit, **0 code files, 0 test files, 0 `@spec` annotations**
- Arrow paths sampled end-to-end: 0 — the Tests and Code layers don't exist yet, so the arrow currently terminates at EARS
- Overlay: no `docs/arrows/` directory, so there is no `index.yaml` to read; reverse-orphan and index-drift enumeration would need `/arrow-maintenance` once that overlay is installed
- Cold-read pass performed on every LID doc as a standalone document

### 4. Notes on applying these

F1 is a small edit you can make yourself (switch the markers to `[ ]` until code and tests land, or point the coach at the implementation repo if the code lives elsewhere). F3 and F5 are design conversations, not edits — they'd want your call on who owns printer state and whether the queue should persist. Structural enumeration (reverse orphans, prefix resolution against a full index) is better answered by `/arrow-maintenance` than by this review.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.