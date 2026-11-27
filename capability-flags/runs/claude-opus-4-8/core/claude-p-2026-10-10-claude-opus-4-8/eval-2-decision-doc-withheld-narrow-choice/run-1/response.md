Phase 2 (LLD) is done and I've stopped here for your review before touching specs. I did **not** open the decision back up — 2Q is locked. Here's what landed and the one round of gaps the probe turned up.

## What changed

**`previews-design.md`** — replaced the "policy is still open / here are three candidates" paragraph with a concrete **Cache Replacement** section describing 2Q: a probationary FIFO queue, a protected LRU queue, and a **key-only recently-evicted list** that detects reuse (keys only, so it doesn't eat the 12 GiB JPEG budget). Added a **Decisions & Alternatives** table (2Q vs. LRU vs. aged-frequency, with the reasoning you gave) and an **Open Questions** section holding the two tunables (probation-share value; recently-evicted-list capacity).

I recorded the choice as a **Decisions row, not a full decision doc** — the policy is entirely private to the worker (per the HLD tenet), which is exactly the case the skill says gets a row rather than a standalone doc, however long the debate ran.

**`high-level-design.md`** — removed the now-false "Its eviction policy remains open" clause (→ "…a private 12 GiB cache with its own replacement policy"). Architecture is unchanged; flagging it only because it's the root doc. **Say the word if you'd rather I leave the HLD untouched.**

## Probe gaps — my recommended resolutions (confirm or redirect)

A blind pass over the new section found real internal gaps. I'm proposing an answer for each so you can approve rather than re-design; none reopens 2Q itself:

1. **Admission/eviction loop precision** (over-budget vs. over-share ordering, oversized sheet, empty cache). Propose: one eviction loop — evict oldest probationary while *either* probation exceeds its share *or* total exceeds 12 GiB; drop to protected LRU only once probation is empty and we're still over 12 GiB. A sheet larger than the whole budget simply can't be cached (it re-renders on each request). **OK?**
2. **Protected evictions are not recorded in the recently-evicted list** (only probationary ones). Propose: keep it that way — a sheet falling out of the hot set shouldn't instantly re-promote. **OK?**
3. **In-cache probationary reuse does not promote** — only reuse *after* eviction (via the key list) promotes. This is intentional 2Q and what defeats scans, but the prose doesn't say it outright. Propose: state it explicitly, and tighten "shortly after leaving probation" to "while its key is still on the recently-evicted list." **OK?**
4. **Dedup interaction**: one shared render completion admits once and removes the key once; a *failed* job keeps the key on the list so the retry still counts as reuse. Propose: add a sentence saying so. **OK?**
5. **Stale renderer-version keys** linger on the recently-evicted list forever (new version = new key, never matches). Two ways to handle: rely on the list's capacity cap to age them out (simplest), or actively prune on version change. **Which do you want — or leave as a third Open Question?**

Once you've ruled on these, I'll fold the confirmed ones into the LLD and move to **Phase 3 (EARS)** — `PREVIEW-004` stays policy-agnostic, but 2Q looks likely to add specs for scan-protection and for the key-list-not-counting-against-budget invariant. I'll draft those for the next stop.