A separate decision doc would be overkill.

The HLD already requires local lookup, no runtime network access, and USB-only updates. Those constraints eliminate the HTTPS directory and managed search service, so the landed choice is not genuinely open to re-litigation. The Decisions & Alternatives row in `registry-design.md` preserves enough rationale.

A full decision doc would become worthwhile only if offline operation stopped being mandatory and the three backends became viable competitors again.