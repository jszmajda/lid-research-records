Phase 1 (HLD check) is done. I've stopped here, as the workflow requires, before drafting the registry LLD.

**Choice: local embedded SQLite index.** This fits the HLD. Its first tenet says all serial-number lookup completes using files on the kiosk, with no runtime network access. That rules out the on-site HTTPS directory and the managed search service, so the choice is settled by the HLD and doesn't need a decision doc. The Phase 2 LLD will record it as a row in the Decisions & Alternatives table, with the two rejected options and the tenet as the reason.

**HLD edit (one line, `docs/high-level-design.md` line 13).** The Registry bullet said its "private lookup backend remains open." That's no longer true, so it now reads: "Its lookup backend is internal to the node and reads only kiosk-local files." The architecture is unchanged, and the certificates interface is unchanged.

**Coherence pre-flight:** clean.
- REG-001 to REG-004 trace to the LLD's Lookup Behavior and Snapshot Import sections.
- CERT-001 to CERT-004 trace to the certificates LLD, which only calls `findBySerial`.

**Known stale text:** `registry-design.md` still says the backend "is not selected yet" and lists the three candidates. Phase 2 will rewrite that.

**Gap for Phase 3:** the no-network tenet has no EARS spec under REG yet. I propose adding one, for example "When a serial-number lookup is requested, the system SHALL complete using only files on the kiosk." The goals (250 ms on 4 GB RAM, 90,000 records, snapshots up to 150 MB) are also not in the specs.

Reply with approval to proceed to Phase 2, or with numbered feedback. Otherwise I'll draft the registry LLD around the SQLite index next, and the EARS specs after that, with a stop after each.