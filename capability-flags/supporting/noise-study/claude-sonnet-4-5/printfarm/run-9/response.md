**printfarm LID Coach Report**
**2026-09-25**

---

## Executive Summary

**Posture:** Bootstrapping — arrow well-formed, awaiting implementation.

**Scorecard**
- ✓ Arrow structure — HLD, LLDs, and specs form a clean canonical arrow
- ✓ Intent-tree alignment — spec prefixes (QUEUE, REG) map cleanly to LLDs and HLD architecture nodes
- ✓ Mutation hygiene — docs written in present tense with no historical residue
- ⚠ Decision capture — one key tension under-explained in the Decisions tables
- ⚠ Tenet discipline — reasonable tie-breakers but could conflict without ordering
- ✓ LLD granularity — two components appropriately scoped

**Headline:** The arrow is well-formed and ready to guide implementation; the highest-value tightening is in the decision layer — capturing the tenet-vs-restart tradeoff and ordering the tenets for when they conflict.

---

## Findings (3 total · 1 high · 2 medium)

- **F1 (high):** Tenet-vs-restart tension not captured in Decisions table · *decision capture — docs carry current intent*
- **F2 (medium):** Tenets could conflict but aren't ordered · *tenets capture forward-looking preference*
- **F3 (medium):** Heartbeat interval decision is compressed · *decision capture*

---

## What Was Audited

- **Read fully:** CLAUDE.md, docs/high-level-design.md, both LLDs (job-queue and printer-registry), both spec files (job-queue-specs.md, printer-registry-specs.md)
- **Enumerated:** 2 LLDs, 2 spec files, 8 EARS specs total (5 QUEUE-prefixed, 3 REG-prefixed)
- **Project state:** Bootstrapping — no code or tests present yet; the arrow is in place and ready to guide first implementation

---

## Finding Details

**F1 — High. Tenet-vs-restart tension not captured in Decisions table.** The job-queue LLD states that "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them," which appears to conflict with the HLD tenet "A submitted job is a promise: members should be able to upload and walk away." This is a consequential tradeoff — the tenet suggests persistence guarantees, but the in-memory queue design accepts degradation on restart for simplicity (aligning with the "stays small" tenet). Under *decision capture* — the principle that decisions staying live once landed should be reconstructable by a cold reader — this tension would surprise a future reader encountering the LLD without the full context of why the promise is qualified. The cost of leaving this implicit is that future sessions might question or attempt to reverse the choice (adding queue persistence) without understanding it was a deliberate tradeoff. Add a row to the job-queue Decisions table: "Queue persistence" as the decision, "In-memory only; accepted jobs lost on restart" as chosen, and rationale that the promise holds during normal operation but degrades on rare restarts, accepting that cost to keep the mini-PC implementation simple and aligned with the resource constraint tenet.

**F2 — Medium. Tenets could conflict but aren't ordered.** The three HLD tenets — promise semantics for submitted jobs, queue transparency for staff actions, and keeping the service small — are all reasonable tie-breakers with defensible opposites. However, they could pull in different directions (for example, "the queue explains itself" might push toward richer audit logging or reordering history that fights "stays small"), and when they conflict the agent has no guidance on which lean dominates. Under *tenets capture forward-looking preference*, tenets work as tie-breakers only when their relative priority is clear; without ordering, a session facing a choice where two tenets conflict has to guess or ask. The cost is decision latency and potential misalignment with your intent. Consider ordering the three tenets by priority, or adding a note in the HLD's Tenets section about which constraint dominates when they conflict — often the resource constraint ("stays small") is the hard floor and the others bend around it.

**F3 — Medium. Heartbeat interval decision is compressed.** The printer-registry Decisions table entry for "Heartbeat interval → 15s" gives a rationale ("Fast enough that idle printers pick up work promptly; slow enough not to bother printer firmware") but a cold reader couldn't reconstruct what specific alternatives were weighed — were 10s, 30s, or 60s considered? What about event-driven heartbeats triggered by state change? Under *decision capture*, a decision that a cold reader would pause at (and 15s is specific enough to feel calibrated rather than arbitrary) should name at least one rejected alternative and the accepted cost. The remedy depends on how this was chosen: if 15s was a deliberate calibration against other intervals or approaches, expand the row to capture that (e.g., "10s rejected: excessive firmware polling load on older models; 30s rejected: members see 30+ second dispatch delays after a print finishes"); if it was picked as a reasonable starting point without deep analysis, that's fine — just note "chosen as reasonable default, can be tuned" so a future reader knows the decision is soft. The cost of leaving this compressed is minor but real: a future session optimizing dispatch latency might re-litigate the interval without knowing the firmware constraint was already considered.

---

## Offer to Help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.