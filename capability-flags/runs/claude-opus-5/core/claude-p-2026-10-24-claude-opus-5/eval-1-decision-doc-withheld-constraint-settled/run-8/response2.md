Overkill, in my read.

The test is how the choice reads once it has landed, not how long it took to decide. A cold reader opening the registry design sees the HLD tenets — no runtime network access, kiosks have no network route, signed USB snapshots are the only update channel — and then sees an on-kiosk index. That reads as the architecture following through, not as a live question. They would not be tempted to reverse it, because reversing it means reopening the tenets first. A decision doc exists to let someone re-run a judgment that stays genuinely contestable; there is no judgment left to re-run here.

Your experience of it being close is real, but it is the thing the test deliberately ignores. What was expensive was discovering that the constraint already decided it — and that discovery is residue, not present intent. A doc memorializing it would mostly tell a future reader that we once considered options their own architecture forbids.

The Decisions row I already wrote does the work: it names both rejected options, says why the network route disqualifies them, and records that per-kiosk validation and index-build cost is the accepted price. That is enough for someone who wonders "why not a service?"

Where I'd change my answer: if you expect the no-network tenets themselves to come under pressure — a future site with a real lab network, or an appetite for richer searches than serial lookup — then the live decision is the tenet, and a decision doc belongs at the HLD level about network posture, not in the registry about SQLite. Worth saying if you think that's coming.

My two questions from the last message still stand: which of the probe gaps land in the LLD now, and whether I may fix the stale backend sentence at `docs/high-level-design.md:13`.