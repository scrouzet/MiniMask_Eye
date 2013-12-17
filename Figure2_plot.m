outdir = 'figures';

addpath('./Functions/');
mycolors =  [[197,88,65],
    [110,119,180],
    [102,144,60],
    [195,81,178]] /255;
myfontsize = 14;
mygray = [0.7 0.7 0.7];
mymarksize = 6;

load('data.mat');
load('res_R_boot.mat');

listsub = unique(data.subjectname);
listvis = {'commonoffset' 'trailing' 'noise' 'contrast'}; % to reorder them as I want
list_title = {{'Common' 'offset'} {'OSM'} {'Backward' 'noise'} {'Low' 'contrast'}};

figname = 'Figure2';
nbb=200;


%-------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------
%                          AVERAGE ACCURACY, MEDIAN AND MININUM SRT
%-------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------


% -------------------------------------------------------------------------
% ACCURACY 

subplot(3,2,1);

myacc = mean(R.accuracy);
myacc_ci = bootci(nbb,@mean,R.accuracy);

plot([0.5 4.5], [50 50], '--', 'Color', [0.8 0.8 0.8], 'LineWidth', 1); hold on

% single observer
for s = 1:numel(listsub)
    for v = 1:numel(listvis)
        plot([v-0.1 v+0.1], [R.accuracy(s,v) R.accuracy(s,v)],'-','Color',mygray); hold on
        plot(v,R.accuracy(s,v),'o','Color',mygray, 'MarkerFaceColor', 'w','MarkerSize', 4); hold on
    end
end

% average
for v = 1:numel(listvis)
    plot([v v], myacc_ci(:,v),'-','Color',mycolors(v,:), 'LineWidth', 1); hold on
    plot(v,myacc(v),'o','Color',mycolors(v,:), 'MarkerFaceColor', 'w','MarkerSize', mymarksize, 'LineWidth', 2); hold on
end
xlim([0.5 4.5]);
ylim([40 100]);
ylabel('Accuracy (% correct)', 'fontSize', myfontsize-3);
set(gca, 'XTick', [1:4], 'XTickLabel', {});
set(gca, 'YTick', [50:25:100], 'YTickLabel', [50:25:100], 'fontSize', myfontsize-3);
set(gca,'fontSize',myfontsize-3,'box','off');

% -------------------------------------------------------------------------
% MEDIAN REACTION TIMES

subplot(3,2,3);

% PARAM for the Median MinRT Acc plot
myylim = [0 18];
myxlim = [0 400];

% single observer
for s = 1:numel(listsub)
    current_sub = listsub{s};
    for v = 1:numel(listvis)
        plot([v-0.1 v+0.1], [R.medianRT(s,v) R.medianRT(s,v)],'-','Color',mygray); hold on
        plot([v v],[R.medianRT_ci(s,v,1) R.medianRT_ci(s,v,2)],'-','Color',mygray); hold on
    end
    plot(R.medianRT(s,:),'o','Color',mygray, 'MarkerFaceColor', 'w','MarkerSize', 4); hold on
end

% average
mymedian = mean(R.medianRT);
mysem = bootci(nbb,@mean,R.medianRT);
minRT_average = mean(R.minRT);
minRT_CI      = bootci(nbb,@mean,R.minRT);
minRT_virtual_average = mean(nanmean(R.minRT_virtual,3));
minRT_virtual_CI      = bootci(nbb,@mean,nanmean(R.minRT_virtual,3));

% test of minSRT
mytest = minRT_average <  minRT_virtual_CI(1,:);

% PLOT
for v = 1:numel(listvis)
    plot([v v], mysem(:,v),'-','Color',mycolors(v,:), 'LineWidth', 1); hold on
    % average
    plot(v,mymedian(v),'o','Color',mycolors(v,:), 'MarkerFaceColor', 'w','MarkerSize', mymarksize, 'LineWidth', 2); hold on
end
xlim([0.5 4.5]);
ylim([0 250]);
ylabel('Median SRT (ms)', 'fontSize', myfontsize-3);
set(gca, 'XTick', [1:4], 'XTickLabel', {});
set(gca, 'YTick', [0:50:250], 'YTickLabel', 0:50:250);
set(gca,'fontSize',myfontsize-3,'box','off');


% -------------------------------------------------------------------------
% MINIMUM REACTION TIMES

subplot(3,2,5);

% PARAM for the Median MinRT Acc plot
myylim = [0 18];
myxlim = [0 400];

% plot individual results
for s = 1:numel(listsub)
    current_sub = listsub{s};
    for v = 1:numel(listvis)
        plot([v-0.1 v+0.1], [R.minRT(s,v) R.minRT(s,v)],'-','Color',mygray); hold on
        %plot([v v],[R.minRT_ci(s,v,1) R.minRT_ci(s,v,2)],'-','Color',mygray); hold on
    end
    plot(R.minRT(s,:),'o','Color',mygray, 'MarkerFaceColor', 'w','MarkerSize', 4); hold on
end

% average across observers
for v = 1:numel(listvis)
    text(v, -20, list_title{v}, 'Rotation', 45, 'FontWeight', 'demi', 'Color', mycolors(v,:), 'HorizontalAlignment', 'right');

    plot([v v], minRT_CI(:,v),'-','Color',mycolors(v,:), 'LineWidth', 1); hold on
    plot(v,minRT_average(v),'o','Color',mycolors(v,:), 'MarkerFaceColor', 'w','MarkerSize', mymarksize, 'LineWidth', 2); hold on
    
    % virtual MIN SRT
    if v>1
        ms = 0.3;
        fill([v-ms v+ms v+ms v-ms], [minRT_virtual_CI(2,v) minRT_virtual_CI(2,v) minRT_virtual_CI(1,v) minRT_virtual_CI(1,v)],...
            mygray, 'EdgeColor', 'none', 'FaceAlpha', 0.4); hold on;
    end    
end
xlim([0.5 4.5]);
ylim([0 250]);
ylabel('Minimum SRT (ms)', 'fontSize', myfontsize-3);
set(gca, 'XTick', [1:4], 'XTickLabel', {});
set(gca, 'YTick', [0:50:250], 'YTickLabel', 0:50:250);
set(gca,'fontSize',myfontsize-3,'box','off');





%-------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------
%                                      ACCURACY OVER TIME
%-------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------
myfontsize = 14;
mygray = [0.3 0.3 0.3];

load('res_Rall_boot.mat');
listvis = {'commonoffset' 'trailing' 'noise' 'contrast'}; % to reorder them as I want

% PARAM for the accuracy over time plots
time_window = 1:600;
myylim = [0.5 0.9];
myxlim = [0 400];
startingpoint = 112;
endingpoint = 400;

sublist = [3 6 9];
list_title = {'OSM' 'Backward noise' 'Low contrast'};
for v = 2:numel(listvis)    
    current_vis = listvis{v};
    
    subplot(3,2,v + (v-2));
    
    % Plot common offset
    %-------------------

    % fill() does not like NaN so we need to remove them
    toplot = find(all(~isnan((Rall.commonoffset.myacc_ci'))));
    debut = max([startingpoint min(toplot)]);
    fin = min([endingpoint max(toplot)]);
    
    % plot
    plof(v) = fill([time_window(debut:fin) fliplr(time_window(debut:fin)) ],...
        [Rall.commonoffset.myacc_ci(debut:fin,1)' fliplr(Rall.commonoffset.myacc_ci(debut:fin,2)')],...
        mycolors(1,:), 'EdgeColor', 'none', 'FaceAlpha', 0.2); hold on;
    plo(v) = plot(time_window(debut:fin), Rall.commonoffset.myacc(debut:fin), 'Color', mycolors(1,:) , 'Linewidth', 1) ; hold on
    
    
    if v>1
        
        % Plot reduced visibility condition
        %----------------------------------
        
        % fill() does not like NaN so we need to remove them
        toplot = find(all(~isnan((Rall.(current_vis).myacc_ci'))));
        debut = max([startingpoint min(toplot)]);
        fin = min([endingpoint max(toplot)]);
        
        % plot
        plof(v) = fill([time_window(debut:fin) fliplr(time_window(debut:fin)) ],...
            [Rall.(current_vis).myacc_ci(debut:fin,1)' fliplr(Rall.(current_vis).myacc_ci(debut:fin,2)')],...
            mycolors(v,:), 'EdgeColor', 'none', 'FaceAlpha', 0.2); hold on;
        plo(v) = plot(time_window(debut:fin), Rall.(current_vis).myacc(debut:fin), 'Color', mycolors(v,:) , 'Linewidth', 1) ; hold on
        
        % Plot shadow of common offset
        %-----------------------------
        
        % fill() does not like NaN so we need to remove them
        toplot = find(~isnan(mean(Rall.(current_vis).acc_shadow,2)));
        debut = max([startingpoint min(toplot)]);
        fin = min([endingpoint max(toplot)]);
        
        % compute the CI of the shadow
        shci = getCIfromboot(Rall.trailing.acc_shadow(min(toplot):max(toplot),:)', .05);
        allshci = nan(size(Rall.(current_vis).myacc_ci));
        allshci(toplot,:) = shci'; 
        
        % plot
        plo(v) = plot(time_window(debut:fin), mean(allshci(debut:fin,:),2), 'Color', mygray , 'Linewidth', 1) ; hold on
        plof(v) = fill([time_window(debut:fin) fliplr(time_window(debut:fin)) ],...
            [allshci(debut:fin,1)' fliplr(allshci(debut:fin,2)')],...
            mygray, 'EdgeColor', 'none', 'FaceAlpha', 0.2); hold on;
        
        
        % Plot the stat
        %-------------------------------
        
        testsig = Rall.(current_vis).myacc_ci(:,1) > allshci(:,2);
        % make a cluster correction (requires 5 adjacent sig values)
        n=5;
        testsig = conv(double(testsig),ones(n,1),'same') == n;
        
        % correct if it's before minRT (it does not make sense and is an artifact of the bootstrap method)
        testsig(1:Rall.(current_vis).MinRT) = 0;
        
        if any(testsig)
            plot([find(testsig,1,'first') find(testsig,1,'last')], [0.86 0.86], 'k', 'LineWidth', 2);
            [find(testsig,1,'first') find(testsig,1,'last')]
        end
        
    end
    
    text(max(time_window(debut:fin))-3, allshci(fin,2)+0.04, list_title{v-1}, 'Color', mycolors(v,:), 'HorizontalAlignment','right');
    text(max(time_window(debut:fin))-3, allshci(fin,1)-0.04, 'Surrogate', 'Color', mygray, 'HorizontalAlignment','right');
    
    ylim(myylim);
    xlim(myxlim);
    if v==4
        xlabel('Time (ms)', 'fontSize', myfontsize-3);
        ylabel('Accuracy (% correct)', 'fontSize', myfontsize-3);
    end
    set(gca, 'YTick', [0.5:0.1:0.9], 'YTickLabel', [50:10:90]);
    set(gca, 'XTick', [0:100:500], 'XTickLabel', [0:100:500]);
    box off
end

set(gcf, 'Color', 'w', 'Position', [10 800 400 600]);
%plot2svg(fullfile(outdir,[figname '.svg']));