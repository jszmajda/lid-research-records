**LID Coach review — Visit Planner**

## 1. Executive summary

**Posture line:** Bootstrapping — design layer in place and strong; the arrow stops at specs.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no implementation detail bleeding upstream
- ✓ LLD sufficiency — both leaf designs close the solution space (constants, locking, transaction boundaries are pinned)
- ✓ Tenet quality — four real tie-breakers with defensible opposites; no platitudes
- ⚠ Spec alignment — one leaf prefix doesn't resolve to its LLD
- ⚠ Tenet cascade — one mechanism works against a named tenet with no recorded exception
- ✗ Arrow completeness — no tests and no code exist for either component

**Headline:** What's working is genuinely good — the design layer (HLD → two LLDs → EARS) is clean, specific, and readable cold. The most valuable next step is to start the next arrow phase *tests-first* from the existing specs, before any code exists to shape them.

## 2. Findings inventory

> **Findings (6 total · 2 high · 3 medium · 1 low)**

- **F1 (high):** No tests or code exist for either component — the arrow ends at EARS · *canonical arrow shape, tests before code*. This is expected at your stage, not a violation; the opportunity is that with zero code written, you can still preload intent fully via tests-first.
- **F2 (high):** The instruction file carries the `## LID` block but none of the standard LID directives — it doesn't name linked-intent-dev or describe the workflow · *modes are declared, not inferred*. Without directives, a fresh session doesn't know how to walk the arrow. Run `/update-lid` to reconcile.
- **F3 (medium):** Spec IDs use prefix `FILL-` but the leaf LLD is `fulfillment`; neither spec file carries a `prefix:` frontmatter to resolve it · *effective intent-tree alignment*. `FILL` is likely intended as fulfillment's leaf path, but a cold grep can't confirm it — either rename IDs to `FULFILLMENT-` or add `prefix:` frontmatter so the leaf boundary is greppable.
- **F4 (medium):** `FILL-004`'s first-come checkout path works against the tenet **"First asked, first served"** — for openings ≤36 hours out, a portal user who never registered interest can beat an earlier requester · *tenets capture forward-looking preference / tenet cascade*. This may be a deliberate trade (fill speed beats queue fairness near cancel time), but no Decisions & Alternatives row records it. Consider one row in `fulfillment-design.md` naming the tenet traded against.
- **F5 (medium):** The 2-hour offer window appears only in LLD prose — no spec fixes the offer duration · *LLDs close enough of the solution space / adjacent-level coherence*. `FILL-002` covers expiry behavior but not when expiry occurs; a test author would have to guess "2 hours."
- **F6 (low):** Spec status is tracked with `[x]` checkboxes, a custom convention outside standard EARS status markers · *minimum surface, maximum discipline*. Harmless at this size, but `/update-lid` can align it with the standard marker vocabulary.

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`), both spec files (15 EARS specs total)
- Cold-read pass: performed on all four design/spec docs
- Decisions-table sweep: 8 rows across both LLDs
- Code/test sampling: none possible — no source or test files exist
- Arrow overlay: `docs/arrows/` absent — structural audit not available; if you install it, `/arrow-maintenance` can enumerate linkage precisely as the project grows

## 4. Capability-flag note

*Omitted — the capability-flags file lists no flagged configurations, so none apply.*

## 5. Out-of-scope note

*Omitted — Full mode; nothing was excluded.*

---

Advisory note: I've made no file changes — the coach is advisory by design, so you stay in review of every decision. If you'd like fixes applied, the relevant commands are `/update-lid` for the instruction-file and marker findings, or just ask and I'll edit outside a coach run.

> Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.
>
> If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

**Defaults taken in this non-interactive run:** dispatch resolved to "instruction file present with mode marker but LID directives absent + LID-shaped artifacts" → proceeded with a Full-mode review (Full is also the skill's stated default when in doubt); the missing directive block was surfaced as finding F2 rather than blocking coaching.