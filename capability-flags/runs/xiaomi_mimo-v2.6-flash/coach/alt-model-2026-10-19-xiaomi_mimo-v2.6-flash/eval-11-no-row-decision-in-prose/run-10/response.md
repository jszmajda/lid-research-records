# LID Coach Report — printfarm

**Posture:** Bootstrapping — the intent layer is tight and well-formed; status markers and one unrecorded tenet trade are the main drift.

**Scorecard**
- ✓ Configuration — directives, `## LID` mode marker (Full), and navigation all present and coherent
- ✓ HLD discipline — architecture-level rationale only; tenets are genuine tie-breakers with defensible opposites
- ✓ LLD granularity — two leaves cleanly matching the HLD's two nodes, no lumping or scatter
- ✗ Status markers — all 8 specs marked `[x]` ("implemented") with zero code and zero tests in the repo
- ⚠ Tenet cascade — the "submitted job is a promise" tenet meets the in-memory queue under a power blip, with no recorded exception
- ⚠ Arrow completeness — HLD → LLD → EARS exist; the Tests and Code phases haven't been walked yet

**Headline:** The docs are a genuinely good start — a lean HLD with real tenets, two focused LLDs with strong Decisions rows, and clean unique spec IDs; the fastest wins are correcting the `[x]` markers and recording the durability trade against the promise tenet before any code gets written.

**Findings (8 total · 2 high · 4 medium · 2 low)**
- **F1 (high):** every spec in both files is marked `[x]` while the repo contains no code and no tests — the marker means "code and tests exist" · *intent leads; code is compiled output* (specs are the source of truth; markers that over-claim make every future session hunt for implementation that isn't there, and the marker loses its meaning as a signal)
- **F2 (high):** the queue lives only in process memory and restarts discard accepted jobs, yet the HLD tenet says a submitted job is a promise and members can walk away — the Context even names "the occasional power blip," and no exception is recorded anywhere · *tenet cascade* (do the design nodes lean the way the tenets say to lean?)
- **F3 (medium):** the durability choice — in-memory queue vs. persisting accepted jobs — has no row in job-queue's Decisions & Alternatives table; a cold reader hits it immediately and can't reconstruct what was given up · *decision capture* (docs carry current intent — the keep-side and its ceiling)
- **F4 (medium):** QUEUE-003 marks a printer "suspect," a state defined nowhere in printer-registry's design or specs (which only know idle/busy/unreachable) · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across* (substance that governs the registry is lodged in the queue leaf) — also a cross-file concept with no inline context per *scope disambiguation*
- **F5 (medium):** two LLD behaviors have no spec anywhere — job acceptance requires "at least one registered printer" of the target class, and staff printer *registration* appears only in Context while only retirement got REG-003 · *effective intent-tree alignment* (an LLD behavior with no spec is unnamed intent that drifts silently because nothing tests against it)
- **F6 (medium):** the arrow stops at EARS — 8 behavioral specs with no tests or code citing them · *tests before code* and *canonical arrow shape* — when implementation starts, walk it tests-first so each spec gets its citation rather than retro-fitting annotations
- **F7 (low):** QUEUE-005 (visible reordering) and REG-002 (recovery to idle/busy) state behavior their owning LLDs only imply · *coherence is adjacency* (specs and LLDs drifting at the seam)
- **F8 (low):** cold-read wobbles: "slugs recycle after 90 days" never says what recycling means, and "printer class" (HLD/queue) vs. "hardware model" (registry) are never equated · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files — the entire repo (single `fixture` commit)
- Enumerated: 2 LLDs, 2 spec files, 8 spec IDs (QUEUE-001–005, REG-001–003), 5 Decisions rows, 3 tenets
- Arrow overlay absent (`docs/arrows/` doesn't exist) — no index to guide sampling
- Code/test sample: 0 source files, 0 test files, 0 `@spec` references (nothing exists to sample yet)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.