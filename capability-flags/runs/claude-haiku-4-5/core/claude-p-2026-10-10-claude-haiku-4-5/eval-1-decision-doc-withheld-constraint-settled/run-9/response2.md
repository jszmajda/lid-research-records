Looking at the decision-doc test from the skill: *would a cold reader find the choice non-obvious and want to re-litigate it?*

In this case, **the Decisions table row is sufficient**—a full decision doc would be overkill.

Here's why: the HLD already has a hard constraint: "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted." That constraint alone makes the local solution inevitable. A cold reader reviewing the result would see:
- SQLite is local ✓
- HTTPS directory requires lab network ✗ (violates HLD tenet)
- Managed service requires external connectivity ✗ (violates HLD tenet)

The row you have captures the real tradeoffs (maintenance burden, service complexity, cost), but the HLD tenet settles which direction wins. A decision doc is for choices that *stay genuinely live*—where a reader would reasonably ask "why not one of the alternatives?" Here, the answer is already encoded in the architecture above it.

**Proceed with the table row as-is.** A directory of decision docs is a smell; this one reads as native to the design once it lands.

---

Ready to move to Phase 3 (EARS specs update) once you've triaged the edge-case probe questions. Which gaps should I address in the LLD now, and which can defer to implementation?