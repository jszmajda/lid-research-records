A separate decision doc would be overkill here.

The choice is local to the Registry node, and the HLD already eliminates the networked options through its offline and USB-only constraints. The Registry LLD should record one `Decisions & Alternatives` row explaining that SQLite provides indexed local lookup and transactional replacement while keeping all import and query behavior inside the component.

A decision doc would be warranted only if the implementation needed to preserve a still-live comparison among several viable local-storage architectures with broader consequences.