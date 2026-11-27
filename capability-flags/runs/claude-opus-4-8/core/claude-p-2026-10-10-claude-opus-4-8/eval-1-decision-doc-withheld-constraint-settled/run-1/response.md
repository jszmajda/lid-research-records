I've finished the registry LLD around the local SQLite choice and stopped here for your review (Phase 2 boundary — I haven't touched the specs or tests yet).

**What changed**

- `docs/intent/registry/registry-design.md` — the backend is now concrete: the active snapshot is a local embedded SQLite database built in-process on each kiosk, with a normalized, indexed lookup key (trimmed + ASCII-uppercased, punctuation preserved) so each lookup is a single indexed query. Import now builds a **staging** database and activates by **atomically replacing** the active one, so any failure (including a failed index build) leaves the last valid database queryable. Added a Decisions & Alternatives table and an Open Questions list.
- `docs/high-level-design.md` — removed the now-stale "lookup backend remains open" note (the backend decision's substance lives in the registry node; the HLD just carried a tracking marker). I kept the backend *unnamed* at the HLD level since it framed it as private — say the word if you'd rather name SQLite there.

**How I recorded the decision:** a Decisions & Alternatives row, not a decision doc. Even though you went back and forth, the landed result reads as settled: the two alternatives both need runtime network access, which the offline tenets ("no runtime network access"; "kiosks have no network route") rule out — an inherited constraint that makes SQLite the obvious pick to a cold reader. That's a row's job, so I didn't spin up a doc.

**One sub-choice I'd like you to confirm (not silently settle):** activation via *staging DB + atomic replace* vs. *in-place rebuild in one transaction*. I went with staging-and-replace because it keeps the last valid snapshot intact even across a crash mid-build, at the cost of transient disk room for two databases. Comfortable with that, given the 150 MB snapshot ceiling?

**Edge-probe (gaps in this LLD, for you to triage — fix now vs. defer):**
1. **Index-build failure** (disk full / I/O error) — right now it's only implied by the general "import failure retains the active snapshot" rule. REG-003 enumerates specific causes (bad signature, bad schema, duplicate serials) and doesn't name build failure. This likely wants its own spec line or a REG-003 extension in Phase 3.
2. **Crash during the atomic swap** — which database is active on restart? The atomicity guarantee needs to hold across a process restart, not just within one run.
3. **Disk headroom** to hold active + staging databases together for a 150 MB snapshot — currently unquantified.
4. **Cold start** — first-ever import fails with no prior snapshot to fall back to.
5. **Where uniqueness is enforced** — a pre-check before build, or a UNIQUE constraint during build (they fail at different points).

(I generated this probe in-session; I can instead delegate a blind pass to a subagent given only the LLD + specs for less-biased coverage if you'd like.)

Once you've reviewed the LLD and settled the activation sub-choice and the probe items, I'll cascade into the EARS specs (Phase 3).