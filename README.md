# Marketing Mix Modeling with Robyn

*A from-scratch MMM build using Meta's open-source Robyn package, on Robyn's
simulated weekly demo dataset. Work in progress -- methodology, results, and
findings will be added to this README as the project develops.*

## Project structure

```
.
├── R/                  # numbered analysis scripts, run in order
├── data/                # any data beyond Robyn's built-in demo set
├── outputs/
│   ├── plots/           # response curves, Pareto front, decomposition charts
│   └── models/          # saved model objects
├── report/               # plain-English write-up for a non-technical stakeholder
└── renv.lock              # exact package versions, for reproducibility
```

## Setup

This project uses [renv](https://rstudio.github.io/renv/) to pin exact
package versions, and a Python virtual environment (via `reticulate`) for
Robyn's hyperparameter optimizer (Nevergrad), which has no R equivalent.

1. Clone the repo and open it in R / RStudio (so the working directory is
   the project root).
2. ```r
   install.packages("renv")
   renv::init()
   ```
3. ```r
   source("R/00_setup.R")
   ```
   This installs Robyn and its dependencies, creates a dedicated Python
   virtualenv, installs Nevergrad into it, and runs a live check that the
   R -> Python bridge actually works (you should see a number close to
   `0.37` printed at the end).
4. ```r
   renv::snapshot()
   ```
   This locks the exact versions you just installed into `renv.lock`, so
   the project is reproducible later.

## Status

- [x] Step 1: Environment setup, Robyn + Nevergrad bridge verified
- [ ] Step 2: Load demo data
- [ ] Step 3: Configure inputs, hyperparameters, run model
- [ ] Step 4: Interpret results (Pareto front, decomposition, ROI)
- [ ] Step 5: Budget allocator
- [ ] Step 6: Stakeholder report
- [ ] Step 7: Final repo polish
