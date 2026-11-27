**Coherence pre-flight** (resuming work, registry segment): REG-001–004 all trace to lines in `registry-design.md`; the LLD matches the HLD's architecture; no tests or code exist yet anywhere in the repo, so nothing downstream is stale. The one piece of drift is the HLD's own note that the backend "remains open" — that's Phase 1 work, below.

## Phase 1 — HLD check

The backend choice lives inside the registry node, so the HLD's architecture doesn't change. One line was stale:

```diff
- Owns snapshot validation and lookup. Its private lookup backend remains open.
+ Owns snapshot validation and lookup, including building and querying its own
+ on-kiosk lookup index. The index is private to this node.
```

Tenets, goals, and non-goals need no change — the chosen backend is what they already described.

**One thing I want to flag before going further.** You said the three options looked close. Read against the HLD as written, they weren't: the first two tenets are *"All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"* and *"Kiosks have no network route during normal operation."* Both the HTTPS directory and the managed search service require runtime network access from the kiosk, so each would have meant amending those tenets and the "no live synchronization or cloud services" non-goal — not just picking a backend. Your sketch presented them as peers on cost and maintenance, which is where the closeness came from, and it understated that. If the tenets are what you actually want, the choice was effectively settled; if the deliberation was real because you'd consider relaxing them, that's a bigger change than a registry backend and worth saying out loud.

Assuming the tenets stand, that also answers how to record the choice: I'd record **nothing** beyond the HLD line above — no decision doc, no Decisions row. An inherited constraint settles it, and a cold reader seeing "on-kiosk SQLite index" next to a no-network tenet won't be tempted to re-litigate. A row saying "chose SQLite because the kiosks have no network" would just restate the tenet.

**Two questions for you:**

1. Do the no-network tenets stand as written? (If yes, I proceed; if you want them revisited, that's a separate HLD pass first.)
2. The index now has to be *built* on each kiosk at import time — 90,000 records from a snapshot up to 150 MB, on 4 GB of RAM. Your goals pin lookup at 250 ms but say nothing about how long an import may take, and that's now a real number a technician waits on. Should the HLD carry an import/index-build budget as a goal, or do you want that left to the registry LLD?

Phase 2 (finishing the registry LLD around the SQLite index, then its edge-case probe) is next once you've ruled on these.