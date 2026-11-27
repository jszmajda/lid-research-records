I wrote the decision doc at `docs/decisions/self-hosted-websockets.md` and linked it from the HLD's delivery decision entry. It covers the three options against the criteria that decided between them, and it names what the choice commits us to.

**Why we accepted the tradeoff**

- **Vendor coupling decided it.** It is the one major-weight criterion. The hosted option is weak on it, while polling and self-hosted sockets are strong.
- **We accept more connection operations.** Self-hosted sockets are weak on connection operations, which the doc records as moderate-weight work we take on.
- **Latency and read load are not the deciding factors.** Polling would meet the 15-second goal, but it adds about 160 requests per second at 800 browsers, which sockets avoid.
- **The doc names the costs of the choice.** The change store must keep seven days of replayable revisions and publish each one reliably. Browsers must show connection state so a dropped socket is not mistaken for an unchanged board.
- **It records when to reopen the decision.** That is when vendor coupling stops being a major criterion, or when connection operations exceed what the project can staff.

**Choices I made in the write-up**

- The vendor-coupling weight comes from your stated priority, not from a tenet. No HLD tenet sets the cost or operational-burden weights.
- I added failure visibility as a moderate criterion, derived from the tenet that connectivity failures must be visible. You didn't name it, but a reviewer would ask about it.

**Review**

Please review the decision doc, along with the HLD changes from the last stop, and send numbered feedback. Once you approve, I'll write the three design nodes.