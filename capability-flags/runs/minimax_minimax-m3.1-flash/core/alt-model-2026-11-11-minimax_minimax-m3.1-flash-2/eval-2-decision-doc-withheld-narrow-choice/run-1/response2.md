**Phase 2 — LLD check/draft (complete). Decision doc written at `docs/intent/previews/decisions/cache-replacement-policy.md`, LLD rewritten at `docs/intent/previews/previews-design.md`.**

## The decision doc

It follows the template: Context (bimodal workload, why the policy is the decision that matters), Decision Elements (five weighted criteria — scan resistance *major*, working-set adaptation *moderate*, time-to-protection *moderate*, bookkeeping *minor*, tuning cost *minor* — each tied back to the HLD tenet), Options in the Domain (LRU, aged frequency, 2Q, each with description, analysis, summary), and Selection. The selection records what 2Q forecloses, what it obliges the previews design to specify, and — importantly — the assumption it rests on: if access turns out to be uniformly sequential with little reuse, the major criterion stops discriminating and the decision should be re-opened. No gates, because all three candidates respect the inherited constraints (12 GiB, fixed contract, private bookkeeping) — those are background, not discriminators.

## The LLD

`docs/intent/previews/previews-design.md` now specifies 2Q concretely: `A1in` (recent FIFO), `Am` (hot LRU), `A1out` (bounded evicted-key list, keys only, no JPEG data); admission and promotion rules; eviction order (recent queue first, hot queue only when recent is empty); the re-admission rule for an evicted key that is requested again (direct to hot, not restart in recent); byte-bounded queue accounting; and a Decisions & Alternatives table with four rows. The review API segment is untouched — the choice is entirely inside the preview worker, so no cross-segment cascade.

## What I need from you

**1. The queue split.** The LLD currently carries my recommended values, which I'll revise if you pick differently:

| Option | Recent `A1in` / Hot `Am` | Downstream consequence |
|---|---|---|
| **A — 25/75** (recommended) | 3 GiB / 9 GiB | ~4,600 hot sheets at 2 MiB; hot set holds a full comparison working set with slack; recent queue absorbs a scan of ~1,500 sheets before touching hot |
| B — 40/60 | 4.8 GiB / 7.2 GiB | Absorbs longer scans (~2,400 sheets), but hot set shrinks to ~3,700 sheets — tighter if a production's comparison set is large |
| C — 10/90 | 1.2 GiB / 10.8 GiB | Maximally protects hot set (~5,400 sheets), but a scan starts evicting hot entries after only ~600 sheets |

The evicted-key list (4,096 keys, metadata only, no JPEG bytes) is uncontroversial at any of these.

**2. Eight forks from the LLD-level edge probe.** The mechanical defaults (3, 4, 6, 8, 10, 12, 15 in the probe — key removal on re-admission, set semantics for the evicted-key list, byte accounting order, promotion-before-eviction ordering, serialized admission, temp output excluded from the 12 GiB, dedup map orthogonal to the evicted-key list) I'll write into the LLD as stated defaults unless you object. These eight need you:

- **Promotion trigger counting.** Does the request that *caused* the render count as request #1? If yes, a comparison sheet needs three requests to become hot. I read it as no — the render request isn't a request for a *cached* sheet, so the second request promotes.
- **A sheet larger than the whole 12 GiB budget.** Render succeeds, sheet is served but never cached; every repeat request re-renders. Currently parked in "Deferred" — I'd move it to a settled rule since an implementer can't infer it.
- **A sheet too large for `A1in` but small enough for the budget** (say 4 GiB). Admit to `Am` directly, or don't cache it?
- **Evicted-key list overflow.** Forget the oldest evicted key (FIFO) or the least-recently-used (LRU)? This decides which keys get direct-to-hot re-admission, so it changes how much of a re-scanned working set survives.
- **Enforcing the hot queue's cap.** If `Am` is full and a promotion arrives: evict the LRU hot entry to make room, or reject the promotion and evict the promoted sheet? I lean toward allowing `Am` to exceed its share briefly and reconciling at the next eviction, since evicting a hot entry to admit a promoted one inverts the policy's purpose.
- **Re-admission decision timing.** Is "was this key evicted?" decided at request time or at admission time (~450 ms later)? At admission time, list overflow during the render can demote a hot sheet back to first-touch — exactly what the re-admission rule exists to prevent. I read it as request time.
- **Eviction during an in-flight serve.** If a sheet is being served when eviction reaches it, does the response still complete with full bytes? I'd commit to yes — a mid-read failure would break the fixed 200 contract, and the HLD tenet covers misses but not partial reads.
- **Superseded renderer versions.** When the renderer version bumps, old-version entries stay resident until ordinary eviction — and a promoted old-version sheet in `Am` could sit there indefinitely, since `Am` is only drained when `A1in` is empty. Purge old-version keys on a version bump, or let them age out?

**3. Still outstanding from Phase 1.** I asked two things you haven't answered: (a) does the HLD tenet *"Protect repeatedly reused work over minimizing the bookkeeping needed to track it"* read right, and (b) design-only, or design plus a greenfield preview worker? On (b) — the repo contains only design documents, no source, no test runner, no `package.json`/`pyproject.toml` — so Phases 5–6 would mean inventing a language/runtime and test framework you haven't specified, for a cache-policy change. I recommend design-only, with the worker implementation as separate work.

Answer 1, 2 and 3 and I'll run Phase 3 (EARS specs + consistency report), then Phase 4 (intent-narrowing edge audit) and stop there — no code, unless you tell me otherwise.