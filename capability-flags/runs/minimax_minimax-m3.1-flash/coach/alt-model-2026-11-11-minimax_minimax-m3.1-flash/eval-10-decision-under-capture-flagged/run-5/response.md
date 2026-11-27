# LID Coach — Field Notes

**Posture:** Healthy docs hygiene, but the arrow stops at EARS and the conflict design contradicts its own stated premise.

**Scorecard**
- ✓ Doc hygiene — no history residue, `[inferred]`, or `[obsolete]` markers anywhere
- ✓ HLD discipline — architecture-level rationale only; implementation detail sits in the LLD
- ✓ Linkage (EARS) — IDs `SYNC-001/002` are grep-anchored, unique, and trace to the LLD's `prefix: SYNC`
- ⚠ Decision capture — the conflict-resolution row says "Simpler." and stops
- ⚠ Goal coverage — "no blocked capture" is stated but not upheld by the mechanism beneath it
- ✗ Arrow completeness — no test and no code phases exist for the specs marked complete

**Headline:** The intent layer is clean, well-formed, and readable cold; the fastest wins are resolving the clock-skew contradiction in the sync design and completing the arrow below EARS.

---

## Findings (10 total · 4 high · 3 medium · 3 low)

- **F1 (high):** The LLD's own context says device clocks are wrong by minutes and NTP-resync only on reconnect, yet conflict resolution is last-writer-wins on device wall-clock — the premise contradicts the chosen approach, and neither the LLD nor the specs say *which* timestamp (edit-time vs. receipt-time) is compared · *LLDs close enough of the solution space — two reasonable agents should land on compatible implementations*
- **F2 (high):** The conflict mechanism discards the losing edit outright, under the HLD goal "No blocked capture in the field" — a technician's captured work can be silently dropped, and no Decisions row or exception records the trade · *tenets capture forward-looking preference — a tie-breaker for choices with no spec cover*
- **F3 (high):** The arrow ends at EARS: no test files, no code files, and zero `@spec` annotations exist, while both specs are marked `[x]` — the intent has no executable half to uphold it · *canonical arrow shape — HLD → LLDs → EARS → Tests → Code*
- **F4 (high):** The `Conflict resolution` Decisions row captures only "Simpler." — a cold reader would question or try to reverse LWW-on-wall-clock and cannot reconstruct what was given up (edit preservation) or what cost was accepted (lost edits under skew) · *docs carry current intent — decisions live in the table, not in chat*
- **F5 (medium):** The HLD names three architecture components (device-local store, sync service, reconciliation) but only sync has an LLD, and the SQLite-on-device decision sits inside the sync LLD even though it governs a different intent component · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F6 (medium):** LLD behaviors with no spec anywhere: "the sync service merges them into the canonical store", the definition of "pending edits", and what happens on partial-upload failure or retry · *effective intent-tree alignment — LLD behaviors with no specs drift silently*
- **F7 (medium):** The HLD has no Target users, Key Design Decisions, or Success Metrics sections, and its goals are unmeasurable prose ("Convergent state after reconnect") — nothing states how convergence or capture-completeness would be judged · *HLD is architecture and rationale — the why that outlives any implementation*
- **F8 (low):** `sync-specs.md` uses `[x]` status markers with no declared meaning and no index in `docs/intent/` explaining marker conventions — a cold reader can't tell whether `[x]` means "current" or "verified" · *docs carry current intent, written to be read cold*
- **F9 (low):** The cold-read of `sync-design.md:9` leaves a genuine ambiguity — "they resync NTP only when connectivity returns" does not say whether correction happens before or after the upload that supplies the comparison timestamp · *docs carry current intent, written to be read cold*
- **F10 (low):** The HLD carries a single tenet ("Boring over clever"), which reads well, but nothing ties it to the project's actual stress point — preserving captured work against merge simplicity · *tenet quality — a real tenet names the choice it is here to break*

---

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file containing 2 EARS specs, 1 git commit
- Sampled: the full repository — 4 tracked files, 0 code files, 0 test files, 0 `@spec` annotations
- Overlay: `docs/arrows/` is not installed, so no arrow index, status markers, or drift fields were available to audit
- Not sampled: nothing — the repository was read in its entirety

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Defaults taken (non-interactive run):* the `## LID` block declared `Mode: Full`, so no scope restriction was applied and the out-of-scope section was omitted; the full review was run and rendered inline rather than persisted to disk, per the skill's advisory posture; where the skill would have asked for confirmation (repairing a corrupt overlay, choosing which findings to detail first), the stated default was taken — no overlay exists, and detail was left to your follow-up.