suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)

  library(pheatmap)    # heatmap
})

#N subjects
#M features: SUVmean, Entropy
#K segmentation methods: Manual (gold), n535, RECOMIA


# ---- Core: pairwise-method agreement profile per feature (CCC preferred) ----
# Returns: M x P matrix where P = choose(K, 2), columns are "A|B"
compute_feature_method_profile = function(df_long)
{
  methods = sort(unique(df_long$method))
  pairs = combn(methods, 2, simplify = FALSE)
  pairs[[3]]=NULL
  pair_names = vapply(pairs, function(p) paste(p, collapse = " & "), "")
  features = sort(unique(df_long$feature))
  res = matrix(0, nrow = length(features), ncol = length(pairs),dimnames = list(features, pair_names))
  for (f in features)
  {
    #print(f)
    d_f = df_long |> filter(feature == f)
    # For each pair of methods, align by subject and compute agreement across subjects
    for (j in seq_along(pairs))
    {
      p = pairs[[j]]
      #        d_f[which(d_f$method %in% p),]
      sub_df = d_f |> filter(method %in% p) |> select(subject, method, value) |> distinct() |> pivot_wider(names_from = method, values_from = value)
      #subject    method      value		->		   subject manual nnUNet535
      #p009       manual 6018.93559				   p009     6019.     203.
      #p009    nnUNet535  203.39032

      # Keep only complete subject rows for the two methods
      #sub_df = sub_df %>% filter(complete.cases(.))
      sub_df = sub_df[which(complete.cases(sub_df)),]
      if (nrow(sub_df) < 3 )
      {
        res[f, j] = NA_real_
        next
      }
      x = sub_df[[p[1]]]
      y = sub_df[[p[2]]]
      #print(j)
      #print(paste(x))
      res[f, j] = suppressWarnings(cor(x, y, use = "pairwise.complete.obs", method = "pearson"))
      #ccc = try(DescTools::CCC(x, y, ci = "z-transform"), silent = TRUE)
      #res[f, j] = if (inherits(ccc, "try-error")) NA_real_ else as.numeric(ccc$rho.c[, "est"])

    }
  }
  res
}

# ---- Clustering & visualization ----
cluster_and_plot = function(feature_pair_matrix, scale_cols = FALSE, method_dist = "euclidean", method_hclust = "ward.D2", show_row_names = FALSE) 
{
  mat = feature_pair_matrix
  # Optional: scale columns so each pairwise-agreement feature has comparable variance
  if (scale_cols)
  {
    mat = scale(mat)
  }
  # Heatmap with hierarchical clustering (Ward)
  pheatmap::pheatmap(mat,
                     clustering_distance_rows = method_dist,
                     clustering_method = method_hclust,
                     show_rownames = show_row_names,angle_col=0,fontsize=10,
                     main = "radiomics parameter × (pairwise method agreement) — clustered")
}


source("/home/leductrung/Documents/cluster1/dataInput.r")
df_long$feature=gsub('original_','',df_long$feature)

# Ensure column types
df_long = df_long |>  mutate( subject = as.character(subject), method  = as.character(method), feature = as.character(feature) )
feat_pair_mat = compute_feature_method_profile(df_long)

setwd("/home/leductrung/Documents/cluster1/")
dn="./"
fn="clusterized_features"
png(file=paste0(dn,fn,".png"),width=1000,height=1000)
    suppressWarnings(cluster_and_plot(feat_pair_mat, show_row_names = TRUE))
dev.off()

