# ==============================================================================
# 07_robustness_check.R
# Step 5b: Does the reallocation conclusion hold up on a DIFFERENT model
# from the Pareto front, or was it specific to picking 2_131_4?
#
# Same scenario and bounds as before, but model 5_266_3 -- one of the
# models where TV looked much stronger (ROAS ~3.35 vs. ~1.14 in 2_131_4),
# making this a meaningful contrast rather than a near-duplicate check.
# ==============================================================================

library(Robyn)

AllocatorCollect_check <- robyn_allocator(
  InputCollect = InputCollect,
  OutputCollect = OutputCollect,
  select_model = "5_266_3",

  scenario = "max_response",
  channel_constr_low = 0.5,
  channel_constr_up  = 1.5,
  date_range = "all"
)

cat("\nRobustness check complete (model 5_266_3).\n")
cat("Compare against the 2_131_4 run: same direction? similar magnitude?\n")
print(AllocatorCollect_check)
