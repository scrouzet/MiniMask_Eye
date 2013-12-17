function [R] = makeRTDistribDiff(RT,correct,mycolor,mylinewidth,myylim,cumul,plotnow,bincenters)
%
%==========================================================================
% Default arguments
if nargin < 3 || isempty(mycolor),     mycolor = 'k'; end
if nargin < 4 || isempty(mylinewidth), mylinewidth = [3 1]; end % 1st for correct responses, 2nd for incorrect
if nargin < 5 || isempty(myylim),      myylim = [0 5]; end
if nargin < 6 || isempty(cumul),       cumul = 0; end % if TRUE, plot the cumulative distribution
if nargin < 7 || isempty(plotnow),     plotnow = 1; end % no plot if 0, plot if 1
if nargin < 8 || isempty(bincenters),  bincenters = 0:10:1000; end
%==========================================================================

% Compute the statistics of the distribution
R.RT = RT;
R.correct = correct;
R.accuracy = mean(correct)*100;
R.meanRT   = mean(RT(correct==1));
R.medianRT = median(RT(correct==1));

% RT distribs
R.bin_centers = bincenters;
R.counts_correct   = hist(RT(correct==1), bincenters);
R.counts_incorrect = hist(RT(correct==0), bincenters);
nTrial = sum(R.counts_correct) + sum(R.counts_incorrect);

% Cumulative RT distribs (can be good for single subject analysis)
if cumul==1
    R.counts_correct = cumsum(R.counts_correct);
    R.counts_incorrect = cumsum(R.counts_incorrect);
end

% Relative counts for plotting (and comparison of conditions)
R.counts_correct_REL   = (R.counts_correct / nTrial) * 100;
R.counts_incorrect_REL = (R.counts_incorrect / nTrial) * 100;

if plotnow
    plot(bincenters, R.counts_correct_REL - R.counts_incorrect_REL, 'Color', mycolor , 'Linewidth', mylinewidth(2)) ; hold on    
end

end