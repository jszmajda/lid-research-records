The 2Q eviction choice clears the decision-doc bar.

A cold reader would question why we accepted extra bookkeeping for two queues and a tunable size split, and would be tempted to reverse it back to LRU once sequential scans are observed. The choice trades bookkeeping cost and operational tuning for protection of reused comparison sheets during big screenings, and it sizes the preview worker’s private metadata and the Q1/Q2 split parameter that downstream implementation will depend on. That is exactly the “choice stays genuinely live” case the heuristic calls for.

We already have the Decisions & Alternatives row in `docs/intent/previews/previews-design.md`. A full decision doc would add the context, criteria, and options at the resolution a future reader needs to re-run the judgment.

I can create `docs/intent/previews/decisions/preview-eviction-2q.md` with:
- Context: 24 editors, 90k clips, alternating sequential screening vs repeated comparison, 12 GiB private cache, fixed preview API
- Criteria: protection of reused sheets during scans, bookkeeping cost, adaptation speed on project switch, operational tunability
- Options: LRU, frequency-based eviction with aging, 2Q
- Decision: 2Q with private Q1/Q2 FIFO, promotion on second access, eviction prefers Q1, configurable size split
- Consequences and tuning notes

Do you want me to draft that decision doc now, or keep the record as the LLD table row only?