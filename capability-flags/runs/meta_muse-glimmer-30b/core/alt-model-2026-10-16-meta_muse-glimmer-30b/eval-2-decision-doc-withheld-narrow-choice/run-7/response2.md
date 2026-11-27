A decision doc is warranted when a cold reader would re-litigate the choice without the competing options and criteria.

For the preview eviction policy you settled 2Q over LRU and frequency-based eviction with aging, with explicit trade-offs:
- LRU: lowest bookkeeping, quick adaptation on project switch, vulnerable to sequential screening evictions
- Frequency + aging: better retention of repeatedly popular clips, counter maintenance and aging lag on project switch
- 2Q: protects reused comparison sheets from one-off screening scans, extra two-queue bookkeeping and a size-split to tune

That set of criteria and downstream consequences is non-obvious and will be sized around by the LLD, so a cold reader would question “why 2Q?” A Decisions & Alternatives row in the Previews LLD will record the choice, and a full decision doc in `docs/intent/previews/decisions/` can preserve the context, options, and selection rationale for future readers.

Do you want me to create a decision doc for the eviction policy choice in addition to updating the LLD Decisions & Alternatives table? And do you approve proceeding to Phase 2 LLD update with 2Q?