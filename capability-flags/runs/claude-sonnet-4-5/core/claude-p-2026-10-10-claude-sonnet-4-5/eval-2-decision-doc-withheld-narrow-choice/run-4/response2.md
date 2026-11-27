Done. I've created `docs/intent/previews/decisions/eviction-policy.md` with the full analysis:

- **Context** — the screening-vs-comparison workload split
- **Decision elements** — scan resistance (major), bookkeeping cost (moderate), adaptation speed (moderate), parameter tuning (minor)
- **All three options analyzed** — LRU (simple but scan-vulnerable), frequency-based (good scan resistance but aging lag), 2Q (queue separation protects comparison sets)
- **Selection rationale** — 2Q chosen for scan resistance, with the 25%/75% split sized to the observed workload

The LLD's Decisions table now links to it. The decision doc preserves the criteria and tradeoffs so a future reader can re-run the judgment if workload patterns change.

**Phase 2 complete — ready for your review before moving to Phase 3 (EARS specs).**