function [res]  = compareDiff95(X1,X2,alpha)
% test if the 95% CI of the distribution of differences between 2 conditions include 0
% return 
%   1 if significantly different = the conditions are significantly different (0 is not included)  
%   0 if not significantly different

%==========================================================================
% Default arguments
if nargin < 3 || isempty(alpha),  alpha = 0.05; end
%==========================================================================

diffs = X1 - X2;

ci = getCIfromboot(diffs,alpha);

if all(ci < 0) % case where X1 is < to X2
    res = -1;
elseif all(ci > 0) % case where X2 is < to X1
    res = 1;
else res = 0;
end