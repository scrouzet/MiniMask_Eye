function [qt] = makeQuantiles(X, myquantiles)
% Return a vector (same size as X) with the corresponding indices of the
% quantiles of each value in X

edges = quantile(X, myquantiles);

% To include all non-NaN values
edges(1) = -Inf;
edges(end) = Inf;

[~, qt] = histc(X, edges);
