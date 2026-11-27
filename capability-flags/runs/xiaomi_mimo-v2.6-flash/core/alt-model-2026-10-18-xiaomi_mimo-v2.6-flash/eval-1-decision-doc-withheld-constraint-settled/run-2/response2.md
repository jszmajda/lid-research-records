Overkill — a row. The decision doc's test is whether a cold reader would re-litigate the choice without the full tradeoffs in front of them; here the HLD's "no runtime network access" tenet eliminates the on-site HTTPS directory and the managed search service outright, so one row in the registry LLD's Decisions & Alternatives table settles it (chosen: local embedded SQLite index; alternatives: the two network backends; rationale: the tenet gate, accepting that each kiosk validates and rebuilds its own index when a snapshot arrives). It also affects only the registry node — the certificate interface is fixed either way — and a decision that settles inside its own node is the other case the heuristic says to keep as a row.

I'll record it that way in Phase 2 unless you want the fuller doc anyway.

Still need from you:

1. Approve the Phase 1 HLD edit?
2. Scope — stop after the specs and edge audit (Phases 2–4), or continue into tests and implementation (Phases 5–6)?