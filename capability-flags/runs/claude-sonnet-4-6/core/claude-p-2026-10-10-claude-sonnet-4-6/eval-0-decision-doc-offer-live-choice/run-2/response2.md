Decision doc written at `docs/decisions/delivery-mechanism.md` and linked from the HLD. It covers:

- **Context** — why the choice is load-bearing and what scale it was sized for
- **Decision elements** — two gates (15-second freshness, 800-browser load) and five criteria, with update latency, disconnection visibility, and operational burden all marked major
- **Options** — polling, self-hosted WebSockets, hosted service, each described at full strength with per-element verdicts
- **Selection** — explains why WebSockets wins on the criteria that matter, names the tenet it aligns with (*Connectivity failures must be visible*), states explicitly what the choice forecloses and what it obligates downstream

Still open from before: `docs/intent/access/access-design.md` has a stale "still-open change-delivery approach" reference. That's a one-line wording fix within the ACCESS segment — say the word and I'll apply it.

Ready to move on to the three LLD nodes whenever you are.