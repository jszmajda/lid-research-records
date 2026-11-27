Done. Here's what landed:

**`docs/decisions/delivery-approach.md`** (new file, linked from the HLD KDD entry)

The doc covers:

- **Context** — why the delivery mechanism is a load-bearing architectural choice (it fixes three downstream designs simultaneously)
- **Decision Elements** — freshness-target gate (all three pass), then four weighted criteria: update latency and vendor independence both major; connection-management burden and store/browser complexity both moderate
- **Options in the Domain** — all three options described at advocate strength, each scored per element with explicit verdicts (strong/partial/weak, passes/eliminated)
- **Selection** — explains that both WebSocket options beat polling on the major latency criterion, then turns on vendor independence (major) to split self-hosted from hosted: the hosted service's lower connection-management burden is real but moderate; vendor coupling is architectural and permanent, which tips the major criterion decisively

A cold reader seeing the result — WebSocket infrastructure with no realtime vendor — now has the competing options and the criteria weights needed to re-run the judgment if circumstances change (e.g., if the team later decides recurring vendor cost is acceptable).

Ready to move on to the three nodes whenever you are.