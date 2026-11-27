**Phase 1 — HLD check (complete)**

Coherence pre-flight: REG-001–004 trace to the registry LLD, and the registry LLD traces to the HLD; there are no tests yet (the repo has no code).

The HLD carried the open question explicitly, so it needed one edit. In `docs/high-level-design.md` (Architecture):

Before:
> - Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup. Its private lookup backend remains open.

After:
> - Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup. Its private lookup backend is a local embedded SQLite index built on the kiosk from the active snapshot.

Nothing else in the HLD moves: the tenets already require kiosk-local lookup with no runtime network, and the approach and goals are unchanged. I don't think a new tenet is warranted — the existing "no runtime network access" line already leans this class of choice.

How the decision will be recorded (Phase 2): the on-site HTTPS directory and managed search service are both eliminated outright by that inherited tenet, so a cold reader won't re-litigate this once the tenets are in view. That makes it a Decisions & Alternatives row in the registry LLD, not a decision doc.

Two things before I proceed:

1. Approve the HLD change above? On approval I move to Phase 2 — finishing the registry LLD: index build and rebuild per snapshot, atomic activation, query path, plus the row recording this choice.
2. Scope: I read "finish the registry design" as running through the EARS specs and the edge audit (Phases 2–4) and stopping there, since there is no code in the repo yet. Should the run stop at spec, or continue into tests and implementation (Phases 5–6)?