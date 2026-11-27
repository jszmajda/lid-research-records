Done — the decision doc is at `docs/intent/previews/decisions/cache-eviction-policy.md`, owned by the previews node, and the LLD's Decisions row now links to it. It lays out the four criteria (scan resistance major; adaptation and bookkeeping moderate; tuning minor), gives each of LRU / frequency-with-aging / 2Q its own analysis against them, and the Selection turns on scan resistance being the one criterion where the options actually diverge.

Two things worth your eye in it:

- **It cites no tenet.** Writing the doc surfaced that the thing the whole decision turns on — protecting the reused working set through a scan — isn't backed by any named HLD tenet; it leans on the problem statement instead. That reads to me like a genuine gap: a candidate tenet along the lines of *"prefer protecting the reused comparison working set over cache simplicity."* I noted it in the doc's Selection and I'd suggest adding it to the HLD, but that's an HLD change for a separate turn — flagging, not doing.
- The doc records the **A1in-no-promotion** behaviour as an accepted weak spot, matching what I put in the LLD — which is still item 1 below, pending your confirm.

**Still at the Phase 2 stop.** Before I cascade to the EARS specs (Phase 3), I still need from the previous turn:

1. **A1in-resident hit — no promotion** (standard 2Q, what I recorded). Confirm, or flip to promote-on-second-reference?
2. **A1out membership read at admission time** (not enqueue). OK as-is?
3. **Restart loses queue state**, deferred. OK to defer?
4. **HLD edit** — may I change line 14's stale *"Its eviction policy remains open"* to note it's 2Q, private to the worker?

And now also: 5. **The missing scan-resistance tenet** — want me to propose that HLD tenet (same upstream turn as #4), or leave it?

Resolve those and I'll write the EARS specs against the 2Q design.