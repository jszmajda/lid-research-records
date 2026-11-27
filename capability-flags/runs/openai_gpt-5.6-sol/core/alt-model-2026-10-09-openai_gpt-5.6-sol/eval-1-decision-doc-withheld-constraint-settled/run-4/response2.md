A standalone decision doc would be overkill.

From the landed system’s perspective, the HLD already requires local-only lookup with no runtime network access. That eliminates both the on-site HTTPS directory and managed search service, leaving SQLite as the only compatible option presented. A cold reader may still ask why SQLite was selected, but the existing Decisions & Alternatives row answers that fully.

The difficulty of the earlier deliberation does not itself justify a decision doc; one would be warranted only if the alternatives remained genuinely viable under the current architecture.