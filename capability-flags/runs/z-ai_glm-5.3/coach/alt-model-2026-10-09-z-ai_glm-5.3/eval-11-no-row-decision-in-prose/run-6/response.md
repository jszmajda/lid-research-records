# LID Coach Review — printfarm

**Posture:** *Bootstrapping — the arrow is authored and unusually clean, but its spec status markers claim an implementation that doesn't exist.*

**Scorecard**
- ✓ HLD discipline — pure architecture and rationale; tenets are real tie-breakers, not platitudes
- ✓ Mutation hygiene — every doc reads fresh-authored; no changelogs, residue, or conversational fossils
- ✓ Mode fit — Full mode matches a whole-repo, two-node adoption
- ✗ Linkage integrity — all 8 specs marked `[x]` ("implemented") with zero code or tests in the repo
- ⚠ Spec coverage — several load-bearing LLD behaviors have no EARS spec
- ⚠ Tenet cascade — the queue's restart behavior works against the HLD's own promise tenet

**Headline:** the doc tree is the healthiest part of this project — terse, specific, self-contained, and honest about trade-offs in its Decisions tables; the most valuable next step is resetting the spec markers to reflect reality and capturing the queue-durability decision *before* code starts writing itself around the gap.

---

**Findings (7 total · 2 high · 3 medium · 2 low)**

- **F1 (high):** Queue restart-loss defeats the HLD's promise tenet under the docs' own operating conditions · *coherence is adjacency / tenet cascade* (each arrow level should agree with its neighbors). The HLD declares "a submitted job is a promise: members should be able to upload and walk away" and the goal is "evening upload, overnight print, morning pickup — with no member present." The job-queue LLD holds the queue entirely in memory and drops accepted-but-undispatched jobs on restart — while its own Context names "unattended OS updates and the occasional power blip." A power blip overnight, inside exactly the promised window, silently voids the promise. No Decisions row records the exception (naming the tenet traded against, and why). If the lossy choice is deliberate, capture the trade; if not, the tenet is unenforced at its most important moment.
- **F2 (high):** All 8 specs are marked `[x]` — "implemented: code and tests exist" — in a repo containing no code and no tests · *intent leads; code is compiled output* (specs are the source of truth; markers are the arrow's claim about compiled output). A future session reading `job-queue-specs.md` will believe implementation exists and hunt for it, or worse, trust the markers as a baseline when writing it. Consider flipping all markers to `[ ]` (active gap) so the arrow tells the truth — it's a one-minute fix that protects every session after.
- **F3 (medium):** The durability decision is under-captured and reads inconsistently · *decision capture under docs carry current intent* (a choice a cold reader would question should reconstruct what was given up and why). The in-memory, loss-on-restart queue appears only in Architecture prose — no Decisions row — and a cold reader will immediately question it, especially given the asymmetry: printer-registry *does* persist (SQLite, "Fits the mini-PC") while the queue doesn't. Worse, the job-ID row says "slugs recycle after 90 days," implying a persistent job-record store the design never builds. A fuller row (persistence rejected because…, accepted cost…, tenet traded against…) would let the next session lean the way you leaned.
- **F4 (medium):** "Suspect" printer state is defined nowhere · *cold-read coherence / cascade within segments*. QUEUE-003 and the job-queue LLD "mark the printer suspect," but printer state is the registry's concern — its LLD derives state solely from heartbeats (idle / busy / unreachable) and knows nothing of "suspect." Does suspect block dispatch? Does the heartbeat poll clear it, or does it overlap with unreachable? A cold reader can't tell. This obligation crosses a segment boundary into registry-owned state and needs a reconciled home — either a registry-recognized state or an explicitly queue-owned do-not-dispatch mark.
- **F5 (medium):** Three LLD behaviors carry no EARS spec · *effective intent-tree alignment* (every spec traces to a node; every LLD behavior should trace to a spec). Unspecified: (1) the acceptance precondition ("at least one registered printer in the target class"), (2) the staff-before-member priority ordering — the concrete form of the HLD's "staff override members" tenet, (3) the member's successful-submission path itself (only the rejection is specced). These are precisely the behaviors most likely to drift once an agent fills the gaps from its own distribution.
- **F6 (low):** Tenet list is unordered though two tenets can conflict · *tenets capture forward-looking preference*. F1 is tenets 1 and 3 in live conflict (durability vs. staying small); when no spec covers a future call, an ordered list would say which yields.
- **F7 (low):** Spec files' `**LLD**:` pointer line is a mild local addition beyond the standard format · *minimum surface, maximum discipline*. Harmless as-is since the LLD frontmatter already carries `prefix:` linkage; just noting it's a convention future sessions will propagate.

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files — the entire repository (5 tracked files)
- Enumerated: 2 design nodes, 8 EARS specs across 2 segments, all Decisions & Alternatives rows
- Code/test sampling: not applicable — the repo contains no code or tests
- No arrow overlay (`docs/arrows/` absent); no structural audit attempted

*Note on posture:* this review is advisory by design — I haven't edited anything. Marker fixes (F2) are yours to make directly; structural follow-ups can be enumerated by `/arrow-maintenance` once the overlay is installed, and any instruction-file reconciliation belongs to `/update-lid`.

---

Want me to walk through any finding in detail, or work through specific items together — e.g., drafting the missing specs for F5 or the durability Decisions row for F1/F3?

If you have broader questions about using LID for this project — when to start tests-first, whether the arrow overlay is worth installing yet, how the first code session should consume these docs — I can help with those too.