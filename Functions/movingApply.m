function [y] = movingApply(x,n,fun)
% Compute a function using a moving sliding window
% Only takes into account past information (different from basic filtering)
% -> moving average of a performance over time for example
%
% Example:
% y = movingApply(x,20,@mean);
%
% Keep in mind that the moving window will only reach the size n
% after the n first iterations.
%
% seb.crouzet@gmail.com

%==========================================================================
% Default arguments
if nargin < 3 || isempty(fun), fun=@mean; end
%==========================================================================

for k=1:length(x)
    if k==1
        y(k) = x(k);
    elseif k<=n
        y(k) = fun(x(1:k));
    elseif k>n
        y(k) = fun(x((k-(n-1)):k));
    end
end
