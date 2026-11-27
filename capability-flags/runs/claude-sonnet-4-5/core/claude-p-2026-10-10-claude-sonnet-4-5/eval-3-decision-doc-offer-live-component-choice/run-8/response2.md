I've expanded the design with thorough rationale and downstream obligations:

## Decisions & Alternatives

The table now explains:

- **Why field-aware merging would be considered**: It would reduce review queue volume and get more visits export-ready faster.

- **Why it was rejected**: A worker correcting a species identification and its cover estimate together has coupled scientific intent. Automated field merging could combine one worker's species correction with another's unrelated observer-name fix, producing a record no one actually observed. The merge rules would need botanical domain knowledge to understand which field edits are scientifically related.

- **When to reconsider**: If review queue volume threatens the Friday export deadline, or if coordinators develop trust in maintained merge rules that respect scientific relationships.

- **Other alternatives explored**: Synthesized revisions (loses "this is what a worker observed"), automatic timestamp selection (treats arrival order as authority, which the problem rejects), automatic author seniority (team has no hierarchy).

## Downstream Accommodations

Now explicit about what each downstream node must handle:

**Tablet-sync** must track base revision IDs in local storage, explain unresolved state to field workers in understandable terms ("Your edit is one of N competing versions awaiting coordinator review"), and handle retry scenarios where both tablets submit concurrently before either sees a response.

**Review-export** must build a side-by-side comparison UI showing full field values (not diffs, since scientific meaning requires whole-visit context), proactively surface unresolved visits before export ("12 visits awaiting resolution"), and exclude unresolved visits from the CSV even when both competing revisions might be scientifically identical.

**Consequences are explicit**: Coordinators trade their labor for preservation of whole-visit scientific intent. A worker fixing observer names while another adds species notes creates review work that field-aware merging would have auto-resolved.

The design now reads as a complete justification that tablet-sync and review-export authors can build against, understanding both what they must accommodate and why the alternative wasn't chosen.