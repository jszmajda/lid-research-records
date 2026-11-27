Given the current tenets, a standalone decision doc would be overkill.

The HLD tenet “All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted” and “Kiosks have no network route during normal operation” removes the on-site HTTPS directory and managed search service options by constraint. The remaining viable option is the local embedded SQLite index.

The choice is therefore settled by an inherited constraint rather than a live trade-off. A Decisions & Alternatives table row in docs/intent/registry/registry-design.md records the chosen option, the alternatives considered, and the rationale a cold reader needs to reconstruct why the choice was made. That satisfies the *docs carry current intent* tenet without adding a decision doc that a reader would find obvious once the tenets are known.

If you want the decision documented beyond the table row, I can draft a decision doc, but based on the earns-its-place test it would be a settled-obvious choice and the structure documents itself.

Do you want to approve the updated LLD and the triage of the edge-case probe so I can proceed to Phase 3 EARS spec update?