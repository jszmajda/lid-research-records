**Phase 1 output — HLD check**

HLD exists, covers the change, and already scopes concurrency to record-store. No architectural redesign. Two passages treated the selection as still open; updated:

1. **Architecture table** — record-store state: `Drafted; concurrency choice open` → `Drafted; whole-visit revisions`
2. **Architecture note** — “depend on that node's **unresolved choice** … wait for **its** contract” → “depend on that node's **contract** … wait for **that** contract” (tablet-sync and review-export still wait; the wait is now on the finished contract, not an open choice)

Full tenets, goals, and non-goals unchanged.

Approve to proceed to Phase 2 (finish the record-store LLD around whole-visit revisions), or give numbered feedback.