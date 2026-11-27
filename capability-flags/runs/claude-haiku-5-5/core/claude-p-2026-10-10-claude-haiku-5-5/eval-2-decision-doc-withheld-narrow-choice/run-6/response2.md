I'd keep this as a Decisions row in `docs/intent/previews/previews-design.md`, not a decision doc.

The decision doc test asks whether a cold reader would keep re-litigating the choice without the options and criteria. This one is settled, and it only affects the Previews node. The render queue, the review API, and the HLD don't change with it. Our debate is the kind of effort the guidance says not to reward with a doc. The Decisions row can hold the key comparison: 2Q chosen, LRU and frequency-with-aging rejected, each with a short reason. That covers what a future reader needs to know.

I'd change my view if the choice started to reshape other nodes, for example if the review API needed to see eviction state, or if the pilot showed we needed to revisit it. Then it would be live for a cold reader, and a doc would be worth writing.

Phase 1 is still waiting on you. Please answer the four items: the line-14 edit, the "reused" definition (I recommend classic 2Q), the size-split values, and the LRU-within-queues assumption. Once you reply, I'll draft the Phase 2 LLD with the Decisions row.