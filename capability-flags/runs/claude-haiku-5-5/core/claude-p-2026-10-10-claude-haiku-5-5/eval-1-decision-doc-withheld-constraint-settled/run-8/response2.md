No, a decision doc would be overkill here. The HLD's no-network tenet already settles the choice. Only the SQLite option satisfies it, so no competing options are left to re-litigate. The choice also affects only the registry node, and the certificates interface doesn't change. A reader of the landed design is unlikely to question it, so a table row is enough.

In the Phase 2 LLD, the Decisions & Alternatives row would read roughly: local embedded SQLite index chosen; the on-site HTTPS directory and managed search service are rejected because the HLD's no-runtime-network tenet excludes them. That gives a cold reader the "why" in one line.

A decision doc would make sense only if the tenet were ever relaxed, for example to allow a central lookup service. In that case the choice would become live again.

The Phase 2 draft is still waiting on your approval of the Phase 1 stop.