# ==============================================================================
# 02_robyn_inputs.R
# Step 3a: First robyn_inputs() call -- everything EXCEPT hyperparameters.
#
# Robyn's workflow calls robyn_inputs() twice on purpose: this first call
# tells Robyn what your data and channels look like, and in return it tells
# YOU exactly which hyperparameter names it needs (based on your channel
# count and adstock choice). The second call, in 03_hyperparameters.R,
# supplies those and finalizes things. So nothing here is hyperparameter
# guessing -- it's purely formalizing what step 2 already confirmed.
# ==============================================================================

library(Robyn)
library(dplyr)

data("dt_simulated_weekly")
data("dt_prophet_holidays")

InputCollect <- robyn_inputs(
  dt_input    = dt_simulated_weekly,
  dt_holidays = dt_prophet_holidays,

  date_var = "DATE",      # the weekly time index
  dep_var  = "revenue",   # what we're trying to explain
  dep_var_type = "revenue",  # vs. "conversion" -- this just tells Robyn the
                              # units are dollars, which affects how ROI gets
                              # computed and labeled downstream

  # Prophet decomposition: pull out trend/seasonality/holiday effects BEFORE
  # any media modeling happens, so a December revenue spike doesn't get
  # wrongly credited to whichever channel happened to be running that month.
  prophet_vars    = c("trend", "season", "holiday"),
  prophet_country = "DE",   # arbitrary for simulated data, but Robyn's
                             # official demo uses DE -- following that for
                             # consistency with anything you reference later

  # Context variables: real drivers of revenue that aren't your marketing,
  # and shouldn't be credited to it.
  context_vars = c("competitor_sales_B", "events"),

  # The spend/exposure split confirmed in step 2:
  # paid_media_spends = actual dollars (used later for ROI and budget allocation)
  # paid_media_vars   = what the model actually learns the effect from
  #                      (impressions/clicks where available, spend where not)
  paid_media_spends = c("tv_S", "ooh_S", "print_S", "facebook_S", "search_S"),
  paid_media_vars   = c("tv_S", "ooh_S", "print_S", "facebook_I", "search_clicks_P"),

  organic_vars = "newsletter",  # free/owned activity, not paid, but still
                                 # a marketing lever worth measuring

  # Modeling window: starting a few weeks after the data begins (rather than
  # at 2015-11-23) leaves a short buffer so that adstock carryover from
  # spend just before the window has some history to draw on, instead of
  # the model assuming those early weeks had zero prior marketing activity.
  window_start = "2016-01-01",
  window_end   = "2019-11-11",  # the actual last date in the data

  adstock = "geometric"  # the decay model -- full explanation coming in the
                          # next script, when we set its actual parameters
)

print(InputCollect)

cat("\n--------------------------------------------------------------\n")
cat("Look for a message above about hyperparameter names Robyn needs.\n")
cat("Paste that back -- it's the exact list we'll define next.\n")
cat("--------------------------------------------------------------\n")
