I'd keep it as a row in the previews LLD, not a decision doc.

The skill's test is whether a cold reader would question or reverse the choice without the competing options. The competing options are already on the page, and a row with a one-line rationale can carry that. The bar is also explicit: don't offer a decision doc for a choice that affects only its own node, however long the debate ran. This choice affects only the preview worker, and the review API is unchanged by it. The length of the argument doesn't count toward the test.

The LLD row covers the rest. It names LRU and frequency-with-aging as the rejected alternatives and gives the rationale: scan resistance for the long screenings, against the extra queues and tuning. Phase 2 will write that row.

Two things would change my view. If the queue split or ghost-list sizing turned out to need a cross-node decision, such as the review API or the render queue having to know about the policy, that would make it a live decision worth a doc. Nothing in the current design points that way.

The three open questions from my last message are still waiting on you: queue split defaults, byte-based sizing, and ghost history on restart.