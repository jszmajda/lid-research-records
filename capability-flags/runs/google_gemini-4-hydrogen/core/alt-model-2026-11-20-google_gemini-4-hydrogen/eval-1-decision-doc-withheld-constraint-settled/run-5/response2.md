It would be overkill—the **Decisions & Alternatives** row in `docs/intent/registry/registry-design.md` is sufficient.

From the landed state, a cold reader won't re-litigate this choice: the HLD's offline/no-network-route tenets eliminate the networked options, the backend is private to `registry` with no effect on `certificates`, and SQLite cleanly fits the 90,000-record / 250 ms / 4 GB RAM constraints.

Whenever you're ready, let me know how you'd like to triage the Phase 2 edge-case items above and whether to proceed to **Phase 3 (EARS specs)**.