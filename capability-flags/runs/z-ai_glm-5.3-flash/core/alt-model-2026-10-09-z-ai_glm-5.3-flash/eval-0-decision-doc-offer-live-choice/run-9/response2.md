Wrote the decision doc at `docs/decisions/self-hosted-websockets-delivery.md` and linked it from the HLD's Self-hosted WebSockets entry.

What the doc gives a cold reader:

- **Context** — why the choice exists: three feasible routes, 800 simultaneous browsers, bursts of 20 edits/second, and what's at stake if the route is wrong (silent staleness vs. vendor lock-in).
- **Decision elements** — five weighted criteria: freshness (major), recurring cost/coupling (moderate), operational burden (moderate), read amplification (moderate), and graceful degradation of freshness on delivery failure (moderate). I probed for a criterion against the emerging pick and kept that last one — a dead socket delivers nothing until the browser notices, which is a real cost WebSockets accept and polling avoids. No gates: all three routes were feasible, so the selection is a weighing, not an elimination.
- **Options** — each described as its advocate would (polling loop, socket-plus-outbox-plus-catch-up, provider SDK with publication reconciliation), with a per-criterion verdict.
- **Selection** — freshness (major) is a tie between the push options, so the moderate criteria decide; WebSockets match polling on cost and the hosted service on freshness, and the hosted option loses because its coupling is the hardest to reverse once socket code spreads into every browser. Names the tenets it turns on, and states the downstream obligations: replayable revisions and reliable publication in the store, session/capacity management in delivery, visible-loss/reconnect/catch-up in browser sync.

Placement note: it lives in `docs/decisions/` (project-level, owned by `high-level-design`) because its substance spans three sibling segments, not one.

Two things before we move on:

1. Does the doc read right to you — particularly whether I've represented the accepted tradeoff the way you'd defend it (the graceful-degradation criterion is the sharpest edge)?
2. Next up are the three nodes. I'd propose drafting them in dependency order — change store first (its replayable-revision shape is what delivery and browser sync hang off), then delivery, then browser sync — pausing at each node's stop for your review. Sound right, or a different order?