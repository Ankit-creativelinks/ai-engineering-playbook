# Operations

Running AI systems after the launch — cost, observability, incidents, and the
migrations nobody schedules.

---

## Unit economics

<a name="unit-economics"></a>

**Cost per successfully completed task is the only AI unit that matters.**

Not cost per request, not cost per token. Cost per *resolved* query — including
the retries, the failed attempts, the reformulations, and the escalations to a
human. A feature with a low per-call cost and a 40% resolution rate is expensive.

The number I want every AI feature owner to know:

```
                total inference spend for the feature
cost/resolution = ─────────────────────────────────────
                  tasks the user actually completed
```

Instrument the denominator deliberately. It is always harder than the numerator,
and it is the half that makes the number mean anything.

**Why this is a leadership metric, not an engineering one:** it is the only form
in which the AI roadmap can be discussed with a CFO. It converts directly into
gross margin, and it answers the question every board eventually asks — does this
get cheaper as we grow, or more expensive? A feature costing more per resolution
than the human process it replaced is not an efficiency. It is a subsidy with a
technical justification, and it should be defended as a deliberate investment or
it should be fixed.

**Attribution is the prerequisite.** Every inference call carries a feature tag
and a tenant tag from day one. Retrofitting this is painful, and without it your
cost conversation is an argument about a single aggregate number that nobody can
decompose.

Levers, in the order I try them: cache aggressively (exact-match caching on
repeated queries is dramatically more effective than teams expect); route by
difficulty rather than sending everything to the largest model; shrink retrieved
context, which cuts cost and often improves accuracy; and answer more queries on
the [deterministic path](05-architecture.md#deterministic-first), which is the
lever with the highest ceiling and the one most often overlooked.

## Latency budgets

Write the budget down before building, as a table with an owner per line.

Two things that matter more than the total:

- **Streaming changes the goal.** Time-to-first-token is the number users
  perceive. A 4-second response that starts in 400ms feels faster than a 2-second
  response that arrives at once.
- **Retrieval is usually the surprise.** Teams budget for model latency and are
  then astonished by their vector store's p99. Measure each stage separately, and
  set the budget on p95 or p99 — averages hide exactly the experience that
  generates complaints.

## The silent failure problem

<a name="the-silent-failure-problem"></a>

**A confidently wrong answer is your worst outage, and nothing pages for it.**

Your web incident taxonomy does not transfer:

| Traditional | AI system |
|---|---|
| 500 error — loud, alerted, someone wakes up | Wrong answer — HTTP 200, no alert, user believes it |
| Latency spike — dashboards go red | Quality drift — invisible without evaluation |
| Outage — clearly bounded in time | Degradation — gradual, no start time |
| Root cause in your code | Root cause may be a vendor's silent model update |

Everything conventional monitoring is built to catch is the *easy* category here.
The dangerous failures return 200 and satisfy every health check.

What this changes in practice:

- **Sample and review production outputs continuously.** A small daily sample,
  reviewed by someone with domain knowledge, catches drift that no automated
  metric will. This is unglamorous and I insist on it.
- **Instrument abstention rate as a first-class metric.** A sudden drop means the
  system started answering things it previously declined — usually a regression,
  never a celebration.
- **Track the distribution, not just the average.** Quality problems appear first
  in a segment, and averages conceal them.
- **Give users a one-click "this was wrong."** The cheapest quality telemetry
  available, and it feeds directly into the eval set.

## Incidents

AI-specific additions to an ordinary incident process:

**Severity needs a quality dimension.** "The assistant is confidently giving
incorrect medical dosages to 5% of users" is a Sev1 even though every system is
green. Write quality-based severity criteria before you need them, because
arguing about severity during an incident is a way of not fixing it.

**Mitigations you should have ready in advance:**

- Disable the feature and fall back to the pre-AI experience *(every AI feature
  should have this path, and it should be tested)*
- Roll back the prompt version *(requires prompts to be versioned and deployable
  independently of code — build this early)*
- Roll back the model version *(requires not having deleted access to the old one)*
- Serve only the deterministic path
- Tighten abstention thresholds — degrade to refusing more, rather than being
  wrong more

**Postmortems where the root cause is "the model."** This is not an acceptable
stopping point, and it is where these postmortems usually stop. Push to: why did
our evals not catch it? Why did we learn from a user? What is the class of inputs
this represents, and is that class now in the eval set? The action item is almost
never "improve the prompt" — it is a gap in the detection apparatus.

Blamelessness needs restating here. When an AI system fails, there is often an
individual who wrote the prompt, and the pull toward blame is stronger than usual
because the artifact looks like an opinion rather than code. Resist it explicitly.

## Model upgrades

<a name="model-upgrades"></a>

**Treat every model change as a migration.** A version bump silently alters the
behaviour of every prompt you have written. Your instructions were fitted to a
specific model's quirks, and some of that fit will not transfer.

The runbook is in [templates/model-upgrade-runbook.md](templates/model-upgrade-runbook.md).
The essentials:

1. Never let production float to "latest." Pin the version. Someone else's
   release should never be your incident.
2. Run the full eval suite on the new version before anything else. Expect
   regressions in specific categories even when the aggregate improves — the
   aggregate hides exactly what you need to see.
3. Shadow-run against production traffic where you can, comparing outputs without
   serving them.
4. Roll out by percentage, with the old version still reachable.
5. Re-tune prompts *after* the migration, not during. Changing two variables at
   once means learning nothing from either.

**Deprecation timelines are the risk nobody schedules.** Providers retire models
on their calendar, not yours. Keep an inventory of which features depend on which
models, and treat an announced deprecation as a dated commitment the moment it is
announced — not when the deadline approaches.

## Governance, proportionate to risk

Governance that treats every feature identically gets routed around. Tier it:

| Tier | Examples | Gate |
|---|---|---|
| **Low** | Internal tooling, drafting aids with a human in the loop | Standard code review |
| **Medium** | Customer-facing assistance, search, summarization | Eval thresholds + launch readiness review |
| **High** | Anything affecting money, health, legal standing, safety, or access to a service | The above + domain expert sign-off + a documented human appeal path |

For every tier, three questions answered in writing before launch — the
[launch readiness template](templates/launch-readiness.md) covers them:

1. What is the worst realistic output, and what happens to the user then?
2. How does the user know they are talking to an AI, and how do they reach a human?
3. What data goes to the provider, under what terms, with what retention?

That third question is where I see the most unmanaged risk. Teams ship features
that send customer data to a third party without anyone having read the data
processing terms or checked them against the commitments in their own privacy
policy. That is a legal and trust exposure created by an engineering decision,
and it belongs in the launch gate rather than in a later audit.

<!-- FILL: add a real incident you handled, with the timeline and what the postmortem changed. A concrete war story is the most credible thing in an operations chapter. -->
