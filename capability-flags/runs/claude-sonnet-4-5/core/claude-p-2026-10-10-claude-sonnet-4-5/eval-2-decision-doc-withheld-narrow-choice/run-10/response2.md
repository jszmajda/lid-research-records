Done. Decision doc created at `docs/intent/previews/decisions/cache-eviction-policy.md` and linked from the LLD's Decisions table.

Now, here's the updated **Previews LLD** with the 2Q eviction design:

---

## Updated LLD: `docs/intent/previews/previews-design.md`

**Key changes:**
- Context updated to state that 2Q protects comparison sheets from scans
- New "2Q Eviction Policy" subsection detailing the A1/Am queues, admission/promotion rules, and 25/75 split
- Decisions & Alternatives table added with eviction policy and queue split decisions
- Decision doc linked for the eviction policy choice

**LLD-level edge-case probe** — which of these gaps should I address in the LLD vs. defer?

1. **A sheet in A1 receives multiple concurrent access requests before promotion completes** — could this cause duplicate promotions or queue corruption?

2. **A single rendered sheet exceeds the entire A1 budget (3 GiB)** — the admission rule doesn't handle oversized entries.

3. **Size accounting: is "A1 full" measured by sum of file sizes, entry count, or something else?** The 12 GiB limit is stated, but the per-queue measurement isn't.

4. **Queue rebalancing: if the 25/75 split is adjusted while the cache is running, how do existing entries migrate?** Or is this a restart-required config change?

5. **Access hits a sheet currently being promoted from A1 to Am** — what's the state during transition?

6. **Eviction fails (disk full, permission error) when making room** — the render completed, so backing out the job ticket might confuse clients.

7. **A sheet is re-requested after being evicted from A1 (never promoted)** — does it start over in A1, or is there any eviction memory?

8. **Four active render jobs complete in a burst, all admitting to A1** — could this cause cascading evictions? (Probably fine, but confirming the batch-handling.)

9. **Cache key collision: two revisions hash to the same key** — collision handling isn't specified.

10. **Promotion from A1 to Am when Am has only one entry** — does 2Q still provide value with a tiny reused set?

Which gaps need LLD text, which go to Open Questions, and which are implementation details?

**Phase 2 STOP** — please review the updated LLD and decision doc, and triage the probe questions.