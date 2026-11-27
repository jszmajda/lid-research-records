Overkill — the Decisions row is the right home. Two reasons:

1. **An inherited constraint does most of the deciding.** The HLD tenet "all lookup completes from kiosk files; no runtime network access" already eliminates the HTTPS directory and the managed service on its face. When the choice re-reads as obvious once it lands, the test for a full doc fails — even though the deliberation felt close in the room.
2. **It doesn't shape other nodes.** Decision docs earn their place when other design nodes are about to be sized around the result. Here the certificates interface stays unchanged and no sibling depends on the backend, so there's nothing downstream for a doc to protect.

The row in `registry-design.md` preserves the rejected alternatives and rationale — that's the level of record a cold reader needs. If the network tenet ever relaxes (say, kiosks gain a route to the lab), the decision goes genuinely live again and *that* would be the moment to promote it to a doc.

So: no decision doc. Shall I carry on with the probe-gap triage — which of the six gaps should I close in the design now vs. defer to implementation?