Updated:

- `docs/high-level-design.md` — records whole-visit revisions as the selected record-store approach.
- `docs/intent/record-store/record-store-design.md` — now defines immutable revision trees, submission and retrieval contracts, idempotency, competing-head resolution, reopening, and downstream boundaries.

The LLD edge-case probe found these points for your triage before I update the EARS specs:

1. **Concurrent submissions:** Should operations serialize per visit, so the first edit extends the current head and the second creates a competitor?
2. **Head definition:** Should every leaf in the revision tree count as a head, including children created below an existing branch?
3. **Reopening:** After resolution, should an edit based outside the current head produce exactly the current head and new head as candidates, without reactivating old closed branches?
4. **Submission/resolution races:** Should commit order determine validity, with the resolution’s expected-head check rejecting any candidate set it did not inspect?
5. **Idempotency:** Should actor/key reservation be atomic and shared between submissions and resolutions, with equality based on canonical request content rather than raw JSON bytes?
6. **Competing resolutions:** Should the first committed resolution win and later resolutions be rejected because the visit is current?
7. **Retrieval consistency:** Should current-state and history responses each come from one consistent database snapshot?
8. **History ordering:** Should revisions and resolutions share a server sequence number and return complete revision payloads?
9. **Plot identity:** Must every revision of a visit retain the initial revision’s plot UUID?
10. **API errors:** Should the design enumerate response/error shapes now, or leave HTTP mapping to implementation?

Please approve the design and indicate which gaps to settle now versus defer. After approval, I’ll update `record-store-specs.md` and run the EARS consistency and divergence audits.