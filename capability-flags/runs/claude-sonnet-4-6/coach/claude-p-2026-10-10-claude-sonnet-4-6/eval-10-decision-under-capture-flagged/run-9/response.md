No `capability-flags.md` in the references directory — no flags apply. Here is the review.

---

## LID Coach — Field Notes

**Bootstrapping — arrow in place, content sparse.**

---

### Scorecard

- ✓ **Arrow structure** — HLD → LLD → EARS path exists, linked, and internally coherent
- ✓ **Spec linkage** — two specs correctly namespaced (SYNC-NNN), ID-prefixes trace cleanly to the LLD's `prefix: SYNC`
- ✓ **Tenet quality** — single tenet is real and well-formed; defensible opposite exists; stated as a lean, not a triggered rule
- ⚠ **Decision capture** — conflict-resolution rationale does not engage the clock-skew tension the same LLD's Context section names
- ⚠ **Arrow completeness** — specs are marked done (`[x]`) but no tests or code appear in the project
- ⚠ **HLD Architecture** — Architecture section restates the Approach almost verbatim; no distinct architectural content added

---

**The HLD–LLD–spec chain is cleanly constructed; the fastest win is one fuller Decisions row that acknowledges the clock-skew tradeoff the LLD itself surfaces.**

---

### Findings (3 total · 1 high · 1 medium · 1 low)

- **F1 (high):** Tests and Code phases absent — the two specs are marked `[x]` (done) but no tests or code files exist in the project; the arrow is not walkable past the EARS layer · *canonical arrow shape — a phase is missing or the completion markers are ahead of the arrow*
- **F2 (medium):** `sync-design.md` Decisions row for conflict resolution gives "Simpler." as the full rationale, but the same LLD's Context section says field-device clocks are frequently wrong by several minutes — a cold reader immediately asks what "later wall-clock timestamp" means under skew, and what the cost is; the row leaves that unanswered · *docs carry current intent, written to be read cold — in-context reasoning didn't land on the page*
- **F3 (low):** HLD `## Architecture` ("Device-local store, sync service, reconciliation on the sync path") is nearly identical to `## Approach` ("Local-first note store per device with background sync to a central service on reconnect"); the Architecture section doesn't add architectural rationale distinct from the Approach · *HLD is architecture and rationale — Architecture should carry the why, not echo the what*

---

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file, 2 specs (SYNC-001, SYNC-002)
- No code or test files found anywhere in the project tree
- No arrow overlay (`docs/arrows/` absent)

---

Want me to walk through the findings in detail, focus on a specific one, or work through what a fuller Decisions row for the conflict-resolution choice would look like?

If you have broader questions about using LID — multi-repo setups, when to promote an LLD to a sub-HLD, how to handle code that lives in a separate repo from the docs — I can help with those too.