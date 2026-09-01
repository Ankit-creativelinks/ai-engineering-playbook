# Evaluation

Evals are the test suite. This chapter is what I expect a team to have built, in
what order, and how I gate releases on it.

---

## The maturity ladder

Teams climb this in order. Skipping a rung does not work — each one produces the
artifact the next one needs.

| Rung | What it looks like | What it can answer | Cost to build |
|---|---|---|---|
| **0. Vibes** | Someone tries a few prompts and forms an impression | Nothing durable | Free |
| **1. Golden set** | 50–200 curated cases with expected outputs, run manually | "Did this change break something obvious?" | Days |
| **2. Automated harness** | Golden set in CI, scored, with a dashboard and history | "Is this release better or worse than the last?" | Weeks |
| **3. Calibrated judge** | LLM-as-judge, validated against human labels, with measured agreement | "Is it better, at a scale humans cannot label?" | Weeks |
| **4. Online measurement** | Production sampling, real user outcomes, segmented | "Is it better *for users*, not just on our set?" | Ongoing |
| **5. Counterfactual** | A/B on model or prompt changes, powered to detect real effects | "Did this change cause the improvement?" | Ongoing |

Most teams that believe they are at rung 4 are at rung 1 with a dashboard.

**Where to stop.** Rung 3 is the right destination for most features. Rungs 4 and
5 are worth it for surfaces with high traffic and a measurable user outcome; for
a feature serving a few hundred requests a day, an A/B test will never reach
significance and building one is a way of feeling rigorous rather than being it.

## Getting to rung 1 honestly

The golden set is the foundation, and it is where most teams go wrong — by
writing the cases themselves.

Hand-written cases sample the distribution you *imagine*, which is systematically
easier and better-behaved than the one you have. The result is a suite that
passes while users struggle.

Where cases should come from, in order of preference:

1. **Production logs**, sampled across the actual traffic distribution — including
   the long tail, deliberately over-sampled relative to its frequency.
2. **Real failures.** Every bug report becomes a permanent case. This is the same
   discipline as a regression test, and it compounds.
3. **Existing human decisions** — support resolutions, moderation calls, expert
   annotations already sitting in your database. Usually the largest untapped
   labelled dataset a company owns.
4. **Adversarial cases**, written deliberately at the boundaries.
5. **Synthetic cases** — last, and clearly tagged, because they carry the biases
   of the model that produced them.

Hold out a slice you never tune against. Without it you will fit the harness
rather than the problem, and you will not notice.

## Measure the halves separately

<a name="measure-the-halves-separately"></a>

For any retrieval-backed system, evaluate retrieval and generation as separate
stages with separate metrics. This is the highest-leverage instrumentation
decision in a RAG system, and it is routinely skipped because the end-to-end
answer is the thing users see.

**Retrieval**, scored independently of what the model does with it:

- Was the necessary context in the retrieved set at all? *(recall@k — the metric
  that matters most and gets measured least)*
- How much irrelevant context came with it? *(precision — this is a cost and
  latency problem, and past a point an accuracy problem too)*
- Was it ranked high enough to survive the context budget?

**Generation**, scored on *given* correct context:

- Faithfulness — is the answer supported by the context provided?
- Completeness — did it use what it was given?
- Format and instruction compliance.

Why this matters concretely: an end-to-end score of 60% is uninterpretable. If
retrieval recall is 65% and faithfulness given good context is 95%, your problem
is entirely retrieval, and a quarter spent on prompt engineering is a quarter
wasted. Teams make this mistake constantly, because prompts are pleasant to edit
and retrieval metrics are work to build.

A related discipline: **measure abstention.** How often does the system correctly
say "I do not know"? A system that never abstains is not confident, it is
uncalibrated — and in most domains a wrong answer costs more than a refusal.

## LLM-as-judge, used responsibly

Judges are how you evaluate at a scale humans cannot reach. They are also a place
teams quietly fool themselves.

The rules I hold teams to:

- **Calibrate against humans before trusting it.** Have humans label 100–200
  cases, measure agreement, and report it. Below ~80% agreement on your specific
  task, the judge is not measuring what you think.
- **Re-calibrate after any judge model change.** A judge upgrade changes your
  measuring instrument, and every historical number silently loses comparability.
- **Never judge with the model that generated the output.** Self-preference is
  real and it flatters you.
- **Score narrow, structured dimensions** — faithfulness, completeness, format —
  rather than a holistic 1–10. Holistic scores drift and cannot be debugged.
- **Publish the disagreement rate** alongside the score, permanently. A quality
  number without its error bar is marketing.

## CI under non-determinism

<a name="ci-under-non-determinism"></a>

"You cannot test LLM outputs" is a claim about effort. The techniques, in
increasing order of cost:

1. **Assert on structure, not prose.** Schema validity, required fields, citation
   presence, refusal behaviour. Fast, deterministic, catches the majority of real
   regressions.
2. **Pin what the provider lets you pin** — temperature, seed where supported,
   model version always. Never let CI float to "latest"; that turns someone
   else's release into your outage.
3. **Score against the graded set with a tolerance band.** Gate on aggregate
   movement, not per-case exact match.
4. **Run N times, assert on the distribution.** For genuinely high-variance
   outputs, assert that the pass rate stays above a threshold.

**The gate I use:** block the merge on any statistically meaningful aggregate
regression, and on *any* regression at all in a designated critical subset —
safety refusals, the top intents by volume, previously-fixed bugs. Everything
else warns rather than blocks. Gating too tightly on a noisy metric trains the
team to bypass the gate, which is worse than not having one.

Keep the full suite out of the pull-request path if it is slow or expensive. A
fast structural subset on every PR, the full harness nightly and pre-release, is
the split that has worked.

## What I ask for as a leader

I do not read eval dashboards day to day. Four questions, asked at review time:

1. **If this regressed, would we find out before a customer told us?** If the
   answer is anything other than a confident yes with a mechanism attached, that
   is the top priority regardless of what the roadmap says.
2. **What is our abstention rate, and is it going the right way?**
3. **When did we last add cases from production failures?** If the answer is
   "when we built it," the suite is decaying.
4. **What does the eval harness cost to run?** If nobody knows, it is either
   trivial or about to become a surprise.

<!-- FILL: add the eval metrics you actually tracked on a real system, with numbers. Concrete before/after figures are the most persuasive content in this entire repository. -->
