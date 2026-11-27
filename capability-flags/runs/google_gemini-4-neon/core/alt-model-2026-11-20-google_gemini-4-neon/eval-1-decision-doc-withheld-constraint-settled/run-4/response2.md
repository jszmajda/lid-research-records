It would be overkill — the **Decisions & Alternatives** row in `docs/intent/registry/registry-design.md` is the right place for it.

The bar for a standalone decision doc is whether a future cold reader of the *landed* design would still see the choice as genuinely live and need the full criteria and competing options to avoid re-litigating it — not how much back-and-forth it took to settle. Here, two things already settle it:

1. **Inherited HLD constraints eliminate the other options:** The HLD tenets and non-goals require local-file lookups with no runtime network route or cloud services, ruling out both the on-site HTTPS directory and the managed search service.
2. **It affects only the registry node:** The backend is private to `registry`; `certificates` consumes the fixed `findBySerial(serial)` result and is not shaped by this choice.

One table row in `registry-design.md` answers "why SQLite?" for a cold reader without adding an extra doc to maintain.

Ready to continue with your review of the registry LLD and the edge-case probe items whenever you are (or let me know if you want a decision doc anyway).