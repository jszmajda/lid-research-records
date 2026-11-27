I'd keep it as a table row, not a decision doc.

The skill reserves decision docs for choices that stay live for a cold reader and that other design nodes have to be sized around. This choice affects only the previews node: the review API, the HLD tenets, and the fixed `/internal/previews` contract don't change with the policy. The debate was long, but that doesn't make the choice live for a future reader.

The row in the previews LLD's Decisions & Alternatives table can carry the reasoning:

- **Chosen:** 2Q. It resists sequential screening scans from evicting comparison sheets. Its cost is two queues and a size split to tune.
- **Rejected:** LRU, because long screenings evict the comparison set. Frequency with aging, because it adds counter maintenance and keeps stale favorites around too long.

If the 2Q split or the history-queue size later turns into a choice that other nodes depend on, that would be the point to revisit a doc. Phase 2 is still waiting on your approval of the Phase 1 HLD edit and on the two 2Q parameters.