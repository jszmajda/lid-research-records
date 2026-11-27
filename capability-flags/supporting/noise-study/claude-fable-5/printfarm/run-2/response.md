**LID Coach Report — printfarm**

**Posture:** Bootstrapping — a clean, disciplined design layer; the arrow isn't yet walkable past the specs.

**Scorecard**
- ✓ Mutation hygiene — docs read as current intent; no changelog residue, no obsolete markers
- ✓ HLD discipline — architecture and rationale only; nothing that belongs downstream
- ✓ Linkage groundwork — spec IDs are unique, zero-padded, grep-friendly, and match each leaf's `prefix:` frontmatter
- ✗ Arrow completeness — the tests and code phases don't exist yet, while every spec is marked `[x]`
- ⚠ Cascade & node ownership — printer state ("suspect") and the queue↔registry contract sit in ambiguous territory
- ⚠ Decision capture — the design's most load-bearing choice isn't in a Decisions table

**Headline:** The two-node design tree is well-shaped and the docs are a pleasure to read cold; the most valuable next step is reconciling the in-memory queue with your own "upload and walk away" tenet — and capturing that decision either way.

---

**Findings (9 total · 3 high · 4 medium · 2 low)**

- **F1 (high):** The in-memory queue drops accepted-but-undispatched jobs on restart — on a mini-PC the LLD itself says takes unattended overnight OS updates — which cuts against the HLD tenet "a submitted job is a promise: upload and walk away" · *coherence is adjacency* — each arrow level should agree with the one above it
- **F2 (high):** The in-memory-vs-persisted queue choice isn't in job-queue's Decisions & Alternatives, though QUEUE-004's restart-rebuild behavior and the resubmission story are built around it; consider an expanded row naming the rejected alternative (e.g., persisting the queue in the SQLite file the registry already uses) and the accepted cost · *docs carry current intent* — a cold reader would still question this choice, so the tradeoff belongs on the page (a separate finding from F1; the design concern doesn't absorb the capture gap)
- **F3 (high):** All 8 specs carry `[x]` markers, but the project contains no tests, no code, and no `@spec` annotations anywhere — either the markers overstate, or the tests/code phases were skipped without a documented deviation · *canonical arrow shape* and *tests before code* — every phase exists, and tests lead implementation
- **F4 (medium):** Job-queue marks a printer "suspect" (QUEUE-003), but printer state is the registry's territory and the registry defines no such state — nor does either doc say what "suspect" means for future dispatch · *intent attaches at the lowest node that dominates it* — substance affecting a sibling rises to the shared parent — plus *LLDs close enough of the solution space*
- **F5 (medium):** Two job-queue behaviors have no EARS spec: the acceptance rule (target class must have ≥1 registered printer) and staff-before-member priority ordering · *effective intent-tree alignment* — LLD behavior with no spec is unnamed intent with nothing to test against
- **F6 (medium):** The two LLDs describe their interaction contract differently — job-queue says "the registry reports a printer idle" (push), the registry says "the queue asks the registry" (pull); the contract spans both nodes, so consider stating it once at their shared parent, the HLD · *intent attaches at the lowest node that dominates it*
- **F7 (medium):** QUEUE-002's "the head job of that printer's class" reads ambiguously once two priority classes exist — printer class and priority class collide in the word "class," and the spec doesn't say which head wins · *scope disambiguation* — would this spec still be unambiguous when read alone via grep?
- **F8 (low):** The tenets are an unordered list, yet "a submitted job is a promise" and "the service stays small" genuinely pull against each other (F1 is that tension, live) — consider ordering them · *tenets capture forward-looking preference* — ordered tenets pre-decide the tie
- **F9 (low):** The HLD has goals but no success metrics — "fair access to popular printer classes" has no measurable shape · *HLD is architecture and rationale*

---

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`
- Enumerated: 2 design nodes (job-queue, printer-registry), 8 EARS specs (5 QUEUE, 3 REG)
- Searched project-wide for tests, code files, and `@spec` annotations: none exist yet, so no arrow-path sampling was possible
- No arrow overlay (`docs/arrows/`) is installed, so `/arrow-maintenance` enumeration isn't available for this project

**Worth a second look:** I couldn't load the capability-flags reference in this run, so I'm treating its flags as applying to me — models in my class are known to miss designs that contradict a project's own tenets. I caught one (F1), but please check the leaf designs against your HLD tenets yourself.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F1/F2 are the pair I'd start with. (Note: I don't edit files from a coach run; configuration changes go through `/update-lid`, and you apply design edits directly.)

If you have broader questions about using LID itself — where PRDs fit, when to add the arrow overlay or switch modes, how to grow the design tree as printfarm gains nodes — I'm happy to help with those too.