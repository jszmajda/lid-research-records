I agree — it earns one. The test isn't that it was hard to argue about; it's that after it lands, a cold reader still has reason to reopen it: the hot-queue share will have to be tuned during the pilot, and "why 2Q when LRU is cheaper and adapts faster?" is exactly the question a row can't answer. So I wrote it.

**New:** `docs/intent/previews/decisions/cache-replacement-policy.md` (frontmatter `node: previews`, no EARS IDs), linked from the replacement-policy row of the LLD's Decisions table.

How it's built:
- **Context** — the screening-vs-comparison split and the shared 24-editor cache; what's at stake if the policy is wrong.
- **Decision Elements** — three inherited gates (12 GiB bound, fixed interface and render queue, private bookkeeping — all of which eliminate nothing) and six weighted criteria: protection of reused sheets (major), isolation between editors, adaptation after a workload shift, per-request bookkeeping cost, structural simplicity, metadata footprint.
- **Options in the Domain** — LRU, aged frequency, 2Q, each given its strongest honest case, then a per-element verdict (passes/eliminated; strong/partial/weak).
- **Selection** — 2Q wins on the major criterion; LRU is admitted as stronger on adaptation and 2Q is only moderate there, with that cost stated plainly rather than smoothed over. It also records what committing forecloses (pinning, per-editor quotas, self-tuning) and obliges (sizing the hot share and ghost list; revisiting if the pilot says comparison sets are small).

One transparency note: I added **isolation between editors** as a criterion — a shared cache means one editor's scan competes with another's comparison set, and neither LRU nor frequency handles that well. It's latent criterion the earlier framing hadn't named, and it strengthens 2Q rather than changing the outcome.

**Still open from before, and now baked into the doc as written** (tell me if any changes and I'll update the doc, the LLD, and the specs together):

1. **No landing target for Phases 5–6** — the repo holds only intent docs, no worker source or test harness, so there are no tests or code to write and every PREVIEW spec stays `[ ]`. Does the worker live in another repo, or should I build it here?
2. **Hot-queue share** — starting at 25% of the 12 GiB budget (3 GiB), marked for retuning.
3. **Ghost-list scope** — classic 2Q: only cold-queue evictions are recorded, so a sheet evicted from the *hot* queue and later re-requested would re-enter the cold queue one step down.
4. **Hot-queue overrun** — demotion to the cold queue's tail rather than outright eviction.

And one offer: the HLD has no tenet covering this class of choice, which is why the decision doc had to state its principle inline. A candidate — *"When a cache must choose what to keep, prefer the work an editor is likely to return to over the work it has just finished"* — has a defensible opposite, so it qualifies as a tenet rather than a platitude. Want me to add it to the HLD's Tenets?