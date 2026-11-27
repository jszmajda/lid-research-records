I now have everything needed to run the review. Let me compose the report.

---

## /lid-coach — printfarm

**Posture:** Bootstrapping well — design layer clean and cold-readable, gaps concentrated in missing coverage rather than structural drift.

---

### Scorecard

- ✓ **HLD discipline** — tight architecture-and-rationale; no schemas or function signatures bleeding in
- ✓ **LLD granularity** — two intent components matching the HLD's declared architecture nodes; scopes clean and non-overlapping
- ✓ **Spec format** — EARS shape and IDs consistent; no orphaned prefixes; no ID collisions
- ⚠ **Arrow completeness** — arrow runs through EARS; no tests or code yet, and the web UI surface named in the HLD has no intent component
- ⚠ **Effective intent-tree alignment** — spec files cover the exception paths well but leave two normal-path behaviors unspecced
- ⚠ **Decision capture** — the most consequential design choice (in-memory queue with restart-loss) appears in Architecture prose without a Decisions row
- ✗ **Tenet cascade** — the in-memory queue, under the conditions the LLD itself describes (OS updates, power blips), defeats the "submitted job is a promise" tenet with no exception on record

**Headline:** The HLD and two LLDs are tight and cold-readable across a coherent scope; the fastest wins are adding a web UI intent component, recording the durability trade-off in Decisions & Alternatives, and filling the two missing normal-path specs.

---

### Findings (8 total · 2 high · 4 medium · 2 low)

- **F1 (high):** In-memory queue under the described restart conditions defeats the "submitted job is a promise" tenet — the job-queue LLD says jobs lost on restart require member resubmission, and the same LLD says the mini-PC "takes unattended OS updates and the occasional power blip." No Decisions row records this exception. · *tenet cascade — designs that work against a tenet under conditions the docs describe, with no recorded exception; decision capture — the choice that carries the consequence*
- **F2 (high):** No web UI intent component — the HLD names "a small web UI" as the primary member-facing surface, QUEUE-005 references a "queue view," but no LLD exists to own that surface or define what "visible" means for staff reordering. · *arrow completeness — each phase exists for components in scope; LLD sufficiency — the spec depends on a behavior the LLD doesn't define*
- **F3 (medium):** Spec gap in job-queue: the LLD says "a job is accepted only if its target class has at least one registered printer" — a named behavior with no QUEUE-NNN spec. · *effective intent-tree alignment — LLD behaviors with no spec are unnamed intent that drifts silently*
- **F4 (medium):** Spec gap in printer-registry: REG specs cover failure, recovery, and retirement but not the normal idle-notification path — the job-queue dispatches on "When the registry reports a printer idle" (QUEUE-002), yet the registry has no spec for that reporting. · *effective intent-tree alignment — specs trace to LLDs trace to HLD in both directions*
- **F5 (medium):** Tenet 1 ("A submitted job is a promise: members should be able to upload and walk away") reads as a restatement of the first Goal rather than a tie-breaker — its defensible opposite isn't obvious the way tenet 3's is. Consider rewording as a lean (e.g., "when durability and throughput conflict, favor the job-holder's expectation"). Also: the three tenets are unordered though tenet 1 and tenet 3 can conflict. · *tenets capture forward-looking preference — real tenets have a defensible opposite; ordered when they could conflict*
- **F6 (medium):** In-memory queue durability choice has no Decisions row — the Architecture section describes it (and its restart-loss consequence) but the Decisions table covers scheduling order, job identifiers, and upload limits only. A cold reader holding this LLD would question why a "promise"-scoped system accepts data loss. · *decision capture — a choice a cold reader would question or try to reverse, surviving only in prose*
- **F7 (low):** Three-consecutive-heartbeat threshold in the registry has no Decisions row — the number is stated in the LLD body and specced in REG-001 without any record of why three (not two, not five). · *decision capture — minor; worth a line*
- **F8 (low):** `[x]` on all specs is ambiguous in a pre-implementation project — the conventional reading is "implemented," which contradicts the absence of code. Consider `[ ]` for pending or a brief convention note at the top of each spec file. · *minimum surface, maximum discipline — custom or unexplained conventions add interpretation overhead*

---

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/job-queue/job-queue-design.md`, `docs/intent/job-queue/job-queue-specs.md`, `docs/intent/printer-registry/printer-registry-design.md`, `docs/intent/printer-registry/printer-registry-specs.md`
- Enumerated: 2 LLDs, 2 spec files, 8 specs (QUEUE-001–005, REG-001–003)
- No arrow-maintenance overlay (`docs/arrows/` absent)
- No code or test files — `@spec` annotation coverage could not be assessed
- Arrow-path sampling: not applicable at this stage (no test or code layer)

---

Want me to walk through any of these findings in detail, focus on a priority level, or work through specific items together? We could start with the tenet-cascade tension (F1/F6) or sketch what the web UI intent component might look like.

If you have broader questions about using LID — how to handle this kind of tenet trade-off, when to write a decision doc vs. a Decisions-table row, or how to structure a UI LLD for a thin frontend — I can help with those too.