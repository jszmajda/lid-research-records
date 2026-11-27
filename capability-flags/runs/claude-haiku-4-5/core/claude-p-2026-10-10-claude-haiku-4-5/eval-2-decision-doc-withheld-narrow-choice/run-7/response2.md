Yes, I'd recommend it. This choice involved three credible options evaluated against multiple criteria (retention under scans, bookkeeping cost, adaptation speed to project switches), and you ran a substantive deliberation on it. A cold reader looking at the design might reasonably ask "why 2Q and not just LRU?" without seeing the screening-workload patterns and eviction dynamics that justify the extra complexity.

A decision doc would let them re-run the judgment from the criteria: the sharp contrast between long screening scans and tight comparison loops, the risk that sequential scans evict a working set under LRU, and the acceptance that extra queue bookkeeping is worth the protection.

**Should I draft the decision doc now?** It should land before we finalize the EARS specs (Phase 3), so the specs can assume 2Q is the chosen policy. The doc would live at `docs/decisions/preview-eviction-policy.md` and be linked from the Decisions & Alternatives row.

Shall I write it and present it at this Phase 2 stop, before moving to Phase 3 specs?