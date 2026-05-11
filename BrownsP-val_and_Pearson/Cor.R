# Load datasets
data_man = read.csv("new_manual_pyradiomic_data.csv")
data_nnunet = read.csv("Project535_pyradiomic_data.csv")

# Initialize output data frame for row-wise Pearson correlation
data_cor_man_nnunet = data.frame(matrix(0, nrow = nrow(data_man), ncol = 1))

# Calculate correlation
for (row_idx in 1:nrow(data_man)) {
  data_cor_man_nnunet[row_idx, 1] = cor(
    as.numeric(data_man[row_idx, 2:ncol(data_man)]),
    as.numeric(data_nnunet[row_idx, 2:ncol(data_nnunet)]),
    method = "pearson"
  )
}

# Set row names and column name
rownames(data_cor_man_nnunet) = data_man[, 1]
colnames(data_cor_man_nnunet) = "pearson_correlation"

# Write the result to CSV
write.csv(data_cor_man_nnunet, "manual_nnunet_cor.csv")
