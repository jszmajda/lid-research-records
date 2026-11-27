The registry design is drafted with the local SQLite index. Three files changed in the working tree, nothing committed:

- `docs/high-level-design.md`: the registry line that said the backend "remains open" now names the embedded SQLite index that each kiosk builds from its imported snapshot.
- `docs/intent/registry/registry-design.md`: rewritten around the SQLite index. It covers the import sequence (verify, stage, commit, rename over the active file), lookup normalization, and a Decisions & Alternatives table. The HTTPS and managed-search options are rejected there because they conflict with the no-runtime-network tenet and the cloud-services non-goal.
- `docs/intent/registry/registry-specs.md`: REG-001 to REG-004 kept, with REG-003 and REG-004 reworded. REG-005 (no network during lookup), REG-006 (punctuation is significant), and REG-007 (staging file deleted on failed import) are new.

The certificates node needs no changes. Its interface is unchanged, and its specs don't depend on the backend.

**Decisions for you before tests:**

1. **Duplicate rule (REG-003).** Lookup normalizes case and whitespace, so `ab-12` and `AB-12` would collide. I've made them duplicates, which rejects the whole snapshot. The alternative is to treat them as distinct and let lookup return an ambiguous result. Which do you want?
2. **Disk space.** During import the staging index and the active index exist together. The index size isn't measured yet, and the HLD gives no kiosk disk budget. Do you know how much free space a kiosk has?
3. **Timing.** The 250 ms lookup goal is in the HLD but not yet a spec line. Should I add one, to be verified on kiosk-class hardware, or leave it as a goal?

Once you've answered these and approved the design, I'll move on to the tests-first phase.