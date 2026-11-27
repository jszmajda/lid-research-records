**printfarm — LID coach review**

## 1. Executive summary

**Posture:** Clean, well-shaped intent layer; the arrow runs out below EARS, and one tenet is quietly contradicted by the queue's architecture.

**Scorecard**
- ✓ Mutation hygiene — no history residue, no planning text, no `[obsolete]` markers anywhere; these docs read cold
- ✓ LLD granularity — two nodes that each name one real thing, no overlap, `prefix:` frontmatter resolving cleanly to `QUEUE-` / `REG-`
- ✓ HLD discipline — architecture and rationale only; SQLite and the 64 MB limit stay down in the leaves where they belong
- ✗ Arrow completeness — all 8 specs are marked `[x]`, but there are no tests and no code in the repo
- ⚠ Tenet cascade — the in-memory queue works against "a submitted job is a promise" under a condition the same doc describes
- ⚠ Adjacent coherence — the queue↔registry dispatch contract isn't specified on either side

**Headline:** For a two-node project this is unusually disciplined intent — the Decisions & Alternatives tables actually name what was given up and what cost was accepted (FIFO vs. shortest-job-first, slugs vs. UUIDs), which is the hardest habit in LID to build. The highest-value next step is reconciling the in-memory queue with the promise tenet, and then deciding whether the `[x]` markers should come off or the tests should go in.

## 2. Findings (9 total · 3 high · 4 medium · 2 low)

- **F1 (high):** `job-queue-design.md:14` holds the queue "entirely in process memory" and loses undispatched jobs on restart, while the same Context paragraph names unattended OS updates and power blips — under that described condition a member who uploaded and walked away silently loses the job, defeating the tenet *a submitted job is a promise* and the goal *evening upload, overnight print, morning pickup*; no row records the trade · *tenet cascade / keep the arrow coherent*
- **F2 (high):** the dispatch contract between the two nodes isn't specified on either side — `QUEUE-002` fires "when the registry reports a printer idle" and the queue design calls dispatch event-driven, but the registry design only polls on an interval and no `REG-` spec emits or reports idleness; likewise `QUEUE-004` depends on the registry enumerating printers and surfacing current jobs, which no registry spec covers · *coherence is adjacency*
- **F3 (high):** every spec in both files carries `[x]`, yet the repo contains no tests and no code — the Tests and Code phases of the arrow are absent, so nothing cites `QUEUE-*` or `REG-*` and the status markers assert an implementation that can't be walked to · *canonical arrow shape*; *tests carry `@spec` annotations*
- **F4 (medium):** the in-memory, resubmit-on-restart choice has no Decisions & Alternatives row at all — a cold reader would immediately want to reverse it, especially since the sibling node already persists to SQLite on the same box, so the asymmetry reads as accidental rather than chosen · *decision capture* (distinct from F1: F1 is the design concern, this is the missing record)
- **F5 (medium):** `QUEUE-003` has the queue mark a printer "suspect," but printer state is the registry's to own (`printer-registry-design.md:14` lists id, class, address, state) and no `REG-` spec or design line defines `suspect`, what it excludes, or how it clears — substance lodged in one leaf that governs its sibling · *intent attaches at the lowest node that dominates it*
- **F6 (medium):** several stated behaviors have no EARS spec: acceptance requires the target class to have at least one registered printer (`job-queue-design.md:20`), staff *registering* a printer (only retirement has `REG-003`), base32 slug identity and 90-day recycling, and content-hash storage of uploads · *effective intent-tree alignment*
- **F7 (medium):** the three tenets are an unordered list, and two of them collide on exactly the decision in F1 — "a submitted job is a promise" pulls toward durable queue state, "the service stays small" pulls toward memory-only; ordering them tells a future session which way to lean · *tenets capture forward-looking preference*
- **F8 (low):** `QUEUE-001` scopes the 64 MB limit to "when a member uploads" — if staff uploads are also bounded (likely), an agent grepping this spec out of context has no way to tell · *scope disambiguation*
- **F9 (low):** the HLD has Goals and Non-Goals but no success metrics, so "fair access to the popular printer classes" has nothing attached that would say whether it's being met · *HLD is architecture and rationale*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 8 EARS specs (5 `QUEUE-`, 3 `REG-`), 5 Decisions & Alternatives rows
- Arrow-path traced: both segments end-to-end (HLD Architecture → leaf design → specs → tests → code); both terminate at the spec layer
- Linkage metric: 0 `@spec` references; no source or test files present in the repo
- Overlay: `docs/arrows/` absent, so cascade findings come from reading the docs rather than from an index
- Cold-read pass: run over all five LID docs; the one term that doesn't stand on its own is "suspect" (F5)
- Configuration: directives, `- Mode: Full`, and standard directories all present and coherent — no `/update-lid` reconciliation needed

---

Want me to walk through the findings in detail, focus on a theme or priority (F1/F4 are really one conversation, as are F2/F5), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on printfarm — where the web UI fits as a third node, how to handle the specs' `[x]` markers while implementation is still ahead of you, or whether the arrow-maintenance overlay is worth installing at this size — I can help with those too.