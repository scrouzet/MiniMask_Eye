function [R]= makeMovingAcc(RT,correct, time_res, time_window)
% Compute Moving Accuracy (EWMA style measurement but simpler)
% also it is computed for fixed time points, which make it more convenient to group observers, etc
%
% Inputs:
% RT        - vector of RTs.
% correct   - vector of 0s and 1s associated with the RT vector and coding if the response was correct.
% time_res  - How long to we integrate before
%             Example: if time_res == 10, for the time point 200, 
%             we'll take into account all RTs from 190 to 200
%
% Example:
% R = makeEWMA(RT,correct,mycolor,mylinewidth,myylim,lambda,plotnow);
%
% seb.crouzet@gmail.com

%==========================================================================
% Default arguments
if nargin < 3 || isempty(time_res), time_res = 20; end % in ms
if nargin < 4 || isempty(time_window), time_window = [1:800]; end
%==========================================================================

for k=time_window
    myvals = correct( RT>=k-time_res & RT<=k );
    
    if length(myvals)>5
        acc(k)  = mean(myvals);
        ci(:,k) = bootci(100,@mean,myvals);
    else acc(k) = NaN;
        ci(:,k) = [NaN NaN];
    end
end

% Compute MinRT
bin_above_chance = ci(1,:) > 0.5;
minRT = FirstSelectiveBin(bin_above_chance,20);

% organize output
R.acc       = acc;
R.acc_ci    = ci;
R.acc_minRT = minRT;