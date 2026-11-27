I picked up the registry design where you left off and ran it through Phase 2 (LLD update) of the LID workflow.

**What I changed in `docs/intent/registry/registry-design.md`:**
- Architecture: names the embedded SQLite index as the chosen backend — each kiosk builds and queries its own, lookup never touches the network.
- Snapshot Import: index build is now part of snapshot preparation; an index-build failure is treated the same as any other import failure (previous snapshot + index stay active).
- Lookup Behavior: notes lookup queries the local index, and nothing else touches it while serving lookups.
- Added a **Decisions & Alternatives** row recording the three options and the rationale.

One thing worth flagging: your HLD already has a tenet that "lookup SHALL complete using files on the kiosk; no runtime network access is permitted." Both the HTTPS directory and managed-search options require network access at lookup time, so they were already ruled out by that tenet — not just by cost/tradeoff. I recorded the SQLite choice as a table row rather than a full decision doc, since a cold reader checking that tenet would find the result dominated rather than genuinely re-litigable (this also means your "went back and forth" wasn't about which is best so much as which is actually allowed).

**Edge-case probe** (a blind reviewer, given only the revised LLD text, flagged these gaps — some newly introduced by the SQLite choice, some pre-existing and just now surfaced):

New from this choice:
1. Is an empty snapshot (zero records) a valid index to activate?
2. If index-build fails partway through, are partial on-disk SQLite artifacts cleaned up, or left as orphaned temp state?
3. Is "no other process touches the index while it serves lookups" enforced by a lock, or just assumed? Is index rebuild itself concurrent with in-flight lookups, or does it block them?
4. Is swapping to the new snapshot+index atomic, or could a crash mid-swap leave neither the old nor new one fully active?

Pre-existing, not caused by this choice:
5. Does uniqueness validation normalize case/whitespace before comparing, and what happens if two raw serials collapse onto the same normalized key?
6. What happens on the very first import — can `findBySerial` be called before any snapshot has ever succeeded?
7. Is the snapshot date itself validated for presence/format?
8. Is there any public-key rotation path, or does a key mismatch just mean permanent import failure?

Which of these do you want folded into the LLD now, and which should I log as deferred open questions? Once you've triaged, I'll finalize this phase and we can move to the EARS spec update.