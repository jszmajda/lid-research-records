Agreed — and worth being precise about *why*, because the strength of the case is in the landed state, not in the length of the argument.

Two readers are foreseeable. The first sees three structures and a ghost queue and asks "why not LRU with one queue?" — the landed LLD's one-line rationale doesn't give them the criteria that made that trade, so they re-litigate it. The second tunes the budget split during the pilot and has to re-ask whether the extra bookkeeping is earning its keep, with no record of what 2Q beat and on what grounds. The doc also preserves the reasoning that shapes the spec set rather than just the queue names: LRU is *eliminated* by a gate (a screening pass displaces the comparison sheets), not merely outscored, and aged frequency fails on adaptation — it needs an aging horizon, and a mis-tuned horizon is hard to read from production behavior.

So I wrote `docs/intent/previews/decisions/cache-replacement-policy.md`, owned by the previews node (`node: previews`, no EARS IDs):

- **Context** — the two editor rhythms, the asymmetric stakes, and the inherited constraints (fixed 200/202/404 interface, four-job render queue, private bookkeeping). It also records that allowing callers to pin a sheet was excluded by those same constraints, which is *why* the policy alone has to carry the burden.
- **Decision Elements** — two gates (comparison sheets must survive a one-off screening pass; no per-request state may outlive a sheet's usefulness) and five weighted criteria, each with an importance, with the protection criterion naming the HLD tenet it turns on.
- **Options in the Domain** — LRU, aged frequency, and 2Q, each given its strongest honest representation, then analysed element by element with verdicts.
- **Selection** — 2Q, with what it forecloses (the simplest available cache; a future one-queue move is a *reversal*, not a simplification) and what it obliges downstream.

One thing I deliberately left out: the current split numbers. The doc says the split and ghost depth are parameters to be tuned against pilot behavior, so it stays correct whichever way you answer the split question below.

Still open from before, since you didn't get to them:

1. **Budget split** — 3 GiB first-use / 9 GiB hot as documented; keep, or 50/50, or 90/10?
2. **Reuse signal** — counted in cache retrievals, excluding the delivery of a freshly rendered sheet and pending-ticket retries. Confirm, or require the retry to carry the job ticket (which would change the review API's forwarding contract)?
3. **Phases 5–6** — the repo has no worker source and no test setup, so all 22 specs sit unimplemented. Scaffold the worker (which language?) or hold at design-only?