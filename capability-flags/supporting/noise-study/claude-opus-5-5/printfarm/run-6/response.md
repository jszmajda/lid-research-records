**LID Coach — printfarm**

**Posture:** Clean, well-shaped design layer. One load-bearing design choice is working against the project's own first tenet.

**Scorecard**
- ✓ Configuration: the `## LID` block declares Full mode and the directives are present. Full mode suits a two-node project.
- ✓ HLD discipline: the HLD holds problem, approach, tenets, goals and non-goals, with no schemas or signatures leaking in.
- ✓ Linkage shape: spec IDs are unique, grep-friendly and match each LLD's `prefix:` frontmatter.
- ⚠ Tenet alignment: the job-queue design conflicts with "a submitted job is a promise."
- ⚠ Decision capture: the in-memory queue choice isn't in any Decisions table.
- ✗ Arrow completeness: the arrow stops at the specs. The repo has no tests or code, yet every spec is marked `[x]`.

**Headline:** Your HLD, LLDs and specs are tidy and readable cold, and most Decisions-table rows already name what was given up. The most valuable next step is to settle how job-queue survives a restart. Right now it drops queued jobs, which cuts against your first tenet and your overnight-print goal.

**Findings (8 total · 3 high · 3 medium · 2 low)**
- **F1 (high):** The job-queue LLD keeps accepted jobs only in memory and loses undispatched jobs on restart. The same doc says the mini-PC takes unattended OS updates and power blips. That conflicts with the tenet "a submitted job is a promise… upload and walk away" and the goal "evening upload, overnight print… no member present". The registry already uses SQLite, so a durable store is on hand · *tenets capture forward-looking preference*: tenets are the tie-breakers leaf designs should follow.
- **F2 (high):** The in-memory queue decision appears only as prose in job-queue §Architecture and has no Decisions & Alternatives row. A cold reader can't tell whether a persisted queue was considered, or that losing jobs was the cost accepted. Consider a full row naming the rejected alternative (for example, persisting the queue in SQLite like the registry) and the cost of members resubmitting. This stands apart from F1, however F1 is resolved · *docs carry current intent*: live decisions carry their tradeoffs on the page.
- **F3 (high):** There are no tests and no code in the repository, yet all 8 specs (QUEUE-001–005, REG-001–003) are marked `[x]`. The arrow can't be walked below the specs. If the implementation lives elsewhere, say where in `CLAUDE.md`. If not, the status markers are ahead of reality · *canonical arrow shape*: HLD → LLDs → EARS → Tests → Code, with each phase present or deliberately documented.
- **F4 (medium):** QUEUE-003 marks a printer "suspect", but the printer-registry LLD owns printer state and defines only unreachable/idle/busy. Nothing says what "suspect" means or when it clears. Consider moving that state into the registry LLD and specs, and having job-queue reference it · *intent attaches at the lowest node that dominates it*: substance belongs to the node that owns the concept.
- **F5 (medium):** Several LLD behaviors have no spec:
  - accepting a job only if its class has a registered printer
  - staff/member priority classes with FIFO inside each class
  - registering a printer (only retiring one is specified)
  - telling members their queued jobs were lost on restart
  
  · *effective intent-tree alignment*: behavior the LLD describes without a spec drifts silently because nothing tests it.
- **F6 (medium):** The three tenets are unordered, and tenets 1 ("a submitted job is a promise") and 3 ("the service stays small") can pull in opposite directions. F1 is exactly that conflict. Consider ordering them so the lean is explicit · *tenets capture forward-looking preference*.
- **F7 (low):** "Printer class" is used throughout (the HLD, QUEUE-002, the registry table) but never defined. It's unclear whether a class is a hardware model (the registry mentions three) or something staff assign. A cold reader has to guess · *docs carry current intent, written to be read cold*.
- **F8 (low):** QUEUE-001 says "when a *member* uploads…". Staff can also upload, so it's unclear whether the 64 MB limit applies to them. Scope the WHEN clause to match the intent · *scope disambiguation*: a spec that sounds universal should actually be universal, or name its scope.

**What was audited**
- Read in full: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`job-queue-design.md`, `printer-registry-design.md`) and both spec files.
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 spec IDs (5 QUEUE, 3 REG), 0 test files, 0 code files, 0 `@spec` annotations.
- Decisions-table sweep: all 5 rows checked. Each row either names its rejected alternative and accepted cost, or records a choice a cold reader wouldn't question. The gap is the missing row in F2.
- Not present: no `docs/arrows/` overlay, so there was no `index.yaml` to guide sampling.
- Not a git repository, so there was no history to check for tests-first evidence or cascade timing.
- This was a non-interactive run with no questions for you. The review defaulted to Full mode, as declared.

**Worth a second look:** I couldn't load the capability-flags reference in this run, so by default I'm treating the flags as applying to me. Models in my class are known to miss designs that contradict the project's own tenets. Please check both leaf designs against your HLD tenets yourself, especially "no silent reordering" and "fair access to popular printer classes".

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project, such as multi-repo setups, where PRDs fit, mode transitions, or what to do when a segment grows too large, I can help with those too.