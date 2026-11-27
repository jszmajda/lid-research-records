Drafted the whole-visit revision design in `docs/intent/record-store/record-store-design.md` and updated `docs/high-level-design.md`.

The design now defines:

- Immutable complete revisions and a per-visit active frontier.
- `settled` versus `unresolved` states and all submission transitions, including late post-resolution edits.
- Submission and resolution idempotency.
- Coordinator resolutions that may select or correct a complete visit while preserving every candidate.
- Exact-candidate-set checks to prevent unseen submissions from being resolved accidentally.
- Retrieval contracts, deterministic history, machine-readable errors, and atomicity invariants.
- Downstream obligations for tablet-sync and review-export without designing those nodes.

An independent edge-case probe examined frontier races, resolution lineage, retries, and read consistency. I incorporated its contract-correctness findings. Two intent decisions remain:

1. **Plot identity:** May later revisions correct a visit’s plot UUID, or is it fixed at creation? I lean toward allowing corrections because the immutable history retains the original reference.
2. **Worker access:** May every authenticated worker read and edit every visit? I lean toward yes, given the shared tablets and collaborative corrections, unless you need ownership boundaries.

Please answer those two questions and approve the LLD or request changes. After approval, I’ll proceed to the record-store EARS updates; tablet-sync and review-export remain untouched.