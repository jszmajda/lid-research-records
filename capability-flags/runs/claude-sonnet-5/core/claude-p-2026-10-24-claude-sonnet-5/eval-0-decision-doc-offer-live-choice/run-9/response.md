The HLD now reflects the decision. I've updated the Approach section, the three downstream Architecture entries, and added the decision as a Key Design Decisions entry.

I've updated the HLD at `docs/high-level-design.md`:

- **Approach**: now states the delivery choice outright — self-hosted WebSockets the server owns end to end — with the trade-off (extra connection/reconnect work for fast, vendor-free updates).
- **Architecture**: the change store, delivery, and browser-sync entries now describe what each owes to that choice (replayable revisions + reliable publication; WebSocket session lifecycle; reconnect/catch-up logic) instead of listing it as still-open.
- **Key Design Decisions**: added a row recording the choice and why the other two options were rejected.

This is a project-level choice that sizes three downstream nodes at once and was made by weighing real trade-offs (latency vs. ops burden vs. vendor cost) — the kind of thing a cold reader would want more than a one-line row for. Want me to write it up as a full decision doc (`docs/decisions/`), or is the row in the HLD enough? Either way, let me know if the HLD update itself looks right before we move on to the three nodes (change store, delivery, browser sync).