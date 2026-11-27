# `/lid-coach` — printfarm

## Executive summary

**Posture:** *Solid design layer; arrow stops at specs — tests and code haven't arrived yet.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale, no schemas or signatures leaking downstream
- ✓ LLD granularity — one LLD per named design node, no overlap
- ✓ Scope disambiguation — every spec is WHEN-clause scoped, no universal-sounding traps
- ⚠ Arrow completeness — the Tests and Code phases are absent, yet every spec is marked `[x]`
- ⚠ Decision capture — the in-memory-queue choice is load-bearing and unlogged
- ⚠ Tenet quality — one tenet mixes a lean with a spec-shaped rule

**Headline:** The two-node design is real, EARS specs trace cleanly to their LLDs, and every doc reads cold on its own — the fastest wins are landing tests+code so the arrow is walkable end-to-end and capturing the "hold the queue in memory" trade-off on the page.

## Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** All 8 specs are marked `[x]` "done" but the repo contains no code or tests · *intent leads; code is compiled output* — specs drive code, not the other way around
- **F2 (high):** The arrow ends at EARS — Tests and Code phases are missing across both nodes · *canonical arrow shape* — the arrow is only walkable when every phase exists
- **F3 (high):** The "queue is entirely in process memory; accepted-but-undispatched jobs are lost on restart" choice is a load-bearing architectural decision with no Decisions & Alternatives row · *docs carry current intent* (decision-capture ceiling) — a cold reader would still ask "why not persist?" and cannot reconstruct the trade-off
- **F4 (medium):** Behaviors described in the job-queue LLD have no spec: (a) reject an upload when no printer of the target class is registered, (b) content-hashed upload dedup, (c) loss/resubmit contract across restart · *LLDs close enough of the solution space* — un-spec'd LLD prose is where two reasonable agents will diverge
- **F5 (medium):** The `Staff override members, but the queue explains itself — no silent reordering` tenet bundles a lean ("staff override members") with a triggered rule already captured in QUEUE-005 · *tenets capture forward-looking preference* — a spec-shaped tenet gives false confidence the space is constrained
- **F6 (low):** The three tenets are unordered even though two of them could conflict (walk-away promise vs. small-service-on-modest-hardware, once background work like retries or notifications is on the table) · *tenets capture forward-looking preference* — ordering makes tie-breaking obvious

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and every file under `docs/intent/` (both design docs + both spec files).
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 EARS specs (5 QUEUE, 3 REG).
- No `docs/arrows/` overlay present — cascade health inferred from doc coherence rather than index state.
- No code or test files exist in the repo, so `@spec` linkage, tests-first evidence, and semantic-legibility dimensions were reviewed against absence rather than sample.
- Mode: **Full** declared in `CLAUDE.md`; project scope is the whole repo, which matches the two named design nodes.
- Non-interactive-run note: no dispatch prompt triggered (project is fully configured — directives, mode marker, and standard directories all present; no `arrows/index.yaml` corruption to arbitrate).

## Worth a second look

Models in my class are known to miss cases where a leaf design quietly contradicts the project's own tenets. Please check the two LLDs against your HLD tenets yourself — in particular whether "held entirely in process memory / members resubmit on restart" sits comfortably against *"a submitted job is a promise: members should be able to upload and walk away."*

## Offer to help

Want me to walk through the findings in detail, focus on a priority band (start with the three highs?), or work through a specific item — for example, drafting the Decisions & Alternatives row for the in-memory-queue call, or splitting the mixed tenet into a lean + an EARS spec?

If you have broader questions about using LID on printfarm — where a PRD would sit if members start requesting features through staff, when to promote `job-queue` to a sub-HLD if dispatch grows a scheduler of its own, or how to stage the tests+code phases without over-committing the mini-PC — I can help with those too.