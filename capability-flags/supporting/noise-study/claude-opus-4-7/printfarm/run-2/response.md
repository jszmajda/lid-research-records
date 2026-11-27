# LID Coach — printfarm

**Posture: Bootstrapping — upstream arrow in place and coherent, downstream not yet built, with two coherence gaps worth closing before code starts.**

**Scorecard**
- ✓ Configuration — LID directives present, `Mode: Full` declared, standard layout
- ✓ Linkage — spec IDs grep-anchored (QUEUE-\*, REG-\*); prefixes in leaf frontmatter match spec IDs; each leaf owns its EARS
- ✓ LLD granularity — two leaves match the two design nodes named in the HLD; no lumping, no over-fragmentation
- ⚠ HLD/LLD coherence — the Approach commits to a web UI, but the Architecture names only two design nodes and no leaf owns UI intent
- ⚠ Cold-read clarity — "printer class" is load-bearing across HLD and both LLDs but never defined
- ⚠ Tenet quality — one tenet blends a real lean with a triggered rule already encoded as an EARS spec

**Headline: The design side is small, tidy, and internally consistent — the fastest wins are naming where UI intent lives and defining "printer class" before any code lands, so the arrow is clean the first time a session walks it.**

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** HLD Approach commits to a web UI but no design node owns UI intent · *one LLD per intent component — a "thing" the user would name gets its own leaf*
- **F2 (high):** "Printer class" is load-bearing across HLD and both LLDs but never defined; a cold reader has no way to know what it means · *docs carry current intent, written to be read cold*
- **F3 (medium):** QUEUE-001 scopes to "a member uploads" — is the 64 MB limit also enforced on staff uploads? · *scope disambiguation — a universal-sounding spec must be actually universal or say what it excludes*
- **F4 (medium):** Tenet 2 blends a lean ("staff override members") with a triggered rule ("no silent reordering") already encoded as QUEUE-005 · *tenets capture forward-looking preference — leans, not spec-shaped rules*
- **F5 (low):** Design side of the arrow is complete; tests and code are not yet started — worth a tests-first plan before implementation lands · *tests before code — the test is the first consumer of the API*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and every file under `docs/intent/` (`job-queue-design.md`, `job-queue-specs.md`, `printer-registry-design.md`, `printer-registry-specs.md`)
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 EARS specs (5 QUEUE-\*, 3 REG-\*)
- Arrow-path sampling: not applicable — no `docs/arrows/index.yaml`, no code, no tests. Design layer walked end-to-end (HLD § Architecture → LLD → EARS) for both segments.
- Instruction-file coherence: `## LID` block present with `Mode: Full` and `Version: 1.4.0`; the "linked-intent-dev" directive reference is current (no precursor naming).

## Worth a second look

I couldn't reach the sibling core skill's `references/capability-flags.md` from this eval sandbox, so I couldn't place my model class against known blind spots. Per the coach's own guidance the flags should be treated as applying — please spot-check the tenet section and the leaf-vs-HLD coherence yourself (a design that quietly contradicts a project's own tenet is a class of miss my model is not reliably good at catching).

## Offer to help

Want me to walk through the findings in detail, focus on the two high-priority ones (F1 and F2), or work through a specific finding together? You can also pick one to dig into.

If you have broader questions about using LID for printfarm — where a UI leaf would fit in this arrow, when to add a third design node vs. fold UI into an existing one, or how much design to commit before the first spike — I can help with those too.