**LID Coach — printfarm review**

**Posture:** Healthy greenfield — the design layers are authored end-to-end and mutually coherent; implementation phases haven't started, and one tenet-level question is worth settling before they do.

**Scorecard**
- ✓ Mode & configuration — Full mode declared, and it fits: the whole repo is LID
- ✓ HLD discipline — architecture and rationale only; real tenets with defensible opposites
- ✓ Intent-tree alignment — `QUEUE` and `REG` prefixes trace cleanly to their LLDs and the HLD's architecture section
- ⚠ Tenet cascade — the restart design works against the HLD's own "promise" tenet
- ⚠ LLD→EARS coverage — a few LLD-stated behaviors have no spec
- ⚠ Arrow completeness — Tests and Code not yet started; spec status markers outrun that reality

**Headline:** The arrow is genuinely walkable — two clean design nodes, tight EARS, decisions tables that mostly pass a cold read. The most valuable next step is resolving the queue-persistence-vs-promise question (F1/F2) *before* code exists, while it's still a one-table-row fix.

---

**Findings (6 total · 2 high · 3 medium · 1 low)**

- **F1 (high):** The in-memory queue drops accepted-but-undispatched jobs on restart — and the LLD's own Context names the triggering conditions (unattended OS updates, power blips) — which defeats the tenet "a submitted job is a promise" and the "evening upload, overnight print, morning pickup" goal under exactly the operating conditions these docs describe; no Decisions row records the tradeoff · *tenet cascade* (do the design nodes lean the way the HLD's tenets say to lean?)
- **F2 (high):** That same restart-loss choice survives only in Architecture prose — a cold reader would question it (the registry persists to SQLite; why doesn't the queue?), and can't reconstruct what was given up. Consider a fuller Decisions & Alternatives row naming the tenet traded and the persistence alternative · *decision capture* (choices a cold reader would still question belong on the record)
- **F3 (medium):** QUEUE-003 marks a printer "suspect," but no doc defines that state — the registry's state model is idle/busy/unreachable. Either define it in the registry leaf (where printer state lives) or give it a spec; right now the concept dangles between segments · *coherence is adjacency* (each level agrees with its neighbors)
- **F4 (medium):** Three LLD-stated behaviors have no EARS: acceptance requires ≥1 registered printer in the class; staff jobs outrank member jobs; restart-loss behavior itself. Unnamed intent drifts silently because there's nothing to test against · *effective intent-tree alignment* (LLD behaviors with no specs)
- **F5 (medium):** All eight specs carry `[x]` markers with zero code and zero tests in the repo, and the convention isn't defined in CLAUDE.md. Future sessions will read that as "implemented." Either define what the marker means in the instruction file or set them to reflect reality · *intent leads; code is compiled output* (status should not claim more than the repo holds)
- **F6 (low):** The HLD goal "fair access to the popular printer classes" has no owning mechanism beyond staff reordering — and the FIFO decision's own rationale concedes a long job can hold a class for hours. A one-line note in the job-queue LLD stating what "fair" means here (or a spec) would close the gap · *tenets capture forward-looking preference* (goals without a node leave future sessions guessing)

---

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files — the repo's entire tracked surface (6 files)
- Code/test sampling: none possible — the repo contains no code or test files yet; no `docs/arrows/` overlay present
- Decisions & Alternatives rows reviewed: 5, all pass the cold-read test except the restart-loss choice (F2)
- Cold-read pass: performed on all five LID docs; residues and conversational fossils: none found — the docs read as freshly authored

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? F1 and F2 are a natural pair to dig into first — the fix is likely one Decisions-table row plus a tenet decision only you can make.

If you have broader questions about using LID for your project — when to start the tests-first phase in a greenfield like this, whether the arrow overlay is worth adding yet, how to handle the status-marker convention — I can help with those too.