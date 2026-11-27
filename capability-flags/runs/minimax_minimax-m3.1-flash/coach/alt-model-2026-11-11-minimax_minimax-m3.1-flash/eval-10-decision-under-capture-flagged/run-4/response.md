# LID Coach Report — Field Notes

## Executive summary

**Posture:** Bootstrapping — the design half of the arrow is real and clean; the implementation half is missing.

**Scorecard**
- ✓ Configuration — `## LID` block declares Full mode, version 1.4.0, and the Linked-Intent Development directive
- ✓ Doc hygiene — no history residue, no obsolete markers, all three docs read cleanly cold
- ✗ Arrow completeness — the chain stops at EARS; there are no tests and no code in the repo
- ✗ Linkage — both specs are marked `[x]` (implemented) though nothing implements them
- ⚠ LLD sufficiency — a sound design with thin decision capture and several open solution edges
- ⚠ HLD discipline — the architecture rationale is one line; users, key decisions, and metrics are missing

**Headline:** The intent spine — one coherent HLD → LLD → EARS chain with correctly namespaced IDs (`SYNC-001`, `SYNC-002`), real EARS phrasing, and zero accumulation residue — is exactly what LID is meant to produce; the fastest wins are the two unimplemented `[x]` markers and the absent test/code rungs, followed by capturing the clock-skew tradeoff the LLD itself raises.

## Findings (11 total · 3 high · 6 medium · 2 low)

- **F1 (high):** Both specs carry the `[x]` "implemented" marker, but the repo contains zero code and zero test files — *status markers mean "code and tests exist that realize this spec"*; consider dropping them to `[ ]` so the arrow reports the truth
- **F2 (high):** The arrow stops after EARS — no tests, no code, no `@spec` annotations anywhere in the tree — *canonical arrow shape — each phase exists for components in scope*
- **F3 (high):** The LLD's own Context notes device clocks are "frequently wrong by several minutes" and resync NTP only on reconnect, yet conflict resolution is last-writer-wins by device wall-clock with the rationale "Simpler." — *decision capture — a live choice needs a row that lets a cold reader reconstruct what was given up*
- **F4 (medium):** LLD behaviors with no spec anywhere — server-side merge into the canonical store, pending-edit queueing, and the NTP resync on reconnect are stated in prose but unnamed in EARS — *effective intent-tree alignment — LLD behaviors with no specs are unnamed intent*
- **F5 (medium):** Both specs say "the system" while the architecture has two actors — the device and the sync service — so an implementer grepping `SYNC-001` can't tell which one uploads — *scope disambiguation — a spec must be unambiguous when found out of context*
- **F6 (medium):** The sync LLD leaves solution edges open: transport, batching, retry, idempotency of replays, delivery ordering, and how deletions are treated are all unstated — *LLDs close enough of the solution space — two agents would land incompatible implementations*
- **F7 (medium):** The Decisions table has no "Alternatives Considered" column and single-word rationales ("Simpler.", "Standard embedded store.") — *decision capture — a cold reader needs the option set and the cost accepted*
- **F8 (medium):** The `Note storage | SQLite on device` decision sits in the *sync* LLD, though note storage is a different component with separable behavior — *intent attaches at the lowest node that dominates it — decisions belong where their substance lives*
- **F9 (medium):** The HLD has no target users, no key design decisions, and no success metrics, and the local-first-plus-background-sync choice carries no architecture-level rationale — *HLD is architecture and rationale — the HLD carries the "why" that outlives any implementation*
- **F10 (low):** One tenet ("Boring over clever") is a legitimate tie-breaker but broad; the project's hardest axis — conflict semantics under skew — has no tenet to lean on — *tenets capture forward-looking preference — a tenet pre-narrows a choice no spec anticipates*
- **F11 (low):** The sync LLD spans both ends of the wire (device upload path and service merge path); watch for a promotion or split as it grows — *one LLD per intent component — split concerns that share design but have separable behavior*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 EARS specs
- Code and tests: none present — `git ls-files` returns only the four files above; 0 `@spec` annotations, 0 test files, 0 code files
- Cold-read pass performed on all three LID docs (no conversation context) — no in-conversation-only meaning or conversational fossils found
- Overlay not installed (`docs/arrows/` absent), so no `index.yaml` or arrow-doc pass was possible and structural enumeration was out of reach
- Defaults taken for this non-interactive run: full-review dispatch (the Fully-configured row applies — directives, mode marker, and standard directories all present); advisory posture respected, so no project files were changed; report rendered inline rather than persisted to disk

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.