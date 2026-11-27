**LID review — Visit Planner**

## 1. Executive summary

**Posture:** Design layer is clean and coherent; the arrow stops at specs, and one tenet is quietly contradicted downstream.

**Scorecard**
- ✓ Mutation hygiene — docs read as current intent; no changelogs, no `[obsolete]` residue, no "was X, now Y"
- ✓ LLD granularity — two components, each matching an HLD concept, no overlap
- ✓ HLD discipline — architecture and rationale only; no schemas, signatures, or pseudocode bleeding upstream
- ⚠ Configuration — the `## LID` block declares Mode and Version but never names LID itself
- ⚠ Tenet cascade — the ≤36h open-search path can pass over an earlier request
- ✗ Arrow completeness — every spec is marked done, but no tests or code exist in the repo

**Headline:** The design layer is genuinely good — tight HLD, four tenets that are real tie-breakers rather than platitudes, Decisions tables with named costs on both leaves. The highest-value next steps are reconciling the instruction file and resolving the conflict between *first asked, first served* and the 20-minute open-search window, which is the kind of contradiction that hardens into behavior once code lands.

## 2. Findings (12 total · 4 high · 6 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block carries `Mode: Full` and `Version: 1.4.0` but no LID directives — nothing tells a fresh session this project runs LID or how to cascade · *modes are declared, not inferred* (an unread mode is a default, and the rest of LID proceeds on it) → `/update-lid`
- **F2 (high):** `FILL-003`/`FILL-004` publish a ≤36h opening to portal search for 20 minutes where *any* eligible signed-in account may check out, so a patient who never queued can take an opening ahead of the earliest `enteredAt` entry — and no Decisions row records the tenet being traded · *tenets capture forward-looking preference* + *coherence is adjacency*
- **F3 (high):** All 15 specs across both files are marked `[x]`, but the repo contains no tests and no code — the last two arrow phases are absent while the spec layer claims they are satisfied · *coherence is adjacency*; *intent leads; code is compiled output*
- **F4 (high):** "Compatible", "clinical compatibility", and "eligibility" carry `FILL-001`, `-005`, `-006` and the HLD's second tenet, yet no doc defines what makes an entry compatible with an opening — two reasonable agents would implement different matchers · *LLDs close enough of the solution space*
- **F5 (medium):** The 36-hour threshold and the 20-minute scan delay are the load-bearing parameters of the whole fulfillment design, with no Decisions row and no source named · *docs carry current intent* (decision capture — a cold reader would question both numbers)
- **F6 (medium):** `INTAKE-006` re-times an entry when the requested service changes, costing the patient their queue position under *first asked, first served*; the Decisions table has no row for that trade · *docs carry current intent* (decision capture)
- **F7 (medium):** The HLD Approach and the intake Context both describe staff acting for patients who call, but `INTAKE-001` only covers "an authenticated account" — the staff-assisted path is named intent with no spec · *effective intent-tree alignment*
- **F8 (medium):** `fulfillment-design.md:9` introduces "a registry scan", "the registry", and `notBefore` with no prior definition; a cold reader cannot tell what the registry is or who reads the field · *docs carry current intent, written to be read cold* (in-conversation-only meaning)
- **F9 (medium):** Neither spec file declares `prefix:` frontmatter, and `FILL-*` does not echo the `fulfillment` leaf, so a spec ID's leaf path can only be resolved by guessing · *specs are grep-anchored linkage*
- **F10 (medium):** Three solution edges left open: tie-break when two entries share `enteredAt`, idempotency-key expiry (the Decisions row names it as an accepted cost but nothing specifies it), and what happens to an interest entry once its claim commits · *LLDs close enough of the solution space*
- **F11 (low):** The HLD has Problem, Approach, Tenets, Goals, and Components, but no Non-goals and no success metrics — the boundary of what Visit Planner declines to do is unstated · *HLD is architecture and rationale*
- **F12 (low):** The four tenets are an unordered list, though *first asked, first served* and *clinical fit precedes utilization* can meet on the same decision · *tenets capture forward-looking preference*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (7 `INTAKE-*`, 8 `FILL-*`), 8 Decisions & Alternatives rows
- Arrow-path sampled: both segments walked end-to-end (HLD Components → leaf design → specs → tests → code); both terminate at the spec layer
- Linkage metric: 0 `@spec` annotations — the repo contains no source or test files
- Overlay: `docs/arrows/` absent, so no `index.yaml` to cross-check and no structural enumeration available. If F3, F7, or F9 turn into a cleanup pass, installing the arrow-maintenance overlay would give you `/arrow-maintenance` for exact orphan and drift counts rather than sampled reads.
- Non-interactive run: no prompts were taken; the review ran in the default **Full** mode declared in `CLAUDE.md`, and per the default the report was not persisted to disk.

---

Want me to walk through the findings in detail, focus on a theme or priority (the tenet conflict in F2 and the capture gaps in F5/F6 hang together), or work through specific items with you? You can also pick a single finding to dig into.

If you have broader questions about using LID on this project — when to promote `fulfillment` into a sub-HLD, where a PRD fits alongside the HLD, how to bring specs and code back into agreement when design ran ahead of implementation — I can help with those too.