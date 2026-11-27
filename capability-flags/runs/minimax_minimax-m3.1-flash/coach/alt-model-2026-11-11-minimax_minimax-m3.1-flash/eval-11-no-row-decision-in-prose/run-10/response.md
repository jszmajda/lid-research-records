**printfarm — LID Coach Report** (2026-11-11)

**Posture:** Design-stage arrow — clean design layer, untraced beyond EARS.

**Scorecard**
- ✗ Arrow completeness — HLD → LLD → EARS only; no Tests or Code phase exists in the repo
- ⚠ Linkage hygiene — spec IDs are clean and unique, but many described behaviors have no spec
- ⚠ LLD granularity & sufficiency — two well-formed leaves, but under-specified at the seams (UI, inter-node contract)
- ⚠ HLD discipline — architecture and rationale are clean; key decisions and success metrics are missing
- ⚠ Coherence & cascade — queue and registry both poll printers; no dependency edge recorded
- ✓ Mode fit & configuration — Full mode, `## LID` block present, clean single navigation path

The arrow is real, small, and well-formed in the parts it covers; the fastest wins are the two poller overlap and the promise-vs-durability gap, then opening the arrow's last two phases.

**Findings (12 total · 3 high · 6 medium · 3 low)**

- **F1 (high):** The queue is held "entirely in process memory" (job-queue-design.md:14) while the HLD tenet says "a submitted job is a promise" (high-level-design.md:20) — under the documented power blips and OS updates, accepted jobs vanish; no Decisions row records this trade-off · *tenets capture forward-looking preference* (lean rules for decisions a spec doesn't cover) and *decision capture* (live choices that survive only in prose)
- **F2 (high):** The arrow terminates at EARS — the repo contains no tests and no code at all, so every spec is untraced and the `[x]` markers are unverifiable · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code) and *tests before code*
- **F3 (high):** Two components poll printers for state with no contract between them: QUEUE-004 has the queue "poll each registered printer for its current job," while REG-001/002 make the registry the owner of reachability and idle state — shared design, separable behavior, boundary undefined · *effective intent-tree alignment* and *cascade within a segment, pause across*
- **F4 (medium):** Six described behaviors have no EARS coverage — staff-vs-member priority classes, "accepted only if its target class has at least one registered printer," acceptance of a valid upload, content-hash dedup, recovery from a printer marked "suspect," and the precedence of staff override vs. staff reorder · *effective intent-tree alignment* (LLD behaviors with no specs drift silently)
- **F5 (medium):** The web UI is an intent component named in the HLD Approach and the queue Context, but it has no design node and no specs — QUEUE-005 ("visible in the queue view") depends on a component nothing owns · *one LLD per intent component*
- **F6 (medium):** Load-bearing vocabulary is undefined — "suspect" (no recovery path, distinct from the registry's "unreachable"), "queue view," "printer class" (never enumerated), and "staff override" vs. "staff reorder" as two separate mechanisms for one tenet · *LLDs close enough of the solution space*
- **F7 (medium):** Per-node spec files scope their behavior as "the system SHALL …" — QUEUE-004 reads as either the queue's or the registry's obligation · *scope disambiguation* (ubiquitous-sounding specs must be actually ubiquitous)
- **F8 (medium):** The HLD has no Key Design Decisions and no Success Metrics, and its Goals are unmeasurable ("fair access to the popular printer classes") — project-global rationale currently lives only in LLDs · *HLD is architecture and rationale*
- **F9 (medium):** Tenets are unordered even though "a submitted job is a promise" and "staff override members" can collide on the same job · *tenets capture forward-looking preference* (order them when they can conflict)
- **F10 (low):** The heartbeat-interval row records a chosen value and rationale but no accepted cost — a cold reader will want to know the 45 s detection latency to unreachable · *decision capture*
- **F11 (low):** The HLD's Architecture section names design nodes but does not map them to spec prefixes (`QUEUE`, `REG`), so intent-tree alignment must be re-derived by hand each session · *specs are grep-anchored linkage*
- **F12 (low):** The `[x]` status marker has no legend anywhere — a cold reader cannot tell whether it means "accepted" or "implemented" · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design LLDs, both spec files (all 6 tracked files in the repo)
- Enumerated: 2 LLDs (prefixes `QUEUE`, `REG`), 2 spec files, 8 specs, 8 unique spec IDs, no collisions or reuse
- Code/tests: none present — the repository contains documentation only (single commit, 6 files)
- Linkage metric: 0 `@spec` annotations (no test or code phase exists to carry them)
- Overlay: `docs/arrows/` not installed, so no index or arrow docs to review

Want me to walk through the findings in detail, focus on a theme or priority (e.g. just F1 and F3), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for this project — mode transitions, when a segment grows too large, how PRDs fit, multi-repo setups — I can help with those too.