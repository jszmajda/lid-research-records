I recommend a **Decisions & Alternatives row**, not a full decision doc.

The discussion was extensive, but the landed choice is local to the Previews node: it changes only private replacement bookkeeping, while the API, render queue, and cache budget remain fixed. A cold reader can reconstruct the judgment from one concise row covering 2Q, LRU, aged frequency, and the priority given to protecting reused comparison sheets from sequential scans.

A full decision doc would mainly preserve the history of the argument rather than information needed to re-run a cross-cutting architectural decision. If you still prefer one, I’ll create it, but my LID recommendation is to keep the rationale in `previews-design.md`.

Does that recommendation change your preference, and do you approve the Phase 1 HLD update?