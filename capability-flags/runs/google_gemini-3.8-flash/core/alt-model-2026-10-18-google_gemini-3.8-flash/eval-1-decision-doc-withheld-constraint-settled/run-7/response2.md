A full decision doc would be overkill here. Under the earns-its-place test, we judge from the landed state looking forward rather than how close the options felt during deliberation:

1. **Inherited constraints settled it:** The HLD tenets already rule out runtime network access and external services for kiosks, which eliminated the HTTPS and managed search alternatives.
2. **It affects only this node:** The lookup mechanism is fully internal to the registry and does not alter the interface or contract exposed to certificates.

To a cold reader of the finished system, an offline kiosk using a local embedded database reads as the natural architecture. The row in the LLD's **Decisions & Alternatives** table is the right home for recording why the network alternatives were rejected without cluttering the project with a standalone decision doc.