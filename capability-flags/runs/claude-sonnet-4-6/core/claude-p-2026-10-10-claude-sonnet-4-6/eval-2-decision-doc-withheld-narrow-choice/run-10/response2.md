The instinct makes sense — three meetings and 180 messages is exactly the kind of effort that makes a decision *feel* like it deserves a monument. But the skill's test for a decision doc is about the doc's future utility, not the cost of the debate.

The disqualifying condition here is explicit: **don't write a decision doc for a choice that affects only its own node, however long the debate ran.** The 2Q choice is entirely internal to the preview worker — the HLD itself says no other node reads eviction metadata, pins entries, or consumes queue state. A cold reader of the LLD will find the choice fully contained there; no other node will be sized around it or tempted to reverse it.

What that means in practice: a well-written Decisions & Alternatives row in the LLD will do everything the doc would do. It'll name all three options, record the concrete tradeoffs (scan resistance vs. bookkeeping cost vs. counter lag), and capture why 2Q won. A future reader questioning the choice finds it right there, next to the mechanism it governs.

The long debate earns a thorough row, not a separate file. Shall I proceed to Phase 2 and draft the LLD with that row included?