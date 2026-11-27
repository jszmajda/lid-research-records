---

## LID Coach — Visit Planner

**Bootstrapping well — design layer solid; a few gaps worth closing before code begins.**

---

**Scorecard**

- ✓ HLD discipline — clean architecture; no implementation detail upstream; tenets are real tie-breakers
- ✓ LLD granularity — two well-scoped components, neither lumped nor fragmented
- ✓ Mutation hygiene — all docs are free of change-narration and conversational residue
- ⚠ Scope disambiguation — FILL-004's actor scope unresolved against the HLD's two-actor model
- ⚠ Decision capture — dual-path threshold constants undercaptured; no HLD-level key design decision record
- ⚠ Cascade health — "first asked, first served" tenet suspended during portal-open window; no exception record

**The design layer is well-constructed: both LLDs are appropriately scoped, the decisions tables are thorough, and the specs are well-formed EARS with clean status markers. The fastest wins are closing two scope and decision gaps before implementation begins — each is a short addition, and both prevent intent drift from entering the code layer.**

---

**Findings (7 total · 2 high · 4 medium · 1 low)**

- **F1 (high):** FILL-003/004 suspend "first asked, first served" during the portal-open window — any eligible signed-in account claims the opening, not specifically the earliest-`enteredAt` patient — with no decision record explaining why this exception is acceptable · *tenet cascade — designs should lean the way HLD tenets say to lean*
- **F2 (high):** FILL-004 says "any eligible signed-in account" but the HLD names two actors (patients via portal, staff acting for callers); the spec doesn't say whether a staff account can execute portal checkout, creating an unresolved actor boundary · *scope disambiguation — universal-sounding specs must be actually universal*
- **F3 (medium):** The dual-path matching model (standard vs. urgent) is an architecture-level choice absent from the HLD; the specific constants that drive it (36-hour threshold, 20-minute scan delay) have no rationale in the fulfillment LLD's decisions table · *decision capture — a cold reader would question both; neither has a row*
- **F4 (medium):** HLD has no non-goals section; a cold reader can't tell whether emergency visits, complex referrals, or multi-provider scheduling are explicitly out of scope — leaving the boundary open for scope creep · *HLD is architecture and rationale — non-goals anchor the scope as much as goals do*
- **F5 (medium):** HLD goals include "refill canceled visits quickly" but no success metric defines "quickly"; the goal is unanchored and unverifiable · *HLD is architecture and rationale — success metrics let the project evaluate whether it is working*
- **F6 (medium):** `intake-design.md` says "Exact retries return the existing entry" — a cold reader doesn't know what makes a retry "exact" until they cross-reference the decisions table for the idempotency key; consider a single sentence linking the two · *docs carry current intent, written to be read cold — a fresh author would name the mechanism*
- **F7 (low):** FILL-* specs use an abbreviated prefix that doesn't mirror the `fulfillment/` path the way INTAKE-* mirrors `intake/`; a future reader must infer the connection · *specs are grep-anchored linkage — the prefix is the root-to-leaf path*

---

**What was audited**

- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/intake/intake-design.md, docs/intent/intake/intake-specs.md, docs/intent/fulfillment/fulfillment-design.md, docs/intent/fulfillment/fulfillment-specs.md
- Enumerated: 2 LLDs, 2 spec files, 15 specs (7 INTAKE-*, 8 FILL-*)
- Code and test phases: not yet present — project is at the spec phase; arrow stops at EARS specs
- Arrow-path sampled: both components traced HLD section → LLD → specs; no code or test layer to sample

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together — F1's tenet exception, F2's actor scope, F3's decision capture, or the HLD gaps? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — how to structure non-goals, when threshold constants warrant a decision doc, how the two-path design maps to the intent tree — I can help with those too.