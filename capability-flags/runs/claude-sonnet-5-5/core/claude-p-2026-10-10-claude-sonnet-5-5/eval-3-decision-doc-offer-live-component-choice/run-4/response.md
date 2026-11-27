Phase 1 (HLD) is updated for whole-visit revisions. It's the first of the six stops, so I'm pausing here for your review before touching the record-store LLD.

**What changed in `docs/high-level-design.md`**
- The record-store row in the Architecture table now reads "Drafted; contract pending" instead of "concurrency choice open".
- The paragraph under the table now states the chosen mechanism. Each submitted visit stays intact and names its base revision. Competing revisions go to a coordinator and are never auto-combined. Tablet-sync keeps base revision IDs and shows pending competing revisions. Review-export gets a revision comparison workflow and holds unresolved visits out of the CSV.

**Questions for you**
1. **Tenet.** Your reasoning suggests a tie-breaker the HLD doesn't have yet: *"Keep a worker's submitted visit intact; never automatically combine edits across fields."* Its opposite (merge for lower review load) is a defensible choice for a different project, so it passes the tenet test. Add it under `## Tenets`, reword it, or skip it?
2. **Decision record.** This choice will stay live for a cold reader. The options trade review load against merge-rule upkeep and scientific integrity, and two nodes are being sized around it. I can write a standalone decision doc at `docs/decisions/` with the criteria and both options, or record it as a row in record-store's Decisions & Alternatives table. Which do you want?
3. **Site-catalog.** `site-catalog-design.md` still says tablet-sync's behavior is "pending that choice". That's a different segment, so I haven't touched it. Should I update that line as a cascade?

**Next**
After your approval I'll move to Phase 2, the record-store LLD. That means replacing the OPEN section with the whole-visit contract (submission envelope, current-state response, unresolved-work representation, resolution operation) and running the LLD edge-case probe. EARS specs, the edge audit, tests and code follow, each with its own stop.