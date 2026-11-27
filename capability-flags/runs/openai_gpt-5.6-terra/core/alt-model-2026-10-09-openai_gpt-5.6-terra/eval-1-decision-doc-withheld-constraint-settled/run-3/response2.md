A decision doc would be overkill here.

The HLD’s `Key Design Decisions` row records the durable rationale a cold reader needs: SQLite was chosen to preserve kiosk-local operation and avoid network services, credentials, and runtime timeout handling, accepting per-kiosk index construction during import. The choice is consequential, but its substance is contained within the registry component and does not create a new cross-component contract.

A separate decision doc would be justified if the choice introduced enduring organization-wide tradeoffs, such as a central service operating model, vendor commitments, regulatory data residency constraints, or shared infrastructure that multiple components must design around.