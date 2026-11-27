I've recorded 2Q in the previews design and the HLD, and I'm stopping here for your review of the design before I draft specs.

**What changed**
- `docs/intent/previews/previews-design.md`:
  - The open "eviction policy" paragraph is replaced by a **Replacement Policy: 2Q** section.
  - There is a new Decisions & Alternatives row recording 2Q over LRU and aged frequency, with the rationale.
  - There is a new Open Questions entry for the two tuning values.
- `docs/high-level-design.md`: the Previews bullet now says "Cache replacement uses 2Q, private to the worker" instead of "remains open".

**The mechanism as drafted** (all private to the preview worker):
- **Probation queue:** a FIFO of sheets admitted but not yet re-requested, with a fixed byte budget.
- **Protected queue:** an LRU of sheets re-requested after admission, holding the rest of the 12 GiB.
- **Ghost list:** a bounded FIFO of evicted keys with no JPEG data. A key found there is admitted straight into protected.
- **Promotion:** a hit on a probation sheet moves it to protected.
- **Eviction:** eviction takes from probation while it is over budget, otherwise from the least recently used protected sheet.
- **Contract:** the preview API, render queue and disk budget are unchanged, so the review API is unaffected.

**Not recorded as a standalone decision doc.** The choice only affects the previews node, so a row in the Decisions table is enough.

**Questions for you**
1. **Probation share of the 12 GiB.** At about 2 MiB per sheet, 12 GiB holds roughly 6,000 sheets, which is close to a week's distinct clips. This is the one real tuning decision, so I've left it open. Options:
   - **25%:** the commonly cited 2Q default. It gives scans a small window and protects the working set most strongly, but a comparison set larger than the other 75% (about 4,500 sheets) is not fully retained.
   - **50%:** a more forgiving window for scans that overlap with comparisons.
   - **Make it a documented worker setting:** start at 25% and tune from pilot data.
   I'd go with 25% as a starting value, tunable, but it's your call.
2. **Ghost list length.** I'd size it at about one cache's worth of keys (roughly 6,000 entries, which is tiny since they are keys only). Is that acceptable, or do you want something different?
3. **Spec drift to be aware of.** PREVIEW-004 (stay within 12 GiB) still holds as written. Phase 3 will add specs for the probation → protected promotion, the scan-resistance behavior, and the ghost list. Does that match what you expect?

Once you answer 1 and 2 and approve the LLD, I'll move on to the EARS specs (Phase 3) and then the edge audit, tests and code, with a stop after each.