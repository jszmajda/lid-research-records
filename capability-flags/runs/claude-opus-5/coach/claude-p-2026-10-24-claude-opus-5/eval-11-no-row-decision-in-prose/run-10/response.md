**LID Coach — printfarm**

## 1. Executive summary

**Posture:** Design layer in good shape; the arrow stops at EARS, and one tenet is quietly traded away.

**Scorecard**
- ✓ **Mutation hygiene** — every doc reads as current intent; no changelogs, no `[obsolete]` residue, no "was X, now Y"
- ✓ **HLD discipline** — problem/approach/tenets/goals/non-goals, and not a line of schema or signature leaking upstream
- ✓ **Configuration & mode fit** — `## LID` block is well-formed, Full mode suits a two-node whole-repo project
- ⚠ **Intent-tree alignment** — several designed behaviors (prioritization, admission, upload storage) have no spec; the web UI has no node
- ⚠ **Cascade / cross-node coherence** — `job-queue` assigns a printer state the registry has never heard of
- ✗ **Arrow completeness** — all 8 specs are marked `[x]`, but there are no tests and no code in the repo
- ✗ **Tenet cascade** — the in-memory queue defeats "upload and walk away" under conditions the design itself describes

**Headline:** The two design nodes are genuinely good — tight Context sections, real Decisions & Alternatives rows with the cost of each choice named, and specs that trace cleanly to their leaf prefixes. The highest-value next step is the volatility of the queue: it works against your first tenet under a restart you explicitly anticipate, and no decision row records that trade.

## 2. Findings

**Findings (11 total · 4 high · 5 medium · 2 low)**

- **F1 (high):** The in-memory queue drops accepted-but-undispatched jobs on restart, and `job-queue-design.md:10` names unattended OS updates and power blips as normal — under that condition a member who uploaded and walked away loses the job, defeating the tenet *"a submitted job is a promise"* and the goal *"evening upload, overnight print, morning pickup — with no member present"*; no decision row records the exception · *tenet cascade / keep the arrow coherent — design nodes should lean the way the HLD's tenets say to lean, or record the trade*
- **F2 (high):** Holding the queue in process memory while persisting G-code on disk under a content hash is the load-bearing choice of the node, and it has no Decisions & Alternatives row at all — a cold reader hits "members resubmit them" and immediately wants to reverse it · *docs carry current intent — a decision that stays live once landed needs its row*
- **F3 (high):** All 8 specs carry `[x]` status markers, but the repo holds no tests, no code, and no `@spec` annotations — the arrow's last three phases are absent, so nothing downstream protects the intent those markers claim is landed · *canonical arrow shape*; *tests carry `@spec` annotations*
- **F4 (high):** `job-queue-design.md:21` and QUEUE-003 mark a printer *suspect*, but printer state is owned by `printer-registry`, whose design and specs know only unreachable/idle/busy — substance that governs a sibling node sits in one leaf, and the registry never cascaded · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F5 (medium):** The HLD promises a member web UI with staff reordering rights (`high-level-design.md:9`), but Architecture declares two design nodes and neither owns it — observed intent with no node to hold it · *one LLD per intent component*
- **F6 (medium):** Designed behaviors with no spec anywhere: the two-priority-class FIFO ordering, the admission rule that a class must have a registered printer, content-hash upload storage, and staff *registering* a printer (only retirement has a spec) · *effective intent-tree alignment — LLD behaviors with no spec are unnamed intent*
- **F7 (medium):** Dispatch is described as event-driven "when the registry reports a printer idle," while the registry derives state from a 15 s poll — no doc says how that transition reaches the queue, so two reasonable agents would build different seams · *LLDs close enough of the solution space*
- **F8 (medium):** The tenets are unordered, yet "a submitted job is a promise" and "the service stays small" collide precisely at F1; tenet 2 also bundles a tie-breaker (staff override members) with a triggered rule (no silent reordering) that already lives as QUEUE-005 · *tenets capture forward-looking preference*
- **F9 (medium):** "Slugs recycle after 90 days" implies a job-retention lifetime that no other line of design or spec carries · *LLDs close enough of the solution space*
- **F10 (low):** QUEUE-001 scopes the 64 MB limit to "when a member uploads," while staff are a distinct actor elsewhere in the design — grepped cold, it reads as if staff uploads are unbounded · *scope disambiguation*
- **F11 (low):** "Printer class" is load-bearing vocabulary in both nodes, but no doc says what defines a class or who assigns it · *semantic legibility as cheap linkage*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 leaf design nodes (prefixes `QUEUE`, `REG`), 2 spec files, 8 EARS specs — all `[x]`
- Downstream sweep: 0 source files, 0 test files, 0 `@spec` annotations found anywhere in the repo
- Arrow overlay: not installed (`docs/arrows/` absent), so no structural enumeration was available — if you want orphan/reverse-orphan counts precisely, `/arrow-maintenance` is the tool for that once code exists
- Cold-read pass: all five LID docs, read without conversation context

## 4. Offer to help

Want me to walk through any of these in detail, focus on a theme (the tenet/decision cluster in F1–F2 is the densest), or work through specific items together? Pick a finding and I'll go deeper on it — F4 in particular has a clean fix once you decide which node owns *suspect*.

If you have broader questions about using LID on printfarm — whether the web UI wants its own node or a sub-HLD, how to handle specs marked done before code exists, when a project is worth installing the arrow overlay for — I'm happy to talk through those too.