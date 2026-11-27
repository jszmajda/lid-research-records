My recommendation is not to write one, and I'd keep the Decisions & Alternatives row we have.

**Why not**
- **Scope:** the choice is contained inside the preview cache. The HTTP interface, the render queue and the review API are unchanged for all three options, so no other design node is sized around the result.
- **What a reader needs:** for a cold reader, the question is "why 2Q and not LRU?". The row answers that in one line, naming the scan-versus-comparison workload and what each rejected option costs.
- **The debate length:** a long argument doesn't make a doc worth having. The test is whether a reader of the landed design would be tempted to reverse the choice without the competing options in front of them. With the workload mix stated in the row, I don't think they would.
- **Doc churn:** decision docs are kept rare on purpose, and one that restates the row mostly adds a file to keep current.

**What would change my mind**
- You expect to revisit the policy once pilot traffic exists, and want the criteria and the data that would trigger a revisit written down. That is a live decision, and a doc earns its place there.
- The three meetings and the thread surfaced criteria or constraints that aren't in the row (a stakeholder concern, a cost or ops limit, a workload number). Those are lost if we only keep the one-liner.

**Middle path:** I can enrich the existing row, or add a short "revisit when" note under Open Questions, without a standalone doc. For example: "revisit if the probation hit rate stays low or editors report evicted comparison sheets". That keeps the re-evaluation trigger on the page at low cost.

If you still want the full doc, I'll write it. It's your call, and I'd put it in `docs/intent/previews/decisions/` and link it from the Decisions row. It would take the structure in `references/decision-doc-template.md`: context, criteria, the three options, the selection, and a fit verdict.

Which do you want: row only, row plus a revisit trigger, or the full doc? Separately, the two forks from before (promotion on a second probation hit, and the 25% / 3,072 starting values) still need your ruling before I move to specs.