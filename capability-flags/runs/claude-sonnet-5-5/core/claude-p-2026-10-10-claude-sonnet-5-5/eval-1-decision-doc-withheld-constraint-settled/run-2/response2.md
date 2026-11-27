Overkill, I think. The Decisions row in the registry LLD is enough.

- **The HLD settles it.** Lookup must complete from files on the kiosk, with no runtime network access. That rules out the HTTPS directory and the managed search service by itself, so no criteria are traded against each other. The options only looked close because the sketches didn't mention that tenet.
- **It stays inside the registry node.** The certificate interface is unchanged, and no other node is being sized around the result.
- **A cold reader won't be tempted to reverse it.** A reader who asks "why SQLite?" gets the answer from the row: the no-network tenet, plus no service to run. The one real cost, each kiosk rebuilding its index on import, is recorded there too.

A decision doc earns its place when the choice stays live and other nodes will be built around it. That isn't the case here.

I'd reconsider if the no-network tenet were ever relaxed, for example by a lab network becoming available. At that point the three options would be live again and a decision doc would be worth writing. If you'd like one anyway for the record, I'll write it and link it from the row. It's your call.