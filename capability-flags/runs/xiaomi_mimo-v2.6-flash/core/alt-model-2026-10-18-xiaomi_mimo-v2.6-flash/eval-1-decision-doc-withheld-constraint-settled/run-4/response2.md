Overkill — a Decisions & Alternatives row in `registry-design.md` is the right size.

Applying the earns-its-place test from the landed state: a cold reader of the HLD sees the no-network tenet first, so the two network-backed options eliminate themselves before any weighing — an inherited gate, not a live trade-off. That leaves one surviving option where SQLite dominates on the criteria you cared about (predictable lookups at 90k records, no service to run), and the choice affects only the registry node — the certificate interface is fixed regardless. The template withholds a doc precisely from choices an inherited constraint settles or that affect only their own node, however long the debate ran; your back-and-forth is the deliberation symptom, not the landed-state test.

So the row carries: chosen = local embedded SQLite index; alternatives = on-site HTTPS directory and managed search service (both excluded by the HLD no-network tenet) plus simpler local options (linear scan of the snapshot NDJSON, prebuilt flat index); rationale = predictable lookups with no service, at the cost of each kiosk validating and rebuilding its own index on snapshot import — a cost that stays inside the registry component.

The honest counter-signal: if the no-network tenet itself were live — if kiosks were about to get a network route — this would become a genuinely re-litigable choice and earn a doc. That tenet is settled in the HLD today, so it doesn't.

A decision doc would become warranted later if that tenet is ever relaxed; the row is written so a future reader can see exactly which constraint to revisit.

Approve the Phase 1 HLD update, and I'll proceed to Phase 2 with the row recorded as above.