**Run notes — defaults taken (non-interactive run):**
- **Dispatch default:** the instruction file lacks the LID directive text (no "linked-intent-dev" reference) but the project has clear LID-shaped artifacts, so per the skill I proceeded with a **full review anchored on the existing artifacts, defaulting to Full mode** — which matches the declared `Mode: Full`.
- **Advisory-posture default:** the prompt asked me to make file changes myself, but the coach skill's advisory posture is load-bearing — it produces the report inline and does not edit files, pointing configuration fixes at `/update-lid` instead. I took that default: **no file changes were made**. No other interactive decision points arose.

---

# LID Coach — Visit Planner

**Design-stage arrow in good shape — clean, coherent, and free of residue; a few load-bearing edges are still open before implementation begins.**

**Scorecard**
- ✓ Mutation hygiene — every doc reads as fresh present-tense intent; no history, planning text, or obsolete markers anywhere
- ✓ HLD discipline — architecture and rationale only; the tenets are genuine tie-breakers, not platitudes
- ✓ Scope disambiguation — the 36-hour regime split is cleanly and complementarily scoped in the WHEN clauses
- ✓ Spec linkage — IDs are unique, stable, and grep-friendly; every leaf prefix resolves to its LLD
- ⚠ LLD sufficiency — the matching/eligibility predicate and the time-boundary edges are left open
- ⚠ Decision capture — the near-term claim design trades against a stated tenet with no recorded exception
- ⚠ Configuration — the instruction file carries the mode marker but not the LID directive block

The arrow is real and unusually tidy — two components, clean HLD→LLD→spec coherence, real tenets doing real work. The most valuable next step is pinning the matching predicate and recording the near-term exception to "First asked, first served" *before* any code is written, plus a quick `/update-lid` to reconcile the instruction file.

**Findings (12 total · 3 high · 4 medium · 5 low)**
- **F1 (high):** `CLAUDE.md` has the `## LID` block with the mode marker, but no directive telling agents this project runs Linked-Intent Development or to consult the skill for changes — a fresh session gets the mode but not the workflow obligation; consider `/update-lid` · *modes are declared, not inferred* (the instruction file is the foundation every future session keys the whole workflow off)
- **F2 (high):** "Compatible," "eligible," and "clinical compatibility" are never enumerated — the core matching predicate is open (does an opening need to *start* within the entry's time window, or fully fit inside it? are accessibility needs part of compatibility? what is "patient eligibility" beyond service/site/time?), so two reasonable implementers would land on different matchers · *LLDs close enough of the solution space* (open solution edges are exactly where intent drift enters, session after session)
- **F3 (high):** The 20-minute searchable window on ≤36-hour cancellations lets a later portal claim beat an earlier compatible request — an unrecorded exception to the "First asked, first served" tenet (and near-term cancellations are precisely the scarce case) · *tenets capture forward-looking preference* (a tenet traded away needs a Decisions row naming the trade and why, or every future session re-litigates it cold)
- **F4 (medium):** The ≤36-hour open-claim mode is the fulfillment design's central call, yet has no Decisions & Alternatives row; the 36-hour / 20-minute / two-hour constants carry no recorded rationale · *docs carry current intent* (decision capture — a cold reader can't reconstruct what was given up and why)
- **F5 (medium):** Entry end-of-life is unspecified — nothing says what happens when an entry's time window elapses, and HLD Goal 3's "expiry" is ambiguous between offer expiry and entry expiry · *effective intent-tree alignment* (LLD behavior with no spec is unnamed intent that drifts silently)
- **F6 (medium):** The `[x]` markers on all 15 specs are defined nowhere — if they mean "implemented," they assert implementation that doesn't exist (the repo is docs-only); if they mean something else, the convention is unwritten · *docs carry current intent* (an unexplained project-local convention is a cost every cold reader pays; also a *minimum surface, maximum discipline* nit)
- **F7 (medium):** The 36-hour boundary is only instant-scoped — an offer made when the opening was >36 hours away can expire after the opening has aged into the ≤36-hour regime, and the specs can't say which rulebook then applies (re-match per FILL-002, or searchable per FILL-003) · *LLDs close enough of the solution space*
- **F8 (low):** "Registry scan" appears only in the fulfillment docs and is never defined — presumably re-running matching over the interest entries; consider naming it in intake's terms · *docs carry current intent* (cold-read)
- **F9 (low):** FILL-003 pins the 20-minute delay in the spec, but FILL-001 leaves the two-hour offer duration in design prose only — parameter placement is inconsistent between adjacent levels · *coherence is adjacency*
- **F10 (low):** The four tenets are unordered while "first asked, first served" and "clinical fit precedes utilization" can both bear on one opening decision; the design resolves the precedence but the tenets list doesn't record it · *tenets capture forward-looking preference*
- **F11 (low):** Intake's "Keys require expiry state" cost references key-expiry behavior that no spec pins — what happens to old idempotency keys is unpinnable · *coherence is adjacency*
- **F12 (low):** Actor attribution for staff-assisted actions is unspecified — the HLD says staff may act for patients and FILL-008 appends an "actor," but no spec says who the actor is when staff acts on a caller's behalf · *docs carry current intent* (cold-read)

**What was audited**
- Read fully: the entire repository — `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (6 files)
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (7 intake, 8 fulfillment)
- Code and tests: none exist — the repo is docs-only, so `@spec` placement, tests-first evidence, and semantic legibility had nothing to sample (not gaps at this stage; they become auditable when implementation starts)
- Overlay: `docs/arrows/` is absent — no `index.yaml` or arrow docs; the sampling-guidance triggers (>15 LLDs, >200 `@spec` files, overlay present) were not met
- Git history: a single commit; no prior code to compare against

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together — F2 and F3 are the pair I'd start with? You can also pick a single finding to dig into.

If you have broader questions about using LID for this project — how tests-first should kick in when implementation starts, mode transitions, or where the arrow overlay fits — I can help with those too.

To apply the fixes: `/update-lid` reconciles F1 (and F6's convention note); F2–F5, F7–F12 are doc edits you'd make directly, or I can make them for you in a follow-up (outside this advisory run).