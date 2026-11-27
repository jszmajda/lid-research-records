# LID Coach Report — printfarm

## Executive Summary

**Posture:** Bootstrapping — arrow solid through design layer, ready for tests and code.

**Scorecard**
- ✓ Configuration — Full mode declared, version current, navigation table clear
- ✓ HLD discipline — architecture and rationale only, no implementation detail creep
- ✓ LLD granularity — two clean nodes, each one intent component, no overlap
- ✓ Linkage structure — spec IDs align to LLD prefixes, grep-friendly, no collisions
- ⚠ Tenet cascade — one design choice contradicts a tenet without a recorded tradeoff
- ⚠ Status markers — specs marked implemented before code exists

**Headline:** The arrow is well-formed through HLD → LLDs → EARS, with clean separation between job-queue and printer-registry. The fastest win is resolving the tension between Tenet 1's reliability promise and the in-memory queue design — either persist the queue or record why job loss is acceptable. After that, align status markers to actual implementation state and order the tenets to clarify which preference wins when they conflict.

---

## Findings (3 total · 1 high · 2 medium)

- **F1 (high):** job-queue architecture contradicts Tenet 1 without decision record · *tenet cascade — designs lean the way tenets say to lean*
- **F2 (medium):** all specs marked `[x]` but no code/tests exist yet · *mutation, not accumulation — status reflects reality*
- **F3 (medium):** HLD tenets can conflict but aren't ordered · *tenets capture forward-looking preference*

---

## Finding Details

### F1 (high): Tenet contradiction in job-queue persistence

The job-queue design holds accepted jobs in process memory and documents that "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." The HLD's first tenet states "A submitted job is a promise: members should be able to upload and walk away." These conflict directly — a member who uploads in the evening and experiences a restart overnight (the context notes the mini-PC takes "unattended OS updates and the occasional power blip") loses their job and must notice and resubmit. That's not "upload and walk away."

**Why this matters:** Tenet violations compound silently when they're not acknowledged. A design that contradicts a tenet without explaining the tradeoff leaves future sessions unable to distinguish intent (was this an intentional choice?) from drift (did someone miss the tenet?). When the next session considers improving reliability, they can't tell whether job loss was accepted deliberately or is a gap to close.

**What to consider:** Either (a) persist accepted jobs so they survive restarts (the registry already uses SQLite, so extending it wouldn't violate Tenet 3's "stay small"), or (b) add a Decisions & Alternatives row in job-queue-design.md explaining that Tenet 3 ("modest hardware") outweighs Tenet 1 in this dimension, what compensates for the broken promise (maybe member notification of job loss? not currently mentioned), and what threshold would trigger revisiting persistence. If you choose (b) and the tenets aren't yet ordered, ordering them (F3) makes this tradeoff clearer.

---

### F2 (medium): Status markers ahead of implementation

All 8 specs across both spec files are marked `[x]`, but the project has no code or tests yet — the arrow stops at the EARS layer. Status markers that don't reflect actual implementation state misrepresent where the project is on the arrow and can mislead agents (or humans) about what's safe to change.

**Why this matters:** An agent reading `[x]` assumes there's code implementing the spec and tests verifying it. When that's not true, changes to the spec feel safer than they are (no regression risk to check), and changes to nonexistent code feel riskier than they are (no orphaned implementation to update). The mismatch creates friction in both directions.

**What to consider:** Change the status markers to `[ ]` (pending) or `[draft]` until tests and code exist for each spec. Once a spec has a test citing it and code passing that test, flip its marker to `[x]`. This keeps the markers accurate as you build out the implementation layers.

---

### F3 (medium): Unordered tenets that can conflict

The HLD has three tenets, but they're not ordered. Tenet 1 ("A submitted job is a promise") and Tenet 3 ("The mini-PC is modest hardware; the service stays small") can conflict — exactly the tension visible in the job-queue design, where an in-memory queue keeps the service small but loses the promise on restart. When tenets can conflict and there's no ordering, future sessions (and even the current one — see F1) can't tell which preference wins.

**Why this matters:** Tenets exist to narrow the solution space when a decision has two defensible answers and no spec covers it. An unordered set of tenets that can conflict doesn't narrow anything — it gives conflicting guidance, and the agent has to guess or ask. Ordering them makes the tie-breaking rule explicit: "when these conflict, lean this way."

**What to consider:** Order the three tenets. Based on the current design (in-memory queue, SQLite only for the registry, no slicing), it looks like Tenet 3 already wins over Tenet 1 in practice. Making that explicit — either by reordering the list to put Tenet 3 first, or by adding a note that Tenet 3 is the highest-priority constraint — clarifies the intent and makes F1's tradeoff decision easier to document.

---

## What Was Audited

- **Read fully:** CLAUDE.md, docs/high-level-design.md, both LLD files (job-queue, printer-registry), both spec files
- **Enumerated:** 2 LLDs, 2 spec files, 8 EARS specs (5 QUEUE-*, 3 REG-*)
- **Design structure:** HLD → 2 leaf LLDs → EARS (no sub-HLDs; appropriate for a 2-component system)
- **Arrow depth:** Design layer complete (HLD ✓, LLDs ✓, EARS ✓); Tests and Code layers not yet started (bootstrap state, not drift)
- **No arrows overlay** (docs/arrows/ not present)

---

## What's Working

The project has strong LID discipline at the design layer:

- **Clean architecture decomposition:** Two intent components cleanly separated (job-queue handles queuing and dispatch; printer-registry handles heartbeats and availability). Each LLD owns one EARS prefix with no overlap.
- **HLD stays architectural:** The HLD describes problem, approach, and tenets without drifting into schemas or API shapes. Implementation detail lives in the LLDs where it belongs.
- **Effective intent-tree alignment:** Spec IDs (QUEUE-*, REG-*) match LLD `prefix:` frontmatter exactly. Grep-friendly, no collisions, clean boundaries.
- **Well-captured decisions:** Both LLDs have Decisions & Alternatives tables explaining key choices with rationale and accepted costs (FIFO vs. shortest-job-first, base32 slugs vs. UUIDs, heartbeat interval tradeoffs).
- **No accumulation:** Docs are written in the present tense as current intent. No "was/now" language, no changelog residue, no `[obsolete]` markers cluttering the specs.

The arrow is ready to extend downward — tests and code can be built directly from the EARS specs and LLD architecture as written.

---

## Next Steps

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.