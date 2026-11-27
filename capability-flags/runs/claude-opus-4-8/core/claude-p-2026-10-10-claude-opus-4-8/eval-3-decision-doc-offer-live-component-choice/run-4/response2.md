Done — the decision doc is written and linked.

## `docs/intent/record-store/decisions/concurrency-model.md`

- **Context** frames the problem from the domain (independent field corrections, the structural-vs-scientific ambiguity the server can't resolve), not from our conversation.
- **Decision Elements** are weighted criteria (no gate — both options honor the "never discard" invariant, so it's background). The two majors are *never silently combine* (turns on the no-inferring-scientific-intent non-goal) and *inspectability*. I surfaced one latent criterion that cuts against our choice — **reviewer effort per item** — and recorded it honestly.
- **Options** gives each its strongest honest form. Field-aware merge is described as its advocate would: base snapshot + structured diff, auto-combine disjoint fields, conflicts pre-narrowed with field-level provenance — and it legitimately wins *review workload* and *reviewer effort per item*.
- **Selection** says plainly that whole-visit wins the majors while *conceding* the workload costs, names the tenets/non-goal it turns on and the one it's taken against, and includes a **"why the merge approach stays live"** paragraph (binding review volume, or a safe field subset → a hybrid) so a future reader knows when to re-run the judgment.
- **Downstream obligations** spell out, as cascade notes, what tablet-sync must accommodate (retain `baseRevisionId`, submit whole payloads, surface the unresolved outcome without implying loss) and what review-export must accommodate (revision-comparison screen, resolution record of coordinator + contributing revision IDs + outcome, hold unresolved visits out of the CSV).

The LLD's Decisions & Alternatives row now points to it.

## Still open from the Phase 2 stop

We're still at the LLD review before Phase 3 (EARS). I still need from you:

1. **Probe triage** — especially the three genuine forks: (1) fork-detection referent while unresolved, (2) chained edits / basing off a dead revision during the unresolved window, (3) duplicate roots & visitId/plot identity. And how far to take resolution mechanics, idempotency-comparison scope, error shapes, and plot-binding/authorization (items 4–7) vs. defer them.
2. **HLD cascade** — OK to update the HLD's record-store status line and the "must wait for its contract" prose to reflect the settled choice?

Once you've triaged the forks and I've folded the decisions into the LLD, I'll move to Phase 3. Tablet-sync and review-export stay parked until record-store is done.