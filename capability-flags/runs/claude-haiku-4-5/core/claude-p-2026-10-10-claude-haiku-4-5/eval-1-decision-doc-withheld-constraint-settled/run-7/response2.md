The table row is the right granularity here. A full decision doc would be overkill.

**Why**: The HLD's tenets (no network access, signed USB snapshots only) make SQLite the natural choice for an informed reader — it's constrained, not genuinely live. The rationale in the Decisions row is clear and complete. The choice affects only the registry component's internal backend, not cross-component contracts or HLD-level architecture. A cold reader won't re-litigate it.

Decision docs earn their place when a choice would genuinely get re-argued without the competing criteria visible. Here, the criteria are inherited from the HLD tenets and are obvious to anyone reading this LLD in context.

**Next step**: Should I move ahead with the edge-case probe resolution — which gaps become LLD elaboration, which become specs, which defer — and then move to Phase 3 (EARS specs)?