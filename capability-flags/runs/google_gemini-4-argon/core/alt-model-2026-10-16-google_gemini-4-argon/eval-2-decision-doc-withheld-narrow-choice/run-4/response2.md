I recommend keeping this as the **Decisions & Alternatives row** in `previews-design.md` rather than creating a standalone decision doc.

In LID, the test for a decision doc looks forward from the landed state rather than back at how long the debate took:

1. **Contained strictly within one leaf node**: By design (and per the HLD tenet *Keep cache paths and replacement bookkeeping private to the preview worker*), the eviction policy does not affect the HTTP contract, the render queue, the 12 GiB disk cap, or `review-api`. No other design node is sized around or constrained by this choice.
2. **One line of rationale settles it for a cold reader**: Given the workload stated in the HLD (editors alternating long sequential screenings with repeated comparisons of a small set of clips), a cold reader wondering "why 2Q instead of LRU or LFU?" gets the complete answer from the table row: LRU flushes comparison sets during sequential scans, and aged frequency counters add ongoing maintenance and lag when editors switch projects.

A standalone decision doc (`docs/intent/previews/decisions/cache-eviction-policy.md`) is best reserved for choices where other nodes lean on the outcome or where a future reader would need the full multi-criterion scoring matrix to avoid reversing it. That said, if you still want the full breakdown preserved as a standalone decision doc for the team, I am happy to write it—just say the word.

Otherwise, let me know how you'd like to rule on the LLD draft and the 6 edge-case questions above so we can finalize Phase 2.