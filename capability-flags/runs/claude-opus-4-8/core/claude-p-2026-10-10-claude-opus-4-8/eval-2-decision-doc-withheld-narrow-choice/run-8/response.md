Phase 2 LLD draft is written to `docs/intent/previews/previews-design.md`. **Stopping here for your review before I touch EARS (Phase 3).** Four things to look at:

## 1. What landed
The `## Private Cache` section now specifies 2Q concretely: three private structures — **A1in** (FIFO, first-sighting bytes), **Am** (LRU, reused bytes), **A1out** (FIFO ghost list of keys only). Admission routes to Am on an A1out hit, else A1in; reclaim evicts A1in's tail into the ghost list first, falling back to Am's LRU tail. A new **Decisions & Alternatives** table records 2Q against the rejected LRU and aged-frequency options, and **Open Questions** holds the two deferred items.

## 2. Edge-probe gaps (your triage — fix in LLD now vs. defer)
These are the component-internal gaps the 2Q design opens:

1. **A1in-resident hit does not promote.** I wrote the standard 2Q reading: a sheet counts as "reused" only after it's evicted and re-requested via A1out — a hit *while still in A1in* leaves it in place. This is deliberately what resists a scan, but it means a clip touched twice in quick succession (before eviction) stays demotion-eligible. **Confirm this reading** — the alternative (promote on any second reference) is simpler but lets a scan that double-touches sheets leak into Am. I recorded "no promotion" as the decision; tell me if you want the opposite.
2. **A1out membership is read at admission time**, not enqueue time. If a key is evicted into A1out while its render job is already pending, the completed sheet still lands in Am. I stated "evaluated at admission time" — flagging in case you want it pinned at enqueue instead.
3. **Restart loses queue state** (deferred #2). All sheets re-enter as first sightings after a worker restart. Fine under the "cache is not authoritative" tenet, but confirm you're happy deferring persistence.

(A sheet larger than the A1in sub-budget is handled by the "repeat until it fits" loop spilling into Am eviction — not a real risk at ~2 MiB sheets vs. a 3 GiB sub-budget, so I left it implicit.)

## 3. Decision-doc offer
This choice clears the bar for a standalone decision doc: three credible options traded against several criteria (bookkeeping cost, scan resistance, adaptation-on-project-switch, retention), and a cold reader landing on 2Q's two queues plus a tuning split — with the HLD itself noting the workload mix varies — would reasonably ask "why not just LRU?" and be tempted to reverse it. I've captured it as a **Decisions & Alternatives row** as the baseline. Do you want me to **also** promote it to a full decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md` (options, criteria, selection at re-runnable resolution), or leave the row as the record?

## 4. Upstream cascade to flag (needs your OK — crosses into the HLD)
The HLD still says, at line 14, *"Its eviction policy remains open."* That's now stale. The decision's substance lives entirely in the previews segment (the interface, concurrency, and disk budget are untouched, per the HLD's existing tenets and goals), so this is a one-line staleness fix in the parent, not a shared decision. I'd change that clause to note the policy is 2Q, private to the worker. **May I make that HLD edit?**

Tell me how to resolve 1–3, whether you want the decision doc (3), and whether to make the HLD edit (4) — then I'll cascade to the EARS specs.