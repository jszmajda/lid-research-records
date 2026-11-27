**Field Notes — LID coaching review**

### Executive summary

**Posture:** Cleanly shaped through EARS — downstream phases and one mechanism need tightening.

**Scorecard**
- ✓ Configuration & linkage — directive block and `- Mode: Full` present; `SYNC` prefix matches the LLD's `prefix:`, IDs are stable and grep-friendly
- ✓ LLD granularity — one leaf for one intent component; no lumping or scatter
- ⚠ HLD content — architecture is a single line; key design decisions, success metrics, and target users are absent
- ⚠ LLD sufficiency — the merge path is described only for one conflict case
- ✗ Design coherence — the conflict rule works against the clock-skew condition the same doc names
- ✗ Arrow completeness — specs are marked done with no tests or code beneath them

**Headline:** The arrow is well-shaped and easy to walk through EARS, with a history-free HLD and a well-scoped single LLD; the highest-value next step is resolving the conflict rule's contradiction with the clock-skew context before tests and code get built on it.

### Findings (6 total · 2 high · 3 medium · 1 low)

- **F1 (high):** Conflict handling keeps the later *device wall-clock* edit, while the LLD's own Context says device clocks are frequently wrong by minutes — under that named condition it can discard the genuinely later edit and works against the "Convergent state after reconnect" goal · *coherence is adjacency* (each level agrees with its neighbor) and *tenet cascade* (design mechanisms should lean the way goals say to)
- **F2 (high):** Specs SYNC-001/002 are marked `[x]` as done, yet no tests cite them and no code exists anywhere · *canonical arrow shape* (HLD → LLD → EARS → Tests → Code) and *tests carry `@spec` annotations*
- **F3 (medium):** The `Conflict resolution` row reads only "Simpler." — a cold reader holding the Context would still question the choice, and the row records neither the alternative nor the data-loss cost accepted · *docs carry current intent* (decision capture)
- **F4 (medium):** The LLD specifies only the two-devices-offline case; "the sync service merges them into the canonical store" leaves upload, deletion, equal-timestamp ties, and central-service edits open · *LLDs close enough of the solution space*
- **F5 (medium):** The HLD has no Key Design Decisions, success metrics, or target users, and its Architecture section is one sentence · *HLD is architecture and rationale*
- **F6 (low):** The `[x]` status markers have no legend, so a cold reader cannot tell approved intent from implemented behavior · *docs carry current intent, written to be read cold*

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file, 2 spec IDs, 0 arrow segments (no `docs/arrows/` overlay)
- Code/test surface: 0 code files and 0 test files in the repository; 0 `@spec` references found
- Arrow-path sampled: the single SYNC segment, end-to-end as far as artifacts exist (HLD → LLD → EARS; Tests and Code absent)
- Sampling note: project is below the threshold that would require `references/sampling.md`

Want me to walk through any of these in detail, focus on the cascade/coherence findings, or work through one item together?

If you have broader questions about using LID here — where tests fit when code doesn't exist yet, how much to put in the HLD versus the LLD, or how to record a contested decision — I can help with those too.

---

*Defaults taken for this non-interactive run: full-mode review (per the declared `- Mode: Full`), advisory posture with no file edits, report rendered inline and not persisted, and no follow-up conversation started.*