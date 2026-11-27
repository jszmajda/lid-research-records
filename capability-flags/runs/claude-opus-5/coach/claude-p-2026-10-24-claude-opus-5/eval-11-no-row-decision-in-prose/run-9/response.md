**LID Coach — printfarm**

## Executive summary

**Posture:** Clean, well-shaped docs layer; the arrow stops at EARS, and one tenet is quietly contradicted.

**Scorecard**
- ✓ Mutation hygiene — no change-narration, no obsolete markers, no planning residue; both design docs read cold without strain
- ✓ HLD discipline — problem/approach/tenets/goals/non-goals with no schema or signature detail bleeding upstream
- ✓ Linkage namespacing — `QUEUE-` / `REG-` prefixes match the `prefix:` frontmatter of their leaves; IDs unique, zero-padded, greppable
- ✗ Arrow completeness — tests and code phases are absent while every spec is marked `[x]`
- ⚠ Tenet cascade — the in-memory queue works against *"a submitted job is a promise"* under conditions the design itself names
- ⚠ Intent-tree alignment — several design behaviors (priority classes, registration, acceptance gate) have no spec

**Headline:** For a two-node project this is unusually disciplined writing — the docs carry current intent, the prefixes line up, and the Decisions tables already name costs rather than just choices; the highest-value next step is reconciling the queue's durability model with the promise tenet, then closing the gap between `[x]` markers and an arrow that has no tests or code yet.

## Findings (10 total · 4 high · 5 medium · 1 low)

- **F1 (high):** The queue is held "entirely in process memory" and undispatched jobs are lost on restart, on a mini-PC the same doc says "takes unattended OS updates and the occasional power blip" — an evening upload can vanish overnight with no member present, against the tenet *"a submitted job is a promise"* and the goal *"evening upload, overnight print, morning pickup"*; no Decisions row records the exception · *tenets capture forward-looking preference* — tenets are the lean a session takes when no spec covers the call
- **F2 (high):** The durability choice itself has no Decisions & Alternatives row in `job-queue-design.md`, while the sibling registry records *why* it persists to SQLite — a cold reader holding both docs would question the asymmetry and be tempted to reverse it · *docs carry current intent* (keep-side) — a live decision's default capture is a fuller Decisions row
- **F3 (high):** All eight specs carry `[x]`, but the repo has no test or code files and no `@spec` annotations anywhere — the arrow's last two phases are unbuilt while the markers assert otherwise · *canonical arrow shape*; *tests carry `@spec` annotations*
- **F4 (high):** `job-queue-design.md` marks a printer "suspect" on dispatch failure, but the registry — which owns printer state (`id, class, network address, state`) and its reachable/idle vocabulary — has no suspect state, spec, or exit condition; the substance sits in the leaf that doesn't own it · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F5 (medium):** Design behaviors with no spec anywhere: the acceptance gate ("accepted only if its target class has at least one registered printer"), the two priority classes, content-hash file storage, staff *registering* a printer (retirement is specced, registration is not), and the 15 s heartbeat poll · *effective intent-tree alignment* — un-specced behavior is unnamed intent with nothing to test against
- **F6 (medium):** `QUEUE-003` returns a failed job to the head of its class queue — a reordering members see but the queue never explains, where the tenet asks for *"no silent reordering"* · *tenet cascade*
- **F7 (medium):** `QUEUE-001` reads "when a **member** uploads a G-code file larger than 64 MB" while the design states a flat "64 MB per G-code file" — an agent grepping the spec cold can't tell whether staff uploads are exempt · *scope disambiguation* — if a second variant existed, would this spec still be unambiguous?
- **F8 (medium):** Three tenets presented as an unordered list, and two of them pull opposite ways — "a submitted job is a promise" wants durability, "the service stays small" wants less machinery (the in-memory queue in F1 looks like that tie broken silently) · *tenets capture forward-looking preference* — order them when more than two could conflict
- **F10 (medium):** `QUEUE-002` dispatches "the head job of that printer's class," which omits the staff/member priority split the design defines — the spec and its LLD disagree at the seam · *coherence is adjacency*
- **F9 (low):** The registry's Decisions table explains the 15 s interval but not the three-missed-heartbeat threshold sitting beside it in `REG-001` · *docs carry current intent* (keep-side)

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 leaf LLDs (`QUEUE`, `REG`), 2 spec files, 8 EARS specs, 2 arrow segments
- Arrow-path walked: both segments end-to-end (HLD §Architecture → leaf design → specs → tests → code); both terminate at EARS
- Linkage metric: 0 `@spec` references across 0 code or test files; 8 of 8 specs marked `[x]`
- Structural depth: flat design layer (root HLD → 2 leaves), no `docs/arrows/` overlay installed, no `index.yaml` to reconcile
- Cold-read pass: both design docs plus the HLD, read without conversation context — no change-narration, obsolete markers, or in-conversation-only phrasing found; the one undefined term is "suspect" (F4)

## Next

Want me to walk through any of these in detail — or focus on a theme, like closing the tenet/durability conflict in F1–F2, or getting the tests-and-code half of the arrow started? Picking a single finding to dig into works well too; remedies and the right command for each come in that follow-up.

If you have broader questions about using LID on printfarm — when two nodes should become a deeper tree, how far to take `[x]` markers before code exists, whether a web-UI node belongs in the design layer, or where a PRD would fit — I'm happy to talk through those instead.