# ==============================================================================
# 05_robyn_outputs.R
# Step 4a: robyn_outputs() -- calculate the Pareto front, cluster similar
# models down to a manageable set, and export the plots we'll actually
# interpret (one-pagers, decomposition, response curves, ROI).
# ==============================================================================

library(Robyn)

OutputCollect <- robyn_outputs(
  InputCollect, OutputModels,

  pareto_fronts = "auto",  # let Robyn decide how many Pareto fronts to keep
                            # (the front = the best fit/plausibility trade-offs;
                            # "auto" doesn't force a single arbitrary cutoff)

  clusters = TRUE,         # often hundreds of models sit on or near the Pareto
                            # front, many nearly identical to each other --
                            # clustering groups similar ones and picks
                            # representatives, so there's a reviewable
                            # shortlist instead of hundreds of near-duplicates

  csv_out = "pareto",      # export the Pareto-front model results to CSV
  export = TRUE,           # save plots to disk
  plot_folder = "outputs/plots/robyn_models",
  plot_pareto = TRUE
)

cat("\nrobyn_outputs() complete.\n")
cat("Selected model IDs (after clustering):\n")
print(OutputCollect$allSolutions)

cat("\nPlots and CSVs saved under outputs/plots/robyn_models/.\n")
cat("Open that folder -- look for the one-pager PNGs -- and let's go\n")
cat("through what's actually in them.\n")
