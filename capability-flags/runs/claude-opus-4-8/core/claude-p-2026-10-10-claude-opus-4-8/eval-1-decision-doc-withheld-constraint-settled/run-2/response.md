Phase 2 (registry LLD) is drafted around the local SQLite index. Here's the output for your review.

## What changed

**`docs/intent/registry/registry-design.md`** — the backend is now specified rather than open:
- **Architecture**: lookup is served from a *kiosk-local SQLite index built on the kiosk from the snapshot's records*, read-only during lookup. The `findBySerial` interface and result types are unchanged, so certificates see nothing of this.
- **Snapshot Import**: added the build-and-swap mechanism — validate, then build a fresh index into a temporary location leaving the active index untouched, then activate by an atomic swap of index + snapshot date together. A failed or incomplete build (including power loss mid-build) joins the existing failure modes in leaving the previous index active. This is what carries the HLD's "last valid snapshot stays available" tenet down into the SQLite mechanism.
- **Lookup Behavior**: normalized serial → single indexed point query; snapshot date still returned on both Found and NotFound.
- **Performance**: a new short section tying the one-row-per-serial point query to the 250 ms / 90k-record / 4 GB goal.
- **Decisions & Alternatives**: one row recording the backend choice.

## One thing I need you to confirm — an HLD touch

Choosing the backend closed a decision the **HLD** still advertised as open. I changed one line in `docs/high-level-design.md`:

> ~~Its private lookup backend remains open.~~ → **Its lookup backend is a registry-private detail.**

I deliberately did *not* name SQLite in the HLD — it stays a registry-private detail there. Flagging it because it edits the root doc rather than the registry segment; tell me if you'd rather I revert it or word it differently.

## How I recorded the decision

I recorded it as a **Decisions & Alternatives row, not a full decision doc**. My reasoning: your HLD tenet "no runtime network access is permitted" directly rules out both the HTTPS-directory and managed-service options, so in the *landed* design the local index reads as close to forced by an existing constraint — which is the case the decision-doc guidance says to record as a row rather than a doc. The row names both alternatives and why the tenet trims them, which is what a cold reader would want. If you'd prefer a standalone decision doc anyway (you mentioned it was genuinely close in deliberation), say so and I'll write one.

## Edge-case probe — please triage

A blind probe of the revised LLD surfaced these internal gaps. Which do you want folded into the LLD now, and which deferred as open questions? (The first few feel load-bearing to me; I haven't resolved any of them.)

1. **Malformed/non-parseable JSON line in a snapshot** — import failure, skipped record, or unspecified? The LLD lists failure modes but not this one.
2. **Serials that collide only after normalization** (distinct raw strings, same normalized form) — does the uniqueness check run on raw or normalized serials? This changes what REG-003's "duplicate serial numbers" means under SQLite.
3. **First-ever import with no active index yet** — the "previous index remains active" fallback has no predecessor.
4. **Empty/whitespace-only serial on lookup** — NotFound, error, or undefined?
5. **Record missing a fixed field or carrying an unparseable date** — reject at import, or let `Found` return partial data?
6. **Schema-version boundary** — is "unsupported" a defined set/range, and is an absent/unreadable version treated as unsupported?

(Items on concurrency of swap-vs-lookup and the exact error shape also came up; I can bring those in too, but on a single-user kiosk they may be lower priority — your call.)

## Next (not done yet — stopping here)

After your review, the free in-segment cascade is Phase 3: REG specs. The main spec question I see is whether **index-build failure** needs its own line or folds into REG-003/REG-004, plus whatever you decide from the probe above. I'll draft those once you've signed off on this LLD, the HLD line, and the triage.