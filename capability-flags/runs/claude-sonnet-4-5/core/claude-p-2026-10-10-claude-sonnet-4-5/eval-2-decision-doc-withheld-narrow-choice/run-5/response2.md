Looking at it through the decision doc test: *would a cold reader re-litigate this choice?*

The case for a table row only:
- The 2Q mechanism is now clearly documented
- The rationale names the workload pattern (screenings vs. comparisons) and why 2Q fits
- The alternatives and their weaknesses are recorded
- A future reader can see what was considered

The case for a full decision doc:
- Cache eviction policies are genuinely contentious — there's no dominant choice
- Three credible options traded against multiple criteria (scan resistance, bookkeeping, adaptation)
- The 25/75 split is a tunable someone might want to revisit
- The decision sizes the entire cache mechanism around it
- The workload assumption (mix of screenings and comparisons) is an empirical bet that could change

Given the 180-message thread and three meetings, this wasn't just hard to decide — it sounds like it stayed contested even after extensive analysis. That suggests the choice is **genuinely live** even in its landed state.

I'd recommend the decision doc. The table row captures *that* you chose 2Q; the doc would capture the workload evidence, the criteria weights, and why the alternatives failed those criteria — enough that a future reader can reconstruct the judgment rather than just seeing the conclusion.

Want me to draft one?