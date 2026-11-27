The 2Q design is drafted and cascaded. Here is the phase output for your review.

## Phase 2 — LLD finished (`docs/intent/previews/previews-design.md`)

The "eviction policy is still open" paragraph is replaced by a **2Q scheme** section:

- **A0 (first-use, FIFO):** a freshly admitted sheet (no prior cached admission for that key) enters at A0's tail; screening scans fill and churn A0, leaving reused sheets alone.
- **A1 (reuse, LRU):** a hit on an A0 entry promotes it to A1's head; a hit within A1 moves it to A1's head. A1 ends up holding exactly the comparison working set.
- **Victim selection:** tail of A0 first; only while A0 is empty, A1's LRU tail. Pending-render entries are never victims (they hold no cached bytes yet).
- **Split:** 75% A1 / 25% A0 as a tunable parameter over entry counts — the 12 GiB byte bound is enforced unchanged; queues only order candidates. All bookkeeping private to the worker.

Decisions & Alternatives row records 2Q over LRU and aged frequency with the rationale. Deferred open questions: tuning the split against screening logs; the classic-2Q non-resident A0 directory.

HLD reconciled: the Architecture bullet no longer says the policy "remains open" (docs/high-level-design.md:14), and the Goals wording now reads "regardless of cache eviction policy."

## Phase 3 — Specs (`docs/intent/previews/previews-specs.md`)

New, all `[ ]`:
- **PREVIEW-006** — first admission → tail of A0.
- **PREVIEW-007** — hit on A0 entry → promote to A1 head, remove from A0.
- **PREVIEW-008** — hit within A1 → move to A1 head.
- **PREVIEW-009** — eviction needed → A0-tail victims first; A1 LRU tail while A0 is empty.

Consistency report: coverage — every behavior in the LLD's cache section now maps to 004/006–009; rendering/dedupe behavior still maps to 003/005. No contradictions; 004 (byte bound) composes with 009 (victim selection). Scope is explicit — 006–009 name "the preview worker's private cache" so they don't read as system-wide. The 75/25 split is deliberately not specced (it's declared a tuning parameter in the LLD); say the word if you want it pinned as a spec instead.

## Phase 2 probe — gap list for your triage

A blind reviewer probed the draft; triaged:

**Dissolved by the design as written** (no change needed unless you disagree): pending entries never sit in A0/A1, so failure-after-admission, pending-starvation, and eviction-completion races don't arise; ticket semantics after a failed job are already fixed by PREVIEW-005's release rule.

**Genuine gaps — fix in the LLD or defer, your call:**
1. The split is over *entries* while the bound is *bytes* — which count governs A1 overflow when sheet sizes vary?
2. Promotion into a full A1: does the displaced A1 tail get evicted or demoted, and does that count against the byte-bound eviction?
3. Re-admission after eviction: a re-requested evicted sheet re-renders and re-enters as a "fresh" A0 admission (one scan pass would then never let it reach A1 — non-resident directory question).
4. Stale-version entries: new renderer versions strand old-key sheets in A1 with no hits — do we need anything beyond letting the bound eventually evict them?

**Likely out of segment:** revision deletion/supersession invalidation (no source-catalog segment exists yet to own it).

## Judgment to you

- A capability flag applies: my configuration has no tested row, so models like me are known to miss tenet/mechanism contradictions. Please check the 2Q mechanism against the HLD tenets yourself — especially "keep cache paths and replacement bookkeeping private to the preview worker" and "a cache miss is ordinary behavior" — rather than trusting my read.
- **Decision doc offer:** this choice was contested across real criteria and other design (queue bookkeeping, tuning) is sized around it — a cold reader could re-litigate it. Want a full decision doc in `docs/intent/previews/decisions/eviction-policy.md` capturing LRU/aged-frequency/2Q with the criteria? Or is the Decisions & Alternatives row (already written) enough?

Also: tell me which of the four genuine gaps to fold into the LLD now versus defer.