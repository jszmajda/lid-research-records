The HLD update is approved. Before I write the record-store contract, one rule needs your decision: when two submissions share the same base revision, how should the store treat the first one?

1. **First accepted revision advances the current state.** A later submission based on an older revision becomes review work. This is simpler and keeps the queue smaller, but the first submission is the current state until a competing edit arrives.
2. **Treat the fork as unresolved once detected.** Keep the shared base as the usable state; when another child revision arrives, put both complete revisions into review and hold the visit from export until resolution. This preserves both sides as competitors, but requires tracking forks and revising the visit’s review state when a conflict appears.

Both approaches retain every submitted revision. Which rule should the design use?