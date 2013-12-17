function [R] = makeAccCumulRT(RT,correct,time_window,integTime,doCI)
% Compute the moving accuracy at each time point based on the "cumulated" RTs
% 
% Also check for:
%   - MinRT        | when information starts to be available | 1st significant bin
%
% Example:
% R = makeRTDistrib(RT,correct,time_window,integTime,doboot);
%
% seb.crouzet@gmail.com

%==========================================================================
% Default arguments
if nargin < 3 || isempty(time_window), time_window = [1:800]; end
if nargin < 4 || isempty(integTime),   integTime = 50; end %
if nargin < 5 || isempty(doCI),        doCI = 0; end
%if nargin < 3 || isempty(mycolor),     mycolor = 'k'; end
%if nargin < 4 || isempty(mylinewidth), mylinewidth = [3 1]; end % 1st for correct responses, 2nd for incorrect
%if nargin < 4 || isempty(myxlim),      myxlim = [0 800]; end
%if nargin < 5 || isempty(plotnow),     plotnow = 1; end % no plot if 0, plot if 1
%==========================================================================

nBinSuc = 5;

R.myacc    = nan(length(time_window),1);
R.myacc_ci = nan(length(time_window),2);
time_selec = zeros(1,length(time_window));

for t = time_window
    myvalues = correct(RT>(t-integTime) & RT <=t);
    if numel(myvalues) > 2
        R.myacc(t) = mean(myvalues); 
        if doCI
            R.myacc_ci(t,:) = bootci(100,@mean,myvalues);
        end
    end
    
    % Get minimum RT
    if doCI
        if R.myacc_ci(t,1) > 0.5 % if > to chance level
            R.time_selec(t) = 1;
        end
    end
end

if doCI
    R.MinRT = FirstSelectiveBin(R.time_selec,5);
end

% CODE TO PLOT
%fill([myxlim(1):myxlim(2)-1 fliplr(myxlim(1):myxlim(2)-1)], [R.myacc_ci(:,1)' fliplr(R.myacc_ci(:,2)')],...
%    mycolor, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on
%plot(myxlim(1):myxlim(2)-1, R.myacc, 'Color', mycolor , 'Linewidth', mylinewidth) ; hold on 
end