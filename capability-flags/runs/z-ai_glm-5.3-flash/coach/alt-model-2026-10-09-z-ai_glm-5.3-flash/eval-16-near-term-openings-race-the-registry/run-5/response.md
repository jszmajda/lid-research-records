# LID Coach Review — Visit Planner

**Posture line:** *Bootstrapping — the design layer is in strong shape; the arrow stops at EARS.*

**Scorecard**
- ✓ HLD discipline — clean architecture-and-rationale; no implementation detail bleeding upstream
- ✓ Tenet quality — four real tie-breakers with defensible opposites, no platitudes
- ✓ LLD granularity — one LLD per intent component, each tightly scoped
- ⚠ Arrow completeness — Tests and Code phases don't exist yet anywhere in the repo
- ⚠ Tenet cascade — checkout flow leans against your first tenet, unrecorded
- ⚠ Decision capture — two live parameters have no Decisions & Alternatives row

**Headline sentence:** The HLD and both leaf designs are lean, cold-readable, and well-linked — the most valuable next step is building the tests-first half of the arrow, and a short decisions row for the checkout-vs-fairness trade.

## Findings (7 total · 1 high · 4 medium · 2 low)

- **F1 (high):** No tests and no code exist anywhere — the arrow ends at EARS. *canonical arrow shape* — each phase exists for components in scope. For Full mode this is the structural gap; specs and designs alone can't catch intent drift because nothing consumes them. Tests-first (`INTAKE-001…` and `FILL-001…` are already testable as written) is the natural entry.
- **F2 (medium):** Fast-track checkout lets any eligible signed-in account claim a published opening while the earliest interested patient waits for the 20-minute scan — this works against the **First asked, first served** tenet under the ≤36-hour condition, and no Decisions row or note records the exception. *tenets capture forward-looking preference / tenet cascade.* If the trade is deliberate, name it; if not, the fast track is silently reversing your own tie-breaker.
- **F3 (medium):** The 36-hour threshold, 20-minute scan delay, and two-hour offer window are load-bearing parameters with no Decisions & Alternatives rows. *docs carry current intent — decision capture.* A cold reader would question why 36 and why 20 and can't reconstruct what was given up; a row each (selected / rejected alternative / accepted cost) closes it.
- **F4 (medium):** INTAKE-006 says a service change "creates a newly timed entry" — "timed" is unclear cold; a fresh reader can't tell whether the new entry reuses the original time window or resets it. *docs carry current intent, written to be read cold.* One clarifying phrase in the spec (and its design counterpart) fixes it.
- **F5 (medium):** FILL-004's "published opening" reads universal, but publication currently exists only in the ≤36-hour path. *scope disambiguation* — if a second variant ever publishes ordinary openings, this spec becomes ambiguous to an agent that greps it out of context. Consider naming the path in the WHEN clause.
- **F6 (low):** Spec ID prefixes (`INTAKE`, `FILL`) abbreviate their leaf paths (`intent/intake`, `intent/fulfillment`). *specs are grep-anchored linkage* — `FILL` doesn't echo `fulfillment`, costing a small semantic hop on every grep. Stable IDs are fine to keep; just worth knowing the convention is a deliberate shortening.
- **F7 (low):** The notification outbox is written (FILL-007) but nothing specifies delivery or retry behavior — a small intent gap at the leaf's edge. *LLDs close enough of the solution space.* Fine to defer until notifications become a thing.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, all 4 files under `docs/intent/` (2 designs, 2 spec files)
- Enumerated: 2 leaf LLDs, 15 EARS specs, 9 Decisions & Alternatives rows, 4 tenets
- Cold-read pass performed through every LID doc; decisions-table sweep performed across all 9 rows
- No code or test files exist to sample; no `docs/arrows/` overlay installed
- Dispatch: fully configured (Full mode, directives present, standard directories) → full review

The advisory posture here means I've changed nothing — findings F2–F5 are quick doc edits you can apply directly; F1 is a `/linked-intent-dev`-style walk per component.

Want me to walk through any finding in detail, focus on a theme (the tenet-conflict in F2 is the one I'd dig into first), or work through specific items together?

If you have broader questions about using LID for your project — where PRDs fit, mode transitions, when to add the arrow-maintenance overlay, or what to do when a segment grows — I can help with those too.