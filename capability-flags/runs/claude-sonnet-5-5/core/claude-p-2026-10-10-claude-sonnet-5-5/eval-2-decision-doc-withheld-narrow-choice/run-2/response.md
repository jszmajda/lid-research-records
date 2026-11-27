The previews LLD now records 2Q as the replacement policy. I stopped at the Phase 2 review before drafting any specs.

**What changed**
- `docs/intent/previews/previews-design.md`:
  - The open-alternatives paragraph is replaced by a *Replacement Policy (2Q)* section. A FIFO first-use queue holds newly admitted sheets, and a sheet moves to an LRU reuse queue on its next hit.
  - Eviction takes from the first-use queue while it exceeds its configured share. Otherwise it takes from the LRU end of the reuse queue.
  - Everything stays private to the worker, so the preview interface, render queue, and disk budget are unchanged.
  - A *Decisions & Alternatives* row records why 2Q beat LRU and aged-frequency eviction.
- `docs/high-level-design.md`: the Previews bullet no longer says the policy is open.

**Decision doc:** I did not write one. The choice affects only the previews node and no sibling is sized around it, so the table row is enough.

**Edge-case gaps in this LLD for you to triage** (fix now vs. defer; the first three are already listed under Deferred):
1. **First-use share value.** What is the initial share? I left it unset rather than invent a number.
2. **Evicted-then-requested sheet.** A first-use sheet evicted by a scan and requested again re-renders as a new first-use entry, so reuse is only recognized while the sheet is still cached. Do we want a ghost list of recently evicted keys? That is a third structure beyond "two queues".
3. **Restart.** Does queue membership persist across a worker restart, or does the cache start cold?
4. **Oversized or empty queues.** When the reuse queue is empty and the first-use queue is under its share, eviction still has to take from first-use. Should I state that explicitly?
5. **Hit on an in-flight key.** A request for a key whose render is still pending is a miss and joins the ticket. Should it count toward "reuse" once the sheet is admitted, or is reuse only a hit on a cached sheet?
6. **Failed render.** I assume nothing enters either queue and nothing is evicted.

Items 2 and 5 change what the specs would say, so I'd like your call on them before Phase 3.

Reply with fixes or approval for the LLD, plus your triage of the gaps, and I'll move on to the EARS specs.