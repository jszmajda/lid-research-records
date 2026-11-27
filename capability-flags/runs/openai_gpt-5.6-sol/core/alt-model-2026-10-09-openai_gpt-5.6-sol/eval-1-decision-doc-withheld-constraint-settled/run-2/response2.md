A separate decision doc would be overkill.

From the landed design, the HLD’s no-runtime-network constraint eliminates both the HTTPS directory and managed search service. The existing **Decisions & Alternatives** row preserves enough rationale for a cold reader.

If offline operation later stops being mandatory, that would first require an HLD change; the backend choice could then warrant a full decision doc.