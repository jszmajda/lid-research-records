For this choice a full decision doc is overkill.

The HLD tenets already make the direction clear: *All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted* and *Kiosks have no network route during normal operation*. With those tenets landed, On-site HTTPS and Managed search require either network at lookup time or external credentials/connectivity — both are ruled out by the architecture, not by a weighing of trade-offs.

The Decisions & Alternatives row in docs/intent/registry/registry-design.md now records what a cold reader needs to reconstruct the choice: what was chosen, the two alternatives you considered, and why the tenets eliminate them while keeping the certificate interface unchanged. That is sufficient rationale for a fresh author.

A decision doc earns its place only when the choice stays genuinely live for a cold reader — i.e., credible options trade against more than one criterion and other design nodes will be sized around the result. Here the tenets settle it; the remaining work is implementation detail, not re-litigation of the backend class.

If you’d like, I can draft a lightweight decision doc for reference, but on the earns-its-place test the table row is the appropriate home.

Do you want to keep the row as-is and proceed to Phase 3 EARS spec review, or would you prefer a decision doc created anyway?