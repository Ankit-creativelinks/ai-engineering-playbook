# Architecture

The design positions I bring to AI systems, and the decisions I want a team to
make consciously rather than by default.

---

## Deterministic first

<a name="deterministic-first"></a>

**The model is the fallback, not the front door.**

The default architecture — user input goes to an LLM, which calls tools when it
needs to — inverts the reliability ordering. It routes questions you can answer
exactly through a component that answers approximately.

The pattern I reach for instead:

```
user input
    │
    ├─▶ can this be answered exactly?  ──yes──▶ deterministic answer
    │      (lookup, match, computation)          (fast, free, correct, debuggable)
    │
    └──no──▶ inference path
                (retrieval + generation, with an honest "I do not know")
```

Every request resolved on the first branch is one that cannot hallucinate, costs
nothing, returns in milliseconds, and produces a stack trace when it breaks.

The objection is that this is "not really AI." The response is that users do not
want AI; they want the right answer. A system that answers 40% of queries from an
index and 60% through inference is strictly better than one that runs everything
through inference — on cost, latency, accuracy, and debuggability, all four at
once.

**The design question I make teams answer explicitly:** what fraction of real
traffic could be served without inference at all? Teams are consistently
surprised by how high it is, because nobody had asked.

See the [case study](case-studies/01-deterministic-retrieval.md) for what this
looks like in a production system.

## Retrieval is not one problem

<a name="retrieval-is-not-one-problem"></a>

Conflating these is the most common and most expensive AI architecture mistake I
encounter:

| The user is doing | Correct mechanism | Wrong mechanism costs you |
|---|---|---|
| Naming a specific entity ("Veer Sagar", invoice 4471) | Normalized key match on an index | Money, latency, staleness, and confidently wrong neighbours |
| Filtering on attributes ("active, in Delhi") | A `WHERE` clause | Same, plus you cannot express the filter precisely |
| Asking an open question ("what do these texts say about X") | Embeddings, genuinely | — |
| Asking for a computation | Code, called as a tool | Arithmetic that is wrong in a way nobody notices |

**Embeddings are for questions where the user does not know the name of the thing
they want.** That is the whole rule.

When someone types a name, you have an identifier-matching problem. It is solved
by normalization — case, accents, honorifics, script, punctuation, word order —
and an index. The result is exact, instant, free, never stale, and it returns an
honest "no match" instead of the nearest vector.

The failure mode of getting this wrong is unusually nasty: vector search always
returns *something*. Ask for a person who does not exist in your data and you get
a plausible, similar, wrong person, delivered with the same confidence as a
correct hit. An index returns zero rows and the system can say so.

**The hybrid worth building:** deterministic match first; if it produces nothing,
fall through to semantic search; if that is weak, abstain. Three tiers, each with
a different confidence, each honest about which one answered.

## Context engineering over prompt engineering

The prompt is a small part of what determines output quality. What is in the
context window matters more, and it is engineering rather than wordsmithing:

- **Budget the window explicitly.** Know what fraction goes to instructions,
  retrieved context, history, and output. Unbudgeted windows silently truncate
  the thing that mattered.
- **Rank before you truncate.** Filling the window with the top-k by similarity
  and cutting at the boundary discards on an arbitrary criterion.
- **Position matters.** Models attend unevenly across long contexts. Put what
  matters most at the edges, not buried at 60% depth.
- **More context is not better.** Precision degrades past a point. Retrieving 20
  documents where 5 suffice costs money and *reduces* accuracy.

Prompts should be **versioned, reviewed, and owned** like code, because they are
code — they are the program. A prompt change reaching production without review
is an unreviewed deploy.

## Build, buy, or fine-tune

<a name="build-buy-finetune"></a>

The ordering I recommend, and the one I got wrong early:

1. **Fix retrieval.** Most quality problems are context problems.
2. **Fix the prompt and the context budget.** Cheap, fast, reversible.
3. **Try a stronger model.** Often cheaper in total than engineering around a
   weaker one — engineer-hours cost more than tokens more often than people
   assume.
4. **Fine-tune** — and by this point the case has usually evaporated.

Fine-tuning is worth it for a narrow band: a consistent output format the base
model resists, a genuinely specialized domain vocabulary, or a latency/cost
target only a smaller tuned model can hit. It is not a fix for factual accuracy —
that is a retrieval problem, and fine-tuning on facts teaches style, not truth.

The hidden cost that decides it: a fine-tuned model is a **maintenance
obligation**. It pins you to a base model that will be deprecated, and every
upgrade means re-running the pipeline and re-validating. Teams underestimate this
by about an order of magnitude.

**Buy** infrastructure that is not your differentiator — gateways, tracing, eval
runners, vector stores. **Build** what encodes your domain judgment: retrieval
strategy, eval contents, the quality bar. The rule is the same one from
[org design](02-org-design.md#the-line), applied to vendors.

## Vendor coupling

<a name="vendor-coupling"></a>

I have changed my mind here. I used to build a provider-agnostic abstraction on
day one. Two problems: it inevitably gets fitted to the first provider anyway, so
it is not actually portable; and it costs design time before you know enough to
design it well.

What I do now:

- Write directly against one provider.
- Keep call sites **few and boundaried** — inference goes through a small number
  of well-named functions, never scattered through business logic.
- Abstract properly when a second provider becomes a real plan, not a
  hypothetical. At that point you know what varies.

The discipline that actually delivers the portability people want from an
abstraction is **not the interface — it is knowing your exposure.** Be able to
answer, in an afternoon: which features break if this model is deprecated? That
question is answered by an inventory and cost attribution, not by a wrapper
class.

**The coupling worth taking seriously** is not the API shape, which is trivially
adaptable. It is that your prompts are tuned to one model's behaviour. That is
the real switching cost, and no abstraction layer removes it — only an eval suite
makes it measurable. Your eval harness *is* your portability strategy.

## Extend, do not fork

A pattern from operating on top of third-party systems, which generalizes:

When building on a component you do not own — a vendor platform, a licensed
plugin, someone else's service — extend it through its published extension points
and never modify it in place. Modified vendor code cannot be upgraded, and it
will be an unmaintained fork within two release cycles, discovered at the worst
possible moment.

This constraint feels limiting and is usually clarifying: it forces the seam
between your logic and theirs to be explicit, which is where the seam should have
been anyway. When a component genuinely offers no adequate extension point, that
is significant information about the vendor — surface it as a risk rather than
routing around it with a patch.

## Degradation

AI systems fail differently from web services, and the design must account for
it. What each layer does when the one below it fails:

| Failure | Response |
|---|---|
| Provider timeout | Retry with backoff, then fall back to a cheaper or alternative model |
| Provider outage | Serve the deterministic path only, and say the assistant is degraded |
| Retrieval empty | Abstain. Never generate from no context — that is a hallucination generator |
| Judge/eval offline | Ship, but flag the release as unvalidated |
| Cost ceiling breached | Degrade to a cheaper model, alert, and never fail silently open |

The one that matters most is the third. **Generating from empty context is the
single most reliable way to produce a confident fabrication**, and it is the
default behaviour of a naive implementation.
