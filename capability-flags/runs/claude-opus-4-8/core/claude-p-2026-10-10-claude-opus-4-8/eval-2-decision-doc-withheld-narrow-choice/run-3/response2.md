Done — the decision doc is at `docs/intent/previews/decisions/eviction-policy.md`, and the LLD's Decisions row now points to it with the one-line reason inline.

A note on how I wrote it: it's in present tense with no trace of the thread — options laid out as they exist in the problem space, each scored against the five criteria (scan resistance major; project-switch adaptation and bookkeeping moderate; long-run popularity and tuning minor), and a Selection that turns on scan resistance. I flagged honestly that no project *tenet* drives this — it's a local choice turning on the HLD's workload characterization — and that frequency-with-aging's one real edge (multi-day popularity) is minor *here* precisely because the reuse that matters is session-scale.

We're still at the **Phase 2 stop**. Two things still need you before I move to specs:

1. **The edge-probe triage** from my last message is still open — especially: worker-restart behavior (pin it, or leave deferred?), and confirming the cold-start eviction rule (evict probation even below its share when main is empty). The ghost-list question stays an Open Question unless you want it in.
2. Anything in the decision doc or LLD you'd word differently.

Once you've cleared those, I'll proceed to **Phase 3 (EARS specs)** — spec lines for the probation/main split and promotion, plus revised PREVIEW-004 wording — then the Phase 4 cross-spec edge audit, each with its own stop.