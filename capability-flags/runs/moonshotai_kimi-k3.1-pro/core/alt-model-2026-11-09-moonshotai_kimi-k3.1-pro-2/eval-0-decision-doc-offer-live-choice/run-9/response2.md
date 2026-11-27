Created [`docs/decisions/self-hosted-websockets.md`](docs/decisions/self-hosted-websockets.md) and linked it from the HLD’s Key Design Decisions.

It gives a new reader:

- The scale, freshness, and recovery context behind the choice.
- The weighted criteria: responsiveness and vendor independence outweighed operational simplicity.
- A standalone analysis of polling, self-hosted WebSockets, and hosted realtime.
- The accepted connection-management burden and the resulting obligations for the change store, delivery, and browser sync.

Please review the decision doc and confirm before I proceed to the three design nodes.