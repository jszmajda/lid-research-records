I've updated the HLD (`docs/high-level-design.md`) to record self-hosted WebSockets as the delivery approach. This is the Phase 1 stop, so nothing downstream has been touched yet.

**What changed**
- **Approach:** the open question is replaced by the decision. Committed changes reach browsers over self-hosted WebSockets, and the project owns connection capacity for up to 800 browsers and the reconnect behavior that comes with it. The change store holds replayable revisions and reliable publication, delivery manages socket sessions, and browser sync reconnects and catches up from its last known revision.
- **Architecture:** the change-store, delivery, and browser-sync entries now describe their WebSocket-based responsibilities instead of "depends on the approach".
- **Key Design Decisions:** one new entry records the choice, the two alternatives, and the tradeoff you accepted.

**Please review**
1. **Tenet that may need revisiting:** "Self-hosted and managed infrastructure are both permitted." That is still true, but the HLD now commits to self-hosting. Do you want to leave it, reword it, or replace it with a lean such as "avoid provider coupling for core delivery"?
2. **Decision doc:** this choice has credible alternatives traded across several criteria, and three nodes are about to be sized around it. Do you want a standalone decision doc under `docs/decisions/`, or is the Key Design Decisions entry enough? I've written the entry only.
3. **Freshness goal:** the goal is still "within 15 seconds". Do you want a tighter target now that sockets are chosen, or should it stay as is, since subsecond updates were never required?

**Cascade note, not yet applied**
`docs/intent/access/access-design.md` still calls delivery "the still-open change-delivery approach". That sits in a different segment, so I haven't touched it. It needs a small wording fix, and I'll make it if you confirm.

On approval of the HLD, I'll move to Phase 2 and start on the change-store LLD.