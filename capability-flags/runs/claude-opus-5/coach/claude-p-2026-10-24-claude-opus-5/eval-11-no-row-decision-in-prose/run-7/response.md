**LID Coach — printfarm**

---

## 1. Executive summary

**Posture:** *Clean design layer, pre-implementation — the sharpest issue is a tenet the queue design quietly works against.*

**Scorecard**
- ✓ Doc hygiene — no history residue, no obsolete markers, every doc reads as current intent
- ✓ Decision rationale (where present) — the FIFO and slug rows name the alternative *and* the accepted cost; that's the good form
- ✓ Mode fit — Full mode matches a two-node project with no out-of-scope remainder
- ⚠ Intent-tree alignment — the HLD names a web UI with no design node; several design behaviors have no spec
- ✗ Tenet cascade — the in-memory queue defeats "a submitted job is a promise" under conditions the LLD itself describes
- ✗ Arrow completeness — Tests and Code phases are absent while all eight specs are marked `[x]`

**Headline:** The design layer here is genuinely well made — two crisply separated nodes, a real `## Tenets` section, and Decisions rows that record what was given up rather than just what was picked. The highest-value next step is reconciling the queue's durability model with the tenet and goal it currently contradicts; after that, closing the arrow past EARS.

---

## 2. Findings inventory

**Findings (11 total · 4 high · 5 medium · 2 low)**

- **F1 (high):** The queue is held "entirely in process memory" and undispatched jobs are "gone, and members resubmit them" — under the unattended OS updates and power blips the same LLD describes, that defeats the tenet *"a submitted job is a promise: members should be able to upload and walk away"* and the goal *"evening upload, overnight print, morning pickup — with no member present"*; no Decisions row records the trade · *tenets capture forward-looking preference* + *keep the arrow coherent*
- **F2 (high):** That durability choice has no Decisions & Alternatives row at all, while the sibling registry records its store choice — a cold reader can't reconstruct what was weighed · *decision capture*
- **F3 (high):** All eight specs carry `[x]`, but the repo has no code and no tests — nothing cites a spec ID, so the arrow stops at EARS · *canonical arrow shape*, *tests carry `@spec` annotations*
- **F4 (high):** The HLD's Approach names a web UI with member and staff views, but the Architecture section declares only two nodes — that intent has no design node and no specs · *effective intent-tree alignment*
- **F5 (medium):** QUEUE-003 has the queue marking a printer "suspect", while printer state otherwise lives wholly in the registry (REG-001/002) — the state vocabulary dominates both nodes and no REG spec mentions suspect or who clears it · *intent attaches at the lowest node that dominates it*
- **F6 (medium):** Design behaviors with no spec: class-must-have-a-registered-printer admission, content-hash file storage, 90-day slug recycling · *effective intent-tree alignment*
- **F7 (medium):** QUEUE-005 requires visible reordering, but no design text says how a job gets staff priority or what "recorded visibly" means — two agents would implement differently · *LLDs close enough of the solution space*
- **F8 (medium):** The three tenets are unordered, yet tenet 1 (a job is a promise) and tenet 3 (the service stays small) collide head-on — which is exactly the decision in F1, left with no tie-breaker · *tenets capture forward-looking preference*
- **F9 (medium):** The HLD has no success metrics; "fair access to the popular printer classes" has no measurable form, so nothing downstream can be checked against it · *HLD is architecture and rationale*
- **F10 (low):** Read cold, "marked suspect" and "rebuilds its picture of the farm" are unresolved, and the printer state set (idle / busy / unreachable / suspect) is never enumerated in one place · *docs carry current intent, written to be read cold*
- **F11 (low):** The HLD's `## Architecture` section lists directory paths rather than system architecture, duplicating CLAUDE.md's navigation table · *HLD is architecture and rationale*

---

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), 5 Decisions & Alternatives rows, 3 tenets
- Arrow-path sampled: both segments walked end-to-end (HLD section → LLD → spec → test → code); both terminate at EARS
- Linkage metric: 0 `@spec` annotations — no source or test files exist in the repository
- Overlay: `docs/arrows/` absent, so no structural audit available; several findings above (F3, F6) are the kind `/arrow-maintenance` would enumerate precisely if the overlay were installed
- Cold-read pass: performed over all four LID docs; no change-narration or conversational fossils found (hence the ✓), F10 is what it surfaced

---

## 4. Offer to help

Want me to walk through any of these in detail, focus on a theme or priority band, or work through specific items together? F1 and F2 are the pair I'd start with — they're the same decision seen from two directions, and the remedy for one shapes the other.

If you have broader questions about using LID on printfarm — when the web UI should become its own node, whether a sub-HLD is warranted as the farm grows, how to handle `[x]` markers ahead of implementation, or where PRDs fit — I'm happy to go into those too.