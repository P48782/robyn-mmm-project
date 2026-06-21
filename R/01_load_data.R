# ==============================================================================
# 01_load_data.R
# Step 2: Load and explore Robyn's demo datasets BEFORE configuring anything.
# Nothing here touches robyn_inputs() yet -- the goal is just to understand
# what's actually in the data first.
# ==============================================================================

library(Robyn)
library(dplyr)
library(ggplot2)

# ---- 1. Load the two datasets that ship inside the Robyn package -----------
data("dt_simulated_weekly")
data("dt_prophet_holidays")

# ---- 2. Structure first -- don't assume, look ---------------------------------
cat("=== dt_simulated_weekly ===\n")
cat("Dimensions:", dim(dt_simulated_weekly), "\n\n")
str(dt_simulated_weekly)

cat("\n=== dt_prophet_holidays ===\n")
cat("Dimensions:", dim(dt_prophet_holidays), "\n\n")
str(dt_prophet_holidays)

# ---- 3. First rows + date range ----------------------------------------------
cat("\n=== First 5 rows of dt_simulated_weekly ===\n")
print(head(dt_simulated_weekly, 5))

cat("\n=== Date range ===\n")
cat("From:", as.character(min(dt_simulated_weekly$DATE)),
    "to:", as.character(max(dt_simulated_weekly$DATE)),
    "(", nrow(dt_simulated_weekly), "weeks )\n")

# ---- 4. Plot: the outcome variable over time ----------------------------------
p1 <- ggplot(dt_simulated_weekly, aes(x = DATE, y = revenue)) +
  geom_line(color = "steelblue") +
  labs(title = "Weekly Revenue Over Time", x = NULL, y = "Revenue") +
  theme_minimal()
print(p1)
ggsave("outputs/plots/01_revenue_over_time.png", p1, width = 9, height = 4)

# ---- 5. Plot: media spend by channel -------------------------------------------
# Auto-detect spend columns rather than hardcoding names -- let the data
# tell us what channels exist instead of assuming.
spend_cols <- names(dt_simulated_weekly)[grepl("_S$", names(dt_simulated_weekly))]
cat("\nDetected spend columns (ending in _S):", paste(spend_cols, collapse = ", "), "\n")

spend_long <- dt_simulated_weekly %>%
  select(DATE, all_of(spend_cols)) %>%
  tidyr::pivot_longer(-DATE, names_to = "channel", values_to = "spend")

p2 <- ggplot(spend_long, aes(x = DATE, y = spend, color = channel)) +
  geom_line() +
  labs(title = "Weekly Media Spend by Channel", x = NULL, y = "Spend") +
  theme_minimal()
print(p2)
ggsave("outputs/plots/02_spend_by_channel.png", p2, width = 9, height = 4)

cat("\nPlots saved to outputs/plots/.\n")
cat("Look at the console output above (column names, types, date range) and\n")
cat("the two plots, then let's talk through what each column actually\n")
cat("represents before we configure robyn_inputs() in step 3.\n")
