Delegated edge probe is back. I've drafted the Phase 2 LLD around 2Q and run the probe. Here's the stop.

---

**Phase 2 (LLD) — 2Q preview design drafted. Stopping for your review.**

I recorded your choice and built the previews LLD around it. What changed:

- **`docs/intent/previews/previews-design.md`** — rewrote *Private Cache* as a **2Q** design: `A1in` (FIFO, first-seen sheets), `Am` (LRU, proven-reused working set), and `A1out` (ghost queue — evicted A1in *keys* only, no bytes). A request whose key is in `A1out` is still a miss and renders normally; the ghost only changes *where* the finished sheet is admitted (straight to `Am`), which is what protects the comparison set from a one-pass screening. Added the reclaim rule, the `Kin`/`Kout` tunables (pilot: 3 GiB / 6000 keys), and a **Decisions & Alternatives** table capturing 2Q over LRU and aged-frequency, plus two sub-decisions (promote-only-on-ghost-hit, byte-based budget).
- **`docs/high-level-design.md`** — the HLD said the eviction policy "remains open"; I changed that one clause to name the 2Q policy now owned by previews. No architectural change — the fixed interface, 4-job queue, and 12 GiB budget are all invariant, which is why this choice stays inside the previews node. (For that reason I'm recording it as a Decisions row, not a decision doc.)

**Edge-probe gaps for you to triage** (a blind reader got only the drafted LLD). I resolved two inline — a failed render leaves the ghost key in place; variable sheet sizes are handled by the byte-based budget. These five are real forks I'd rather you call than I silently pick:

1. **First-seen miss evicting the working set.** Once `A1in` is at its `Kin` share, admitting a brand-new one-off sheet falls to evicting `Am`'s LRU — i.e. a never-seen sheet can push out a proven-reused one. This is standard 2Q behavior, but given the whole point is protecting the working set during big screenings, do you want it as-is, or a floor on `Am`?
2. **Ghost-hit promotion still reclaims `A1in` first.** Promoting a reused sheet into `Am` runs the normal reclaim, which shrinks `A1in` while it's over `Kin`. Intended, or should `Am` admissions reclaim from `Am` itself?
3. **Concurrency.** Up to four renders can complete at once, each mutating the queues / `A1out` / byte accounting while requests read `Am`/`A1in`. Do you want the LLD to state a serialization discipline for replacement metadata, or defer it to implementation?
4. **Degenerate reclaim.** State the invariant that one sheet (~2 MiB) always fits in 12 GiB so reclaim always terminates, or add an explicit guard/rejection for an unfittable sheet?
5. **Stale renderer versions.** After a renderer upgrade, old-version sheets never match a new key and only leave via normal eviction while still counting against the 12 GiB. Leave to age out, or invalidate on version change?

**Out of scope for this decision, but the probe flagged them** — they live on the fixed HTTP contract shared with the review-api segment (what polling clients get when a shared render *fails*, render-queue saturation, source-resolution failure vs. 404). I haven't touched them; they predate the 2Q choice and cross into another segment. Want me to open a separate pass on the previews↔review-api contract, or leave them?

**Next after your approval:** Phase 3 cascades to EARS — PREVIEW-004 gets rewritten for 2Q reclaim, and I'll add spec lines for the hit/promotion/ghost behaviors. All within the PREVIEW segment, so it cascades freely once you've signed off here.

Give me numbered feedback or an OK to proceed to the specs.