**LID Coach — printfarm**

## Executive summary

**Posture:** Clean, well-disciplined arrow through EARS — with a durability decision that works against the HLD's own promise.

**Scorecard**
- ✓ **Mutation hygiene** — both design docs and both spec files read as current intent; no changelogs, no `[obsolete]` residue, no "was X, now Y"
- ✓ **Linkage hygiene** — IDs unique, zero-padded, prefixes match each leaf's `prefix:` frontmatter; every spec file names its LLD
- ✓ **LLD granularity** — two nodes, one EARS segment each, no silent scope overlap; the right shape for a service this size
- ⚠ **Tenet cascade** — the job-queue's in-memory design works against the "upload and walk away" tenet under conditions its own Context describes
- ⚠ **Intent-tree alignment** — the HLD's web UI has no design node; several load-bearing behaviors carry no spec
- ⚠ **Arrow completeness** — specs are all marked `[x]`, but no tests or code exist in the repo

**Headline:** The documented part of this arrow is in genuinely good shape — the HLD stays at architecture-and-rationale, the tenets are real tie-breakers rather than platitudes, and the Decisions tables record what was given up (shortest-job-first, UUIDs), which is more than most projects bother with. The highest-value next move is reconciling the queue's durability design with the promise the HLD makes to members.

## Findings (11 total · 5 high · 5 medium · 1 low)

- **F1 (high):** The queue is held "entirely in process memory" and undispatched jobs are lost on restart, while the same doc's Context names unattended OS updates and power blips — so an evening upload can silently vanish overnight, defeating the tenet "a submitted job is a promise: members should be able to upload and walk away" and the goal "evening upload, overnight print, morning pickup — with no member present." No Decisions row records the trade · *tenet cascade — design nodes should lean the way the HLD's tenets say to lean, or record the exception*
- **F2 (high):** That durability choice ("jobs… are gone, and members resubmit them") lives only in `job-queue-design.md:14` prose, with no Decisions & Alternatives row — a cold reader would immediately question it, especially next to the registry's "single SQLite file" that already sits on the same box · *decision capture — a choice that stays live once landed needs its alternative and accepted cost on the page*
- **F3 (high):** The HLD's Approach names "a small web UI" and staff with "reordering rights," but Architecture declares only two design nodes — the UI and the member/staff identity that `QUEUE-005` and the two priority classes both depend on have no node that owns them · *effective intent-tree alignment — architecture concepts should resolve to design nodes*
- **F4 (high):** `QUEUE-002` fires "when the registry reports a printer idle," but the registry's design polls printers on an interval and none of `REG-001`–`003` promises any notification outward — the dispatch trigger is an event one node consumes and the other never commits to publishing · *coherence is adjacency — each level and node should agree with what it is wired to*
- **F5 (high):** Load-bearing behaviors described in design but carrying no spec: the two priority classes and FIFO-within-class ordering, the "accepted only if its target class has at least one registered printer" gate, content-hash dedup of uploads, the 15 s heartbeat poll, and printer *registration* (only retirement is specced) · *effective intent-tree alignment — LLD behavior with no spec is unnamed intent with nothing to test against*
- **F6 (medium):** All eight specs are marked `[x]`, yet the repo holds no tests and no code — so the status markers claim a Tests and Code phase the arrow doesn't have yet · *canonical arrow shape; intent leads, code is compiled output*
- **F7 (medium):** `QUEUE-003` marks a printer "suspect," but the registry's state model (id, class, address, state) and its specs know only unreachable / idle / busy — it's unclear who stores "suspect" or whether it blocks dispatch · *docs carry current intent, written to be read cold*
- **F8 (medium):** "Printer class" is the pivot of the whole dispatch design — per-class queues, the acceptance gate, the 64 MB rationale resting on "the largest bed" — and is never defined anywhere, nor related to the "three hardware models" the registry mentions · *docs carry current intent, written to be read cold*
- **F9 (medium):** The three tenets are an unordered list, but the first (the upload-and-walk-away promise) and the third ("the mini-PC is modest hardware; the service stays small") can pull opposite ways — which is exactly where F1 landed; an ordering would have pre-narrowed that call · *tenets capture forward-looking preference*
- **F10 (medium):** The goal "fair access to the popular printer classes" is never given a meaning or a mechanism, and the HLD carries no success metrics — so there's no way to tell whether two priority classes plus FIFO delivers it · *HLD is architecture and rationale*
- **F11 (low):** "Slugs recycle after 90 days" is recorded as an accepted cost, but it's not stated what a 90-day-old reference to a recycled slug resolves to · *docs carry current intent, written to be read cold*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), 5 Decisions & Alternatives rows, 3 tenets, 2 goals
- Arrow-path walked: both segments, HLD Architecture → leaf design → EARS; Tests and Code phases are absent from the repository, so no `@spec` sampling was possible (0 annotations, 0 test files, 0 source files)
- Configuration: LID directives present, `- Mode: Full`, version 1.4.0; no `docs/arrows/` overlay, so structural enumeration (orphans, reverse orphans, index drift) was out of reach — `/arrow-maintenance` is the tool if you install it
- Cold-read pass: all five LID docs re-read without conversation context (source of F7, F8, F11)

---

Want me to walk through any of these in detail, focus on a theme (the durability cluster F1–F2 is the one I'd start with) or a priority band, or work through specific items together? Picking a single finding to dig into works well too.

If you have broader questions about using LID on printfarm — when to promote a node to a sub-HLD, where a web UI and identity belong in the design tree, how to handle a pre-implementation project's spec status markers, or whether the arrow-maintenance overlay is worth installing at this size — I'm happy to get into those instead.