Done. The decision doc is at `docs/intent/record-store/decisions/concurrency-reconciliation.md`, written to read cold, and linked from the LLD's Decisions row.

It lays out:
- **Context** — why reconciliation is needed and the shared invariants both approaches respect (never discard an original; no combined record exported without coordinator approval), so they don't muddy the comparison.
- **Decision Elements** — weighted criteria, with the two *major* ones tied to tenets (fidelity to whole-visit scientific intent → *inspectable path* + *no inference of scientific intent*; maintenance burden → *no dedicated sysadmin*). Coordinator review workload is called out as the *moderate* criterion that cuts against the choice and keeps field-aware merge live.
- **Options** — both given their strongest honest form. Field-aware merge's real pull is written straight: smaller queue, more visits export-ready, smaller payloads — and why we'd return to it (only if we also accept merge rules that can cross scientific couplings unnoticed).
- **Selection** — whole-visit wins on the two major criteria, chosen with eyes open on the review-queue cost, with the revisit trigger named. The downstream obligations spell out what tablet-sync (track/send base revision, show pending competes, whole visits not change sets) and review-export (whole-visit comparison, hold unresolved out of the CSV, no field-level provenance needed) must accommodate.

We're still at the Phase 2 stop, and the edge-probe gaps from my last message are still open. Before I move to the EARS update (Phase 3), could you triage those — which to pin down in the LLD now vs. defer? The ones most likely to shape the specs:

1. **N-way resolution** — does selecting one competing revision resolve the whole set, or only pairwise?
2. **Editing off a competing (unresolved) revision** — reject, or accept as another competitor?
3. **`currentRevision` while under review** — null/absent vs. last-resolved revision.
4. **Resolution validation** — resolving an already-resolved visit, or selecting a revisionId that isn't a current competitor.
5. **Idempotency scope & "identical payload"** — per-visit or global; whole envelope or just `fields` (touches REC-002/003).
6. **Same-base concurrency** — is acceptance serialized so exactly one edit extends and the rest fork?
7. **Base-presence validation** — first submission carrying a base, or a later one omitting it.

Give me a read on these (even "defer all but 1, 2, 5" is enough) and I'll fold them in, then draft the EARS.