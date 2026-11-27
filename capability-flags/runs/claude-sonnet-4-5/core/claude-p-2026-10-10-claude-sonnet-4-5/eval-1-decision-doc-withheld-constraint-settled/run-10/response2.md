Table row is right — a decision doc would be overkill here.

The test: would a cold reader of the *landed* design find the SQLite choice non-obvious and be tempted to reverse it? No. The HLD tenet requiring all lookups to complete using local files eliminates the HTTPS directory and managed search service immediately. Given that constraint plus the 90K records and 250ms target, SQLite is the clear choice — it's what you'd reach for by default.

The alternatives you considered were real options *before* committing to the local-only tenet, but once that tenet landed in the HLD, it settled this decision. A cold reader sees the tenet, sees SQLite, and moves on.

Decision docs are for choices that stay live even after landing — where a reader would re-litigate without seeing the full criteria and tradeoffs. This one doesn't meet that bar. The table row captures it fine.

Should I address the edge-case probe gaps, or do you want to triage which ones matter first?