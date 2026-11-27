**Phase 1 (HLD check) is done. I've stopped here for your review. No files have changed yet.**

**Coherence:** The HLD, both design nodes, and all nine EARS specs agree with 2Q. It keeps the fixed 200/202/404 interface, the four-job render queue, the 12 GiB budget, and the rule that replacement bookkeeping stays private to the preview worker. The architecture doesn't change, so the HLD needs no structural update. The review API node and specs need no changes.

**One stale HLD line:** The Previews bullet under Architecture ends with "Its eviction policy remains open." That's no longer true. I propose deleting that sentence. The policy is a preview-node decision, and the existing tenet "Keep cache paths and replacement bookkeeping private to the preview worker" already covers the boundary.

**Where the decision goes:** The choice's substance sits entirely in the previews node, so I'll record it as a row in `docs/intent/previews/previews-design.md`'s Decisions & Alternatives table. The row will name LRU and frequency-with-aging as the rejected alternatives and give the reasons for 2Q. It doesn't need a standalone decision doc: it affects only its own node, and the row is enough for a cold reader.

**Two choices I need from you before the LLD draft:**

1. **Probation share.** How much of the 12 GiB goes to first-use sheets? I recommend 25% (3 GiB) to start, with the rest as the protected queue, then tuned against pilot data. The alternative is a sheet count instead of bytes. Which do you want?
2. **Promotion and history.** Should a sheet move to the protected queue only on a second hit while it's still in probation? Or should the design also keep a key-only "ghost" list of recently evicted probation keys, so a sheet re-requested shortly after eviction is promoted directly? The ghost list is the extra bookkeeping that makes 2Q resist scans well. I recommend including it, bounded to the same count as the probation queue. Yes or no?

Please also confirm the deletion of the HLD sentence.

**Next, after your approval:** Phase 2 drafts the previews LLD. It replaces the "still open" prose in the Architecture and Private Cache sections, adds the decision row, and runs the LLD edge-case probe. Phases 3–6 follow, each with its own stop.