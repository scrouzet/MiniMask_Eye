function [] = makeEyeTrace(saccades,correct,sac_dir,times)
% seb.crouzet@gmail.com

%==========================================================================
% Default arguments
%if nargin < 3 || isempty(mycolor),     mycolor = 'k'; end
%if nargin < 4 || isempty(mylinewidth), mylinewidth = [3 1]; end % 1st for correct responses, 2nd for incorrect
%if nargin < 5 || isempty(myylim),      myylim = [0 5]; end
%if nargin < 6 || isempty(cumul),       cumul = 0; end % if TRUE, plot the cumulative distribution
%if nargin < 7 || isempty(plotnow),     plotnow = 1; end % no plot if 0, plot if 1
%if nargin < 8 || isempty(bincenters),  bincenters = 0:10:1000; end
%==========================================================================

% shape eye traces to be analyzed
% rather than left/right, organize them with up=target, down=distra
saccade_aligned(correct == 1 & sac_dir ==1,:) = saccades(correct == 1 & sac_dir ==1,:); % correct left kept
saccade_aligned(correct == 1 & sac_dir ==2,:) = -saccades(correct == 1 & sac_dir ==2,:); % correct rigt mirrored
saccade_aligned(correct == 0 & sac_dir ==1,:) = -saccades(correct == 0 & sac_dir ==1,:); % incorrect left mirrored
saccade_aligned(correct == 0 & sac_dir ==2,:) = saccades(correct == 0 & sac_dir ==2,:); % incorrect rigt kept

% alpha = 0.01;

% take all before 0 (image onset) as a baseline, and compute its 95% CI
baseline      = saccade_aligned(:,1:find(times==0));
baseline      = baseline(:);
baseline_ci95 = quantile(baseline,[0.005 0.995]);

tsig = zeros(1,length(times));
for t=1:size(saccade_aligned,2)
    eyedata(t,:)    = saccade_aligned(correct==1,t); % takes only correct trials
    eyedata_ci(t,:) = bootci(100,@mean,eyedata(t,:)); % [0.025 0.975]
    
    % assess latency
    if eyedata_ci(t,1) > baseline_ci95(2)
        tsig(t) = 1;
    end
end
eyelat = times(FirstSelectiveBin(tsig,20));

% PLOT
% baseline
plot(times,repmat(baseline_ci95(1),1,length(times)), '--', 'Color', 'k', 'LineWidth', 1); hold on
plot(times,repmat(baseline_ci95(2),1,length(times)), '--', 'Color', 'k', 'LineWidth', 1); hold on

% eye trace envelope and mean
fill([times fliplr(times)], [eyedata_ci(:,2)' fliplr(eyedata_ci(:,1)')], 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on
plot(times, mean(eyedata,2), 'Color', 'k', 'LineWidth', 2); hold on

% MinRT
a=axis;
plot([eyelat eyelat], [a(3) a(4)], 'Color', 'k' , 'Linewidth', 1); hold on
% display text with a 10% decalage (on y and x axes)
text(eyelat + eyelat*0.1, a(4) - a(4)*0.1, [num2str(round(eyelat)) ' ms'], 'Color', 'k'); hold on