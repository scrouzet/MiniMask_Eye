function [perf, myquant, zRT] = makeVincentizeRT(RT,correct,subjects,grouping_factor,myquantiles,mycolors,mylinewidth,plotnow)
% mycolors shoudl contains as much lines as modalities in grouping_factor
% seb.crouzet@gmail.com

%==========================================================================
% Default arguments
if nargin < 5 || isempty(myquantiles), myquantiles = [0 0.25 0.5 0.75 1]; end % quartiles
if nargin < 6 || isempty(mycolors),    mycolors = [0 0 0;0.2 0.2 0.2;0.4 0.4 0.4]; end
if nargin < 7 || isempty(mylinewidth), mylinewidth = 2; end
if nargin < 8 || isempty(plotnow),     plotnow = 'no'; end
%==========================================================================
list_subjects = unique(subjects);
modalities = unique(grouping_factor); % get the number of modalities of the grouping factor

myquant = nan(1,length(RT));
zRT = nan(1,length(RT));
for s = 1:length(list_subjects)
    thissubject = list_subjects(s);
    
    % assess quantiles values
    qt = quantile(RT(subjects==thissubject), myquantiles);
    
    % loop over quantiles and mark each trial
    for q = 1:length(qt)-1;
        mytrialselec = subjects==thissubject & RT>qt(q) & RT<qt(q+1);
        myquant(mytrialselec) = q;
        
        % analysis per quartile according to the grouping factor
        for mod = 1:length(modalities)
            mytrialselec = subjects==thissubject & RT>qt(q) & RT<qt(q+1) & grouping_factor==modalities(mod);
            perf.acc.mean(q,s,mod) = mean(correct(mytrialselec));
            perf.acc.ci(q,s,mod,:) = bootci(100,@mean,correct(mytrialselec));
            
            perf.meanrt.mean(q,s,mod) = mean(RT(mytrialselec));
            perf.meanrt.ci(q,s,mod,:) = bootci(100,@mean,RT(mytrialselec));
        end
    end
    
    % also do the z-score method
    zRT(subjects==thissubject) = zscore(RT((subjects==thissubject)));
end

% compute group stats
for q =  1:length(qt)-1
    for mod = 1:length(modalities)
        perf.group.acc.mean(q,mod)    = mean(perf.acc.mean(q,:,mod));
        perf.group.acc.ci(q,mod,:)    = bootci(100,@mean,perf.acc.mean(q,:,mod));
        perf.group.meanrt.mean(q,mod) = mean(perf.meanrt.mean(q,:,mod));
        perf.group.meanrt.ci(q,mod,:) = bootci(100,@mean,perf.meanrt.mean(q,:,mod));
    end
end


%--------------------------------------------------------------------------
%PLOT
switch plotnow
    case 'group'
        for mod = 1:length(modalities)
            for q =  1:length(qt)-1
                % x erros bars (mean rt)
                plot([perf.group.meanrt.ci(q,mod,1) perf.group.meanrt.ci(q,mod,2)],[perf.group.acc.mean(q,mod) perf.group.acc.mean(q,mod)], 'Color', mycolors(mod,:), 'LineWidth', 1); hold on
                % y error bars (acc)
                plot([perf.group.meanrt.mean(q,mod) perf.group.meanrt.mean(q,mod)],[perf.group.acc.ci(q,mod,1) perf.group.acc.ci(q,mod,2)], 'Color', mycolors(mod,:), 'LineWidth', 1); hold on
            end
            % mean curve with markers
            plot(perf.group.meanrt.mean(:,mod), perf.group.acc.mean(:,mod), '.-', 'MarkerSize', 16, 'Color', mycolors(mod,:), 'LineWidth', mylinewidth); hold on
        end 
    case 'single'
    case 'no'
end