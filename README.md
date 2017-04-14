# independent-variable-selection
Code to pare down correlated variables prior to regression

For all variable pairs, a measure of pairwise correlation is computed using either Spearman's rho, ANOVA, or chi-squared tests. The largest subset of variable having no significant correlations between them (with significant being decided via a predefined cutoff, default p=0.1) is then identified by modeling the inter-variable correlations as edges in a graph, and identifying the [maximum independent vertex set](https://en.wikipedia.org/wiki/Independent_set_(graph_theory))

TODO:
1) Use different measures to quantify correlation, as the current tests flag even non-correlated variables if the number of data points is large enough (shouldn't be using p-values at all...)