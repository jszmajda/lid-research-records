**Offer the choice, per the skill's judgment:**

The SQLite selection clears the bar for a decision doc. The choice trades three credible options (SQLite, HTTPS directory, managed service) against multiple criteria (maintenance burden, network dependency, cost, performance isolation), and a cold reader would reasonably question why the decentralized path won over the simpler-to-maintain alternatives. Other design decisions downstream — snapshot file format, import atomicity, error surfaces — are being sized around this result.

The skill's test: "would a cold reader re-litigate it without the competing options and criteria?" For this one, yes — the tradeoffs are non-obvious enough that a future maintainer would benefit from seeing them recorded.

**However,** the table row I added captures the essentials in compact form. A full decision doc is worthwhile only if you want to record more context: e.g., the specific constraints that ruled out network-dependent options (isolation mandate from the HLD, no runtime connectivity), the performance targets that guided the choice, or lessons learned from the sketching process.

**What would be most useful to you:** Would a short decision doc (roughly the length of the table row, formatted as a standalone file) be worth the extra artifact, or does the row suffice for future readers?

Once you answer that, I'll proceed to Phase 3 (specs verification) and then to the edge-case probe results, which still need your triage before we move on.