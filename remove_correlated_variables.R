library(igraph)

# Uses Spearman's rho to determine whether a significant correlation exists between two continuous variables
cont_cont_corr_p <- function(var1_cont, var2_cont){
  cor.test(var1_cont,var2_cont,method='spearman')$p.value
}

# Uses ANOVA to determine whether a significant correlation exists between a continuous variable and a discrete variable
cont_disc_corr_p <- function(var1_cont, var2_disc){
  summary(aov(var1_cont~var2_disc))[[1]][[1,"Pr(>F)"]]
}

# Uses chi-squared test to determine whether a significant correlation exists between two discrete variables
disc_disc_corr_p <- function(var1_disc, var2_disc){
  chisq.test(table(var1_disc,var2_disc))$p.value
}

get_pairwise_correlations <- function(data, colnames1, colnames2, corr_func){
  colname_pair_df <- expand.grid(colnames1, colnames2)
  colname_pair_df$p_value <- mapply(function(colname1,colname2) corr_func(data[,colname1],data[,colname2]), colname_pair_df[,1], colname_pair_df[,2])
  colname_pair_df
}

# Given some multivariate dataframe, return a vector of variable names, with the names being the largest subset
# of variables having no pairwise correlations between them (if multiple such subsets exist, pick one at random)
get_uncorrelated_variables <- function(data, cutoff=0.1){
  
  # Subdivide data frame into factor and non-factor variables
  col_classes <- sapply(data, class)
  
  numeric_colnames <- colnames(data)[col_classes %in% c('numeric','integer')]
  factor_colnames <- colnames(data)[col_classes == 'factor']
  
  if (length(numeric_cols) + length(factor_cols) < ncol(data)){
    stop("Input dataframe contains columns of type other than 'numeric', 'integer', and 'factor'")
  }
  
  # Continuous-vs-Continuous
  cont_cont_pval_df <- get_pairwise_correlations(data, numeric_colnames, numeric_colnames, cont_cont_corr_p)
  
  # Continuous-vs-Discrete
  cont_disc_pval_df <- get_pairwise_correlations(data, numeric_colnames, factor_colnames, cont_disc_corr_p)
  
  # Discrete-vs-Discete
  disc_disc_pval_df <- get_pairwise_correlations(data, factor_colnames, factor_colnames, disc_disc_corr_p)
  
  # Aggregate pairwise correlation results into single wide matrix
  pairwise_corr_mat <- rbind(cont_cont_pval_df, cont_disc_pval_df, cont_disc_pval_df[,c(2,1,3)], disc_disc_pval_df)
  pairwise_corr_mat <- reshape(pairwise_corr_mat, idvar="Var1", timevar="Var2", direction="wide")
  if (!(setequal(rownames(pairwise_corr_mat),colnames(data)) && setequal(colnames(pairwise_corr_mat),colnames(data)))){
    stop("Something has gone horribly wrong!")
  } else{
    pairwise_corr_mat <- pairwise_corr_mat[colnames(data),colnames(data)]
  }
  
  # Apply significance cutoff to convert matrix entries to binary 0/1
  adjacency_mat <- 1 * (pairwise_corr_mat <= cutoff)
  
  # Return the largest independent set, i.e. the largest subset of variables with no significant pairwise correlations between them
  graph <- graph_from_adjacency_matrix(adjacency_mat, mode="undirected", diag=FALSE)
  indep_colnames <- largest_ivs(graph)[[1]]$name
  indep_colnames
}