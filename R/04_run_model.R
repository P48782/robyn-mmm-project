# ==============================================================================
# 04_run_model.R
# Step 3c: robyn_run() -- where the actual search happens.
#
# Run this TWICE: once with run_mode = "TEST" (fast, catches errors cheaply),
# then with run_mode = "FULL" (the real result) once the test run confirms
# nothing's broken. Worth doing given we've already caught two real
# mistakes earlier in this project -- cheap checks before expensive runs.
# ==============================================================================

library(Robyn)

# ---- Toggle this ------------------------------------------------------------
run_mode <- "FULL"   # change to "FULL" after a clean test run

if (run_mode == "TEST") {
  n_iterations <- 100
  n_trials <- 2
} else {
  n_iterations <- 2000
  n_trials <- 5
}

cat("Running in", run_mode, "mode:", n_iterations, "iterations x", n_trials, "trials\n")
cat("(TEST should take a few minutes. FULL can take a while longer --\n")
cat("it's doing", n_iterations * n_trials, "total model fits.)\n\n")

OutputModels <- robyn_run(
  InputCollect = InputCollect,
  iterations = n_iterations,
  trials = n_trials,
  ts_validation = TRUE   # uses the train_size split to check for overfitting
)

cat("\nrobyn_run() complete.\n")
print(OutputModels)
