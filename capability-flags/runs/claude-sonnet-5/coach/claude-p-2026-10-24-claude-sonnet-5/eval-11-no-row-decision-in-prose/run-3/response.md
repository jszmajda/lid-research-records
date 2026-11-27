## LID Coach Review — printfarm

**Posture:** Clean skeleton, one real tension underneath it. The arrow is small but genuinely coherent at the doc level — and it already surfaced the kind of conflict LID exists to catch.

**Scorecard**
- ✓ Linkage — `QUEUE-*` / `REG-*` IDs are grep-anchored, no collisions, no facet weirdness across all 8 specs
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` residue, docs read as live intent
- ✓ HLD discipline — architecture and rationale only; no schemas or request shapes leaked upstream
- ⚠ Tenet cascade — the in-memory queue's restart behavior pulls against the "upload and walk away" tenet, and nothing records that trade
- ⚠ Tenet ordering — three tenets, unordered, and the tension above is exactly the kind that ordering would resolve
- ✗ Arrow completeness — every spec is marked `[x]` (implemented), but there is no test or code file anywhere in the project

The two-node split (job-queue / printer-registry) is well-drawn, the Decisions & Alternatives rows are tight and specific (slug recycling, 64 MB cap, 15s heartbeat — each with a named cost), and nothing here smells like accumulation. The fastest win is resolving what the `[x]` markers mean before more specs get added under the same assumption.

**Findings (4 total · 2 high · 2 medium)**
- **F1 (high):** `job-queue-design.md`'s own Context names unattended restarts and power blips as a real operating condition, under which un-dispatched jobs are silently dropped and members must resubmit — in tension with the HLD tenet "a submitted job is a promise: members should be able to upload and walk away" · *tenets capture forward-looking preference* / tenet cascade
- **F2 (high):** All 8 EARS specs (`QUEUE-001`–`005`, `REG-001`–`003`) carry the `[x]` implemented marker, but no test or code file exists anywhere in the repo · *coherence is adjacency*
- **F3 (medium):** The in-memory, non-persistent queue is a consequential design choice (it's the direct cause of F1) but has no Decisions & Alternatives row naming the durability trade-off or the tenet it costs · *docs carry current intent* (decision capture)
- **F4 (medium):** The HLD's three tenets are an unordered list, but tenet 1 (promise/durability) and tenet 3 (mini-PC stays small/simple) can genuinely pull opposite ways — F1 is a live example — so there's no stated lean for resolving that class of conflict · *tenets capture forward-looking preference*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`job-queue-design.md`, `printer-registry-design.md`), both spec files (`job-queue-specs.md`, `printer-registry-specs.md`)
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs total, 0 test or code files found in the repository
- No arrow-maintenance overlay present (`docs/arrows/` absent) — not required for a project this size

Want me to walk through any of these findings in more detail, or work through one together (e.g. how to decide between persisting the queue vs. updating the tenet)? I can also help with broader LID questions — like how to handle status markers in a project that's still pre-code, or when to introduce the arrow-maintenance overlay as this grows.