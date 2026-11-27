Overkill, in my read — the Decisions row is the right home.

The skill's test isn't "was it a hard call" (you went back and forth, which is real) — it's two things about where it *landed*:

- **Scope.** The backend is private to the registry node and the certificate contract is unchanged — all three options said as much. A choice that affects only its own node is one the skill explicitly says *not* to write a doc for, however long the debate ran. A full decision doc earns its place when other design nodes get sized around the result; nothing downstream reshapes here.
- **Live-ness for a cold reader.** A doc is for a choice a cold reader would re-litigate *without* the options and criteria in front of them. But the three options and the tradeoff that decides them (your offline/no-network tenets make local lookups the natural fit; the rejected two each drag a network or external-service dependency into the registry for an identical lookup result) now sit right there in the Decisions table. A reader hitting that row gets the "why this, not the other two" in three lines and moves on — they don't need a separate artifact to reconstruct the judgment.

So: row, not doc. The one thing a doc would add that the row doesn't is a deeper record of the deliberation itself — and the skill's view is that a settled choice which reads cleanly once landed shouldn't carry that; it's the kind of residue the *docs carry current intent* tenet strips.

If you'd still like the fuller doc — say the backend choice is one you expect to get challenged in a review and you want the criteria laid out at full resolution to point people at — I'm happy to write one and link it from the row. Just say so. Otherwise the gap triage above is the live question for moving to the EARS specs.