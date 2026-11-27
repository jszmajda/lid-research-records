Expanded the decision entry with:

- **What it prioritizes**: fast updates and avoiding vendor fees over operational simplicity
- **What we accept**: connection capacity planning, session management, reconnect logic
- **Implications for each component**: store maintains replayable revisions, delivery broadcasts and handles drops, browsers reconnect with backoff and request catch-up
- **Why polling was rejected**: meets freshness goal but can't reach subsecond delivery, repeated reads for no-change polls
- **Why hosted services were rejected**: fast updates with less work, but vendor coupling, usage-based fees, and publication reconciliation complexity

A cold reader can now reconstruct why this choice was made and what it commits the three components to do. Ready to proceed to the LLD drafts?