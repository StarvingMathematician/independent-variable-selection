# independent-variable-selection
Code to pare down correlated variables prior to regression

For all variable pairs, a measure of pairwise correlation is computed using either Spearman's rho, ANOVA, or chi-squared tests. The largest subset of variable having no significant correlations between them (with significant being decided via a predefined cutoff, default p=0.1) is then identified by modeling the inter-variable correlations as edges in a graph, and identifying the [maximum independent vertex set](https://en.wikipedia.org/wiki/Independent_set_(graph_theory))

TODO:
1. Use different measures to quantify correlation (i.e. combination of p-value and correlation coefficient), as the current tests will flag even non-correlated variables if the number of data points is large enough
2. Test the code on additional datasets