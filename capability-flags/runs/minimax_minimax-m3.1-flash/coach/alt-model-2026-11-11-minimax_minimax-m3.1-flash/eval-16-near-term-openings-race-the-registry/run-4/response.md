**LID Coach — Visit Planner**

### 1. Executive summary

**Posture:** *Healthy design layer, arrow not yet extended past EARS.*

**Scorecard**
- ✓ HLD discipline — pure architecture and rationale, no schema or signature leakage upstream
- ✓ Linkage — 15 EARS, globally unique, well-namespaced, every LLD behavior traced
- ✓ Mutation hygiene — no `[obsolete]`, no changelog residue, no stale `[inferred]`
- ⚠ Intent-tree alignment — `FILL-*` prefix doesn't resolve to the `fulfillment` leaf
- ⚠ Arrow completeness — the arrow terminates at EARS; no test or code phases
- ⚠ Configuration — mode is declared, but the instruction file carries no LID directives

**Headline:** The design layer is genuinely coherent — the HLD's architecture, the two leaf LLDs, and 15 specs form a clean, walkable path — so the fastest wins are configuration reconciliation, aligning the `FILL` namespace now before IDs get cited, and closing one tenet conflict the fulfillment design opens silently.

---

### 2. Findings inventory

**Findings (12 total · 4 high · 5 medium · 3 low)**

- **F1 (high):** `CLAUDE.md` has a `## LID` block (Mode/Version) but no directive block naming `linked-intent-dev` — no workflow, no phase order, no arrow conventions · *modes are declared, not inferred* / *minimum surface, maximum discipline* → run `/update-lid`
- **F2 (high):** The arrow stops at EARS — zero test files, zero code files, so none of the 15 specs has an executable or `@spec` anchor; if design-only is deliberate, the instruction file should say so · *canonical arrow shape*
- **F3 (high):** `FILL-001…008` doesn't resolve to the `fulfillment` leaf (intake's `INTAKE-*` does); IDs are stable once assigned, so this is cheap to align now and expensive after tests cite them · *specs are grep-anchored linkage* / *effective intent-tree alignment* → `/arrow-maintenance`
- **F4 (high):** FILL-004 lets any eligible signed-in account claim a published opening, which works against the HLD tenet *First asked, first served*; no Decisions row names the tenet traded against and why, and "eligible" is never defined · *tenets capture forward-looking preference* / *decision capture*
- **F5 (medium):** HLD carries no non-goals, no key design decisions, no success metrics, and no explicit target-users section — a cold reader can't see what's out of scope · *HLD is architecture and rationale*
- **F6 (medium):** The 36-hour threshold and the two-hour offer duration live only in LLD prose — neither has a Decisions row with the rejected alternative, and the two-hour duration isn't stated in any spec · *decision capture* / *coherence is adjacency*
- **F7 (medium):** Intake's staff-assisted channel (design Context, HLD Approach) has no specs, while INTAKE-001/002/007 read universally ("an authenticated account", "a patient") across both channels · *scope disambiguation*
- **F8 (medium):** Fulfillment never defines "compatible" or "eligible" — matching predicates are left open, so two reasonable implementers would land on different behavior · *LLDs close enough of the solution space*
- **F9 (medium):** Undefined jargon in the fulfillment LLD — "registry", "registry scan", "the matcher", "outbox" appear without a definition anywhere in the doc tree · *docs carry current intent, written to be read cold*
- **F10 (low):** FILL-004 ("While a published opening remains free…") isn't scoped to openings published under FILL-003, so it reads as applying to any visible opening · *scope disambiguation*
- **F11 (low):** The four tenets are unordered and unprioritized; *First asked, first served* and *Clinical fit precedes utilization* can conflict with no stated precedence · *tenets capture forward-looking preference*
- **F12 (low):** Fulfillment consumes Intake's contract (`enteredAt` immutability, entry status, allowed sites) without citing the intake LLD — the dependency is real but invisible · *effective intent-tree alignment*

---

### 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake/`, `fulfillment/`), both spec files (15 EARS total: 7 intake, 8 fulfillment)
- Grepped: directive strings in the instruction file (0 matches), `@spec` references (0), `[obsolete]`/`[inferred]`/changelog residue (0)
- Sampled: the whole repo — it contains only `CLAUDE.md` and `docs/`; no `src/`, `tests/`, or `docs/arrows/` overlay exists, so no code or test surface was available to sample and `/arrow-maintenance` is not currently installable for structural enumeration
- Not consulted: `references/sampling.md` (threshold not met — 2 LLDs, 0 `@spec` files, no overlay)

**Defaults taken (non-interactive run):** proceeded with a full review anchored on the existing artifacts at the skill's default **Full mode**, since the instruction file lacks LID directives but the project is clearly LID-shaped; treated the arrow overlay as absent (no `docs/arrows/index.yaml` to parse); produced the report inline and did not persist it to disk.

**Note on posture:** the coach is advisory — it makes no file edits, so no project files were changed. Remediation for F1 is `/update-lid`; for F3 and any structural enumeration, `/arrow-maintenance` once the overlay is installed; F2/F4/F5–F9 are yours to apply by editing the docs directly.

---

### 4. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F4 in particular is worth deciding before any code lands, since it changes what the specs mean.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.