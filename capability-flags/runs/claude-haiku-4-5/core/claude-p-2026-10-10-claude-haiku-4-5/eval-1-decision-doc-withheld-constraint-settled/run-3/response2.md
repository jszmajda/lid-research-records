A table row is sufficient. Here's the reasoning:

The HLD's constraint — "no runtime network access is permitted" — narrows the field significantly. That eliminates the on-site HTTPS directory option outright, leaving SQLite vs. managed search service as the real choice. The managed service would require credentials and external connectivity during operation, which the HLD forbids.

Within the narrowed field, SQLite vs. other embedded approaches (BerkeleyDB, custom hash table, etc.) is a technical choice that the LLD's Performance and Storage sections justify clearly: native indexing, predictable behavior on isolated hardware, no extra dependencies. A cold reader looking at the HLD constraint and the LLD's explanation would understand the choice without re-litigating it.

A decision doc earns its place when a choice stays genuinely live — when a reader would naturally question it or want to revisit it. Here, the constraint settles most of the uncertainty, and the technical justification is concrete. The table row does the work.

**Ready to proceed to Phase 4 (intent-narrowing edge audit)?** I'll probe the specs for divergent readings and cross-segment interactions with the certificates component.