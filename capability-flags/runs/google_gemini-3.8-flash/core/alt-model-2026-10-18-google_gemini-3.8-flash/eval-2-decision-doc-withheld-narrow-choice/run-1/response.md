I have updated `docs/high-level-design.md` and `docs/intent/previews/previews-design.md` to establish 2Q as the cache eviction policy for the preview worker, detailing the FIFO ($A1$) admission queue, the LRU ($Am$) promotion queue, eviction order, and the rationale in the Decisions & Alternatives table.

### Phase 2: LLD Edge-Case Probe
Before drafting EARS specs (Phase 3), here are the key edge-case questions for the 2Q eviction design:
1. **Admission vs. Promotion on In-Flight Renders**: If an entry in $A1$ is requested again while a concurrent render is in flight or immediately after completion, does the second request promote it to $Am$ immediately?
2. **Ghost Cache / Simplified 2Q ($2Q$ vs $A1_{in}/A1_{out}$)**: Standard 2Q uses an out-of-memory key history ($A1_{out}$) to detect re-references after eviction from $A1_{in}$, whereas simplified 2Q promotes only on hits while still resident in $A1$. Does the preview worker maintain a ghost key queue ($A1_{out}$) on disk/memory, or promote strictly on hits while resident in $A1$?
3. **Cold Boot & Re-indexing**: On worker startup, existing cached sheets on disk must be loaded into memory. Should existing valid sheets populate $A1$, $Am$, or be sized proportionally based on modification time?

### Decision Doc Option
Under the decision doc heuristic: would you like to memorialize this 2Q selection in a standalone decision doc (`docs/intent/previews/decisions/cache-eviction-policy.md`), or is the Decisions & Alternatives table row sufficient?

Please let me know your thoughts on these items so we can proceed to Phase 3 (EARS specs).