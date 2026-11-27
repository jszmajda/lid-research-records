Good — `linked-intent-dev` is present in CLAUDE.md ("Consult the linked-intent-dev skill."), so the project is fully configured. The capability-flags file is outside my accessible directories; I'll treat the flags as applying per the skill's guidance.

---

# LID Coach Report — printfarm

**Posture:** Bootstrapping solid — arrow well-shaped, a few key gaps worth closing before moving into the code phase.

**Scorecard**
- ✓ Configuration — directives, mode marker (`Full`), and standard directories all in place
- ✓ HLD discipline — clean architecture and rationale; no implementation detail bleeding upstream
- ✓ LLD granularity — 1:1 match with the two architecture nodes; no lumping, no fragmentation
- ✓ Mutation hygiene — no change-narration, no obsolete markers; both docs read as live intent
- ⚠ Tenet/design coherence — tenet 1 ("a submitted job is a promise") sits in tension with the volatile in-process queue
- ⚠ Decision capture — the volatile-queue architectural choice has no Decisions-table row
- ⚠ Arrow completeness — code and tests not yet present; `[x]` spec markers ambiguous in that context

**Headline:** Both LLDs are clean, well-separated, and grounded in good rationale; the fastest wins before moving to implementation are capturing the volatile-queue decision, addressing the tenet-vs-durability tension, and filling in the missing specs that describe behaviors already written into the LLD prose.

---

**Findings (7 total · 1 high · 5 medium · 1 low)**

- **F1 (high):** HLD tenet 1 ("a submitted job is a promise: members should be able to upload and walk away") conflicts with the job-queue LLD's explicit design choice that accepted-but-not-dispatched jobs are lost on restart · *coherence is adjacency* (adjacent levels must agree) / *tenets capture forward-looking preference* (tenets are load-bearing tie-breakers, not aspirations)
- **F2 (medium):** The volatile in-process queue is the single most consequential architectural choice in the system — it trades off the promise tenet against simplicity — yet has no row in the job-queue Decisions table · *decision capture* (decisions a cold reader would question or try to reverse deserve a captured rationale)
- **F3 (medium):** The cross-component interface between job-queue and printer-registry is unspecified in both LLDs: neither says how the registry surfaces an "idle printer" event to the queue (push callback, shared polling loop, in-process subscription?) · *LLDs close enough of the solution space* (a good LLD is specific enough that two implementers land on compatible implementations)
- **F4 (medium):** Two behaviors described in the LLD body have no EARS spec: the job-acceptance guard ("only if target class has at least one registered printer") and priority ordering (staff before member, FIFO within class) · *specs are grep-anchored linkage* (every exercised behavior gets a stable, greppable ID)
- **F5 (medium):** The printer-registry specs cover heartbeat failure (REG-001), recovery (REG-002), and retirement (REG-003), but there is no spec for staff adding a new printer to the registry · *arrow completeness* (each phase exists for each component's full behavior surface)
- **F6 (medium):** "Class" is the core matching concept that links job dispatch to printer selection across both LLDs, but it is never defined — neither LLD says what a class is, how it relates to the "three hardware models" the context mentions, or whether staff configure it · *LLDs close enough of the solution space*
- **F7 (low):** All specs carry `[x]` checkbox markers, which a cold reader reads as "implemented," but no code is present yet; if the intent is to track spec status, consider using LID's standard status conventions or documenting this custom marker in CLAUDE.md · *minimum surface, maximum discipline* (custom conventions create learning overhead and drift from LID's own evolution)

---

**What was audited**
- Read fully: CLAUDE.md, `docs/high-level-design.md`, `docs/intent/job-queue/job-queue-design.md`, `docs/intent/job-queue/job-queue-specs.md`, `docs/intent/printer-registry/printer-registry-design.md`, `docs/intent/printer-registry/printer-registry-specs.md`
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (QUEUE-001–005, REG-001–003)
- Arrow-path sampling: full intent layer read; no source code or test files present to sample
- No `docs/arrows/` overlay present

---

**Worth a second look:** The capability-flags file for this model class was not accessible during this review, so I'm treating all flags as applying. One known flag for models in my class is missing designs that contradict the project's own tenets — F1 names one such tension, but please also check tenets 2 and 3 against the LLD content yourself to confirm I haven't missed a second conflict.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.