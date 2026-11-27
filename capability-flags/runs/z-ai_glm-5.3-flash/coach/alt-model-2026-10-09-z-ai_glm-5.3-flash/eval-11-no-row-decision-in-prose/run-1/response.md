# LID Coach — printfarm

**Posture:** *Strong start — the design layer is real and well-crafted; the arrow stops after EARS.*

**Scorecard**
- ✓ HLD discipline — clean architecture-and-rationale doc; real tenets, goals, non-goals; no implementation detail bleeding up
- ✓ Decision capture — both LLDs carry Decisions & Alternatives rows with rejected alternatives *and* accepted costs; this is exactly the keep-side of *docs carry current intent*
- ✓ Mode fit — Full mode matches a whole-repo greenfield service
- ⚠ Spec coverage — both LLDs describe behaviors no EARS spec names
- ✗ Arrow completeness — specs are all marked `[x]`, but Tests and Code don't exist yet
- ⚠ Tenet cascade — one mechanism quietly works against your own tenet

**Headline:** The design layer is genuinely good — two focused nodes, real tenets, honest decision tables. The most valuable next step is walking the arrow downward: spec the unnamed LLD behaviors, then let tests precede the first line of code.

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** All 8 specs (`QUEUE-001..005`, `REG-001..003`) carry `[x]` "done" markers, yet the repo contains no code and no tests — the arrow ends at EARS while the specs claim completion. The `[x]` markers will mislead any future session into assuming implementation exists. *canonical arrow shape — phases exist for components in scope*
- **F2 (high):** `job-queue-design.md` Architecture: jobs accepted but not dispatched before a restart "are gone, and members resubmit them." This works against your HLD tenet *"A submitted job is a promise: members should be able to upload and walk away"* — under the very power-blip condition the Context section describes, the promise breaks silently. No Decisions row records this trade. Consider either capturing it as an accepted cost (with why persistence was rejected) or changing the design. *tenets capture forward-looking preference / tenet cascade*
- **F3 (medium):** Several LLD behaviors have no spec anywhere: acceptance rule ("job accepted only if its target class has at least one registered printer"), FIFO-within-priority ordering, content-hash disk storage, registry SQLite persistence and 15 s polling. Unnamed intent drifts silently because there's nothing to test against. *effective intent-tree alignment*
- **F4 (medium):** The queue says dispatch is "event-driven: when the registry reports a printer idle," while the registry "polls each printer's status endpoint on an interval" — who calls whom, and how the registry pushes to the queue, is left open. Two reasonable agents would land on incompatible implementations (push vs. poll). *LLDs close enough of the solution space*
- **F5 (low):** The three tenets are unordered (fine at this size), but "the service stays small" leans platitude — consider sharpening to a real tie-breaker with a defensible opposite, e.g. "prefer in-process simplicity over adding a database or service, even when scale argues otherwise." *tenets capture forward-looking preference*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 2 intent components, 2 LLDs, 2 spec files, 8 EARS specs
- Repo sweep: complete file listing — confirmed no source, tests, or arrow overlay exist
- No sampling needed: project is well under the sampling thresholds

## What is working (worth naming)

The linkage you do have is clean: `QUEUE` and `REG` leaf prefixes resolve correctly to each LLD's `prefix:` frontmatter, scope disambiguation is handled in WHEN clauses (staff-only reordering is scoped, not universal-sounding), and the Decisions tables read as present intent — no history residue, no `[inferred]` markers, no obsolete specs anywhere.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — where PRDs fit, when to add an arrow overlay, what to do when a segment grows too large — I can help with those too.