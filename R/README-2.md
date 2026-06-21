# Marketing Mix Modeling with Robyn

A complete, reproducible Marketing Mix Model built with Meta's open-source Robyn package — from raw data through a budget reallocation recommendation, with every modeling decision explained along the way.

## Key findings

- **Out-of-home (OOH) consumes 62% of media spend but returns only ~1.0–1.6x** — consistently the least efficient channel across every candidate model tested.
- **Print is the most efficient channel by far (5–7x return)** despite being only ~5% of spend.
- Reallocating the existing budget — no new spend — could plausibly grow revenue by **17–33%**, depending on modeling assumptions. The direction is robust across models; the exact magnitude isn't, and the report says so explicitly.
- **Facebook's effect is genuinely indeterminate** from this data — historical spend varied too little to estimate it with confidence, and two independent models disagree on whether to increase or cut its budget.

Full write-up, written for a non-technical stakeholder: **[`report/mmm_case_study.md`](report/mmm_case_study.md)**

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
│   └── plots/
│       └── robyn_models/         # one-pagers, response curves, allocator plots
└── report/
    └── mmm_case_study.md          # full stakeholder-ready write-up
```

## Methodology

Geometric adstock, Hill-function saturation curves, ridge regression, and a multi-objective evolutionary search (Nevergrad's `TwoPointsDE`, called from R via `reticulate`) optimizing jointly for prediction accuracy and decomposition plausibility. 10,000 candidate models fit across 5 independent trials, reduced to 9 representative models via Pareto-front clustering. The reasoning behind every parameter choice is documented in the script comments and in the full report.

**Data:** Robyn's official `dt_simulated_weekly` demo dataset — simulated, not real company data. Disclosed explicitly rather than implied otherwise; the methodology shown transfers directly to real data, the specific numbers do not.

## Setup

This project uses [renv](https://rstudio.github.io/renv/) to pin exact package versions, and a Python virtual environment (via `reticulate`) for Robyn's hyperparameter optimizer (Nevergrad), which has no R equivalent.

1. Clone the repo and open it in R / RStudio (so the working directory is the project root).
2. ```r
   install.packages("renv")
   renv::init()
   ```
3. ```r
   source("R/00_setup.R")
   ```
   Installs Robyn and its dependencies, creates a dedicated Python virtualenv, installs Nevergrad into it, and runs a live check that the R -> Python bridge actually works (look for a number close to `0.37`).
4. ```r
   renv::snapshot()
   ```
5. Run `R/01_load_data.R` through `R/07_robustness_check.R` in order.

## Status

- [x] Environment setup, Robyn + Nevergrad bridge verified
- [x] Data exploration
- [x] Input configuration (`robyn_inputs()`)
- [x] Hyperparameter ranges defined (adstock + Hill saturation)
- [x] Model search (10,000 models, Pareto front + clustering)
- [x] Budget allocator + cross-model robustness check
- [x] Stakeholder report
- [x] Repo packaged for GitHub
