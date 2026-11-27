The decision doc is written and linked.

## `docs/intent/record-store/decisions/concurrent-visit-edits.md`

It's built to be re-run cold:

- **Context** frames the problem from the domain (divergent submissions, visit-as-one-observation, no botanical inference), and notes that *retaining all originals* is a floor both options clear — so it's background, not a deciding criterion.
- **Decision Elements** — six weighted criteria, each tied to the tenet or goal it turns on. The three *major* ones (no silent combining of coupled edits; whole-visit fidelity; inspectability) are where the options actually diverge; the three *moderate* ones (review volume, Friday readiness, maintenance burden) are surfaced precisely because they cut **against** the choice we made.
- **Options in the Domain** — both given their strongest honest form, with a worked example each and a per-criterion verdict. Field-aware merge is described as its advocate would (auto-combine disjoint fields, review only true overlaps), and its weakness is stated factually: "disjoint" means field identity, not scientific coupling.
- **Selection** — whole-visit wins on the major criteria, and the doc says plainly what it costs: weak on review volume, partial on Friday readiness, accepted knowingly. It names **when field-aware merge is worth reconsidering** (coordinator volume proves unsustainable *and* a trustworthy coupling model emerges), and spells out the downstream obligations:
  - **tablet-sync**: track + send the base revision per edit, keep each visit whole, explain the current-vs-competing outcome to the worker — no structured field changes, no merge state.
  - **review-export**: whole-visit comparison of current vs. competing revisions (not a field-merge view), carry the coordinator's selection into resolution, hold unresolved visits out of the Friday CSV.

## Still open from the last turn

You answered the decision-doc offer; these two are still waiting before I go to specs:

1. **Edge-case triage (a–d).** Which of these to fold into the LLD now vs. defer: **(a)** idempotency equality definition + key scope, **(b)** whether open competitors re-anchor when current advances, **(c)** resolution error shapes / is selecting the already-current revision a valid no-op, **(d)** whether a genuine fast-forward arriving after competitors exist is demoted to competing (current stays frozen until resolution).

2. **HLD cell.** OK to change record-store's State from "Drafted; concurrency choice open" to "Drafted; concurrency contract defined"?

Once I have those, I'll draft the EARS specs (Phase 3).