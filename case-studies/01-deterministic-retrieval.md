# Case study: deterministic retrieval before inference

A production conversational assistant over ~3,200 biographical records, in two
scripts, where the highest-value engineering decision was choosing **not** to use
embeddings for the primary retrieval path.

<!-- FILL: name the system and link it if you are comfortable doing so. A named, visitable production system is significantly more credible than an anonymous one. -->

---

## Context

A public reference site holds around 3,200 biographical records of Jain monastic
figures, maintained as structured content with roughly forty metadata fields per
record plus several taxonomies. Visitors wanted to ask a natural-language
question — most commonly, where a particular figure is staying for the annual
Chaturmas retreat — and get a direct answer instead of navigating a listing
interface.

Three constraints shaped everything:

- **Names arrive in two scripts** (Latin transliteration and Devanagari), with
  inconsistent spacing, optional honorifics and rank numerals, and multiple
  accepted transliterations of the same name.
- **A wrong answer is worse than no answer.** These are real people, and their
  location is factual information a visitor may act on. Confidently naming the
  wrong person is a serious failure, not a degraded experience.
- **The chat widget itself was a licensed third-party product** whose files could
  not be modified without forfeiting upgrades.

## The decision that mattered

The obvious architecture — the one the platform already supported — was to embed
all 3,200 records and let semantic search find the person.

We did not do that. **The primary retrieval path uses no embeddings at all.**

The reasoning: when a user types a name, that is not a semantic similarity
problem. It is an *identifier matching* problem wearing a natural-language
costume. Embeddings solve the wrong problem, and they solve it in the most
dangerous available way — vector search always returns a nearest neighbour, so
asking for a person absent from the data returns a *similar, plausible, wrong
person* with exactly the same confidence as a correct hit. For this domain, that
failure mode was disqualifying on its own.

A normalized key match, by contrast, returns nothing when there is nothing. The
system can then say so honestly, or hand off to general conversation.

**The rule we settled on, and then applied everywhere:** embeddings are for
free-form semantic questions, never for "find the thing named X."

## The architecture

```
incoming message
      │
      ├─▶ explicit-mode branches (checked first, so an intentional
      │     search is never hijacked by a name collision)
      │
      ├─▶ normalize → window-match against indexed name keys
      │        │
      │        ├─ exactly one confident match ──▶ structured answer card
      │        │                                  (deterministic, ~free, correct)
      │        └─ too many matches ──▶ fall through
      │
      └─▶ general AI chat (the vendor's own embedding-based RAG)
             — the fallback, not the front door
```

### Name normalization

The matching key is built by the same function on both sides — once when the
cache is populated, once per incoming query — which is what makes the match
robust rather than coincidental. It:

- **Strips rank and honorific tokens in both scripts** (Muni, Acharya, Aryika,
  Kshullak, Ganini, Shri, Maharaj, Mataji and their Devanagari equivalents,
  including common spelling variants).
- **Strips numeric tokens** in both Western and Devanagari digits — the 108/105
  rank numerals appear only in the prefix, never inside a name.
- **Deliberately does not strip the "ji" honorific suffix**, because it appears
  both fused ("Sagarji") and separate ("Sagar Ji"). Collapsing whitespace
  normalizes both forms anyway, and stripping it as a token would have broken the
  fused case.

That last point is the kind of detail that only emerges from real data. It was a
bug before it was a design decision.

### Window matching

The name can appear anywhere in a sentence — *"chaturmas location for Veer
Sagar"* — so the normalized message is tokenized and **every contiguous word
window** is tested against every stored key, using a prefix rule.

Two properties fall out of this that a substring search would not give:

- Partial names match ("Veer Sagar" → the full stored key).
- Compound names do *not* produce false positives, because windows are whole-word.
  A bare query for one name will not match a different, longer name that happens
  to contain it as a substring.

The **longest matching window wins**, on the reasoning that the most specific name
is the intended one. Matches are **capped** — a query broad enough to hit many
people is treated as not-a-lookup and falls through to general chat rather than
guessing.

### The data layer, and an honest trade-off

The source of truth is the CMS content itself. A SQL view flattens the metadata
and taxonomies into one row per record — accurate, and slow, because it re-runs a
pivot on every query (roughly 4 seconds for a filtered query). That is fine for
admin reporting and completely unacceptable on the path of every chat message.

So the view feeds a plain indexed snapshot table, which pays the aggregation cost
once. The chat path reads only that table.

**The cost of this choice, stated plainly: the snapshot goes stale after bulk
content edits until it is refreshed.** We accepted that and made the refresh an
explicit one-click admin action rather than pretending the problem away. Given
the option, I would rather have a staleness window I have documented than an
invalidation scheme I have to reason about at 2am — but it is a real trade, and
it has bitten us at least once when someone edited content and did not refresh.

## The second path, which confirmed the rule

A later feature added search over a separate corpus of ~79 liturgical texts.

Same decision, more obviously correct: the titles are already bilingual within a
single field, and the corpus is small. An indexed `LIKE` over the title serves
both scripts instantly, costs nothing, and **never goes stale** — no re-embedding
when content is added or edited, which for a corpus that grows slowly but
unpredictably is the dominant operational advantage.

Ranking is title matches first, body text only as top-up, with every word in a
multi-word query required to match.

Building the second path took a fraction of the time the first one did, because
the rule was already established. That is what a good architectural position buys
you: the second instance is cheap.

## Working inside a third-party system

Every piece of this hooks into the vendor plugin from the outside — its action
hooks and its DOM — with **no vendor file modified**. The constraint held through
multiple vendor updates.

It also produced the single most useful debugging lesson in the project, now a
permanent entry in the operations notes:

> **"Works on the server, fails in the browser"** → check which endpoint the
> frontend is *actually* calling, rather than assuming it is the one you hooked.

The vendor exposed two request paths depending on a streaming setting, and we had
instrumented one while the browser used the other. Hours went into that. The
generalizable lesson is that when integrating with a system you do not own, the
first thing to verify is not your logic but your assumption about which of the
vendor's code paths is live.

## Outcomes

- **The primary retrieval path costs nothing per query and returns in
  milliseconds**, against a vector-search alternative that would have carried a
  per-query embedding cost, network latency, and a re-indexing obligation on every
  content edit.
- **The failure mode is honest.** No match produces a fall-through or an
  admission, never a confidently wrong person.
- **Cross-script matching works** without any multilingual embedding model,
  because normalization handles what the problem actually required.
- **Adding a second retrieval domain was cheap**, because the pattern was
  established rather than re-litigated.

<!-- FILL: add real numbers if you have them — match rate against production queries, p95 latency, monthly inference spend avoided. Even rough figures make this section substantially more persuasive. -->

## What I would do differently

**Build the eval set first.** Match quality was assessed by trying names and
seeing what happened — rung 0 on the [maturity ladder](../04-evaluation.md#the-maturity-ladder).
A few hundred real queries with expected outcomes should have existed before the
first line of matching code, and every reported miss should have become a
permanent case. The matching rules are now subtle enough that I cannot change one
with full confidence, which is exactly the position an eval suite exists to
prevent. This is the clearest gap in the system.

**Instrument the fall-through rate from day one.** The most valuable signal in
this architecture is *which queries the deterministic path failed to resolve* —
it is simultaneously the bug report, the roadmap, and the eval set. It was not
captured early, and that data is simply gone.

**Handle cache staleness at the source.** An explicit refresh button was the right
call to ship. The right long-term answer is to invalidate on content save, and the
reason it has not happened is that the manual step works well enough — which is
how a documented trade-off quietly becomes permanent technical debt.

## Transferable positions

1. **Ask what fraction of traffic could be served without inference.** The answer
   is routinely higher than teams expect, because nobody asked.
2. **Match the mechanism to the question.** Named lookup is an index problem;
   open-ended questions are an embedding problem. Conflating them costs money and
   returns confident errors.
3. **Prefer failure modes that are honest over ones that are fluent.** In any
   domain where a wrong answer causes real harm, a system that can return nothing
   is worth more than one that always returns something.
4. **Extend, never fork.** The upgrade path you preserve is worth more than the
   convenience you give up.
