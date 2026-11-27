Yes—this choice earns a full decision doc. A future maintainer could reasonably revisit 2Q in favor of LRU or aged frequency eviction, and the decision depends on several durable tradeoffs: scan resistance, adaptation to project switches, bookkeeping cost, and queue-size tuning. A single table row would not preserve enough of that reasoning.

I’d place it at `docs/intent/previews/decisions/2q-eviction.md`, owned by the preview node, and link it from the preview LLD’s **Decisions & Alternatives** table. The HLD would remain a brief architecture pointer rather than absorbing the detailed debate.

Shall I proceed on that basis and draft the decision doc alongside the detailed preview design?