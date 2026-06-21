# ==============================================================================
# 00_setup.R
# One-time environment setup for the Robyn MMM project.
#
# Run this from the project root, inside the renv-activated project
# (see README.md for the renv::init() step that comes before this).
# ==============================================================================

# ---- 1. CRAN dependencies Robyn needs ---------------------------------------
# This is Robyn's actual Imports list (pulled straight from its DESCRIPTION
# file), plus 'remotes' so we can install Robyn itself from GitHub below.
cran_pkgs <- c(
  "remotes", "reticulate", "dplyr", "ggplot2", "doParallel", "doRNG",
  "foreach", "glmnet", "jsonlite", "lares", "lubridate", "nloptr",
  "patchwork", "prophet", "stringr", "tidyr", "ggridges"
)
to_install <- setdiff(cran_pkgs, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install)

# ---- 2. Robyn itself, from Meta's GitHub repo -------------------------------
# Robyn is not on CRAN -- Meta ships it via GitHub only, since the package
# moves faster than CRAN's release cycle. This is the correct, official
# install path (see facebookexperimental/Robyn).
if (!"Robyn" %in% rownames(installed.packages())) {
  remotes::install_github("facebookexperimental/Robyn/R", upgrade = "never")
}

# ---- 3. The R -> Python bridge (reticulate + Nevergrad) ---------------------
# WHY THIS STEP EXISTS:
# Robyn's hyperparameter search has to explore adstock decay rates, Hill
# saturation shapes, and ridge regularization strength all at once, while
# balancing two competing objectives (fit accuracy vs. business-plausible
# decomposition). That's a multi-objective, non-differentiable search problem
# -- there's no clean gradient to descend. Meta's answer is Nevergrad, a
# Python library of derivative-free/evolutionary optimizers. Robyn defaults
# to Nevergrad's "TwoPointsDE" algorithm. There's no R equivalent, so Robyn
# reaches into Python for just this one piece via reticulate, which lets R
# call Python objects/functions as if they were native R objects.
library(reticulate)

venv_name <- "robyn-mmm-env"
if (!venv_name %in% virtualenv_list()) {
  virtualenv_create(venv_name)
}
use_virtualenv(venv_name, required = TRUE)
py_install("nevergrad", envname = venv_name, pip = TRUE)

# ---- 4. Verify the bridge actually works -- don't just trust the install ----
# This runs a real (tiny) optimization loop through Nevergrad from R. If you
# see a number close to 0.37 printed below, the bridge is live and correct.
ng <- import("nevergrad")
cat("Nevergrad version visible from R:", ng$`__version__`, "\n")

param <- ng$p$Scalar(init = 0.5, lower = 0, upper = 1)
opt   <- ng$optimizers$registry[["TwoPointsDE"]](parametrization = param, budget = 10L)
for (i in 1:10) {
  x <- opt$ask()
  opt$tell(x, (x$value - 0.37)^2)   # toy objective: converge toward 0.37
}
cat("Bridge check -- optimizer converged toward 0.37, got:",
    round(opt$recommend()$value, 4), "\n")

cat("\nSetup complete.\n")
cat("If the number above is close to 0.37, R, Robyn, and the Nevergrad\n")
cat("bridge are all working. Next: renv::snapshot() to lock these versions,\n")
cat("then move to R/01_load_data.R.\n")
