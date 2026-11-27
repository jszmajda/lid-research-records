All inputs are read — this is a small, fully-readable project (6 files, no sampling needed). The review is complete. Per the skill's advisory posture, I've made no file changes; here is the report.

---

# LID Coach Review — printfarm

## Executive summary

**Posture:** Bootstrapping — design layers authored with real care; spec status markers and one cross-node contract have drifted ahead of reality.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no implementation detail creeping upstream
- ✓ LLD granularity — one doc per design node, scopes don't overlap, tenets are genuine tie-breakers
- ✓ Mutation hygiene — docs read as fresh intent; no history residue or planning text
- ⚠ Alignment — the tree is real, but three LLD behaviors and one HLD concept have no spec or node
- ⚠ Cascade health — the queue↔registry contract is stated two incompatible ways across the segment boundary
- ✗ Spec status coherence — every spec is marked implemented; no code or tests exist

**Headline:** The design layers are genuinely strong — a clean HLD with real tenets, two well-scoped LLDs, disciplined EARS; the fastest wins are resetting the spec status markers to match reality and pinning the queue↔registry contract where it belongs.

## Findings (10 total · 4 high · 3 medium · 3 low)

- **F1 (high):** All 8 specs are marked `[x]` ("Implemented: code and tests exist" per the EARS syntax reference), yet the repo contains no code and no tests — consider resetting them to `[ ]` (active gap) · *coherence is adjacency* (each level of the arrow agrees with its neighbors; here the spec layer claims a phase that doesn't exist)
- **F2 (high):** The in-memory queue silently loses accepted jobs on the restarts the LLD itself describes ("unattended OS updates and the occasional power blip") — under that described condition it defeats tenet 1 ("a submitted job is a promise") and the overnight-pickup goal, and no Decisions row records the exception · *tenets capture forward-looking preference* (a mechanism working against a stated tenet, sharing no wording with it)
- **F3 (high):** The same durability choice survives only in Architecture prose — no Decisions & Alternatives row records what was given up (persisting the queue beside the content-hashed files already on disk) or the accepted cost, and a cold reader holding the HLD would try to reverse it · *docs carry current intent* (decision capture — the live decision needs a fuller row)
- **F4 (high):** The queue↔registry contract is stated two incompatible ways: the registry LLD says "the queue asks the registry which printers are idle" (pull) while the queue LLD and QUEUE-002 say "the registry reports a printer idle" (push) — the contract dominates both nodes but the HLD names the nodes without stating their interaction; consider deciding it at the shared parent · *intent attaches at the lowest node that dominates it* (substance governing both siblings belongs to their shared parent, not either leaf)
- **F5 (medium):** "Suspect" printer state (set by QUEUE-003 on dispatch failure) is never defined — the registry owns printer state and lists only idle/busy/unreachable; nothing says what suspect does, whether suspect printers get dispatches, or what clears it, and no REG spec covers recovery · *coherence is adjacency* (the seam between the two segments disagrees)
- **F6 (medium):** LLD behaviors with no spec anywhere: acceptance gated on the target class having a registered printer; staff-vs-member priority ordering; staff printer registration (only retirement is spec'd as REG-003) · *effective intent-tree alignment* (LLD behavior with no spec is unnamed intent that drifts silently — there's nothing to test against)
- **F7 (medium):** The web UI named in the HLD's Approach ("Members interact through a small web UI; staff see the same queue") has no design node, and no LLD owns the "queue view" that QUEUE-005 references · *effective intent-tree alignment* (an architecture concept that traces to no design node)
- **F8 (low):** QUEUE-005's "record the reordering visibly in the queue view" could land as an audit log or an inline annotation — consider tightening what "visibly" means · *LLDs close enough of the solution space* (under-specified edges are where intent drift enters)
- **F9 (low):** QUEUE-002 references "the registry" with no inline gloss — per the EARS reference, cross-segment concepts deserve a brief parenthetical so a grep-found spec can't be implemented plausibly-but-wrong · *scope disambiguation* (specs must stand alone when found cold)
- **F10 (low):** Three tenets that can genuinely conflict (keeping the promise vs. staying small — exactly the F2 trade) are listed unordered · *tenets capture forward-looking preference* (tie-breakers need an order when more than two could collide)

## What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, both design docs, both spec files — the entire repo; no sampling needed
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (5 QUEUE, 3 REG), all with unique grep-friendly IDs matching their frontmatter `prefix:` declarations
- Linkage metric: 0 `@spec` annotations in code — no code or tests exist in the repo, so tests-first and entry-point placement could not be assessed
- No `docs/arrows/` overlay present; no capability flags populated for review dimensions

## Offer to help

Want me to walk through any of these findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into — F2/F3 (the durability trade) and F4 (the cross-node contract) are the two I'd tackle first, since both will bite the very first implementation session.

If you have broader questions about using LID for this project — where the web UI should sit in the design tree, how to handle the tests-first phase as implementation starts, or whether an arrow overlay would pay off at this size — I can help with those too.

---

Note on the advisory posture: this skill reviews and recommends but does not edit files. When you're ready to apply fixes, you can edit the docs directly, run `/update-lid` for configuration changes, or just tell me which findings to work through and I'll help you make the edits interactively.