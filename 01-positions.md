# Positions

Ten claims I am prepared to defend in a room where someone disagrees. Each links
to the chapter that argues it in full.

---

### 1. The model is the fallback, not the front door

Every answer you can produce deterministically is cheaper, faster, more correct,
and vastly easier to debug than one you generate. The instinct to route all input
through an LLM because the product is "an AI product" is architecture by
branding.

The pattern I reach for first: intercept, match, and answer deterministically
when the question is one you can definitively answer; fall through to inference
only when it is not. This inverts the common design — LLM first, tools as
rescue — and it survives contact with production far better.

→ [Architecture](05-architecture.md#deterministic-first)

### 2. Embeddings are for open-ended semantic questions, never for "find the thing named X"

Vector search used as a lookup index is a category error. If a user types a name,
a SKU, an invoice number, or a title, you have an *identifier matching* problem —
solved by normalization and an index, exactly, instantly, and for free. Reaching
for a vector store adds cost, latency, and staleness, and its failure mode is
returning a confidently wrong neighbour instead of an honest "no match."

Reserve embeddings for the genuine case: questions where the user does not know
the name of the thing they want.

→ [Architecture](05-architecture.md#retrieval-is-not-one-problem)

### 3. Evals are the test suite

A team without an eval harness is not a team that can ship. It is a team that can
demo. The distinction shows up the first time someone asks "is the new prompt
better?" and the honest answer is a shrug.

I treat eval coverage the way I treat test coverage: not a number to maximize,
but a question to answer honestly — *if this regressed, would we find out before
a customer did?*

→ [Evaluation](04-evaluation.md)

### 4. Retrieval quality is the bottleneck; generation almost never is

When a RAG system gives a bad answer, the overwhelmingly likely cause is that the
right context never reached the model. Teams nonetheless spend their tuning
budget on prompts and model selection, because prompts are fun to edit and
retrieval metrics are work to build.

Measure retrieval separately from generation, or you will spend a quarter tuning
the half that was not broken.

→ [Evaluation](04-evaluation.md#measure-the-halves-separately)

### 5. Model upgrades are migrations, not swaps

A version bump silently changes the behaviour of every prompt you have written.
Your carefully tuned instructions were fitted to a specific model's quirks, and
some of that fit will not transfer. Teams that treat this as a config change
discover the regression from users.

Budget for model upgrades the way you budget for schema migrations: planned,
evaluated, staged, reversible.

→ [Operations](06-operations.md#model-upgrades)

### 6. Cost per successfully completed task is the only AI unit that matters

Tokens are an implementation detail. Cost per *resolved query* — including the
retries, the failed attempts, and the escalations to a human — is a P&L line, and
it is the number your CFO will eventually ask for. Know it before you are asked.

A feature that costs more per resolution than the human process it replaced is
not an efficiency; it is a subsidy with a technical justification.

→ [Operations](06-operations.md#unit-economics)

### 7. Hire for evaluation design, not model trivia

Anyone can call an API. The scarce skill is being able to say whether the output
got better, and to build the apparatus that answers that question repeatedly and
cheaply. Interview questions about attention mechanisms select for people who
read the same blog posts as you.

→ [Hiring](03-hiring.md#the-eval-design-interview)

### 8. Centralize the platform, embed the application

AI platform teams that own product features become bottlenecks that every roadmap
routes around. Product teams that own inference infrastructure rebuild the same
gateway, cache, and eval runner six times with six sets of bugs.

The line I draw: the platform owns everything that is identical across features
(gateway, routing, caching, tracing, cost attribution, eval infrastructure, the
safety layer). Product teams own everything that encodes domain judgment (the
prompts, the retrieval strategy, the quality bar, the eval *contents*).

→ [Organization design](02-org-design.md#the-line)

### 9. Non-determinism is a testing problem, not an excuse

"You can't test LLM outputs" is a statement about effort, not possibility. You
can pin seeds where the provider allows it, assert on structure rather than
prose, score against a graded set with a tolerance band, and gate on statistical
regression rather than exact match. Every one of these is more work than a string
comparison, and all of them are ordinary engineering.

→ [Evaluation](04-evaluation.md#ci-under-non-determinism)

### 10. A confidently wrong answer is your worst outage, and nothing pages for it

Your web incident taxonomy does not transfer. A 500 is loud, instrumented, and
someone gets woken up. A fluent, plausible, wrong answer is silent — it returns
HTTP 200, it satisfies every health check, and the user believes it. It may be
months before you learn about it, and you will learn from a customer.

This asymmetry should change what you instrument, what you sample, and what you
consider an incident.

→ [Operations](06-operations.md#the-silent-failure-problem)

---

## Where I have changed my mind

**On vendor abstraction layers.** I used to build a provider-agnostic interface
on day one. I now think that is premature in most cases: the abstraction gets
fitted to the first provider anyway, and the leverage it promises rarely
materializes before you have learned enough to design it properly. I now write
directly against one provider, keep the call sites few and boundaried, and
abstract at the point where a second provider becomes a real plan rather than a
hypothetical. → [Architecture](05-architecture.md#vendor-coupling)

**On fine-tuning.** I over-recommended it early. For most teams the honest
ordering is: fix retrieval, then fix the prompt, then fix the context window
budget, *then* consider fine-tuning — and by the time the first three are done,
the case for the fourth has usually evaporated.
→ [Architecture](05-architecture.md#build-buy-finetune)

<!-- FILL: add a third "changed my mind" entry from your own experience — these are the most-quoted parts of a document like this -->
