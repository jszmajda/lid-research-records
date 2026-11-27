Phase 2 is drafted. Here's where it landed — please review before I cascade to EARS.

## Decision recorded: 2Q

I rewrote the previews LLD's eviction section around 2Q (`docs/intent/previews/previews-design.md`): a **probationary queue** (first-seen sheets, FIFO), a **protected queue** (reused sheets, LRU), and a bounded **ghost list** of evicted identifiers that carries the reuse signal. A one-pass screening stays confined to the probationary queue, so it can't evict the comparison set — which is the protection you bought the extra bookkeeping for.

I recorded it as a **Decisions & Alternatives row** (plus a second row for the reuse-signal choice), not a standalone decision doc. The three-option debate was long, but length isn't the test — the effects of this choice stay entirely inside the preview worker (interface, render queue, and disk budget all unchanged, as you noted for all three options), and LID reserves decision docs for choices other design nodes get sized around. A row that answers "why 2Q and not plain LRU?" is the right weight here. Say the word if you'd rather have the full doc anyway.

## One cascade to confirm (touches the HLD)

The HLD still says previews' *"eviction policy remains open"* (`docs/high-level-design.md`, Architecture). That's now stale. It's a one-line edit in the parent segment, so I'm flagging rather than editing silently — **OK to change that clause to name 2Q?** Nothing else in the HLD needs to move; its tenets and goals already abstract over the specific policy.

## Edge probe — your triage before EARS

A blind pass over the drafted LLD (given only the design, not our history) surfaced real gaps. Several shape the specs, so I need your call. To keep momentum I've proposed a default for each — **approve the batch, or redline individual ones:**

**Pin in the LLD now (these drive the specs):**
1. **Share enforcement** — evict from the probationary queue once it exceeds its share *even when total budget has headroom* (classic 2Q; freed bytes just leave slack).
2. **Protected evictions are not ghosted** — a re-request after a protected-queue eviction is treated as first-seen again. This is the intended asymmetry; only probationary evictions feed the reuse signal.
3. **Reuse = a fresh render (miss) for a key on the ghost list.** A hit on a still-resident probationary entry never promotes it — consistent with the "hits don't promote" rule already in the draft.
4. **Promotion when the protected queue is full** evicts protected LRU to make room; never the entry just admitted.
5. **Invariant:** a key is on the ghost list *or* resident, never both (admission clears it from the ghost list).

**Safe defaults, worth a line:**
6. **Oversized sheet** (can't fit after draining both queues) — serve the rendered bytes once, don't cache. Effectively unreachable at ~2 MiB sheets vs 12 GiB, but defined rather than left dangling.
7. **Concurrency** — admission (budget check + eviction + queue placement) is serialized on the single worker; the shared job ticket yields exactly one admission per completed render, so two admissions can't jointly overshoot 12 GiB.

**Deferred as tuning** (already in Open Questions): the probationary-share value **and** the ghost list's length — both set against pilot traffic.

Once you confirm the HLD edit and the triage, I'll update the EARS specs (PREVIEW-004 splits into the admission/hit/eviction behaviors above), run the Phase 4 cross-spec divergence audit, and stop again before tests.