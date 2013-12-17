addpath('./Functions/');

% Define colors
mycolors =  [[197,88,65],
    [110,119,180],
    [102,144,60],
    [195,81,178]] /255;
myfontsize = 14;
mygray = [0.7 0.7 0.7];
mymarksize = 6;

% Load
load('./data.mat');
listsub = unique(data.subjectname);
listvis = {'commonoffset' 'trailing' 'noise' 'contrast'}; % to reorder them as I want
list_title = {'Common offset' 'OSM' 'Backward noise' 'Low contrast'};

% -------------------------------------------------------------------------
% Contrast tested function of RT bin - for each observer and each condition
% -------------------------------------------------------------------------
figure;
figname = 'FigS1_Contrast-SRT_obscond';

k=1;
for v = 1:numel(listvis)
    for s = 1:4
        subplot(4,4,k);
        plot(data.RT(strcmp(data.subjectname,listsub{s}) & strcmp(data.Visibility,listvis{v})),...
            data.StimulusRGB(strcmp(data.subjectname,listsub{s}) & strcmp(data.Visibility,listvis{v})),'o', 'Color', mycolors(v,:));
        
        xlim([0 400]);
        ylim([120 260]);
        set(gca, 'XTick', [0:100:400], 'XTickLabel', [0:100:400]);
        box off
        if v==4, xlabel({'Saccadic Reaction Times (SRT)'}); end
        if v==1, title(['Observer ' num2str(s)]); end
        if s==1, ylabel({list_title{v} 'Contrast tested (RGB value)'}); end
        
        % regression
        [b,dev,stats] = glmfit(data.StimulusRGB(strcmp(data.subjectname,listsub{s}) & strcmp(data.Visibility,listvis{v})),...
            data.RT(strcmp(data.subjectname,listsub{s}) & strcmp(data.Visibility,listvis{v})),...
            'gamma', 'link', 'reciprocal');
        res.beta(v,s)   = stats.beta(2);
        res.se(v,s)     = stats.se(2);
        res.p(v,s)      = stats.p(2);
        
        if res.p(v,s) < 0.05
            text(10, 136, sprintf('b = %f', res.beta(v,s)), 'Color', [0.8 0.2 0.2]);
        else text(10, 136, sprintf('b = %f', res.beta(v,s)));
        end
        
        k=k+1;
    end
end
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [2.5 2.5 12 12]);
print(gcf, [figname '.eps'],'-depsc');



% -------------------------------------------------------------------------
% SRT Distribs for each observer and each condition
% -------------------------------------------------------------------------
figure;
figname = 'FigS2_SRTdistribs_obscond';

time_window = 0:10:400;
k=1;
for v = 1:numel(listvis)
    for s = 1:4
        subplot(4,4,k);
        
        ind = strcmp(data.subjectname,listsub{s}) & strcmp(data.Visibility,listvis{v});
        R = makeRTDistrib(data.RT(ind), data.correct(ind), time_window, 1, [], 500);
        
        plot(time_window, R.counts_correct_REL,'-', 'Color', mycolors(v,:), 'LineWidth', 2); hold on
        plot(time_window, R.counts_incorrect_REL,'-', 'Color', mycolors(v,:), 'LineWidth', 1); hold on
        
        xlim([0 400]);
        ylim([0 100]);
        set(gca, 'XTick', [0:100:400], 'XTickLabel', [0:100:400]);
        box off
        
        if v==4, xlabel({'Saccadic Reaction Times (SRT)'}); end
        if v==1, title(['Observer ' num2str(s)]); end
        if s==1, ylabel({list_title{v} 'Proportion of saccades (%)'}); end
        
        k=k+1;
    end
end
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [2.5 2.5 12 12]);
print(gcf, [figname '.eps'],'-depsc');