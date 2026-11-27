## LID Coach — Shelfwise review

**Posture:** *Healthy bootstrap — arrow in place, content clean; a small config reconciliation and a few LLD-sufficiency tightenings.*

**Scorecard**
- ⚠ Configuration — `CLAUDE.md` has the `## LID` block but no `linked-intent-dev` directive
- ✓ HLD discipline — architecture-and-rationale only, no implementation detail bleeding upstream
- ✓ LLD granularity — two components in the HLD, one LLD each, no overlap
- ⚠ LLD sufficiency — a couple of edges left open a cold reader would notice
- ✓ Mutation hygiene — no history residue, no obsolete markers, no accumulation
- ✓ Linkage — spec IDs are stable, grep-anchored, no collisions

**Headline:** The HLD-to-specs arrow is coherent and free of accumulation drift; the fastest wins are reconciling `CLAUDE.md`'s LID directives and tightening two under-specified LLD edges before code lands.

### Findings (5 total · 1 high · 3 medium · 1 low)

- **F1 (high):** `CLAUDE.md` declares `## LID` Mode/Version but is missing the `linked-intent-dev` directive block · *modes are declared, not inferred*
- **F2 (medium):** Hold Allocation LLD doesn't state that allocation only fires on check-in — a fresh hold placed while a copy sits idle waits silently for the next event · *LLDs close enough of the solution space*
- **F3 (medium):** `HOLDALLOC-002` says "tell the patron the limit" without naming the mechanism (in-request response vs. the pickup channel) · *scope disambiguation*
- **F4 (medium):** Pickup Notices doesn't say how the phone-call channel counts as a "failed delivery" — email/SMS have obvious bounce signals; a missed dialer call does not · *LLDs close enough of the solution space*
- **F5 (low):** HLD tenets are an unordered list, and "patrons hear once, clearly" can plausibly tug against "staff attention goes to exceptions" at edges · *tenets capture forward-looking preference*

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation-design.md`, `pickup-notices-design.md`), both spec files (`hold-allocation-specs.md`, `pickup-notices-specs.md`).
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs (7 HOLDALLOC + 6 PICKUP).
- Arrow-path sampling: not applicable — no code or tests exist yet (project appears to be pre-implementation), no `docs/arrows/` overlay installed. Below the >15-LLD / >200-`@spec`-file threshold that would require end-to-end path sampling.
- Detection: no `linked-intent-dev` / `Linked-Intent Development` directive found in `CLAUDE.md`; `## LID` block present with `Mode: Full`, `Version: 1.4.0`; no `## LID Scope` (correct for Full).

### Worth a second look

Models in my class are known to miss cases where a leaf design quietly contradicts the project's own HLD tenets. Please spot-check the hold-allocation and pickup-notices LLDs against the four HLD tenets yourself — especially "waiting is honored in sequence" (does the branch-local preference in HOLDALLOC-003 read as compatible with that framing, or does it feel like a second, unstated tenet?) and "patrons hear once, clearly" (does the exceptions-list path in PICKUP-006 stay on the right side of that line?).

### Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for Shelfwise — where a PRD would fit before the HLD, how to structure things if hold allocation grows a sub-tree, when Scoped mode starts to make more sense than Full, or what to do as code lands and the arrow's downstream phases fill in — I can help with those too.