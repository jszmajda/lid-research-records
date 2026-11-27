I've expanded the decision documentation and downstream contract obligations. The updated LLD now includes:

## Decision Documentation (Expanded)

**Chosen approach**: Whole-visit revisions with full rationale including why field-aware merge remains credible but was rejected for this project.

**Key trade-off**: Larger manual review queue vs. risk of silently combining scientifically related edits.

**Why field-aware merge was considered**: Would reduce coordinator workload and get more visits export-ready faster through automatic merging of unrelated field edits.

**Why rejected**: Cannot reliably infer scientific relationships between fields (species ID + cover estimate are separate fields but botanically coupled), risk of combining conflicting field assessments, team's explicit preference for manual review over automated merge risks.

## Downstream Obligations (Expanded)

**Tablet-sync must**:
- Track revision IDs locally for base revision ID population
- Handle unresolved states and delayed conflict discovery during offline work
- Present resolution outcomes when visits return to resolved state
- Note: Simpler than field-aware merge would require (complete snapshots vs. field-level deltas)

**Review-export must**:
- Provide coordinator queue with side-by-side revision comparison
- Support resolution submission workflow
- Apply binary export eligibility (clean/resolved = exportable, unresolved = blocked)
- Display resolution metadata for transparency
- Note: Binary eligibility vs. the field-level provenance field-aware merge would require

The contrast between the chosen approach and the alternative now shows up in both the decision rationale and the downstream implications.

**Edge-case gaps**: Still need your triage on the probe findings. Which should I resolve in this LLD vs. defer?