Honest answer: I'd lean against it.

The test is whether a cold reader would re-litigate the choice without seeing the competing options and criteria. They would — three credible alternatives with real tradeoffs is exactly the profile. But the other half of the test is whether the choice affects only its own node, and it does: 2Q is entirely private to the preview worker; the HLD tenet and the "no other node reads cache files" constraint both reinforce that. The review API, render queue, and everything else are unchanged. A decision that's internal-only and where the tradeoff can be summarized concisely is the textbook case for a Decisions & Alternatives table row rather than a full doc.

The practical question is whether a table row can actually carry the three-way tradeoff well enough that a reader won't want to reverse it. I think it can — the failure modes are short: LRU loses comparison sheets to sequential scans; frequency+aging keeps stale favorites too long and adds counter work; 2Q fixes both at the cost of an extra queue and a size parameter to tune. That fits in one Decisions row.

My recommendation: record a Decisions row in the LLD (which I'll add in Phase 2), skip the decision doc. The length of the debate doesn't change the analysis — it argues for capturing the reasoning well, not for a separate file.

That said, it's your call. If you want the doc anyway — maybe because you want a shareable artifact for the rest of the team — I'll write it. Just say so. Otherwise, let's proceed: approve the HLD update and I'll move to Phase 2.