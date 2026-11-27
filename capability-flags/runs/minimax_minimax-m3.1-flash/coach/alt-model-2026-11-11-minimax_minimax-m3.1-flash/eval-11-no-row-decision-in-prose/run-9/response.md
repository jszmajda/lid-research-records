## LID Coach — printfarm

### 1. Executive summary

**Posture:** *Bootstrapping — arrow in place through EARS, content thin and partly uncoupled.*

**Scorecard**
- ✓ **HLD discipline** — clean architecture-and-rationale; no schemas, signatures, or pseudocode leaking upstream
- ✓ **Linkage & IDs** — 8 unique, zero-padded, prefix-scoped spec IDs; no collisions, no ID residue
- ✗ **Arrow completeness** — the arrow stops at EARS: no tests, no code, yet every spec is marked `[x]`
- ⚠ **Spec coverage** — several LLD behaviors (acceptance rule, priority classes, registration, queue contract) have no spec
- ⚠ **Decision capture & tenet cascade** — durability and fairness trade-offs live in prose and collide with HLD tenets/goal without a recorded exception
- ⚠ **Cross-node coherence** — the registry→queue contract and the `suspect` printer state are undefined across the seam
- ✓ **Configuration & mode fit** — `CLAUDE.md` declares `linked-intent-dev`, `Mode: Full`, and the standard paths; Full mode fits a project this focused

**Headline:** The intent layer is unusually clean for a project this young — the HLD stays architectural and the two LLDs read as current intent — but the arrow has no terminal phases and the specs claim completion that no implementation backs; the fastest wins are closing the spec-coverage gaps and recording the two decisions (durability, fairness) that currently contradict the HLD's own tenets.

---

### 2. Findings inventory

**Findings (11 total · 4 high · 5 medium · 2 low)**

- **F1 (high):** all 8 specs are marked `[x]` while the repo contains zero tests and zero source files — status markers report implemented intent that does not exist, and the arrow stops at EARS (*intent leads; code is compiled output* — specs are the source of truth; the compiled result must exist to be the result)
- **F2 (high):** the in-memory-queue / jobs-lost-on-restart decision has no row in Decisions & Alternatives, and it collides with the HLD tenet "a submitted job is a promise" and the overnight goal, with no exception recorded (*docs carry current intent* — a decision that survives only in prose will not survive the next session; *tenets capture forward-looking preference* — when a mechanism works against a tenet, the trade is named)
- **F3 (high):** job-queue LLD behaviors with no spec anywhere: the acceptance rule ("target class has at least one registered printer"), the two priority classes with FIFO within class, the loss of accepted jobs across restart, the content-hash dedup, and acceptance of files ≤ 64 MB (*effective intent-tree alignment* — LLD behaviors with no specs are unnamed intent that drifts silently)
- **F4 (high):** the registry→queue contract is uncontracted: QUEUE-002 depends on "the registry reports a printer idle," but no registry spec states that reporting, and no spec covers staff registering a printer or the 15 s poll cadence (*effective intent-tree alignment*; *intent attaches at the lowest node that dominates it* — a decision governing both nodes belongs at their shared parent)
- **F5 (medium):** `suspect` appears in QUEUE-003 as a printer state, but the registry LLD's state model (id, class, network address, state) knows only idle/busy/unreachable, and the queue is the one marking it (*cascade health* — adjacent levels must agree at the seam)
- **F6 (medium):** two polling mechanisms coexist without explanation — the registry's 15 s heartbeat and QUEUE-004's startup poll of every printer's current job — and the second bypasses the first (*cascade health*; *docs carry current intent* — a fresh author would have to re-derive which mechanism owns printer state)
- **F7 (medium):** the FIFO decision explicitly accepts "one long job can hold a class for hours," which is the monopolization pain named in the HLD Problem, while the HLD goal "fair access to the popular printer classes" has no mechanism (no aging, no residency cap, no member-visible wait estimate) and no decision row names the goal traded against (*tenet cascade* — name the goal, the mechanism, and the condition)
- **F8 (medium):** the "Job identifiers — short base32 slugs" row records the accepted cost (recycling after 90 days) but not why the 90-day window or why base32; a cold reader holding this row and the docs above it would still question it (*docs carry current intent* — the keep-side: rationale survives, but an unexplained accepted cost reads as an accident)
- **F9 (medium):** the tenet "The mini-PC is modest hardware; the service stays small" restates a constraint rather than breaking a tie between defensible alternatives, and the three tenets are unordered even though "service stays small" can conflict with "the queue explains itself" (*tenets capture forward-looking preference* — a tenet's reverse must be a choice a different project could reasonably make)
- **F10 (medium):** cold-read gaps a future session cannot resolve from the page: "queue view" (QUEUE-005) and "farm state" (QUEUE-004) are never defined; "short base32 slugs" states no length or alphabet (*docs carry current intent, written to be read cold* — lost implicit context is the residue that compounds)
- **F11 (low):** the two doc types use different linkage conventions — LLDs carry YAML frontmatter (`parent:`, `prefix:`), spec files carry a bold `**LLD**:` markdown line and no `prefix:` — so an agent must open the design doc to learn a spec file's namespace (*minimum surface, maximum discipline* — one convention for the same job)
- **F12 (low):** no `docs/arrows/` overlay is installed, so structural enumeration (reverse orphans, prefix resolution, coverage by segment) is unavailable; that is not drift, but once code lands `/arrow-maintenance` is the right tool for the precise pass (*coherence is adjacency*)

---

### 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`job-queue-design.md`, `printer-registry-design.md`), both spec files (`job-queue-specs.md`, `printer-registry-specs.md`)
- Enumerated: 2 design nodes, 8 specs (5 `QUEUE-*`, 3 `REG-*`), all prefix-scoped and zero-padded
- Arrow-path sampled: 0 end-to-end — the repository contains no source or test files, so the Tests and Code phases could not be traced
- Linkage metric: 0 `@spec` annotations (no code or tests exist); spec IDs referenced only from their sibling design docs
- Repository history: a single commit, no prior implementation to compare against
- Overlay: `docs/arrows/` absent — no arrow docs, no index to read

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.