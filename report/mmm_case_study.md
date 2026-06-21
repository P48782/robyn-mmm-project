# Marketing Mix Modeling Case Study: Channel Performance & Budget Allocation

*A self-directed MMM build using Meta's open-source Robyn package, demonstrating the full methodology end-to-end on Robyn's official simulated demo dataset.*

---

## TL;DR

Across four years of simulated weekly data, **out-of-home (OOH) advertising consumes 62% of the media budget but is only barely breaking even**, while **print is the most efficient channel by a wide margin** despite getting just 5% of spend. Reallocating the existing budget — no new spending, just a smarter split — is projected to increase revenue by **17–33%**, depending on modeling assumptions. The direction of that recommendation (less OOH, more print/search/TV) is consistent across multiple independent models. The exact size of the opportunity, and what to do about Facebook specifically, is genuinely uncertain, and this report says so explicitly rather than hiding it behind a single confident-sounding number.

---

## What is Marketing Mix Modeling?

Marketing Mix Modeling (MMM) is a statistical approach to answering a deceptively hard question: **how much of your revenue did your marketing actually cause, versus everything else that was happening anyway?** Revenue moves for a lot of reasons that have nothing to do with this week's ad spend — seasonality, holidays, what competitors are doing, the general trajectory of the business. MMM's job is to separate those "would have happened anyway" effects from the genuine, attributable effect of each marketing channel, using historical spend and revenue data rather than a live experiment.

It does this by modeling two things every channel does after you spend money on it:

- **Carryover (adstock):** a campaign's effect doesn't end the week you ran it — it fades in over the following weeks. A TV ad builds awareness that influences purchases later, not just immediately.
- **Diminishing returns (saturation):** the 100th dollar spent on a channel this week rarely buys as much incremental revenue as the first dollar did. Every channel eventually saturates; the question is at what spend level, and how sharply.

MMM fits these two effects per channel, then asks a regression model (here, ridge regression — chosen because marketing channels often move together, which a plain regression handles badly) to explain revenue using the resulting transformed variables. Because there's no single "correct" carryover/saturation shape for any channel, the actual fitting process searches across thousands of plausible combinations, scoring each one on both statistical fit and business plausibility, and keeps the set of best trade-offs rather than one "winning" model.

---

## About this analysis

This project uses Robyn's official `dt_simulated_weekly` dataset — a synthetic dataset built and maintained by Meta's own MMM team specifically for demonstrating the methodology, not real company data. **This is a disclosed limitation, not an oversight:** the goal of this project was to build genuine fluency with the MMM workflow end-to-end, and the methodology shown here — input configuration, hyperparameter search, model selection, budget allocation — is identical to what would be applied to a real client's data.

**Data:** 208 weeks (2015–2019), revenue plus five paid media channels (TV, out-of-home, print, Facebook, search), one organic channel (newsletter), and two non-media context variables (competitor sales, a one-off events flag).

**Method:** Geometric adstock, Hill-function saturation curves, ridge regression, and a multi-objective evolutionary search (Nevergrad's TwoPointsDE algorithm) optimizing simultaneously for prediction accuracy and decomposition plausibility — 5 independent trials of 2,000 iterations each (10,000 models fit in total), reduced via clustering to 9 representative candidates from the Pareto-optimal front.

**Model fit:** Adjusted R² of 0.94–0.98 across the 9 candidate models, on both training and held-out test data — the models explain the data well and aren't simply overfitting to history.

---

## What actually drives revenue

Before getting to marketing specifically, it's worth being upfront about scale: **the large majority of revenue movement isn't explained by marketing at all.** Across every one of the 9 candidate models, roughly 55–66% of revenue variation is attributed to competitor sales (a factor outside marketing's control), and another 20–33% to the underlying business trend. All paid and organic media combined explain a comparatively modest share. This matters for how confidently anyone should talk about marketing's overall importance to the topline — even a highly effective channel is operating on a small piece of the pie.

---

## Channel-by-channel findings

| Channel | Share of media spend | Return per dollar (ROAS) | Confidence |
|---|---|---|---|
| **Print** | ~5% | **5–7x** | High — consistent across every model |
| **TV** | ~21% | 1.1–3.9x | Mixed — most models show 3–4x, two of nine show closer to breakeven |
| **OOH** | **62%** | **~1.0–1.6x** | High — consistently near breakeven across every model |
| **Search** | ~9% | 1.4–3x | Moderate — wide uncertainty band |
| **Facebook** | ~3% | ~0–1.6x | Low — in several models, statistically indistinguishable from zero |

The headline pattern: **the channel getting nearly two-thirds of the budget (OOH) is the least efficient at the margin, while one of the smallest channels (print) is by far the most efficient.** TV is generally solid but not unanimous across models. Facebook and, to a lesser extent, search carry real uncertainty — largely because their historical spend varied so little that the model doesn't have enough signal to pin their effect down precisely (this was visible even in the raw spend data, before any modeling).

---

## Budget reallocation recommendation

Using `robyn_allocator()` to test: *if total spend stayed exactly the same, how should it be redistributed to maximize revenue?*

Run on two different candidate models (to check the recommendation wasn't an artifact of picking one specific model):

| Channel | Model A result | Model B result |
|---|---|---|
| Total revenue gain | +16.7% | +33.3% |
| OOH | −31% | −26% |
| Print | +50% (hit upper limit) | +50% (hit upper limit) |
| Search | +50% (hit upper limit) | +50% (hit upper limit) |
| TV | +50% (hit upper limit) | +50% (hit upper limit) |
| Facebook | +50% (hit upper limit) | **−50% (hit lower limit)** |

**What's robust:** cutting OOH and growing print, search, and TV. Both models agree on this, and notably, three of those four channels wanted to move *past* the 50% cap we deliberately imposed — meaning the true opportunity is likely larger than even the smaller of these two estimates, not smaller.

**What's not robust:** the exact magnitude (17% vs. 33% is a meaningful spread) and Facebook's recommended direction, which flips entirely between the two models. The honest conclusion is a **range, not a point estimate** — and an explicit recommendation to *not* make a confident call on Facebook budget without better data (ideally a real incrementality test, since the historical data alone can't resolve it).

---

## What I'd tell a stakeholder

*"Out-of-home is taking nearly two-thirds of the media budget but is only marginally profitable at current spend levels, while print — a much smaller line item — is consistently your most efficient channel. Shifting budget from OOH toward print, search, and TV, without spending an extra dollar overall, could plausibly grow revenue by somewhere in the high teens to low thirties percent, though the exact number depends on modeling assumptions we can't fully resolve with this data alone. Facebook is the one channel I can't give you a confident answer on — its historical spend barely moved, so the model genuinely can't tell if it's working. If there's appetite to actually test that, a real holdout experiment on Facebook would resolve it far better than more modeling can."*

---

## Limitations, stated honestly

- **Simulated, not real, data.** Disclosed above — methodology transfers directly, results do not.
- **No calibration data.** Without a real experiment (e.g. a geo holdout test) to anchor to, the model is inferring everything from historical correlation, constrained by adstock/saturation shape assumptions. This is standard MMM practice, but it's a real limitation, not a footnote.
- **The business-plausibility objective (DECOMP.RSSD) didn't fully converge** even after 10,000 model fits — meaning there's genuine, irreducible ambiguity in how credit splits between the lower-spend channels, not just noise that more iterations would resolve.
- **Facebook and, to a lesser extent, search lack enough spend variation** to be estimated with real confidence — a data limitation, not a modeling failure.

---

## Reproducing this analysis

Full code, in order, in `R/`: environment setup → data exploration → input configuration → hyperparameter ranges → model search → Pareto front selection → budget allocation. Package versions are pinned via `renv.lock` for exact reproducibility. See the project README for setup instructions.
