**LID Coach — Field Notes**

**Posture:** Bootstrapping — the arrow skeleton is real, but content is sparse and one live design concern sits unaddressed.

**Scorecard**
- ✓ Configuration — Full mode declared; `docs/intent/` and HLD present; directive block coherent
- ✓ Linkage — one LLD, one spec file, `SYNC` prefix resolves cleanly to the leaf
- ✓ LLD granularity — one component, one design doc; right-sized for the project
- ⚠ HLD discipline — architecture is a single line; target users, success metrics, and key decisions are absent
- ⚠ Arrow completeness — EARS exists, but no Tests or Code phase is evidenced anywhere
- ⚠ Design coherence — conflict handling leans against the project's own clock-skew fact and convergence goal

**Headline:** The spec-to-LLD skeleton is clean and traceable; the highest-value next step is resolving the last-writer-wins-by-wall-clock decision, which currently contradicts the clock-skew condition the LLD itself names.

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** SYNC-002's wall-clock LWW lets a device with a several-minute-off clock overwrite a genuinely newer edit — under the clock-skew condition the LLD documents, it defeats the "convergent state after reconnect" goal · *tenet cascade* (design nodes should lean the way the HLD's goals say)
- **F2 (high):** the conflict-resolution Decisions row ("Last-writer-wins by device wall-clock — Simpler.") leaves a cold reader unable to reconstruct what was traded away, especially against the stated clock skew · *docs carry current intent* (decision capture)
- **F3 (medium):** Tests and Code phases are absent from the repo; the two specs are not exercised by anything · *canonical arrow shape* / *tests before code*
- **F4 (medium):** the LLD leaves edges open — "merges them into the canonical store" is unspecified, as is behavior when upload or merge fails · *LLDs close enough of the solution space*
- **F5 (medium):** the non-conflict merge behavior has no spec of its own; only upload and conflict resolution are governed by EARS · *effective intent-tree alignment*
- **F6 (low):** the HLD omits target users, success metrics, and key design decisions, and its Architecture section is one line · *HLD is architecture and rationale*
- **F7 (low):** `[x]` status markers in `sync-specs.md` have no legend, and `Field Notes`/`central service` are named but never defined · *docs carry current intent* (cold-read)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file, 2 specs (`SYNC-001`, `SYNC-002`), 0 arrow segments
- Sampled: code and tests — none present in the repo (single `fixture` commit, no source tree)
- Linkage metric: 0 `@spec` references; 2 unique spec IDs

Want me to walk through the findings in detail, focus on the conflict-resolution concern first, or work through specific items together?

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, or what to do when a segment grows too large — I can help with those too.

*Defaults taken: Full mode (declared), report rendered inline and not persisted, no files edited (advisory posture).*