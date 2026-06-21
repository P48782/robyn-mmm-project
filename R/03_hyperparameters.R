# ==============================================================================
# 03_hyperparameters.R
# Step 3b: Define hyperparameter RANGES (not fixed values) and finalize
# InputCollect with the second robyn_inputs() call.
#
# alpha/gamma ranges stay standard and wide across every channel -- we're
# deliberately not presupposing each channel's saturation shape, that's
# what the search (robyn_run(), next script) figures out.
#
# theta ranges differ by channel TYPE, because carryover speed is something
# we can reason about directly: digital/performance channels convert fast
# (low theta), traditional/brand channels linger longer (high theta).
# ==============================================================================

library(Robyn)

if (!exists("InputCollect")) {
  message("InputCollect not found in this session -- running 02_robyn_inputs.R first.")
  source("R/02_robyn_inputs.R")
}

hyperparameters <- list(
  # --- Digital/performance: fast, short-lived effects ----------------------
  # NOTE: named after paid_media_vars (the modeling column), not
  # paid_media_spends -- adstock/saturation apply to impressions/clicks,
  # not raw dollars. Confirmed from the "Paid Media:" line in the
  # robyn_inputs() printout, not assumed.
  facebook_I_alphas = c(0.5, 3),
  facebook_I_gammas = c(0.3, 1),
  facebook_I_thetas = c(0, 0.3),

  search_clicks_P_alphas = c(0.5, 3),
  search_clicks_P_gammas = c(0.3, 1),
  search_clicks_P_thetas = c(0, 0.3),

  # --- Traditional/brand: effects build and linger --------------------------
  tv_S_alphas = c(0.5, 3),
  tv_S_gammas = c(0.3, 1),
  tv_S_thetas = c(0.3, 0.8),

  ooh_S_alphas = c(0.5, 3),
  ooh_S_gammas = c(0.3, 1),
  ooh_S_thetas = c(0.1, 0.4),

  print_S_alphas = c(0.5, 3),
  print_S_gammas = c(0.3, 1),
  print_S_thetas = c(0.1, 0.4),

  # --- Organic: owned channel, moderate carryover ---------------------------
  newsletter_alphas = c(0.5, 3),
  newsletter_gammas = c(0.3, 1),
  newsletter_thetas = c(0.1, 0.4)
)

# Second robyn_inputs() call -- pass the existing InputCollect back in, plus
# the hyperparameters, to finalize everything.
InputCollect <- robyn_inputs(InputCollect = InputCollect, hyperparameters = hyperparameters)

print(InputCollect)

cat("\nInputCollect is now fully configured. Next: robyn_run().\n")
