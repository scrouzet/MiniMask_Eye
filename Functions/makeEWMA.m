function [R]= makeEWMA(RT,correct, lambda, N, time_window)
% Compute EWMA = Exponentially Weighted Moving Average
%
% - From the statistical quality control literature (Chandra, 2001; Roberts, 1959)
% - Milosavljevic, Madsen, Koch & Rangel (2011) Journal of Vision
% - Used to ﬁlter “fast guesses” from perceptual data in the Drift Diffusion Model 
% (Ratcliff & McKoon, 2008; Vandekerckhove & Tuerlinckx, 2007).
%
% Inputs:
% RT = vector of RTs.
% correct = vector of 0s and 1s associated with the RT vector and coding if the response was correct.
% lambda = determines the rate at which 'older' data enter into the calculation of the EWMA statistic. 
%          A value of  = 1 implies that only the most recent measurement influences the EWMA
%          (degrades to Shewhart chart). Thus, a large value of = 1 gives more weight to recent data 
%          and less weight to older data; a small value of  gives more weight to older data. 
%          The value of lambda is usually set between 0.2 and 0.3 (Hunter) although this choice is 
%          somewhat arbitrary. Lucas and Saccucci (1990) give tables that help the user select .
% N =  nb of sd for the ci baseline - 3 is the default used in Milosavljevic paper
%
% Example:
% R = makeEWMA(RT,correct,mycolor,mylinewidth,myylim,lambda,plotnow);
%
% seb.crouzet@gmail.com

%==========================================================================
% Default arguments
if nargin < 3 || isempty(lambda), lambda = 0.01; end % 0.01 is the default used in Milosavljevic paper
if nargin < 4 || isempty(N),      N = 3; end         % default used in Milosavljevic paper
if nargin < 5 || isempty(time_window), time_window = [1:800]; end
%==========================================================================

[RTsorted, sortinds] = sort(RT);
correct_sorted = correct(sortinds);

ewma = [];
for i = 1:length(RTsorted)
    if i==1
        ewma(end+1) = lambda*correct_sorted(i) + (1-lambda)*0.5;
    else
        ewma(end+1) = lambda*correct_sorted(i) + (1-lambda)*ewma(end);
    end
    ewma_ci(1,i) = 0.5 + N * 0.5 * sqrt( (lambda/(2-lambda)) * (1-(1-lambda)^(2*i)) );
    ewma_ci(2,i) = 0.5 - N * 0.5 * sqrt( (lambda/(2-lambda)) * (1-(1-lambda)^(2*i)) );
end

% smooth it by removing multiple values for same RT
tewma    = nan(1,length(time_window));
tewma_ci = nan(2,length(time_window));
for k = 1:length(tewma)
    validval = RTsorted==k;
    if k==1,
        tewma(k) = 0.5;
        tewma_ci(:,k) = [0.5;0.5];
    elseif all(validval==0),
        tewma(k) = tewma(k-1);
        tewma_ci(:,k) = ewma_ci(:,k-1);
    else
        tewma(k) = mean(ewma(validval));
        tewma_ci(:,k) = mean(ewma_ci(:,validval),2);
    end
end
ewma = tewma;
ewma_ci = tewma_ci;

%THIS METHOD UNDERWEIGHTS TIME POINT WITH MULTIPLE RT SO BAD
% ewma = nan(1,length(time_window));
% ewma_ci = nan(2,length(time_window));
% for k=time_window
%     idx = RTsorted==k;
%     
%     if k==1 && all(idx==0), % first time point, basically set to 0.5
%         ewma(k) = 0.5;
%     elseif all(idx==0), % if no RT in this time point, keep the same EWMA value
%         ewma(k) = ewma(k-1);
%     else
%         % adjust lambda to weight appropriately when multiple RTs
%         lamb = lambda*sum(idx);
%         ewma(k) = lamb*mean(correct(idx)) + (1-lamb)*ewma(k-1);
%     end
%     
%     %CIs
%     ewma_ci(1,k) = 0.5 + N * 0.5 * sqrt( (lambda/(2-lambda)) * (1-(1-lambda)^(2*k)) );
%     ewma_ci(2,k) = 0.5 - N * 0.5 * sqrt( (lambda/(2-lambda)) * (1-(1-lambda)^(2*k)) );
% end


% Compute MinRT from EWMA
sigtime = ewma > ewma_ci(1,:);
mybin = FirstSelectiveBin(sigtime,5);
if ~isnan(mybin)
    ewma_minRT = round(RTsorted(mybin));
else ewma_minRT = NaN;
end

% organize output
R.ewma       = ewma;
R.ewma_ci    = ewma_ci;
R.ewma_minRT = ewma_minRT;
R.RTsorted   = RTsorted;