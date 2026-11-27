Done. `docs/intent/previews/decisions/cache-eviction-policy.md` is written — Context, the four weighted criteria, all three options in their strongest form, and the Selection — and the LLD's Decisions row now links to it. It reads cold: present-tense, no trace of the thread, just the options as they exist in the problem space.

One thing surfaced while writing it. The decision turns on a lean the project hasn't written down anywhere: **retain the reused comparison set over one-pass screening sheets.** The decision-doc template treats a choice that cites no tenet as a signal the project may be missing one — and this one passes the tests (its opposite, favoring screening throughput over the comparison set, is a stance a different production tool could reasonably take; it leans a class of caching decisions no spec anticipates; it's one line). Right now it's load-bearing but invisible above the Selection section. **Want me to add it to the HLD `## Tenets` as a one-liner?** That's a root-doc edit above this segment, so I'm asking rather than doing it.

Still open from the last stop, whenever you're ready (no rush, and order doesn't matter):

- **Edge-probe triage #1–6** — the three I'd fix in the LLD now (first-use never evicts Am; loop defined against the 12 GiB total counting the arrival; serialize admit/evict). And the one that's genuinely yours: **#4** — should a repeated hit on a still-resident A1in sheet promote it to Am, or stay strict 2Q (promotion only via the evict→ghost→re-render cycle)?
- **The stale HLD clause** — may I drop "Its eviction policy remains open" from the HLD Architecture section?

Once I have the tenet call, the #1–6 triage, and the HLD clause, I'll fold the resolutions into the LLD and move on to the EARS specs.