**Visit Planner — LID coach review**

## Executive summary

**Posture:** Design layer solid and well-shaped; the arrow stops at EARS, and one tenet is quietly contradicted downstream.

**Scorecard**
- ✓ Mutation hygiene — no changelogs, "previously" sections, or `[obsolete]` residue anywhere; docs read as current intent
- ✓ HLD discipline — architecture and rationale only, no schemas or signatures bleeding upstream
- ⚠ Arrow completeness — HLD → LLD → EARS is real; Tests and Code phases are absent while every spec is marked `[x]`
- ⚠ Tenet cascade — the short-horizon fulfillment path leans against *first asked, first served*
- ⚠ Decision capture — the two-path fulfillment split and its constants survive in prose, not in a Decisions row
- ⚠ Configuration — the instruction file carries a `## LID` block but no LID directives

**Headline:** For a two-component project this is unusually disciplined work — tenets that are genuine tie-breakers, Decisions & Alternatives tables with real rejected alternatives and accepted costs, and specs that trace cleanly to their leaf designs. The highest-value next steps are reconciling the instruction file, and deciding (on the record) whether the ≤36-hour scramble path is an intentional exception to your first tenet.

## Findings (13 total · 5 high · 6 medium · 2 low)

- **F1 (high):** `CLAUDE.md` has a `## LID` block with `Mode`/`Version` but no LID directive text — agents get the mode without the method · *modes are declared, not inferred* (an unread mode is a default; here the directives that make it mean anything are missing)
- **F2 (high):** `FILL-003`/`FILL-004` let any eligible signed-in account claim a ≤36h opening for 20 minutes before the registry scan, so a patient who asked later — or never asked — can take an opening ahead of the earliest `enteredAt`; no Decisions row names the trade · *tenet cascade* (design nodes should lean the way the HLD's tenets say to lean, or record the exception)
- **F3 (high):** The dual-path split itself, the 36-hour boundary, and the 20-minute `notBefore` appear only in `fulfillment-design.md:7-9`; a cold reader would question all three and can't reconstruct what was given up · *decision capture* (judged forward from the landed design, not by how hard the call was)
- **F4 (high):** All 15 specs carry `[x]`, but the repo contains no tests and no code — the arrow has no Tests or Code phase to be coherent with · *canonical arrow shape*; *coherence is adjacency*
- **F5 (high):** "Compatible" carries the matching logic in both leaves and is defined in neither; `intake-design.md:7` stores allowed sites and accessibility needs, but no spec makes matching honor them · *LLDs close enough of the solution space* (two reasonable agents would implement different matchers)
- **F6 (medium):** Notification delivery is real behavior — offers, confirmations, expiries, the outbox drain — with no owning design node under `docs/intent/` · *effective intent-tree alignment* (an LLD gap, not an empty-directory nag)
- **F7 (medium):** "Registry scan" (`fulfillment-design.md:9`, `FILL-003`, `FILL-005`) names a thing no doc introduces; "registry" appears nowhere in the HLD or Intake design · *docs carry current intent, written to be read cold* (in-conversation-only meaning)
- **F8 (medium):** `FILL-002` ("release the opening and run matching again") is horizon-agnostic, but the two paths release differently — does a ≤36h expiry return to portal search or to FIFO offering? · *scope disambiguation* (a universal-sounding spec in a file covering two contexts)
- **F9 (medium):** The HLD has Problem, Approach, Tenets, Goals, Components — but no non-goals, target users, or success metrics; Goal 2's "quickly" has nothing to measure it against · *HLD is architecture and rationale*
- **F10 (medium):** Four tenets in an unordered list, and more than two can collide — *first asked, first served* against Goal 2's fast refill is exactly the collision F2 lands on · *tenets capture forward-looking preference*
- **F11 (medium):** Entry `status` values are never enumerated (`intake-design.md:7`) and the idempotency key expiry the Decisions table accepts as a cost has no spec · *LLDs close enough of the solution space*
- **F12 (low):** Neither spec file declares `prefix:` frontmatter, and `FILL-*` doesn't echo the `fulfillment` node name — the leaf path has to be inferred from file location · *specs are grep-anchored linkage*
- **F13 (low):** No `docs/arrows/` overlay; once tests and code exist, the structural checks F4 implies are cheaper to run deterministically than by sampling · *coherence is adjacency*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs, 2 spec files, 15 specs (7 `INTAKE-*`, 8 `FILL-*`), 8 Decisions & Alternatives rows
- Arrow-path sampled: both segments end-to-end (HLD component → LLD → specs → tests → code); the Tests and Code legs are empty in both
- Linkage metric: 0 `@spec` annotations — no non-doc files exist in the repo
- Cold-read pass: all 5 LID docs; decisions-table sweep: all 8 rows
- Overlay: `docs/arrows/` absent, so structural enumeration was not attempted
- Non-interactive run: took the skill's stated defaults — Full mode per the declared `- Mode:` bullet, and the full-review dispatch for a LID-shaped project whose instruction file lacks directives (F1)

Want me to walk through the findings in detail, focus on a theme or priority — the fulfillment tenet conflict and its missing decision record are the thread I'd pull first — or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on this project — where a notifications component would sit in the tree, how to stage specs when code hasn't landed yet, what `[x]` should mean before tests exist, or when to reach for `/arrow-maintenance` — I can help with those too.