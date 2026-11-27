# LID Coach — Visit Planner

**Posture:** Bootstrapping — the arrow is authored cleanly through EARS, implementation hasn't begun, and one central design choice needs settling against your own tenets before it does.

**Scorecard**
- ✓ Tenets — four genuine tie-breakers, ordered, phrased as leans rather than rules
- ✓ Doc hygiene — every doc reads clean cold; no history residue or accumulation anywhere
- ✓ LLD granularity & alignment — one LLD per intent component; INTAKE/FILL prefixes resolve cleanly
- ⚠ Tenet cascade — the near-term search flow works against "First asked, first served," unrecorded
- ⚠ Arrow completeness — the arrow stops at EARS; all 15 specs are marked done with no code
- ⚠ Configuration — the instruction file has the mode block but not the workflow directive

**Headline:** What's working is real — tenets that actually constrain, two tight LLDs, well-formed EARS, docs that stand on their own cold. The most valuable next step is settling the near-term flow against the first-asked-first-served tenet and recording the outcome in the fulfillment Decisions table before the first implementation session starts.

**Findings (9 total · 4 high · 3 medium · 2 low)**
- **F1 (high):** The near-term flow (FILL-003/FILL-004) lets any eligible signed-in account pass every earlier interest entry — the tenet "an earlier request is never passed by one made after it" is defeated under the exact condition the docs describe (a same-day cancellation with compatible entries waiting), and no exception records the tradeoff · *tenet cascade* (design nodes should lean the way the HLD's tenets say to lean)
- **F2 (high):** Why fulfillment splits into two flows at 36 hours — what fairness yields to search-and-claim, and why — survives nowhere on the page; a cold reader holding the tenet would question or reverse the choice · *decision capture under docs carry current intent* (current intent must be reconstructable from the doc, not the conversation)
- **F3 (high):** All 15 specs are checked `[x]` while the repo holds no tests or code; the markers misreport implementation status or lack defined semantics · *coherence is adjacency* (each level of the arrow agrees with its neighbors)
- **F4 (high):** The instruction file carries the `## LID` block but no directive routing code changes through the linked-intent-dev workflow — future cold sessions won't know to consult it; `/update-lid` will reconcile · *modes are declared, not inferred* (the instruction file is the foundation the rest of LID keys off)
- **F5 (medium):** FILL-002 ("release the opening and run matching again") doesn't say which flow re-runs for a near-term opening — or for an offer that crosses the 36-hour boundary while pending · *scope disambiguation* (a universal-sounding spec must be unambiguous where variants exist — and two variants exist here)
- **F6 (medium):** Nothing ends an entry's "active" status when its time window passes; withdrawal and service-change closure are the only exits specified, and the matcher's "compatible active entry" hinges on the undefined term · *LLDs close enough of the solution space* (edges left open are where intent drift enters, session after session)
- **F7 (medium):** How openings reach the "normalized view of clinic openings" (HLD Approach) has no LLD or spec; FILL-001's "becomes free" assumes that ingestion model exists · *effective intent-tree alignment* (every behavior traces to named intent; this one is unnamed)
- **F8 (low):** FILL-004's reach hinges on "published," a term defined only by FILL-003's effect — a cold reader grepping FILL-004 alone can't tell whether 36h+ openings are ever searchable · *scope disambiguation*
- **F9 (low):** fulfillment-design.md:9's "registry scan with `notBefore`" names a mechanism the corpus never introduces — the delayed-task registry lived only in the author's head · *docs carry current intent*

**What was audited**
- Read fully: the entire LID corpus — CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files
- Enumerated: 2 LLDs, 15 EARS specs (7 INTAKE, 8 FILL), 0 arrow-overlay segments (no overlay installed)
- Code/test sampling: none possible — the repo contains no source or test files; 0 `@spec` annotations repo-wide
- Cold-read pass and decisions-table sweep (all 8 rows) completed across every doc
- No capability flags applied — the sibling skill's `capability-flags.md` lists no flagged configurations

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into — F1/F2 reward a close read.

If you have broader questions about using LID for this project — where PRDs fit, when to install the arrow overlay, how tests-first should begin here — I can help with those too.

---

**Defaults taken (non-interactive run):** Full-mode full review per the declared `Mode: Full` (matching the skill's default); report rendered inline and *not* persisted to disk per the skill's advisory default — the skill is advisory by design, so no project files were changed, and config items point at `/update-lid`. No interactive decision points arose (no arrow overlay to parse).