# ================================================================
# Brown’s Method P-value Calculation for Manual vs RECOMIA Features
# ================================================================

# Load required package
library(poolr)

# --------------------------
# Step 1: Load Input Datasets
# --------------------------
data_man     <- read.csv("new_manual_pyradiomic_data.csv")
data_recomia <- read.csv("RECOMIA_pyradiomic_data.csv")

# ----------------------------------------
# Step 2: Normality Filtering
# ----------------------------------------
check_normality_and_filter <- function(data) {
  passing_rows <- c()
  
  for (i in 1:nrow(data)) {
    vals <- as.numeric(data[i, 2:ncol(data)])
    vals <- na.omit(vals)
    
    if (length(vals) >= 3 && sd(vals) > 0) {  # avoid errors with constant vectors
      pv <- shapiro.test(vals)$p.value
      if (pv >= 0.05) {                       # keep if normal
        passing_rows <- c(passing_rows, i)
      }
    }
  }
  
  return(data[passing_rows, ])
}

# ------------------------------
# Step 3: Apply Normality Filter
# ------------------------------
data_man_normal     <- check_normality_and_filter(data_man)
data_recomia_normal <- check_normality_and_filter(data_recomia)

# Keep only features (rows) that passed normality in BOTH datasets
common_features <- intersect(data_man_normal[,1], data_recomia_normal[,1])
data_man_filt     <- data_man[data_man[,1] %in% common_features, ]
data_recomia_filt <- data_recomia[data_recomia[,1] %in% common_features, ]

# -----------------------------------------------------
# Step 4: Compute Wilcoxon Test for Each Feature
# -----------------------------------------------------
data_pval_man_recomia <- data.frame(matrix(NA, nrow = nrow(data_man_filt), ncol = 1))

for (row_idx in 1:nrow(data_man_filt)) {
  wilcox_result <- wilcox.test(
    as.numeric(data_man_filt[row_idx, 2:ncol(data_man_filt)]),
    as.numeric(data_recomia_filt[row_idx, 2:ncol(data_recomia_filt)]))
  data_pval_man_recomia[row_idx, 1] <- wilcox_result$p.value
}

rownames(data_pval_man_recomia) <- data_man_filt[, 1]
colnames(data_pval_man_recomia) <- "wilcoxon_pvalue"

# Write Wilcoxon p-values to CSV
write.csv(data_pval_man_recomia, "manual_recomia_wilcoxon_pvalues.csv")

# ------------------------------------------------
# Step 5: Apply Brown’s Method (Generalized Fisher)
# ------------------------------------------------
# Prepare RECOMIA matrix for correlation
recomia_mat <- data_recomia_filt
rownames(recomia_mat) <- recomia_mat$Case
recomia_mat$Case <- NULL

# Correlation matrix
r <- cor(t(recomia_mat))

# Brown’s method p-value
brown_p <- fisher(data_pval_man_recomia$wilcoxon_pvalue,
                  adjust = "generalized",
                  R = mvnconv(r))$p

# Print result
cat("Final Brown’s method p-value:", brown_p, "\n")
