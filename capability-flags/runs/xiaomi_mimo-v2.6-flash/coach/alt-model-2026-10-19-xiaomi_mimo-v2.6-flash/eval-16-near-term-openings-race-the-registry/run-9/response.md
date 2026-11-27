# LID Coach — Visit Planner

**Posture line:** *Bootstrapping — design tree in place, arrow not yet walkable; configuration needs reconciliation.*

**Scorecard**
- ✗ Arrow completeness — HLD → LLD → EARS exists; no tests, no code, and nothing on the page saying that's intentional
- ⚠ Configuration — the `## LID` block declares Mode and Version but carries no linked-intent-dev directives
- ⚠ Tenet cascade — same-day checkout leans against *first asked, first served* with no recorded exception
- ⚠ LLD sufficiency — "compatible", "invalid", "complete preferences", and the two-hour offer window are named but never defined
- ✓ Mutation hygiene — no changelogs, no `[obsolete]` markers, no planning residue in any doc
- ✓ Mode fit — Full mode matches a repo where every path is under LID

**Headline:** The design layer is real and tight — two LLDs that mirror the HLD's components exactly, 15 collision-free specs that cover nearly all LLD behavior, and tenets that actually read as tie-breakers. The single most valuable next step is running `/update-lid` to restore the directive block in `CLAUDE.md`, so every future session knows this project is walked under LID.

**Findings (12 total · 3 high · 8 medium · 1 low)**
- **F1 (high):** `CLAUDE.md:5-8` has the `## LID` mode marker but no directive naming linked-intent-dev — a future agent sees a mode with no workflow attached · *modes are declared, not inferred* (a mode nobody is told to act on is a default) → `/update-lid`
- **F2 (high):** the arrow stops at EARS — 15 specs with zero tests and zero code, and no line in the instruction file or HLD saying design-first is deliberate · *canonical arrow shape* (`HLD → LLD → EARS → Tests → Code`; undocumented missing phases are drift, not a plan)
- **F3 (high):** `fulfillment-design.md:9` lets any eligible signed-in account claim a published same-day opening, which passes an earlier request — directly against the tenet "an earlier request is never passed by one made after it", with no Decisions row naming the trade · *tenet cascade* (mechanism defeats a tenet under a described condition with no recorded exception)
- **F4 (medium):** the ≤36h publish-plus-20-minute-scan design has no Decisions row — a cold reader can't reconstruct what was given up (queue fairness, scan latency) · *decision capture* (the default capture for a live decision is a fuller row)
- **F5 (medium):** compatibility, eligibility, validity, and "complete preferences" (`intake-design.md:4`, `INTAKE-001/002`, `FILL-001/006`) are load-bearing but undefined — two agents will close those edges differently · *LLDs close enough of the solution space* (open edges are where intent drift enters, session after session)
- **F6 (medium):** the two-hour offer duration (`fulfillment-design.md:7`) lives only in the LLD; `FILL-002` fires on expiry but nothing fixes the window, so behavior exists with nothing to test against · *effective intent-tree alignment* (LLD behaviors with no spec drift silently)
- **F7 (medium):** every spec is marked `- [x]` and nothing on the page says what that means — implemented? approved? — while no implementation exists; a status convention that only resolves for its author · *docs carry current intent* (in-conversation-only meaning)
- **F8 (medium):** cold-read vocabulary doesn't resolve: "registry scan" appears in fulfillment with no registry defined anywhere; "authenticated account" (`INTAKE-001`) vs "eligible signed-in account" (`FILL-004`) vs patients/staff (HLD §Approach); `FILL-007` writes "the notification" with no antecedent · *docs carry current intent* (read to be read cold)
- **F9 (medium):** the HLD carries Problem, Approach, Tenets, and Goals but no non-goals, no success metrics, and no key design decisions — scope questions ("is SMS in scope?") have nothing to resolve against · *HLD is architecture and rationale*
- **F10 (medium):** `FILL-004`'s scope rides on the word "published", defined only in sibling `FILL-003`; grepped out of context, checkout reads as available for any free opening · *scope disambiguation* (litmus: a second publish variant would make it ambiguous)
- **F11 (medium):** changing requested service closes the entry and issues a new `enteredAt` (`intake-design.md:7`) — forfeiting queue position with no row explaining why · *decision capture*
- **F12 (low):** the `FILL-` prefix abbreviates the leaf path `fulfillment` while `INTAKE-` doesn't abbreviate — mild inconsistency in *specs are grep-anchored linkage*; IDs are stable once assigned, so this is worth one deliberate call now, while nothing consumes them

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (7 intake, 8 fulfillment), 0 arrow segments (no `docs/arrows/` overlay)
- Sampled: code and tests — none exist; linkage metric: 0 `@spec` references across 0 code files
- Sampling strategy: judgment mode (below the 15-LLD / 200-file threshold, no overlay index)

**Defaults taken (non-interactive run):** dispatch landed on row 2 of the table — instruction file present but missing the linked-intent-dev directive block, while the project is clearly LID-shaped — so I proceeded with a **full review anchored on the existing artifacts, treating the declared `Full` mode as authoritative**; the missing directive block surfaced as high-priority F1 pointing at `/update-lid`. Per the advisory posture I made **no file changes** — the report is rendered inline and not persisted to disk, and no remedies were applied.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.