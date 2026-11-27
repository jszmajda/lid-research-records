Yes, I'd recommend it. This fits the LID pattern exactly:

You settled a choice among three genuinely credible options (LRU, frequency-based with aging, 2Q), traded them against real criteria (bookkeeping cost, retention during screenings, tuning burden), and the result is consequential enough that a cold reader of the code would reasonably wonder "why 2Q over the alternatives?" 

A decision doc here would capture:
- **The problem:** editors alternate long screenings (many one-off sheets) with comparison sessions (small working set). No single policy is best for all workloads.
- **The options:** LRU (quick, lightweight, vulnerable to scan eviction), frequency-based aging (better retention, more bookkeeping), 2Q (scan-resistant, needs queue tuning)
- **The criteria:** bookkeeping overhead, retention of comparison sheets during big screenings, complexity of tuning
- **The choice:** 2Q — accept the extra queue bookkeeping to protect reused sheets from one-off screening scans
- **The consequences:** A1/A2 size split needs tuning (currently 1:2), future maintainers know why we didn't pick the simpler option

Without the doc, someone will eventually ask "could we simplify this to LRU?" and have to re-litigate. With it, the tradeoff is preserved.

Want me to draft the decision doc? It would live at `docs/decisions/preview-eviction-policy.md` and be linked from the Previews LLD's Decisions & Alternatives table.