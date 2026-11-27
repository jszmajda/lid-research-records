I've recorded 2Q in the previews design (Phase 2) and stopped there. The specs, tests and code are untouched until you approve.

**What changed**
- **`docs/intent/previews/previews-design.md`:**
  - The "eviction policy is still open" paragraph is replaced by an *Eviction Policy* section.
  - New *Decisions & Alternatives* and *Open Questions* sections record why 2Q beat LRU and aged-frequency eviction.
- **`docs/high-level-design.md`:** one line changed from "eviction policy remains open" to "2Q replacement", so the root doesn't go stale. It's a status update, not an architecture change, but it is an HLD edit you didn't ask for. Say so if you'd rather revert it.

**The 2Q design as drafted**
- **Probation queue:** FIFO, capped at 25% of the 12 GiB budget (3 GiB).
- **Reused queue:** LRU, may use all remaining budget.
- **Ghost list:** keys only, 3,072 entries.
- **Admission:** a sheet whose key is in the ghost list goes to the reused queue; otherwise it goes to probation.
- **Making room:** evict from probation when it is over its cap, otherwise from the reused queue's LRU end.
- **Scope:** all of this stays private to the preview worker. The HTTP contract, the 4-job render queue and the 12 GiB budget are unchanged, and the review API is not affected.

**Decisions I need from you**
1. **Does a second hit while a sheet is still in probation promote it?** As drafted it does not (classic 2Q: only a ghost-list hit promotes). That means a comparison set viewed repeatedly within one probation window stays "first-use" and is still scan-vulnerable until it cycles out and returns. The alternative is to promote on any second request. This is a real fork in intent, so I didn't want to pick it silently.
2. **Initial split values.** The 25% probation cap and 3,072-key ghost list are my starting guesses. They are configurable, and the weekly working set (~6,000 clips ≈ 12 GiB) leaves the cache near capacity. Confirm them or give me different numbers.

**Edge-case probe (for you to triage: fix in the LLD now, or defer)**
- **Pending requests:** do requests coalesced onto one pending job count as one reference or several? As drafted, the ghost lookup happens at admission, not at request time.
- **Restart:** on worker restart, are queue order and the ghost list rebuilt from disk or reset? A reset loses the reused/probation distinction.
- **Renderer version bump:** old-version sheets are never requested again and just age out. Should they be evicted eagerly?
- **Oversized sheet:** what happens if a sheet is larger than the probation cap? Nothing bounds sheet size today.
- **Failed or 404 jobs:** these are never admitted, so they never enter the ghost list. I'm treating that as intended.
- **Temp render output:** it sits outside the 12 GiB cached-JPEG budget, as before.

**Decision doc:** I'm not offering one. The choice affects only the previews node, so the Decisions row is enough.

Reply with feedback on the forks and probe items, or approve, and I'll move to Phase 3 (EARS specs: new `PREVIEW-*` lines for admission, promotion, eviction order and the ghost bound, plus a re-scope of `PREVIEW-004`).