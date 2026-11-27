Honestly, no — and the length of the argument is the reason to be careful here rather than the reason to write it.

The test I'd apply is how the choice reads once it's landed, not how hard it was to settle: would a cold reader re-litigate this without the competing options in front of them? Two things say they wouldn't. The choice affects only the previews node — all three candidates left the interface, the render queue, and the 12 GiB budget untouched, so no other design node gets sized around the result and there's no second node whose author needs to re-run your judgment. And the three Decisions rows already carry what made it non-obvious: the two rejected options with the specific criteria they lost on (LRU's scan vulnerability, aged counters' project-switch lag), plus the two sub-calls a reader would otherwise question — no promotion on an A1in hit, no ghost record for Am evictions. A reader who wonders "why 2Q, given the bookkeeping?" gets an answer in one line.

What a doc would add is mostly a record of the deliberation, and that's the residue the *docs carry current intent* tenet strips. A `decisions/` directory with one entry for the loudest argument also tends to mislead the next reader about which decisions in this project are actually still live.

Two things I'd rather spend the effort on, if the worry is that this knowledge evaporates:

- The parameters really are unsettled — 3 GiB / 3,000 keys are the paper's defaults, not measurements. That's already an Open Question; I can make it sharper by naming what to measure in the pilot (hit rate on a screening-heavy vs. comparison-heavy production) so the next session has a procedure rather than a shrug.
- If you want more than a row's worth of resolution on the policy itself, I can expand that row into a few sentences of criteria in place — cheaper than a doc and it stays where the policy lives.

That said, this is your call and you have more context on who reads these than I do. If you want the doc, say so and I'll write it at `docs/intent/previews/decisions/` and link it from the Decisions row — it'd take one pass.

Either way, Phase 2 is still waiting on you: confirm items 1–8 from the probe triage (especially #1, hard partition vs. remainder), and whether to defer the five pre-existing gaps as Open Questions.