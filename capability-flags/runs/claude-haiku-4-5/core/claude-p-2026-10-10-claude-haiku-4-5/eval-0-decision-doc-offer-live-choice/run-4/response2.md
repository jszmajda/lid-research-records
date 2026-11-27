Done. The decision doc now reads as a complete, standalone analysis. A future reader can see:

- **Why the problem is real** (subsecond is desirable for time-pressure decisions, but all three approaches are viable).
- **How each option scores against what matters** (latency, operational complexity, cost, store requirements), with concrete details so the scoring is transparent (e.g., "160 read requests per second at a 5-second interval" for polling; "connection storms after an outage" as a real operational hazard for WebSockets).
- **Why WebSockets won** (subsecond is achievable in-house, so the vendor cost buys nothing; operational complexity is bounded and manageable).
- **Why the alternatives were rejected** (not as bad choices in the abstract, but as bad fits for this specific problem).

The implications cascade clearly: change-store needs replay-ordered revisions, delivery owns session state, and browser-sync handles reconnection recovery. Ready to move to Phase 2 and draft the three LLDs?