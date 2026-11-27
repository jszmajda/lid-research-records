A separate decision doc would be overkill.

The SQLite choice is local to the registry node, and the HLD’s offline-only constraints strongly favor it: the HTTPS and managed-service options conflict with “no runtime network access.” The `Decisions & Alternatives` row in `registry-design.md` preserves enough rationale for a cold reader without creating another artifact to maintain.

A full decision doc would become worthwhile only if the project later reconsidered the offline architecture or needed to compare several genuinely viable local indexing approaches.