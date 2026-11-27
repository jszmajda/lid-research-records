**Coherence pre-flight** (resume check for the previews segment): PREVIEW-001…005 each trace to the current previews LLD; review-api specs are untouched by this change; the LLD matched the HLD except for one stale line (below). The repo contains only docs — no test artifacts exist yet, which will need a ruling when we reach Phase 5.

**Phase 1 — HLD check.** The HLD exists and covers this change; your 2Q selection doesn't alter the architecture, but it falsified one HLD statement. Changed in `docs/high-level-design.md:14`:

- Before: `Owns rendering, pending jobs, and a private 12 GiB cache. Its eviction policy remains open.`
- After: `Owns rendering, pending jobs, and a private 12 GiB cache evicted under the 2Q policy.`

Nothing else in the HLD moves — tenets, goals ("same interface for every eviction policy"), and non-goals already hold under 2Q. Recording the choice itself: since all effects stay inside the previews node, it lands as a Decisions & Alternatives row in the previews LLD during Phase 2, not a full decision doc.

Approve to proceed to Phase 2 (finish the previews LLD around 2Q), or give numbered feedback on this stop.