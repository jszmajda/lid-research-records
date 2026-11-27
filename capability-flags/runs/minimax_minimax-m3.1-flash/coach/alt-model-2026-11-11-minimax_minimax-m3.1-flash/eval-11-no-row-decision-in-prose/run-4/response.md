# LID Coach — printfarm

**Posture:** Bootstrapping — the arrow is clean through EARS, but it stops before tests and code, and the durability story contradicts one of your own tenets.

**Scorecard**
- ✓ Configuration & mode fit — `CLAUDE.md` declares Full mode, correct for a single-service repo
- ✗ Arrow completeness — the repository holds design and specs only; no test or code phase exists
- ✓ Spec format & namespacing — all 8 IDs are EARS-shaped, unique, and resolve to their LLD `prefix:`
- ✓ Mutation hygiene — no `[obsolete]` markers, changelog residue, or "was X, now Y" narration
- ⚠ LLD sufficiency & HLD coverage — behaviors and interfaces are under-specified; the HLD carries no decisions or metrics
- ⚠ Cross-node coherence & decision capture — printer state is split across leaves, and the queue's durability trade-off lives only in prose

**Headline:** The design docs are disciplined, current, and honestly written — the fastest wins are recording the durability trade-off you already made, and settling who owns printer state before code starts.

**Findings (12 total · 4 high · 5 medium · 3 low)**
- **F1 (high):** every spec is marked `[x]` (complete) while the repository contains no implementation — status markers currently overstate reality · *intent leads; code is compiled output* — specs are the source of truth and code is the compiled result, so the marker and the tree should agree
- **F2 (high):** the arrow stops at EARS — no tests and no source exist, so no segment is walkable end-to-end yet · *canonical arrow shape* — the arrow is `HLD → LLD → EARS → Tests → Code`, and a phase that does not exist cannot be checked
- **F3 (high):** keeping the queue "entirely in process memory" loses accepted jobs on restart, which works directly against the promise tenet and the "no member present" goal under the power-blip condition your own LLD names · *tenet cascade* — a mechanism that defeats a stated goal under a described condition needs either a different mechanism or a recorded exception
- **F4 (high):** that durability choice has no Decisions row, no spec, and no mention in the HLD — a cold reader would reverse it on sight and could not reconstruct what was given up · *decision capture* — a live decision needs to live on the page, not only in the author's head
- **F5 (medium):** "suspect" printer state is owned by the `job-queue` leaf but changes who the registry dispatches to; the registry has no suspect state and no spec for it, and the idle-reporting mechanism between the two nodes is undefined · *intent attaches at the lowest node that dominates it* — substance that governs a sibling belongs at their shared parent
- **F6 (medium):** the LLD says "two priority classes: staff and member," while QUEUE-002/003 say "the head job of that printer's class" — whether staff and member are one queue or two lanes is left open · *LLDs close enough of the solution space* — two reasonable agents would land on incompatible dispatch behavior
- **F7 (medium):** several stated behaviors have no spec anywhere: accept-only-if-the-class-has-a-printer, priority/FIFO ordering, content-hash upload dedup, staff printer registration, and the 15 s heartbeat interval · *effective intent-tree alignment* — an LLD behavior with no spec is unnamed intent that drifts silently
- **F8 (medium):** the HLD has no target-users section, no key design decisions, and no success metrics — the queue-per-class and heartbeat-polling choices, and the durability weakness, live only in the leaves · *HLD is architecture and rationale* — the HLD is where the "why" belongs, so the architecture survives leaf edits
- **F9 (medium):** the tenets read as values ("a submitted job is a promise") and as triggered rules ("no silent reordering," which QUEUE-005 already fixes) rather than as tie-breakers with defensible opposites · *tenets capture forward-looking preference* — a tenet narrows the choice a future session makes cold
- **F10 (low):** QUEUE-005's "record the reordering visibly in the queue view" leaves the record's medium, audience, and retention open · *LLDs close enough of the solution space* — the phrase "no silent reordering" in your tenets implies an auditable trail
- **F11 (low):** the base32 job-identifier row states slugs "recycle after 90 days" without naming the source of that window or what happens on collision · *decision capture* — a cost a reader cannot evaluate is a cost nobody can revisit
- **F12 (low):** the registry LLD names three ways a printer stops being eligible (offline for maintenance, missed heartbeats, retired) without mapping them, so a reader must infer that maintenance-offline *is* the unreachable state · *docs carry current intent, written to be read cold* — a fresh author would spell out the mapping

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes, and both spec files — every LID document in the project
- Enumerated: 2 design nodes, 2 LLDs, 8 spec IDs (`QUEUE-001`–`005`, `REG-001`–`003`), all with distinct, grep-friendly, namespaced identifiers whose prefixes match their LLD `prefix:` frontmatter
- Code and tests sampled: none to sample — the repository contains 0 source files and 0 test files, and therefore 0 `@spec` annotations on either side
- Arrow overlay: not installed (`docs/arrows/` absent), so structural checks such as orphan prefixes and reverse orphans could not be enumerated mechanically

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.