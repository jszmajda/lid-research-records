My honest read: a row, not a doc — but it's your call, and here's the test I'm applying.

The skill reserves a full decision doc for choices a cold reader would *re-litigate* — where you need the competing options and criteria laid out to re-run the judgment. Three things push 2Q back toward the row:

- **It only touches its own node.** All three options you weighed live entirely inside the preview cache; no sibling design changes with the outcome. The skill explicitly says long debate doesn't override that: "however long the debate ran."
- **The debate's length is a symptom, not the test.** Three meetings and 180 messages explain why *you're* tired of the question; they don't tell me whether a reader two years from now needs the full tradeoff table. A well-written rationale line — "2Q protects the repeatedly-compared working set from sequential screening scans; LRU is cheaper but scan-vulnerable, aged frequency counters lag on a project switch" — settles it.
- **Once 2Q's mechanism is in the LLD, some of the "why" documents itself.** A reader who sees first-use entries quarantined from reused entries can see why scans don't evict comparison sheets.

What would flip me to a doc: if you expect this to come **back on the table** — e.g., you plan to re-open the eviction choice once pilot workload measurements exist, or the queue-size split becomes a real tuning fight. A doc earns its place by being re-run, not by being deserved. If 2Q is meant to settle permanently, the row is the right weight and a doc is over-recording.

So, two things for you to rule on:

1. **Decision doc or Decisions row?** Say "doc" and I'll write `docs/intent/previews/decisions/preview-eviction-policy.md` at Phase 2 and link it from the LLD's Decisions table; say "row" and I'll record it there.
2. **Approve Phase 1?** The two-line HLD update from my last message stands as presented, or tell me what to change.