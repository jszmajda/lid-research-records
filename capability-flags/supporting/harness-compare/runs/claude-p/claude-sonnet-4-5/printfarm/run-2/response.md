# printfarm — LID Coach Report

## Executive Summary

**Posture:** Solid design foundation, tenet-cascade drift.

**Scorecard**
- ✓ Intent-tree alignment — clean HLD → 2 LLDs → 8 EARS specs, proper frontmatter and prefixes
- ✓ HLD discipline — architecture and rationale only, no implementation detail
- ✓ Decision capture — good Decisions & Alternatives tables with clear rationales
- ⚠ Tenet cascade — design contradicts one tenet without recording the exception
- ⚠ Tenet formulation — tenets read more as values than tie-breakers
- ⚠ Arrow completeness — specs marked satisfied but no implementation exists yet

**Headline:** The arrow's design phase is well-structured and coherent across HLD, LLDs, and specs; the fastest wins are in resolving the tenet-cascade conflict and clarifying implicit recovery behavior.

## Findings (5 total · 2 high · 3 medium · 0 low)

- **F1 (high):** job-queue's in-memory queue loses accepted jobs on restart, contradicting the "A submitted job is a promise" tenet · *tenet cascade*
- **F2 (high):** "members resubmit" assumes discovery/recovery behavior not described in the design · *docs carry current intent, written to be read cold*
- **F3 (medium):** all specs marked `[x]` but no tests or code exist · *arrow completeness*
- **F4 (medium):** tenets read as values/constraints rather than tie-breakers with defensible opposites · *tenets capture forward-looking preference*
- **F5 (medium):** tenets unordered when they could conflict (promise vs. modest hardware) · *tenets capture forward-looking preference*

## What Was Audited

- Read fully: CLAUDE.md, docs/high-level-design.md, 2 LLDs (job-queue, printer-registry), 2 spec files
- Enumerated: 8 EARS specs (QUEUE-001 through QUEUE-005, REG-001 through REG-003)
- Linkage: all spec IDs unique and grep-friendly
- Implementation: no code or tests present (design-only project state)

## Detail

**F1 — High. The job-queue design's in-memory queue loses accepted jobs on restart, directly contradicting the HLD tenet "A submitted job is a promise: members should be able to upload and walk away."** The LLD says "The queue is a per-printer-class list of accepted jobs held entirely in process memory" and later "jobs that were accepted but not yet dispatched before a restart are gone." Under *tenet cascade* — design nodes should lean the way the HLD's tenets say to lean, and exceptions should be recorded — this is a present contradiction with no explanation. A mechanism exists (the tenet cascade principle, dimension 19) holds each tenet while reading each design and asks: under the operating conditions these docs describe, does this work against a tenet? Here it does: the mini-PC "takes unattended OS updates and the occasional power blip," jobs are accepted, the queue holds them in memory only, restarts lose them, and the tenet says accepted jobs are promises. The Decisions & Alternatives table in the job-queue LLD has no row explaining why in-memory was chosen over persistent queue, or what cost was accepted by trading against the promise tenet. You have three remedies, and it's your choice which fits: (1) change the design to persist accepted jobs (SQLite, append-only file, or similar), (2) add a Decisions row naming the tenet traded against and why the tradeoff was accepted (e.g., "keeping the service small" tenet won; accepted cost: members resubmit lost jobs), or (3) revise the tenet if it no longer reflects what you want the system to lean toward. The displacement trap: even if you later decide the in-memory choice is technically wrong, the decision-capture gap is its own finding — a live decision (one a cold reader would still question) surviving only in conversation or missing from the Decisions table compounds every future session.

**F2 — High. The job-queue LLD says "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them," but the design doesn't describe how members discover a restart happened or what UI support exists for resubmission.** Under *docs carry current intent, written to be read cold* — a doc should stand on its own for a reader with no conversation context — this is an implicit-context leak. The LLD mentions that "Uploaded G-code files are kept on disk under a content hash, so resubmitting the same file is cheap," which implies resubmission is anticipated, but not *how* it happens from the member's perspective. Does the UI show a notification when a previously-accepted job is gone? Do members manually check queue state? Is there a retry mechanism? A cold reader (or a future agent implementing the web UI) would have to guess. Try adding a sentence or two in the job-queue LLD's Architecture section explaining the member-facing behavior: what signals job loss (a queue view showing the job missing? an explicit alert?), and what the resubmission flow looks like. This closes the gap and makes the design implementable without guessing.

**F3 — Medium. All 8 specs are marked `[x]` as if satisfied, but no tests or code exist in the project.** Under *arrow completeness* — each phase of the arrow should exist for components in scope — the project is in a design-only state, which is legitimate (greenfield or pre-implementation), but the `[x]` markers suggest implementation exists when it doesn't. A future reader seeing `[x]` would expect to find tests and code; not finding them creates confusion about what "satisfied" means here. Try changing the markers to `[ ]` or omitting them entirely until tests and code exist, so the spec files accurately reflect the project's current state. This is a documentation-hygiene issue, not a structural one, but it compounds if the markers sit misleading for a long time.

**F4 — Medium. The HLD's tenets read more as values or constraints than as tie-breakers with defensible opposites.** Under *tenets capture forward-looking preference* — a real tenet's reverse is a choice a different project could reasonably make, and it's phrased as a lean (which way to prefer) not a triggered rule (when X, do Y) — these don't quite fit. "A submitted job is a promise: members should be able to upload and walk away" is a value statement or goal; its opposite ("members must babysit their jobs") isn't a defensible alternative another project would choose, it's just worse. "Staff override members, but the queue explains itself — no silent reordering" is closer to a triggered rule (when staff reorder, explain it) than a tie-breaker. "The mini-PC is modest hardware; the service stays small" is a constraint, not a preference to lean toward when two choices are otherwise equal. The cost of tenets that aren't real tie-breakers is that future sessions facing an uncovered decision won't get useful guidance — a tenet that doesn't narrow the space (because its opposite is absurd) or that's actually a spec (because it triggers on a condition) won't help the agent make the choice the user would have made. Try rephrasing each as a lean-not-trigger ("prefer X over Y when both are feasible") and checking whether the opposite is something a reasonable project could choose. For example, "Prefer member autonomy over UI hand-holding" (opposite: "Prefer rich UI guidance over member autonomy" — defensible for a different audience) or "Prefer simpler code over richer features when resource-constrained" (opposite: "Prefer feature richness even if it costs complexity" — defensible). If a tenet doesn't pass the defensible-opposite test, it might belong in Goals, Non-Goals, or as a spec rather than in Tenets.

**F5 — Medium. The three tenets are unordered, but they could conflict.** The "promise" tenet and the "service stays small" tenet can pull in opposite directions: keeping promises robustly (persisting state, retrying failures, handling edge cases) tends to grow the service, while keeping it small favors in-memory state and fewer mechanisms. When two tenets conflict on a specific decision, an ordered list tells the agent which wins; an unordered list leaves the tiebreak unresolved. Try ordering the tenets by precedence if you haven't already thought through which should win when they conflict. If they don't conflict in practice (or you want case-by-case judgment), you can leave them unordered, but making the precedence explicit now saves a future session from guessing.

## Offer to Help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.