# LID Coach — printfarm

**Bootstrapping — a clean, well-linked arrow through EARS, with one high-impact tenet conflict to settle.**

**Scorecard**
- ✓ Configuration & mode — `linked-intent-dev` directive and `- Mode: Full` present; Full fits this docs-only project
- ✓ Spec hygiene — 8 EARS specs, unique `QUEUE`/`REG` IDs, scope kept in WHEN clauses, no `[obsolete]`/`[inferred]` residue
- ✓ Decisions & mutation hygiene — every Decisions row names its alternative and accepted cost; no history residue
- ⚠ Tenet cascade — the job-queue design cuts against "a submitted job is a promise" under its own restart conditions
- ⚠ Decision capture — the durability choice is live but lives only in prose, with no Decisions row
- ✗ Arrow completeness — no Tests or Code phases yet; no `@spec` linkage established

The HLD, both LLDs, and all eight specs are clean and well-aligned (frontmatter prefixes match spec prefixes, EARS is consistent, scopes are stated) — the fastest win is settling one contradiction at the top: the in-memory queue drops promised jobs on restart, even though the HLD's first tenet and its core goal say the member should be able to walk away.

**Findings (5 total · 2 high · 3 medium)**
- **F1 (high):** The job-queue LLD keeps accepted jobs "entirely in process memory" and drops them on restart ("members resubmit them"); under its own unattended-OS-update / power-blip condition this defeats the tenet "A submitted job is a promise" and the "evening upload … no member present" goal, and no Decisions row records the trade · *tenets capture forward-looking preference* — tenets pre-narrow the lean for choices no spec covers
- **F2 (high):** The in-memory-queue / drop-on-restart choice is one a cold reader would question or reverse (accepted "promised" jobs vanish, while the registry persists less-critical state in SQLite), yet it survives only in Architecture prose — none of the three Decisions & Alternatives rows covers it · *docs carry current intent* — docs are written to be read cold; live choices belong in the Decisions table so a future reader can reconstruct what was given up
- **F3 (medium):** The three tenets are an unordered bullet list, though "a submitted job is a promise" (durability) and "the service stays small" (simplicity) pull opposite ways on whether the queue must persist — consider ordering them or naming which wins · *tenets capture forward-looking preference* — tenets are tie-breakers for decisions no spec covers; an unordered set leaves the lean un-narrowed
- **F4 (medium):** Two LLD behaviors have no covering spec — "a job is accepted only if its target class has at least one registered printer" (`job-queue-design.md`) and "staff register … printers" (`printer-registry-design.md`) · *effective intent-tree alignment* — every behavior should trace to a spec ID, so none drifts untested
- **F5 (medium):** There are no test or code files; all 8 specs carry `[x]` but no test cites a spec ID and no code carries an `@spec` annotation, so the Tests → Code legs aren't authored yet · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code; *tests carry @spec annotations* — each test cites the spec it exercises

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/` — 6 files, the entire repository
- Enumerated: 2 LLDs (prefixes `QUEUE`, `REG`), 2 spec files, 8 EARS specs (all `[x]`), 5 Decisions & Alternatives rows
- Cold-read pass over all 5 LID docs as if read fresh; decisions-table sweep over all 5 rows
- Sampled: no code or test files exist in the repo, so entry-point `@spec` placement and semantic legibility could not be sampled; 0 `@spec` references found
- No `docs/arrows/` overlay present; Full mode → whole repo in scope

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.