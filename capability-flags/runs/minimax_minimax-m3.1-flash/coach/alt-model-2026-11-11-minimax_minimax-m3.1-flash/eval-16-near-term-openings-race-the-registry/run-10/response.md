## LID Coach — Visit Planner

### 1. Executive summary

**Posture:** Design-layer health is good; the arrow is unfinished and one tenet is being broken in the design itself.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures leaked upstream
- ✓ Spec hygiene — EARS clauses, unique zero-padded IDs, no `[obsolete]` residue, no `[inferred]` markers to triage
- ✗ Arrow completeness — arrow ends at EARS; no test or code phase exists
- ⚠ Linkage — `FILL-*` doesn't resolve to the `Fulfillment` leaf
- ⚠ Decision capture — the two numeric thresholds carry no trade-off record
- ⚠ Tenet cascade — near-term checkout contradicts "First asked, first served"

**Headline:** The design documents are clean, terse, and in good LID shape — the fastest wins are reconciling the instruction file, reconciling the "all specs are done" claim against a repo with no implementation, and deciding how the ≤36-hour portal path relates to your first-asked-first-served tenet.

### 2. Findings

**Findings (11 total · 3 high · 5 medium · 3 low)**

- **F1 (high):** `CLAUDE.md` declares `Mode: Full` but carries no LID directive — nothing tells a future session to run the linked-intent workflow or that `docs/` is the arrow · *modes are declared, not inferred* → **/update-lid**
- **F2 (high):** all 15 specs are marked `[x]` (implemented) but the repo contains no tests and no code — the arrow stops at EARS · *tests before code*, *canonical arrow shape* · *spec status markers assert completion nothing supports*
- **F3 (high):** the ≤36-hour path lets *any* eligible signed-in account claim a published opening, so an earlier `enteredAt` can be passed by a later one — a direct conflict with the "First asked, first served" tenet, with no Decisions row recording the trade · *tenet cascade*, *tenets capture forward-looking preference*
- **F4 (medium):** spec IDs use `FILL-*` but the owning leaf is `Fulfillment` — `grep -r FULFIL` finds nothing, so half the arrow is unreachable by grep · *specs are grep-anchored linkage* · consider `FULFILL-001…` (IDs are stable once assigned, so decide early)
- **F5 (medium):** the HLD has Problem, Approach, Tenets, Goals, Components — but no non-goals, target users, key design decisions, or success metrics; the Goals read as aspirations rather than measurable targets · *HLD is architecture and rationale*
- **F6 (medium):** `docs/high-level-design.md:20` names only Intake and Fulfillment — the clinic openings/availability source of truth that Fulfillment matches against is unnamed as a component · *one HLD per project*, *effective intent-tree alignment*
- **F7 (medium):** the 36-hour cutoff and the 20-minute `notBefore` delay are live, arbitrary-looking choices with no Decisions row saying what was given up · *decision capture*
- **F8 (medium):** cold-read gaps — "36 hours" is measured from nothing (visit start? cancellation time?), FILL-001/FILL-003 share a boundary no one can place, and "registry" is never defined · *docs carry current intent, written to be read cold*, *scope disambiguation*
- **F9 (low):** the tenet list is unordered, though "First asked, first served" and "Clinical fit precedes utilization" can conflict (FILL-006 vs FILL-001) · *tenets capture forward-looking preference*
- **F10 (low):** "First asked, first served" is phrased as a triggered rule ("When openings are scarce, …") and duplicates FILL-001 rather than leaning as a tie-breaker · *tenets capture forward-looking preference*
- **F11 (low):** no `docs/arrows/` overlay is installed, so prefix-resolution and reverse-orphan checks have no index to run against · *coherence is adjacency* → consider **/arrow-maintenance** when you want the precise enumeration

### 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/intake/intake-specs.md`, `docs/intent/fulfillment/fulfillment-design.md`, `docs/intent/fulfillment/fulfillment-specs.md`
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 15 spec IDs, 8 Decisions & Alternatives rows, 4 tenets, 2 HLD components
- Sampled: the entire repository (6 tracked files) — no source tree, test suite, or `docs/arrows/index.yaml` exists, so no code/test sampling was possible
- Linkage metric: 15 spec IDs, 0 `@spec` annotations in code (no code), 0 spec IDs reused, 0 obsolete markers
- Git history: a single commit (`fcd7016 fixture`) — no test-before-code ordering evidence available

### 4. Defaults I took

- Dispatch: `CLAUDE.md` has a `## LID` block with `- Mode: Full` but no workflow directive → **full review**, anchored on the existing artifacts, with the missing directives raised as F1 (per the skill's rule that a visibly LID-shaped project is coached, not refused)
- Full mode → no out-of-scope section
- Report rendered inline and **not persisted to disk**; the coach's advisory posture is load-bearing, so I made **no file edits** — F1's configuration fix belongs to `/update-lid`, F4/F11's structural enumeration to `/arrow-maintenance`
- Non-interactive: the report is the whole output; follow-up-turn detail and remedies are deferred to the turns you'd take next

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F3 (tenet vs. portal checkout) and F7 (threshold capture) are the two I'd start with, since both change design rather than paperwork.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.