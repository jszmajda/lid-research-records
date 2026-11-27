I've gone with 2Q and written it into the previews design (Phase 2). Nothing is committed, and I haven't touched specs, tests, or code yet.

## What changed
- **`docs/intent/previews/previews-design.md`**: the "policy is still open" paragraph is replaced by a **Replacement Policy** section and a **Decisions & Alternatives** table.
  - **Structures:** a probation FIFO for sheets seen once, a protected LRU for sheets that proved reuse, and a ghost list of evicted keys with no JPEG bytes.
  - **Admission:** a completed render whose key is in the ghost list goes straight to protected; every other render goes to probation.
  - **Hits:** a hit in probation does not promote the sheet. This keeps the retry sequence 202, then 200 for one viewing from counting as "reuse".
  - **Eviction:** if probation is over its byte budget, evict its oldest sheet and record the key in the ghost list; otherwise evict the protected LRU tail. Both queues share the single 12 GiB bound.
  - **Initial tunables:** probation budget 3 GiB (25% of the cache) and a ghost list of 3,000 keys. I chose these as starting points; they are worker settings, not part of the interface.
- **`docs/high-level-design.md`**: one line changed, from "eviction policy remains open" to naming 2Q.
- **Decision record:** the choice is a Decisions & Alternatives row, not a full decision doc. It only affects the preview node and the interface is unchanged, so a standalone doc would be residue.

## Edge-case gaps in this LLD (my own pass, not delegated)
Please triage each as fix now or defer:
1. **Worker restart:** if replacement metadata lives only in memory but JPEGs persist on disk, what happens to the queues? Options are to rebuild all surviving sheets into probation, or to clear the cache.
2. **Eviction during a read:** what happens when a sheet is evicted while a response is streaming its file?
3. **Renderer version bump:** old-version sheets and ghost keys simply age out. Is that acceptable, or should they be purged?
4. **Probation budget at 0 or above 12 GiB:** should the worker reject these settings or clamp them?
5. **Hit-time promotion race:** a request that hits the cache just as the same key is being re-admitted (ghost to protected). I read this as harmless because the key is resident either way, but I've left it unspecified.

## For you to check
- **Initial 3 GiB / 3,000-key values:** are these the numbers you want to start tuning from?
- **Promotion trigger:** I picked "re-render after probation eviction" over "second hit in probation". This is the classic 2Q behavior, but it is a real fork, so confirm you want it.
- **HLD goal wording:** it still says "for every eviction policy". That is now slightly stale but harmless; say if you want it reworded.

Reply with edits to the draft, plus your triage of gaps 1–5. Once you approve, I'll move to Phase 3 and draft the EARS specs for the replacement policy.