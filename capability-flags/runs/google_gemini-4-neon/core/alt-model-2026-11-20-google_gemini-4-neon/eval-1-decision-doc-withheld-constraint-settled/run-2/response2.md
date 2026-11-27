It would be overkill—the `Decisions & Alternatives` row in `docs/intent/registry/registry-design.md` is the right fit here.

The bar for a standalone decision doc is whether the choice stays *genuinely live* for a future cold reader once it lands—not how much back-and-forth it took to decide. Here, two things settle it in a single row:

- **Inherited constraints eliminate the other options:** The HLD's offline tenets (no runtime network access, no network route, USB-only updates) and Non-Goals (no remote access or cloud services) rule out both the on-site HTTPS directory and the managed search service outright.
- **No other node is sized around it:** The lookup backend is private to `registry`; `certificates` depends only on `findBySerial` and is unaffected.

Unless you want to keep a full decision doc anyway, we can leave it as the table row and proceed with triaging the Phase 2 edge-case probe items (or move to Phase 3 if you want to defer them).