# Marketing Mix Modeling with Robyn

A self-directed project building a full Marketing Mix Model from scratch — environment setup through a budget reallocation recommendation — using Meta's open-source Robyn package.

## Why I built this

I'm a marketing professional with a quantitative background (forecasting, discrete-event simulation, optimization) moving toward AI-focused marketing and marketing analytics roles. I didn't want to just read about MMM — I wanted to actually build one, hit the real problems that come up, and be able to talk through every decision in an interview, not just describe the methodology in the abstract.

## What I actually did

- **Set up the R ↔ Python bridge Robyn depends on** — its hyperparameter search runs on Meta's Nevergrad library, which is Python-only. I built the bridge with `reticulate`, then proved it actually worked with a live optimization round-trip before touching any marketing data, rather than assuming the install succeeded.
- **Explored the data before modeling anything** — looked at revenue seasonality and per-channel spend patterns first, which surfaced a real issue early: some channels had so little spend variation that I knew their effects would be hard to estimate precisely before the model ever confirmed it.
- **Configured inputs and set hyperparameter ranges with actual reasoning**, not defaults — adstock carryover ranges differ by channel type (digital/performance channels decay fast, traditional/brand channels linger), based on how each channel plausibly behaves, not arbitrary numbers.
- **Caught a real bug before it became expensive** — my hyperparameter names didn't match Robyn's actual internal variable names, which would have silently broken the model. Found it by checking the printed configuration before running anything, not after.
- **Ran a 10,000-model search** (5 trials × 2,000 iterations) and worked through Pareto-front model selection and clustering rather than picking one model and trusting it blindly.
- **Tested the budget reallocation recommendation for robustness** — reran the allocator on a second, meaningfully different model from the Pareto front specifically to check whether the recommendation held up or was an artifact of one model choice. It mostly held; one channel's recommendation flipped entirely between models, and I reported that honestly rather than picking the number that looked cleaner.
- **Wrote a stakeholder-ready report** that states real limitations (non-converged plausibility metric, no calibration data, simulated dataset) rather than hiding them.
- **Debugged the deployment, not just the modeling** — getting this onto GitHub involved working through a stale GitHub token, a CRAN-vs-GitHub-mirror dependency issue, mismatched hyperparameter names, and a large-push failure that needed a git buffer fix. All real problems, all solved.

## What the analysis found

- Out-of-home (OOH) consumes **62% of media spend but returns only ~1.0–1.6x** — consistently the least efficient channel across every candidate model tested.
- Print is the most efficient channel by far (**5–7x return**) despite being only ~5% of spend.
- Reallocating the existing budget — no new spend — could plausibly grow revenue by **17–33%**, depending on modeling assumptions. The direction is robust across models; the exact magnitude isn't, and the report says so explicitly.
- Facebook's effect is genuinely indeterminate from this data — two independent models disagree on whether to increase or cut its budget, which traces back to too little historical spend variation to estimate it confidently.

Full write-up, written for a non-technical stakeholder: **[`report/mmm_case_study.md`](report/mmm_case_study.md)**

## Skills this project demonstrates

R (data manipulation, statistical modeling), Python interoperability via `reticulate`, ridge regression and regularization, time-series decomposition (Prophet), multi-objective optimization concepts, reproducible environment management (`renv`), and — maybe most relevantly for analytics roles — translating model output into a business recommendation while being explicit about where the data does and doesn't support confidence.

## What's in this repo

```
.
├── README.md
├── renv.lock                   # exact package versions, for reproducibility
├── R/
│   ├── 00_setup.R               # environment + R <-> Python (Nevergrad) bridge
│   ├── 01_load_data.R           # data exploration
│   ├── 02_robyn_inputs.R        # first-pass input configuration
│   ├── 03_hyperparameters.R     # adstock + saturation ranges
│   ├── 04_run_model.R           # robyn_run() -- the model search
│   ├── 05_robyn_outputs.R       # Pareto front selection + clustering
│   ├── 06_allocator.R           # budget reallocation
│   └── 07_robustness_check.R    # cross-model robustness test
├── outputs/
│   └── plots/                    # one-pagers, response curves, allocator plots
└── report/
    └── mmm_case_study.md          # full stakeholder-ready write-up
```

## Reproducing this

This project uses [renv](https://rstudio.github.io/renv/) to pin exact package versions, and a Python virtual environment (via `reticulate`) for Robyn's hyperparameter optimizer.

1. Clone the repo, open it in R / RStudio.
2. ```r
   install.packages("renv")
   renv::init()
   ```
3. ```r
   source("R/00_setup.R")
   ```
   Installs Robyn and dependencies, builds the Python bridge, and verifies it works (look for a number close to `0.37`).
4. ```r
   renv::snapshot()
   ```
5. Run `R/01_load_data.R` through `R/07_robustness_check.R` in order.

**Note:** this uses Robyn's official `dt_simulated_weekly` demo dataset — simulated, not real company data. Disclosed explicitly; the methodology shown transfers directly to real data, the specific numbers do not.
