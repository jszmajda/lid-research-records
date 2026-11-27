## Coherence pre-flight

Resuming the previews segment. Checked the arrow before touching anything: the five `PREVIEW-*` specs trace to the LLD's rendering, dedup, and cache-bound behavior; the LLD reflects the HLD's architecture; no code or tests exist yet (design-stage repo). One drift found and fixed: the HLD still said the eviction policy "remains open" — now closed.

## Phase 2 — Previews LLD updated for 2Q

Changed `docs/intent/previews/previews-design.md` and `docs/high-level-design.md:14`.

- Rewrote **Context** and the **Private Cache** section so the doc reads as if 2Q were always the design — the old "policy is still open, candidates are LRU/aged-frequency/2Q" paragraph is gone (deliberation residue), and the alternatives moved into a new **Decisions & Alternatives** row.
- Added a **2Q eviction** subsection: A1 (first-use FIFO) and Am (reuse LRU) sharing the 12 GiB budget; new sheets enter A1's tail; an A1 hit promotes to Am's head; admission evicts A1's tail first, then Am's LRU. All bookkeeping is in-memory and private to the worker.
- Recorded the eviction-policy decision as a table row (chosen 2Q; alternatives LRU and aged frequency; rationale = protects reused comparison sheets from screening scans).
- Added **Open Questions → Deferred**: the A1/Am budget split value/tuning, and whether the queues should persist across restarts.

I did **not** offer a decision doc: the choice affects only the previews node, no sibling node is sized around it, and the HLD states no other node consumes eviction metadata — so a table row is the right record.

## LLD-level edge probe (delegated to a blind reader)

Findings most tied to the 2Q change, for you to triage as *fix in LLD* vs *defer as open question*:

1. **Split vs. eviction rule conflict** — the text says Am is only touched "if A1 cannot free enough," yet also gives A1/Am a tunable budget split. Can Am exceed its share, and which rule wins?
2. **Promotion when Am is full** — on an A1→Am promotion at Am capacity, is an Am entry evicted synchronously, and does that interact with the admission budget check?
3. **Shared-miss reuse** — does serving a 202 ticket to N concurrent requests count as a "reuse" that promotes the entry to Am, or not?
4. **Oversized sheet** — a completed sheet larger than the 12 GiB bound (or larger than evicting A1+Am can free): admitted, rejected, or streamed uncached?
5. **Restart resident set** — after a restart the queues reset but disk entries persist; are they counted against 12 GiB immediately or only on next request?
6. **Eviction timing** — is the bound checked only at admission, so the resident set can transiently exceed 12 GiB between a hit and the next admission?
7. **Bound semantics** — is the 12 GiB bound on disk bytes or memory, and do temporary render outputs count?

The probe also surfaced pre-existing gaps unrelated to 2Q (renderer-version selection, non-404 resolution failures, retry-after-failed-job shape, unbounded pending queue, ticket TTL, crash cleanup). I can fold those in now or leave them.

## Stop — your call before Phase 3

Two questions:

1. **Approve the LLD as revised?** Numbered feedback welcome.
2. **Triage the gaps above** — which do you want resolved in the LLD now, and which deferred? My read: #1 and #3 are genuine forks that change behavior and should be pinned down before specs; #2, #4–#7 can be recorded as deferred if you prefer.

On your approval I'll move to Phase 3 (EARS updates for the 2Q behavior, since `PREVIEW-004` currently states only the 12 GiB bound).