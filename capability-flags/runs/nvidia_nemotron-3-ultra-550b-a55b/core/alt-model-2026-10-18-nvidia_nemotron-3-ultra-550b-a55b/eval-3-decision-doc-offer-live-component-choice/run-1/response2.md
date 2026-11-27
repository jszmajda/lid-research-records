Done — the decision is now written up with full rationale, why field-aware merge was credible but rejected, and what tablet-sync and review-export must accommodate.

Now back to the **Phase 4 edge audit**. Before I proceed to tests, please resolve these forks:

### Cross-spec / Cross-segment

1. **REC-007 vs REC-011 race**: Two submissions for same base arrive concurrently. Tie-break rule?
   - A: First-write-wins (serializable transaction), second gets rejected with "rebase required"
   - B: Both accepted into same cycle (optimistic), cycle now has 3 competing revisions
   - C: Both rejected, both workers must re-fetch and re-edit

2. **REC-010 cycle definition**: "competing revisions already exist for that base"
   - A: Same `base_revision_id` only (per LLD cycle definition)
   - B: Any open cycle for the `visit_id` (broader grouping)

3. **REC-012 resolution base**: "latest resolved revision" — if cycle base is R1 but R2 exists (from earlier cycle), resolution base = R2. Coordinator must see R2 when resolving R1's cycle. Confirm?

4. **REC-018 partial resolution**: Cycle has 3 competing revisions; coordinator resolves 2. Third remains `competing` → cycle stays open. Allow partial resolution?
   - A: No — resolve all or none (cycle is atomic)
   - B: Yes — each revision resolved independently, cycle closes when last is superseded

5. **Tablet-sync return on acceptance**: Server must return new `revision_id` and current cycle state (competing count, base). Add to specs?

6. **Export eligibility**: REC-016 (resolved + open cycle = flag) vs REC-019 (no resolved + open cycle = no current state). Which visits enter CSV?
   - A: Only visits with resolved revision AND no open cycle
   - B: Visits with resolved revision (open cycle = flag but export allowed with warning)
   - C: Coordinator decides per visit at export time

### Per-spec forks

7. **REC-007 "at submission time"**: Reading A (request receipt), B (transaction commit), C (MVCC snapshot)?
8. **REC-015/016 current visit with open cycle**: Reading A (latest resolved + flag), B (404), C (only if cycle base matches latest resolved)?

Reply with choices (e.g., "1=A, 2=A, 3=yes, 4=A, 5=yes, 6=A, 7=B, 8=A") or clarifications. I'll then narrow the specs and LLD.