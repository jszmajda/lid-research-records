A table row is sufficient here. Applying the decision doc test:

**Would a cold reader re-litigate this choice?** Probably not — the HLD tenet "all serial-number lookup SHALL complete using files on the kiosk" plus "no runtime network access is permitted" effectively settles it. The HTTPS directory option would violate those constraints, and the managed search service introduces external dependencies the goals reject. SQLite reads as the obvious fit once you've read the HLD.

**Does this choice size other design nodes?** No — the HLD explicitly scopes the lookup backend as "private" to the registry. The certificates node doesn't depend on it, and no sibling component needs to coordinate with this decision.

A decision doc is for choices that stay genuinely live for a cold reader — where credible options trade against multiple criteria *and* the result shapes other nodes. This one affects only the registry node, and the HLD constraints lean it heavily toward SQLite.

The Decisions & Alternatives table row already captures the options, rationale, and why the alternatives were rejected. That's sufficient documentation for a choice that won't be re-litigated.