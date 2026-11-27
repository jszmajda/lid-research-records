Good question. Let me apply the decision doc test.

**The test**: Would a cold reader of the landed design find this choice non-obvious — question it or be tempted to reverse it?

This choice has:
- 3 credible options (SQLite, HTTPS directory, managed search)
- Multiple criteria traded (network dependency, maintenance, cost, reliability)
- Other nodes sized around it (the entire registry implementation depends on this)

A cold reader might question "why not centralize the index?" — the offline requirement isn't obvious from looking at registry code alone; it comes from the HLD's kiosk isolation tenet.

However, the Decisions & Alternatives table row already captures the competing options and the key tradeoff ("no network dependency... self-contained... avoids service timeout handling"). That might be enough to prevent re-litigation.

**My recommendation**: Keep the table row as-is. The rationale is clear enough that a cold reader can reconstruct the judgment without needing the full decision-doc treatment. If we later find people questioning this choice (in code review, handoff, or maintenance), we can always promote the row to a full doc then.

Does that sound right, or would you prefer the full decision doc now while the context is fresh?