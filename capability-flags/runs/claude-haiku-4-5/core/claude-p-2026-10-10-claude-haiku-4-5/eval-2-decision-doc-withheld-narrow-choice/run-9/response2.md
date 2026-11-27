I'd offer a decision doc for this one. Three meetings and 180 messages suggest the tradeoff was genuinely live — a cold reader *would* see the 30/70 split and 2Q structure in the code and ask "why not LRU?" or "could we tune this differently?" without seeing the options you weighed.

The choice clears the bar: credible competing options (LRU, frequency with aging, 2Q), multiple criteria (bookkeeping cost, scan resilience, adaptation speed, working-set retention), and design nodes that will flow from this decision (preview worker memory layout, admission thresholds, cache monitoring).

A Decisions table row in the LLD would name the choice; a full doc would let a future maintainer re-run your judgment without that thread.

**Offer**: Write a decision doc at `docs/intent/previews/decisions/2q-eviction-choice.md` capturing context, the three options with their tradeoffs, and why 2Q wins here. Then link it from a "Eviction Policy" row in the LLD's Decisions & Alternatives table.

Proceed with that, or stick with a table row, or skip it entirely?