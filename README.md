# AI Engineering Playbook

**How I build AI systems that hold up in production — and run the teams that ship
them.**

This is my working playbook — the architectural positions I hold, the quality bar
I set, the way I structure teams, and the interview loops I run. It is opinionated
on purpose. Where I have changed my mind, I say so and explain what changed it.

**Scope, stated up front.** I have led a 10-engineer team building AI features,
and I am hands-on: the architecture and evaluation chapters come from systems I
have built and operated myself. Sections about larger organizations are reasoned
positions rather than lived ones, and they are labelled that way where they
appear. A playbook that blurs those two is not much use to anyone reading it.

It is public for three reasons: writing a position down is how I find out
whether I actually hold it, colleagues have asked for these documents often
enough that a link is cheaper than a re-send, and if you are considering me for
a leadership role, you should be able to read how I think before we meet.

---

## Start here

If you read one page, read **[Positions](01-positions.md)** — ten claims I am
prepared to defend, each linking to the chapter that argues it properly.

If you are evaluating me and have twenty minutes, the path I would suggest is
**[Positions](01-positions.md) → [Architecture](05-architecture.md) →
[the case study](case-studies/01-deterministic-retrieval.md)**. That is the
through-line: a position, the reasoning behind it, and a production system where
it was load-bearing — including what I would do differently.

A few of the claims, in short:

> **The model is the fallback, not the front door.** Every answer you can
> produce deterministically is cheaper, faster, more correct, and vastly easier
> to debug than one you generate.

> **Embeddings are for open-ended semantic questions, never for "find the thing
> named X."** Vector search used as a lookup index is a category error. It costs
> money, adds latency, goes stale, and returns the wrong record with total
> confidence.

> **Evals are the test suite.** A team without an eval harness is not a team
> that can ship. It is a team that can demo.

> **Cost per successfully completed task is the only AI unit that matters.**
> Tokens are an implementation detail. Cost per resolved query is a P&L line and
> belongs in a conversation with your CFO.

---

## Contents

| | Chapter | What it covers |
|---|---|---|
| 01 | **[Positions](01-positions.md)** | Ten claims, stated plainly, with the reasoning compressed |
| 02 | **[Organization design](02-org-design.md)** | Platform vs. embedded, when to form an AI platform team, the roles people conflate |
| 03 | **[Hiring](03-hiring.md)** | The loop, the rubrics, the levels, and the highest-signal interview I run |
| 04 | **[Evaluation](04-evaluation.md)** | The eval maturity ladder, judge calibration, CI under non-determinism |
| 05 | **[Architecture](05-architecture.md)** | Deterministic-first retrieval, build vs. buy vs. fine-tune, vendor coupling |
| 06 | **[Operations](06-operations.md)** | Unit economics, latency budgets, incidents, model migrations, governance |

### Case studies

Real systems, real trade-offs, including the ones that did not work out.

- **[Deterministic retrieval before inference](case-studies/01-deterministic-retrieval.md)** —
  a production multilingual assistant over ~3,200 records where the highest-value
  decision was choosing *not* to use embeddings for the primary retrieval path.

### Templates

The artifacts I actually ask teams to produce. Copy them freely.

- **[AI architecture decision record](templates/ai-adr.md)** — an ADR format adapted for systems whose dependencies change underneath them
- **[Evaluation spec](templates/eval-spec.md)** — what "better" means, written down before anyone tunes anything
- **[Model upgrade runbook](templates/model-upgrade-runbook.md)** — treating a model change as the migration it is
- **[Launch readiness review](templates/launch-readiness.md)** — the gate an AI feature passes before it meets users

---

## How to read this

These documents describe how I operate, not universal law. The heuristics carry
stated thresholds ("form a platform team when three or more product teams are
duplicating eval infrastructure") because unfalsifiable advice is not advice.
Disagree with the thresholds — that is a useful conversation, and I have moved
several of them after having it.

Two standing biases you should know about, so you can correct for them:

1. **I over-index on determinism.** Most of my production AI work has been in
   domains with a knowable right answer, where a wrong-but-fluent response is
   worse than an admission of ignorance. If you are building open-ended creative
   tooling, discount me accordingly.
2. **I have run lean teams.** My instincts are tuned for organizations where
   nobody is available to maintain a component that exists only in principle.

---

## License

Prose in this repository is released under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — use it, adapt it,
ship it inside your own handbook. Attribution appreciated, not enforced. See
[LICENSE](LICENSE).

<!-- FILL: add your name, a one-line bio, and a contact link below before publishing -->
