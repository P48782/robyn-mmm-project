# ==============================================================================
# 06_allocator.R
# Step 5: robyn_allocator() -- turn the channel efficiency pattern from step 4
# into an actual "move $X here, $X there" recommendation.
# ==============================================================================

library(Robyn)

# Using 2_131_4: best fit on held-out data (lowest test NRMSE) AND the most
# business-plausible decomposition (lowest DECOMP.RSSD) of all 9 candidates.
# Note: this is also one of the two models where TV showed up weaker than
# in the others -- worth keeping in mind when reading the result below.
selected_model <- "2_131_4"

AllocatorCollect <- robyn_allocator(
  InputCollect = InputCollect,
  OutputCollect = OutputCollect,
  select_model = selected_model,

  scenario = "max_response",   # same total budget, better split -- not a
                                # "spend more" recommendation

  channel_constr_low = 0.5,    # no channel drops below half its current
  channel_constr_up  = 1.5,    # spend, or rises above 1.5x -- keeps the
                                # recommendation realistic, not extreme

  date_range = "all"
)

cat("\nrobyn_allocator() complete.\n")
print(AllocatorCollect)
