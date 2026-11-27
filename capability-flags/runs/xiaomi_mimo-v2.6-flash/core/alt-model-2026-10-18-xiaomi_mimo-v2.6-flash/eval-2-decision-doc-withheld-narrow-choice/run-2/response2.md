My recommendation: **a Decisions & Alternatives row, not a full decision doc.**

The earns-its-place test judges the landed state, not the deliberation — three meetings and a 180-message thread are symptoms, not the test. Judging forward:

- **Scope**: by your own framing, every change stays inside the preview cache's private bookkeeping. A choice that affects only its own node gets a row, however long the debate ran.
- **Would a cold reader re-litigate it?** They'd ask "why not LRU?" — and one rationale line settles it: 2Q protects reused comparison sheets from one-off screening scans, and the extra queues are contained in the worker. They don't need the full option-by-option criteria laid out to reach the same call, and no other design node is being sized around the result — the two conditions a full doc exists for.

The row (Phase 2) will name LRU and aged-frequency as considered alternatives with the rationale written context-free, so a cold reader can reconstruct the call from the table alone. A full doc would memorialize a debate whose memory nothing downstream needs to lean on.

If you disagree — or the doc is for the team's benefit beyond this repo — say so and I'll write it at `docs/intent/previews/decisions/` when we reach Phase 2.

We're still at the Phase 1 stop: approve the HLD changes (with the row-only decision record), give numbered feedback, or opt for the full decision doc?