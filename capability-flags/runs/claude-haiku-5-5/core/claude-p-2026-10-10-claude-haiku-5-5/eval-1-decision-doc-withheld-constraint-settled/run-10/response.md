**Phase 1 (HLD check) is done. Stopping here for your review before the LLD.**

**Choice recorded:** The registry uses a local embedded SQLite index. Each kiosk builds that index from a snapshot during import and activates it only after validation succeeds. The on-site HTTPS directory and the managed search service are out, because the HLD tenet "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" rules out both. The SQLite option is the only one left, so this is a Decisions & Alternatives row in the registry LLD, not a standalone decision doc.

**HLD change (applied to `docs/high-level-design.md`):**

> Registry: ... Owns snapshot validation and lookup. Lookup runs against a local embedded index that the registry builds on the kiosk from each snapshot; the index is private to the registry.

This replaces "Its private lookup backend remains open." The HLD still doesn't name SQLite; the choice is internal to the registry node. The certificates node is unaffected: `findBySerial` and the result types are unchanged, and the certificates design already keeps backend details out of view. I didn't add a tenet, because the existing tenets already cover this choice.

**Still to do in Phase 2 (LLD), not yet applied:**
- `docs/intent/registry/registry-design.md` still says "Candidates are…" and "The concrete index and query path remain open." I'll rewrite the Architecture and Lookup Behavior sections to describe the SQLite index and its query path, and add the Decisions row with the tenet as its rationale.
- The Snapshot Import section will spell out the staging-then-activate sequence, since the current text only says "prepare the new snapshot."

**Please confirm:**
1. The HLD wording above is right.
2. I should proceed to Phase 2 and draft the registry LLD changes.