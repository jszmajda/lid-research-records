Yes — this one earns a full decision doc, not just a table row.

The choice stays live for a cold reader: LRU is the obvious default, frequency-with-aging is a credible rival, and the queue split will be sized around the 2Q result. Someone unfamiliar with the workload would be tempted to reverse it back to LRU without the options and criteria laid out.

I’d put it at `docs/intent/previews/decisions/eviction-policy.md` and link it from the Previews LLD’s Decisions & Alternatives table.

Want me to draft it now?