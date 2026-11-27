**Coherence pre-flight (resuming in Full mode):**
- HLD Architecture still said the registry's lookup backend "remains open" — stale now that you've selected SQLite; fixed below in Phase 1.
- Registry LLD still says the backend is unselected — will be finished in Phase 2.
- REG-001–004 all trace to the current registry LLD; LLD matches HLD; no tests or code exist yet (this run's scope, per your request, is finishing the design — Phases 1–3 plus the Phase 4 audit).

**Phase 1 — HLD check.** Your selection changes what the HLD's Architecture section asserts, so I updated it. Only this line changed:

```markdown
- Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup. Its private lookup backend is a local embedded SQLite index; each kiosk validates and rebuilds its own index from an incoming snapshot, all inside this component.
```

Tenets, goals, and the certificates bullet need no change — offline lookup, the 250 ms / 90,000-record targets, and the fixed result interface all still hold, and certificates remains untouched.

On recording the choice: it lands in Phase 2 as a **Decisions & Alternatives row in the registry LLD** (per your own framing, its substance is registry-internal), not a standalone decision doc — the HLD's no-network tenet settles the alternative network-backed options for any cold reader. Say if you'd rather have the full decision doc.

**STOP — Phase 1 complete.** Approve with any numbered feedback and I'll proceed to Phase 2: finishing `registry-design.md` around the SQLite index (import/build/activate flow, index schema and query path, Decisions row), followed by the LLD-level edge-case probe for you to triage. For that drafting I'll default to whole-document review per artifact — tell me if you'd rather elicit one aspect at a time, or delegate any stop's inspection.