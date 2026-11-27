# LID Coach Review — Field Notes

**Posture:** Bootstrapping — the design layers are real and clean; the arrow stops at EARS while the specs claim otherwise.

**Scorecard**
- ✓ Configuration — mode declared (Full), version pinned, directive present
- ✓ Mutation hygiene — every doc reads clean cold; no history, residue, or changelog tax
- ✓ Tree alignment — one component, one LLD; the SYNC prefix traces cleanly from HLD to spec IDs
- ⚠ Decision capture — the load-bearing conflict rule carries a one-word rationale
- ✗ Verification — no tests and no code exist, while both specs are marked done

**Headline:** The design tree is healthy — a genuine tie-breaker tenet, tight HLD → LLD → EARS traceability, and docs that read cleanly cold; the most valuable next step is reconciling the spec status markers with reality and capturing the conflict-resolution rationale *before* implementation freezes the choice.

---

**Findings (5 total · 3 high · 1 medium · 1 low)**

- **F1 (high):** Both specs carry `[x]` status markers, but the repo contains no code and no tests — whatever the marker means, nothing in the repo defines it, and the natural reading ("implemented") is false · *intent leads; code is compiled output* — specs are the source of truth; the spec layer here asserts a compiled result that was never compiled, and every future session that greps these specs inherits the false claim
- **F2 (high):** The conflict-resolution Decisions row records only "Simpler." against a constraint the same doc states — the LLD's Context says device clocks are wrong by minutes, yet the row doesn't say what was given up or what cost was accepted · *docs carry current intent* — decision capture: a cold reader would immediately question this choice and the row leaves them unable to reconstruct the trade
- **F3 (high):** SYNC-002's winner rule leans on the exact clock the LLD declares unreliable — a fast-clock device's edit can deterministically discard the actually-later edit, losing field data through the system's core reconciliation path · design concern surfaced by the decision review — and note the *boring over clever* tenet doesn't rescue it: service-side receive timestamps or a per-note version counter are equally boring, so the tenet's "unless decisively better" carve-out may even point at them
- **F4 (medium):** The conflict rule leaves edges open — identical wall-clock timestamps have no defined winner, and upload/merge failure semantics are unspecified · *LLDs close enough of the solution space* — two reasonable agents would implement different tie-breaks, which is exactly where intent drift enters
- **F5 (low):** HLD coverage is thin — no target users, success metrics, or key-design-decisions sections · *HLD is architecture and rationale* — the *why* that outlives any implementation is thinner than it could be

---

**What was audited**
- Read fully: 100% of the repo — CLAUDE.md, docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md
- Enumerated: 1 LLD, 1 spec file, 2 EARS IDs (SYNC-001, SYNC-002), 0 `@spec` annotations (no code or tests exist to annotate)
- No arrow overlay present (`docs/arrows/` absent); at four files, sampling was exhaustive rather than strategic
- Cold-read pass and Decisions-table sweep run on every LID doc; the SQLite row passes the sweep, the LWW row does not

---

**Defaults taken (non-interactive run):** the skill's advisory posture held — no file changes were made, even though the run requested them; the coach surfaces recommendations for you to apply (configuration changes → `/update-lid`; F1–F4 → direct doc edits, or the linked-intent-dev workflow when you start the tests-first phase for F1). The report renders inline rather than persisted to disk. No dispatch questions arose: the project is fully configured, so a full review ran.

---

Want me to walk through any finding in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into — F2/F3 together would be my suggested starting point.

If you have broader questions about using LID for this project — when to add the tests-first phase, how the arrow overlay fits in as the project grows, what a second intent component should look like — I can help with those too.