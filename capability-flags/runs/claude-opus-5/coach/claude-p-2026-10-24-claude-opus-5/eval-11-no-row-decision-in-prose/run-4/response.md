**LID Coach — printfarm**

## 1. Executive summary

**Posture:** Well-formed arrow, thin at the ends — strong design layer, missing downstream phases and one load-bearing decision.

**Scorecard**
- ✓ Configuration — `CLAUDE.md` carries the directive, `Mode: Full`, and a navigation table; nothing to reconcile
- ✓ HLD discipline — architecture and rationale only, no schemas or signatures bleeding upstream
- ✓ Linkage shape — both leaves declare `prefix:` and `parent:`, every spec ID resolves to its leaf, no collisions or churn
- ⚠ Intent-tree alignment — several described behaviors (prioritization, registration, file retention) have no spec
- ✗ Arrow completeness — no tests and no code in the repo, yet all eight specs are marked `[x]`
- ⚠ Tenet cascade — the in-memory queue works against *"a submitted job is a promise"* under conditions the design itself names

**Headline:** For a two-node project this is unusually disciplined — clean EARS, real tenets with defensible opposites, and Decisions rows that name what was given up (the shortest-job-first row is a model of the form). The highest-value next step is the durability question: the job-queue design chooses a memory-only queue on a machine it describes as taking unattended reboots, and that choice is both unrecorded and in tension with the HLD's central promise.

## 2. Findings inventory

**Findings (11 total · 4 high · 6 medium · 1 low)**

- **F1 (high):** The memory-only queue loses accepted-but-undispatched jobs across the restarts and power blips `job-queue-design.md:10` itself describes — defeating the tenet *"a submitted job is a promise: members should be able to upload and walk away"* and the goal *"evening upload, overnight print, morning pickup"*; no row records the trade · *tenet cascade / keep the arrow coherent*
- **F2 (high):** The durability choice (in-process memory, resubmit after restart) has no Decisions & Alternatives row at all, while the sibling node persists far less critical state to SQLite — a cold reader would reach for the reverse immediately · *decision capture*
- **F3 (high):** The arrow stops at EARS — no tests, no code — while all eight specs carry `[x]`, so the status markers can't be trusted on the next read · *coherence is adjacency*; *tests before code*
- **F4 (high):** `QUEUE-003` and `job-queue-design.md:21` mark a printer "suspect," but the registry — the node that owns printer state — has no suspect state and no spec for it; the substance lands in the wrong leaf and crosses a node boundary unannounced · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F5 (medium):** `## Prioritization` (two priority classes, FIFO within) is described design with no spec anywhere — unnamed intent with nothing to test against · *effective intent-tree alignment*
- **F6 (medium):** The registry describes staff registration and a 15 s heartbeat poll but specs only cover retirement (`REG-003`); registration and the polling cadence are spec-less · *effective intent-tree alignment*
- **F7 (medium):** The content-hashed on-disk G-code store has no spec and no stated lifecycle — nothing says when files leave, on a disk the HLD calls modest · *LLDs close enough of the solution space*
- **F8 (medium):** Printer state vocabulary is never enumerated — "idle," "busy," "unreachable," "suspect" appear across three files, each introduced in passing; a cold reader has to assemble the set · *docs carry current intent, written to be read cold*
- **F9 (medium):** The three tenets are an unordered list, yet *"a submitted job is a promise"* and *"the mini-PC is modest hardware; the service stays small"* pull opposite ways — precisely the conflict F1 resolves silently · *tenets capture forward-looking preference*
- **F10 (medium):** `QUEUE-005` specifies behavior in "the queue view," and the HLD names a member/staff web UI, but no design node owns it — the UI is intent with no home in the tree · *one LLD per intent component*
- **F11 (low):** Base32 slugs "recycle after 90 days" is recorded as an accepted cost but has no spec governing collision with older references · *effective intent-tree alignment*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 leaf design nodes, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), 3 tenets, 2 goals, 2 non-goals, 5 Decisions rows
- Arrow-path walked: both segments end-to-end (HLD §Architecture → leaf design → specs → tests → code); both terminate at the spec phase
- Repo sweep: 6 files total, no source or test directories present, so `@spec` annotation coverage was not applicable rather than sampled
- Overlay: `docs/arrows/` absent — no structural index to cross-check against; no `[inferred]` markers found
- Cold-read pass: completed on all four LID docs

## 4. Offer to help

Want me to walk through any of these in detail, focus on a theme (the durability thread F1–F2 is the one I'd start with) or a priority band, or work through specific items together? Pick a finding and I'll go deep on it — F3 and F10 in particular have more than one reasonable remedy worth weighing.

If you have broader questions about using LID on printfarm — when a leaf like `job-queue` earns a promotion to a sub-HLD, how to seed tests-first from specs that are already marked done, where a web-UI node belongs in the tree, or what to do about status markers during a bootstrap phase — I can help with those too.