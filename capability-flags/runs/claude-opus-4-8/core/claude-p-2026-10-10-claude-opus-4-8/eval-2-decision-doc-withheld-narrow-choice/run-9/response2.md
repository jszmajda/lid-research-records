Honestly? My read is still a row, not a doc — and I want to separate the two things that are getting tangled here.

The thing pushing you toward a doc is how much the decision *cost* — three meetings, 180 messages. But the skill's test is deliberately not "was this hard to decide." It's forward-looking from the landed state: *would a cold reader of the result be tempted to re-open it without the full options-and-criteria laid out?* A long fight that lands on a choice which reads as settled is exactly the case the skill says to record as a row (or nothing) — the deliberation is residue once it lands. "However long the debate ran" is called out explicitly.

The two conditions for a doc are also ANDed, and the second one fails here:
- **Stays genuinely live for a cold reader** — partly arguable (see below).
- **Other design nodes about to be sized around the result** — no. All three options kept every change inside the preview worker; the interface, queue, and budget are fixed, and nothing else reads the policy. It's node-local.

So by the skill's bar, I wouldn't offer one.

The one thing that would genuinely change my mind: your HLD/LLD both say the best policy is workload-dependent, and `Kin`/`Kout` are tunable. If you expect to **re-run this judgment once pilot data comes in** — LRU vs 2Q vs frequency, re-weighed against the real workload mix — then preserving the full options × criteria so a future reader can replay it is what a decision doc is actually for. That's a real liveness argument, not the "it was exhausting" one.

So the question back to you: is this choice settled for the pilot and beyond, or is it a bet you expect to revisit with data? If the former, the Decisions row carries it and a doc would just be the residue of the argument. If the latter, I'll write a proper one at `docs/intent/previews/decisions/cache-replacement-policy.md` (options in the domain, gates, weighted criteria naming the scan-resistance tenet, selection) — and keep the Decisions row pointing at it.

Your call — which is it? And note you can have the doc either way; I just don't want to hand you one because the fight was long.