Yes — it earns its place, and I've written it: `docs/intent/previews/decisions/cache-replacement-policy.md`.

**Why a full doc rather than a table row:** the choice is still live. Two credible options traded against each other on more than one criterion (scan resistance vs. bookkeeping cost vs. adaptation on project switch), and the design around it is being sized by the answer — the 80/20 budget split and the ghost-list bound are both parameters that exist only because 2Q won. A cold reader would otherwise be right to re-litigate it.

**What the doc contains:** context (the two editor modes and what's at stake), decision elements with the scan-resistance criterion marked *major* and tied to a new HLD tenet, one `###` section per option (LRU, frequency-with-aging, 2Q) with its strongest honest case and a per-criterion verdict, and a Selection that names what committing forecloses and obliges. It carries no EARS IDs.

**Cascade that followed the decision:**
- `docs/high-level-design.md` — eviction policy no longer "remains open"; added a Key Design Decisions entry and a tenet, *"Protect reused work over minimizing bookkeeping."*
- `docs/intent/previews/previews-design.md` — full "Cache Replacement: 2Q" section: first-use queue (FIFO by admission), reuse queue (LRU by recency), ghost list (10,000 keys, consulted at admission, key removed on admission), 80/20 split of the 12 GiB budget as private configuration, plus a Decisions & Alternatives table.
- `docs/intent/previews/previews-specs.md` — PREVIEW-006 … PREVIEW-026 covering admission, promotion, ghost recording/removal, per-queue eviction order, the cap sum, and the oversized-preview case. Two blind-reader divergence probes turned up forks (404-vs-cache-hit precedence, ghost-list timing, whether the 12 GiB bound is global or per-queue, first-service counting); each was closed with a narrowing edit rather than left ambiguous. The review-api segment is untouched — 2Q stays entirely inside the worker.

All specs remain `[ ]` active gaps: this repository holds only design documents, so there are no tests to write and no code to change. I did not invent an implementation to attach them to.

**Three things I need from you:**

1. **The two defaults I picked** — 80% reuse queue / 20% first-use queue, and a 10,000-key ghost list. Both are private worker settings and cheap to change, but they're my numbers, not yours. Say the word if you want different ones.
2. **Restart behavior.** 2Q's protection lives in queue membership and the ghost list, and the design keeps that bookkeeping in worker memory only. On restart the worker would lose the knowledge of which sheets had been compared, and a returning comparison set would start over in the first-use queue. Options: persist the metadata inside the worker (disk-backed, survives restart, adds a write path), or accept the cold start on restart and rebuild from the cache directory on disk. I left this open rather than pick for you.
3. **Where the preview worker code lives.** Tests-first is the next phase, but there's no implementation in this repo — no source, no package manifest, no test harness. Point me at it (another repo, a branch, or "the implementation hasn't been written yet") and I'll take it from the tests.