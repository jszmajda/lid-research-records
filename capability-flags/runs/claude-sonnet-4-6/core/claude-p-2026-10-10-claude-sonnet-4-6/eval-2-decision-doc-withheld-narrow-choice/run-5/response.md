**Phase 2 stop — LLD for review.**

Here's what changed and what I flagged in the edge-case probe:

---

## Updated: `docs/intent/previews/previews-design.md`

The Private Cache section now fully specifies 2Q mechanics:

- **A1 (admission queue):** All new sheets enter here, FIFO eviction, 25% soft target (3 GiB).
- **Am (main queue):** Sheets promoted on second access, LRU eviction, 75% soft target (9 GiB).
- **Soft targets:** Slack is shared — the total stays ≤ 12 GiB but neither queue is a hard partition.
- **Admission order:** Evict A1 head first; if A1 is empty, evict Am head; then admit new sheet to A1 only.
- **Promotion:** On a hit in A1, move to Am tail immediately — byte count shifts queues, no extra eviction triggered.
- **No direct Am admission:** every sheet enters via A1.

The Decisions & Alternatives table records both the policy choice (2Q vs. LRU vs. aging-frequency) and the 25/75 split, with rationale.

The HLD's Architecture section now reads "private 12 GiB 2Q cache" instead of "eviction policy remains open."

---

## Edge-case probe

These are gaps in the current LLD I'd like you to triage:

1. **Evicted-then-re-requested sheet:** A sheet evicted from Am that's later requested again will re-enter A1 as a new admission. Is that the right behavior, or should a previously-promoted sheet skip A1 on re-admission?

2. **Promotion concurrency:** Two concurrent requests can hit the same A1 entry at once. The LLD doesn't specify whether both threads attempt promotion or one wins. Needs a statement on thread safety / atomic promotion.

3. **Am overflow during promotion:** If A1 is nearly empty and a burst of promotions fills Am past its 9 GiB soft target, eviction from Am would fire. The LLD implies this but doesn't state the invariant explicitly: "promotion never triggers eviction of a different Am entry" is not currently guaranteed — it is, but it's not written.

4. **Accounting during a render:** A sheet that's currently rendering isn't in either queue (it's in temporary render output). Its in-flight size doesn't count against the 12 GiB. Should the spec say anything about what happens if total pending render output + cached data would together exceed disk capacity? (This might be out of scope for the cache policy spec, but worth confirming.)

Please triage those: which land in the LLD now, which become EARS specs in Phase 3, and which are out of scope or deferred?

---

One procedural note: per the workflow I should offer this once — the eviction policy choice (2Q vs. the two alternatives, weighed against the sequential-scan workload) might warrant a **decision doc** since a cold reader could credibly ask why not LRU. I've captured it in the Decisions table which is probably enough, but if you'd like a standalone decision doc I'll write one before we move to specs. Just say yes or no and we'll proceed.