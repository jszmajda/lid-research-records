Done — `docs/intent/record-store/decisions/concurrent-visit-edit-policy.md` is written and linked from the LLD's Decisions row. Here it is:

---

# Decision: Concurrent Visit Edit Policy

## Context

Field workers capture visit records offline and edit independently. The same visit can be corrected by more than one worker after they compare field notes, and submissions can arrive days after the state they started from was fetched. The server cannot treat arrival order as evidence that one worker's observations are more authoritative, so it needs a policy for how independently based edits become a single current record.

The policy is load-bearing beyond this node: it fixes the metadata each submission must carry, the shape of the review work a coordinator sees, and which visit states can enter the partner's Friday CSV. Tablet-sync's local state machine and review-export's coordinator interface are both sized around it.

An invariant holds across every option and is therefore background, not a criterion: no submitted edit is silently discarded. Whatever the policy, every accepted submission remains stored and inspectable.

## Decision Elements

**Weighted criteria** (importance in parentheses):

- **Whole-visit integrity — the submitted visit remains the reviewable unit** (major). Derived from the tenet that a submitted edit is not discarded and the path from a submitted observation to an exported value stays inspectable. A policy that dissolves the worker's visit into field-level pieces makes each exported value harder to trace back to a single reviewer decision.
- **Coordinator review workload** (major). Derived from the tenet that two coordinators operate the workflow without a dedicated systems administrator. The policy decides how much conflict each independent edit generates.
- **Scientific safety and rule-maintenance burden** (major). Derived from the non-goal of inferring scientific intent. A policy that combines fields automatically risks merging edits that are scientifically related — for example a revised species identification and its cover estimate — through rules that do not understand the relationship; it also obliges the team to maintain those rules.
- **Share of visits exportable without review** (moderate). Derived from the goal of making reviewable problems visible before the Friday export: the more visits a policy leaves clean, the smaller the pre-export crunch.
- **Implementation and per-submission data burden** (moderate). The concurrency logic the server and tablets must carry, and the size of what a tablet stores per in-progress visit.
- **Latent criterion — peak-season coordinator throughput** (major). The team submits roughly 6,000 visit records per season with up to 48 hours offline. A policy that routes a large share of independent edits to review can exceed what two coordinators can clear in a week, regardless of how safe each review is.

## Options in the Domain

### Whole-visit revisions

**Description.** Every submission carries the complete visit and names the base revision it started from. Two submissions derived from the same base become competing complete revisions. The server keeps a revision tree per visit: a visit is resolved when it has exactly one open tip (the current revision) and unresolved when it has more than one. A coordinator resolves a visit by selecting one competing revision as current and setting the others aside; all submissions remain stored. The server never compares payload fields, so it needs no merge rules. Tablets retain the revision ID they last received and attach it as the base of their next submission.

**Analysis.**

- Whole-visit integrity: **strong** — each competing revision is exactly what a worker submitted; nothing is composed across submissions.
- Coordinator review workload: **weak** — any submission whose base is not the current revision creates review work, including edits to unrelated fields.
- Scientific safety and rule-maintenance burden: **strong** — there are no merge rules that could combine scientifically related edits, and none to maintain.
- Share of visits exportable without review: **weak** — every competing set is held out of the export until a coordinator resolves it.
- Implementation and data burden: **strong** — submissions already carry the complete visit; the server adds only revision linkage and resolution bookkeeping.
- Peak-season throughput: **weak** — the review queue grows with every independently based edit.

**Summary.** Maximizes whole-visit integrity and minimizes maintenance, at the cost of a larger review queue.

### Field-aware three-way merge

**Description.** Every submission carries a base snapshot and a structured set of field changes rather than a whole visit. The server combines changes to disjoint fields automatically into a current record; changes to the same field from the same base become review work. This requires maintained merge rules for each field shape — scalar fields, the observer list, and species entries — that decide what "disjoint" and "same field" mean. Tablets retain base snapshots and send diffs. Review-export needs per-field provenance and a review view that shows only overlapping changes.

**Analysis.**

- Whole-visit integrity: **partial** — per-field provenance is retained, but the worker's submitted visit is no longer the unit of record; an exported value may be a composition the worker never saw.
- Coordinator review workload: **strong** — edits to disjoint fields need no review, so most independent corrections resolve automatically.
- Scientific safety and rule-maintenance burden: **weak** — rules that treat a revised species identification and its cover estimate as independent fields will combine them silently, and the rule set for scalars, observer lists, and species entries must be maintained as fields evolve.
- Share of visits exportable without review: **strong** — automatically combined visits enter the export without a coordinator touching them.
- Implementation and data burden: **weak** — base snapshots, diffs, and three-way merge logic on the server; more local state on tablets.
- Peak-season throughput: **strong** — a much smaller share of edits reaches the queue.

**Summary.** Reduces review volume and raises export readiness, at the cost of maintained merge rules that can combine scientifically related edits without noticing.

## Selection

**Whole-visit revisions.** The decision turns on the tenet that a submitted edit stays inspectable as submitted and the non-goal of inferring scientific intent. On the two high-importance criteria that carry that intent — whole-visit integrity and scientific safety — whole-visit revisions are strong and field-aware merge is partial and weak respectively. Field-aware merge wins the coordinator-workload and throughput criteria, and the choice accepts that cost knowingly: the queue grows, but every item in it is a complete visit a coordinator can rule on, and the team keeps no rule set that could merge a species revision with an unrelated cover change.

The choice is taken partly *against* the review-workload tenet: whole-visit revisions load the two coordinators more heavily than field-aware merge would. That is acceptable because the queue is visible and safe, whereas the merge rules' failure mode is silent.

**What it forecloses.** Automatic combination of disjoint edits; any field-level merge-rule maintenance; field-level provenance as a merge input (submission history is still retained, but not used to compose records).

**Downstream obligations.**

- **Tablet-sync** must retain the revision ID of the last state it received as the base for its next submission; attach that base to every submission; reuse an idempotency key across retries of one edit; and render the unresolved outcome, showing the worker that their visit is pending coordinator review rather than silently replacing local state.
- **Review-export** must provide a revision comparison screen that shows competing revisions side by side; key export eligibility on the visit's resolution state so unresolved visits are held out of the Friday CSV; and record the coordinator's identity and the set-aside submissions when a resolution is made, so the exported value traces to a human decision.
- **Record-store** owns the revision tree, the resolution operation, and the resolution-state boundary both sibling nodes consume.

---

**Back at the Phase 2 stop.** The LLD is otherwise as shown in my previous message, now with the decision-doc link. Two things still need your ruling before I go to Phase 3:

1. **Triage the 9 edge-probe gaps** — for each, say "fix in LLD" or "defer to Open Questions". Several look worth fixing now (the loser-of-a-race outcome, the superseded-sibling base row, idempotency-key scope, error/response shapes). My recommendation: fix gaps 1–4, 6, 8, and 9 in the LLD; defer 5 and 7.
2. **Approve the LLD** so I can update the EARS specs (Phase 3), apply the triaged fixes, and flip the HLD's stale "concurrency choice open" state.