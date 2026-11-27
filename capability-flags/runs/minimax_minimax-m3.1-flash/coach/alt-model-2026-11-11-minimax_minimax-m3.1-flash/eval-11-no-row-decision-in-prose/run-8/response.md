# LID Coach — printfarm

**Posture:** *Bootstrapping — the intent layer is real and clean, but the arrow stops at EARS.*

**Scorecard**
- ✓ Design layer — HLD + two leaf LLDs, prefixes declared, node-as-folder layout correct
- ✓ Mutation hygiene — no change-narration, no obsolete markers, no conversational fossils in any doc
- ⚠ Arrow completeness — EARS present; tests and code phases absent entirely
- ⚠ Tenet cascade — one tenet is contradicted by the queue's own design
- ⚠ Alignment — HLD's web UI has no owning design node
- ⚠ Configuration — instruction file carries only a one-line directive

**Headline:** The intent layer is unusually clean for a young project — short HLD, tight LLDs, disciplined spec IDs — and the fastest wins are filling in the two halves of the arrow (tests, code) and reconciling the queue's design with the tenet it breaks.

---

**Findings (13 total · 4 high · 5 medium · 4 low)**

- **F1 (high):** all 8 specs are marked `[x]` (implemented) but the repo contains no code and no tests — the arrow's lower two rungs don't exist yet · *canonical arrow shape — HLD → LLDs → EARS → Tests → Code* and *tests before code*
- **F2 (high):** the HLD's Approach promises a members/staff web UI and staff reordering, but no design node owns the UI; `QUEUE-005` depends on a "queue view" with no owning LLD · *effective intent-tree alignment — specs trace to LLDs, LLDs to HLD*
- **F3 (high):** tenet "a submitted job is a promise: members should be able to upload and walk away" is defeated by the queue LLD's in-memory hold — accepted-but-undispatched jobs are lost on restart and "members resubmit them," i.e. they must be present · *tenet cascade — does each mechanism work against a tenet?*
- **F4 (high):** the job-queue ↔ printer-registry seam is undefined: the queue acts on "the registry reports a printer idle" and polls printers "for the job it is currently running," while the registry LLD declares only state (idle/busy/unreachable) and a heartbeat poll; no contract owns push-vs-poll or the current-job capability · *coherence is adjacency — each level agrees with the next*
- **F5 (medium):** the in-memory, jobs-lost-on-restart choice has no row in job-queue's Decisions table — it's exactly the choice a cold reader would question, and it's the one F3 turns on · *decision capture — a live choice survives only in prose*
- **F6 (medium):** `QUEUE-002` says "dispatch the head job of that printer's class" while the LLD defines two priority classes — which class's head is unspecified, so the spec admits two readings · *scope disambiguation — the spec must stand alone when grepped*
- **F7 (medium):** `QUEUE-001` scopes the 64 MB limit to "a member"; whether staff uploads are limited is left undefined, and a staff-first priority class suggests they are · *scope disambiguation — a universal-sounding rule quietly scoped*
- **F8 (medium):** job-queue's LLD describes behaviors with no specs — content-hash storage on disk, upload acceptance by class, dispatch timeout value — while upload handling (size limit, slugs, hashing) is a separable concern bundled into the queue node · *effective intent-tree alignment — LLD behaviors with no specs drift silently*
- **F9 (medium):** the HLD has no `## Target Users`, `## Key Design Decisions`, or `## Success Metrics`; Full mode expects these filled · *HLD is architecture and rationale — the full set of architecture-level questions*
- **F10 (medium):** the instruction file carries only "Consult the linked-intent-dev skill" — no workflow pointer, bug-fix line, terminology, or annotation guidance, and its navigation table names only two of the doc kinds that exist · *modes are declared, not inferred* / configuration drift → `/update-lid`
- **F11 (low):** "suspect" (queue) vs "unreachable" (registry) — two words for printer-not-ready states, one of them coined outside the node that owns printer state · *intent attaches at the lowest node that dominates it*
- **F12 (low):** neither LLD carries `## Open Questions & Future Decisions`, so deferred questions (dispatch timeout, retry policy, staff-upload path) have no home · *LLD sufficiency*
- **F13 (low):** the 64 MB limit row names no rejected alternative and the registry's rows name no alternatives either, so a cold reader can reconstruct the choice but not what was given up · *decision capture*

---

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (6 of 6 project files — the repository is docs-only)
- Enumerated: 2 LLDs (prefixes `QUEUE`, `REG`), 2 spec files, 8 specs — all `[x]`
- Code/test sampling: none possible — 0 code files, 0 test files, 0 `@spec` annotations exist
- Overlay: `docs/arrows/` absent (the `arrow-maintenance` plugin is installed but not applied here)
- Cold-read pass run over all five docs as if authored by a stranger with no chat history

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.