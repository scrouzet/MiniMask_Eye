function [R] = plotzDistribs(RT, correct, myedges, contrast)
% works only to contrast one factor with 2 modality
%
%

mylinewidth = 2;
mycolors = [ 170 170 128; % beige
    85 170 128; % vert clair
    0  85   0; % vert fonce
    245 163  26; % orange
    170  85 128; % violet
    0  85 255; % bleu electrique
    255  85 128; % rose
    85  85 128; % bleu violace sombre
    0  85 128; % bleu fonce
    73  73  73; % gris sombre
    170   0   0; % rouge sang
    ] / 255;
comcol = mycolors(9,:);
osmcol = mycolors(4,:);
myfontsize = 12;

%--------------------------------------------------------------------------

modalities = unique(contrast);
com = makeDistrib_sacc(RT(contrast==modalities(1)), correct(contrast==modalities(1)), myedges);
osm = makeDistrib_sacc(RT(contrast==modalities(2)), correct(contrast==modalities(2)), myedges);


figure;

subplot(2,2,1); %----- Basic RT distrib -------------------------------
plot(com.bin_centers, com.counts_correct_REL, 'Color', comcol , 'Linewidth', 3) ; hold on
plot(com.bin_centers, com.counts_incorrect_REL, 'Color', comcol, 'Linewidth', 1); hold on
plot(osm.bin_centers, osm.counts_correct_REL, 'Color', osmcol, 'Linewidth', 3); hold on
plot(osm.bin_centers, osm.counts_incorrect_REL, 'Color', osmcol, 'Linewidth', 1); hold on

% display the number of trials
text(0.5,4,[num2str(length(com.RT)) ' COM']);
text(0.5,3.5,[num2str(length(osm.RT)) ' OSM']);

% min RT
myerrorbar = [com.minRT - (myedges(2)-myedges(1))/2  com.minRT + (myedges(2)-myedges(1))/2];
fill([myerrorbar fliplr(myerrorbar)], [0 0 12 12], comcol, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on
text(com.minRT + 0.1, 7.5, [num2str(com.minRT) ' ms'], 'Color', comcol);

myerrorbar = [osm.minRT - (myedges(2)-myedges(1))/2  osm.minRT + (myedges(2)-myedges(1))/2];
fill([myerrorbar fliplr(myerrorbar)], [0 0 12 12], osmcol, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on
text(osm.minRT + 0.1, 7, [num2str(osm.minRT) ' ms'], 'Color', osmcol);

ylim([0 8]);
xlim([-2 2]);
xlabel('Time (ms)','fontSize',myfontsize)
ylabel('Percentage of RT', 'fontSize', myfontsize);
%title(['Subject ' num2str(thissubject)]);
%set(gca, 'YTick', [0:0.1:0.3], 'YTickLabel', [0:0.1:0.3]);
set(gca,'fontSize',myfontsize)%,'box','off')


subplot(2,2,2); %---- EWMA analysis -----------------------------------

[com.ewma, com.ewma_ci, com.ewma_minRT, com.RTsorted] = compute_EWMA(RT(contrast==modalities(1)), correct(contrast==modalities(1)));
[osm.ewma, osm.ewma_ci, osm.ewma_minRT, osm.RTsorted] = compute_EWMA(RT(contrast==modalities(2)), correct(contrast==modalities(2)));

plot(com.RTsorted, com.ewma, 'Color', comcol , 'Linewidth', 2) ; hold on
plot(osm.RTsorted, osm.ewma, 'Color', osmcol, 'Linewidth', 2); hold on
% CI
plot(com.RTsorted, com.ewma_ci(1,:), '--', 'Color', comcol , 'Linewidth', 1) ; hold on
plot(osm.RTsorted, osm.ewma_ci(1,:), '--', 'Color', osmcol , 'Linewidth', 1) ; hold on

% min RT
myerrorbar = [com.ewma_minRT - (myedges(2)-myedges(1))/2  com.ewma_minRT + (myedges(2)-myedges(1))/2];
fill([myerrorbar fliplr(myerrorbar)], [0 0 1 1], comcol, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on
text(com.ewma_minRT + 10, 0.9, [num2str(com.ewma_minRT) ' ms'], 'Color', comcol);

myerrorbar = [osm.ewma_minRT - (myedges(2)-myedges(1))/2  osm.ewma_minRT + (myedges(2)-myedges(1))/2];
fill([myerrorbar fliplr(myerrorbar)], [0 0 1 1], osmcol, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on
text(osm.ewma_minRT + 10, 0.8, [num2str(osm.ewma_minRT) ' ms'], 'Color', osmcol);

ylim([0.4 1]);
xlim([-2 2]);
xlabel('Time (ms)','fontSize',myfontsize)
ylabel('EWMA', 'fontSize', myfontsize);
set(gca,'fontSize',myfontsize)%,'box','off')


subplot(2,2,3); %---- Cumulative RT distrib ---------------------------
plot(com.bin_centers, com.counts_correct_CUM_REL, 'Color', comcol , 'Linewidth', 3) ; hold on
plot(com.bin_centers, com.counts_incorrect_CUM_REL, 'Color', comcol, 'Linewidth', 1); hold on
plot(osm.bin_centers, osm.counts_correct_CUM_REL, 'Color', osmcol, 'Linewidth', 3); hold on
plot(osm.bin_centers, osm.counts_incorrect_CUM_REL, 'Color', osmcol, 'Linewidth', 1); hold on

% min RT
myerrorbar = [com.minRT_CUM - (myedges(2)-myedges(1))/2  com.minRT_CUM + (myedges(2)-myedges(1))/2];
fill([myerrorbar fliplr(myerrorbar)], [0 0 100 100], comcol, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on
text(com.minRT_CUM + 10, 65, [num2str(com.minRT_CUM) ' ms'], 'Color', comcol);

myerrorbar = [osm.minRT_CUM - (myedges(2)-myedges(1))/2  osm.minRT_CUM + (myedges(2)-myedges(1))/2];
fill([myerrorbar fliplr(myerrorbar)], [0 0 100 100], osmcol, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on
text(osm.minRT_CUM + 10, 55, [num2str(osm.minRT_CUM) ' ms'], 'Color', osmcol);

ylim([0 75]);
xlim([-2 2]);
xlabel('Time (ms)','fontSize',myfontsize)
ylabel('Percentage of RT', 'fontSize', myfontsize);
%set(gca, 'YTick', [0:0.1:0.3], 'YTickLabel', [0:0.1:0.3]);
set(gca,'fontSize',myfontsize)%,'box','off')

set(gcf, 'Units', 'centimeters');
pos = get(gcf, 'Position');
pos(3) = 30; % Select the width of the figure in [cm]
pos(4) = 20; % Select the height of the figure in [cm]
set(gcf, 'Position', pos);


