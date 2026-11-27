Based on the earns-its-place test, a decision doc is warranted here.

A cold reader of the landed system will see 2Q, two queues and a size split with extra bookkeeping, and will plausibly ask “why not LRU or aged frequency?” The rationale — protecting reused comparison sheets from eviction during long sequential screenings while accepting bookkeeping cost — is not self-evident from the code or the LLD prose alone. With three meetings and a long thread behind the choice, the decision stays live: the trade-off is still legible and re-litigable if production workloads shift.

The Decisions & Alternatives row you already have is the right minimal record. The step up is a full decision doc in `docs/intent/previews/decisions/` that lets a future reader re-run the judgment: context, decision elements with gates and weighted criteria, strongest honest descriptions of LRU / frequency-with-aging / 2Q with per-element analysis, and selection with implications and tenet tie-in.

I can draft it now as `docs/intent/previews/decisions/cache-eviction-policy.md` and link it from the Decisions & Alternatives table. Do you want me to create it?