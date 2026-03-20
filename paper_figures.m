%% ========================================================================

% Name:			paper_figures.m

% Author:		Kate Dembny
% Date:			1/20/23
% Updated:		6/16/23

% Syntax:		
% Arguments:	

% Description:	figures for paper
% Requirements: matlab
% Notes:    

%% ========================================================================

clearvars

% DIRECTORIES 

scr_dir = pwd;
pdir = fileparts(cd);
data_dir = [pdir filesep() 'data'];
fig_dir = [pdir filesep() 'figures'];

addpath("/home/kdembny/MATLAB/toolboxes/violinplot/Violinplot-Matlab-master")
addpath("/home/kdembny/MATLAB/toolboxes/sigstar")
addpath('/home/kdembny/MATLAB/toolboxes/cprintf/cprintf/')

%% ========================================================================

% Figure 1 - appearance of data 
cwd = [data_dir filesep() 'nodes' filesep() '10' filesep() '004' ];

load([cwd filesep() 'orig' filesep() 'orig_data.mat'])

% establish figure
f = figure;
f.Position = [100 100 1200 700];
set(gcf,'renderer','Painters')

% third tile - adjacency matrix - 1/0 connection
subplot(2,3,1)
imagesc(tcoup)
colormap(flipud(bone))
xlabel("Reciever Node")
ylabel("Source Node")
title('True Network Connections')
yticks(1:10)
yticklabels(1:10)
xticks(1:10)
xticklabels(1:10)
text(-1.2,0, ['A)'], 'FontSize', 20)

% second tile - adjacency matrix - node to node
subplot(2,3,4)
dg = digraph(tcoup);
plot(dg, 'Layout', 'force', 'EdgeColor', "k", 'NodeColor', 'k')
ax = gca;
ax.FontSize=16;
text(-3.5,3, ['B)'], 'FontSize', 20)

% first set of tiles - timeseries data
subplot(2,3,[2:3, 5:6])
hold on
for i = 1:size(ts, 1)
    plot(ts(i,1:1000) - 0.25*i, 'Color', "k")
end
ax = gca;
ax.FontSize=16;

ylim([-0.25*(i+1),0])
yticks(-0.25*(i):0.25:-0.25)
yticklabels(size(ts,1):-1:1)
ylabel('Node Number')
xlabel('Time (samples)')
ax = gca;
ax.FontSize=16;
text(-70,.07, ['C)'], 'FontSize', 20)

saveas(gcf, [fig_dir filesep() '01_methods.jpg'])
exportgraphics(gcf, [fig_dir filesep() '01_methods.eps'], 'ContentType', 'vector')

%% ========================================================================

% Figure 2 - Coupled vs uncoupled channels

% assign colors
colors = [136 34 85; 102 17 0; 17 119 51; 68 170 153; 102 153 204; 51 34 136; 204 102 119; 170 68 153; 153 153 51; 148 148 148]/255;

% establish figure
f = figure;
f.Position = [100 100 1600 1000];
set(gcf,'renderer','Painters')

lw = 2;
nd_end = 100;

subplot(211)
hold on
plot(ts(1,1:nd_end), 'LineWidth', lw, 'Color', [colors(3,:)])
plot(ts(6,1:nd_end), 'LineWidth', lw, 'Color', [colors(7,:)])
legend(["Node 1", "Node 6"])
xlabel('Time (samples)')
ylabel('Amplitude (AU)')
ylim([-0.12, 0.12])
title('Coupled Nodes')
ax = gca;
ax.FontSize=16;

subplot(212)
hold on
plot(ts(1,1:nd_end), 'Linewidth',lw, 'Color', [colors(3,:)])
plot(ts(7,1:nd_end), 'Linewidth',lw, 'Color', [colors(5,:)])
legend(["Node 1", "Node 7"])
xlabel('Time (samples)')
ylim([-0.12, 0.12])
ylabel('Amplitude (AU)')
title('Uncoupled Nodes')
ax = gca;
ax.FontSize=16;

saveas(gcf, [fig_dir filesep() '02.coupled_noncoupled.jpg'])
exportgraphics(gcf, [fig_dir filesep() '02.coupled_noncoupled.eps'], 'ContentType', 'vector')

%% ========================================================================

% Figure 3 - Network Reconstructions

% load data
pt_file = [data_dir filesep() 'nodes' filesep() '10' filesep() '004'];
load([pt_file filesep() 'orig' filesep() 'orig_data.mat'])
load([pt_file filesep() 'ml_fc' filesep() 'xc_biv.mat'])
load([pt_file filesep() 'ml_fc' filesep() 'xc_pt.mat'])
load([pt_file filesep() 'ml_fc' filesep() 'gc.mat'])
load([pt_file filesep() 'bvte' filesep() 'te_bivar.mat'])
load([pt_file filesep() 'mvte' filesep() 'te_multivar.mat'])
load([pt_file filesep() 'mi_lagged' filesep() 'mi_lagged.mat'])
load([pt_file filesep() 'mi_zerolag' filesep() 'mi_zerolag.mat'])
load([pt_file filesep() 'ml_fc' filesep() 'xc_zerolag_biv.mat'])
load([pt_file filesep() 'ml_fc' filesep() 'xc_zerolag_pt.mat'])
calc_mi = calc_mi_lag;
load([pt_file filesep() 'shuff' filesep() 'shuff.mat'])

% plot 
labs = {{"True Network Connections"},{"Biv. Cross-Corr"}, {"Pt. Cross-Corr"}, {"Mv. Granger Causality"}, ...
        {"Mutual Information"}, {"Biv. Transfer Entropy"},{"Mv. Transfer Entropy"},...
        {"Zero-Lag Biv.","Cross-Corr"}, {"Zero-Lag Pt.","Cross-Corr"}, {"Zero-Lag Mutual","Information"}, {"Shuffled"}};

arrs = zeros(size(labs,2), size(gc,1), size(gc,2));
arrs(1,:,:) = tcoup;

arrs(8,:,:) = xc_zerolag_biv;
arrs(9,:,:) = xc_zerolag_partial;

arrs(10,:,:) = calc_mi_zerolag;
arrs(6,:,:) = te_bivar;

arrs(2,:,:) = xc_biv(:,:,1);
arrs(3,:,:) = xc_partial(:,:,1);
arrs(4,:,:) = gc;
arrs(5,:,:) = calc_mi;

arrs(7,:,:) = te_multivar;
arrs(11,:,:) = shuff;

num_cols = round((size(arrs,1))/2) + 1;
figLabs = 'A':'K';

f = figure;
clf
f.Position = [100 100 2000 500];
set(gcf,'renderer','Painters')

subplot(2,num_cols,[1,2,num_cols + 1,num_cols + 2])
imagesc(squeeze(arrs(1,:,:)))
title(labs{1})
axis square
ylabel("Source Node")
xlabel("Receiver Node")
c = colorbar();
c.Ticks = [0, 1];
c.TickLabels = ["2%", "98%"];

text(-1,.7,[figLabs(1) ')'], 'FontSize', 20)

for i = 2:size(arrs,1)

    if i < num_cols
        loc = i+1;
    else
        loc = i+3;
    end

    subplot(2,num_cols,loc)
    imagesc(squeeze(arrs(i,:,:)))
    title(labs{i})
    axis square

    pct2 = prctile(arrs(i,:,:), 2, 'all');
    pct98 = prctile(arrs(i,:,:), 98, 'all');
    %if i<11
        clim([pct2 pct98])
    %else
        %clim([0 1])
    %end

    if i == 2 || i == 7
        ylabel("Source Node")
    end
    if i >= 7
        xlabel("Receiver Node")
    end

    text(-2.2,0.7,[figLabs(i) ')'], 'FontSize', 20)

end

saveas(gcf, [fig_dir filesep() '03.samp_recons.jpg'])
exportgraphics(gcf, [fig_dir filesep() '03.samp_recons.eps'], 'ContentType', 'vector')

%% ========================================================================

% Figure 4 - number of nodes by metric

cwd = [data_dir filesep 'agg'];
load([cwd filesep 'nodes_all_dist.mat'])
nodes_alpha = 0.05/15;

makeFig_byMetric(nodes_cos_dist, nodes_opts, nodes_alpha, 'Number of Nodes', 'Cosine Distance')
saveas(gcf, [fig_dir filesep() '04.1_nodes_by_metrics.jpg'])
exportgraphics(gcf, [fig_dir filesep() '04.1_nodes_by_metrics.eps'], 'ContentType', 'vector')
%
% Alt Figure 4 - number of nodes by bin of nodes
makeFig_byParam(nodes_cos_dist, nodes_opts, nodes_alpha, '', 'Cosine Distance', 'Nodes')
saveas(gcf, [fig_dir filesep() '04.2_methods_by_nodes.jpg'])
exportgraphics(gcf, [fig_dir filesep() '04.2_methods_by_nodes.eps'], 'ContentType', 'vector')

%% STATS

clc
cprintf('red', 'Nodes by Cosine Distance \n')
doStats(nodes_cos_dist, nodes_opts, nodes_alpha, 'Nodes')

%% ROC 

cwd = [data_dir filesep 'roc'];
load([cwd filesep 'nodes_roc.mat'])
nodes_alpha = 0.05/15;

% ROC Figure 4 - number of nodes by metric
makeFig_byMetric(nodes_roc_aucs, nodes_opts, nodes_alpha, 'Number of Nodes', 'AUC of ROC')
saveas(gcf, [fig_dir filesep '04.3_nodes_roc_by_metrics.jpg'])
exportgraphics(gcf, [fig_dir filesep '04.3_nodes_roc_by_metrics.eps'], 'ContentType', 'vector')

clc
cprintf('red', 'Nodes ROCs by Cosine Distance \n')
doStats(nodes_roc_aucs, nodes_opts, nodes_alpha, 'Nodes')

%% ========================================================================

% Figure 5 - number of time points by metric

cwd = [data_dir filesep() 'agg'];
load([cwd filesep() 'tps_all_dist.mat'])
tps_alpha = 0.05/14;

makeFig_byMetric(tps_cos_dist,tps_opts, tps_alpha, 'Number of Time Points', 'Cosine Distance')
saveas(gcf, [fig_dir filesep() '05.1_tps_by_methods.jpg'])
exportgraphics(gcf, [fig_dir filesep() '05.1_tps_by_methods.eps'], 'ContentType', 'vector')

% Alt Figure 5 - number of time points by time points bin
makeFig_byParam(tps_cos_dist, tps_opts, tps_alpha, '', 'Cosine Distance', 'Time Points')
saveas(gcf, [fig_dir filesep() '05.2_methods_by_tps.jpg'])
exportgraphics(gcf, [fig_dir filesep() '05.2_methods_by_tps.eps'], 'ContentType', 'vector')

%% STATS

clc
cprintf('red', 'Time Points by Cosine Distance \n')
doStats(tps_cos_dist, tps_opts, tps_alpha, 'Time Points')

%% ROC

cwd = [data_dir filesep 'roc'];
load([cwd filesep 'tps_roc.mat'])
tps_alpha = 0.05/14;

makeFig_byMetric(tps_roc_aucs,tps_opts, tps_alpha, 'Number of Time Points', 'AUC of ROC')
saveas(gcf, [fig_dir filesep '05.3_tps_roc_by_metrics.jpg'])
exportgraphics(gcf, [fig_dir filesep '05.3_tps_roc_by_metrics.eps'], 'ContentType', 'vector')

% stats
clc
cprintf('red', 'Time Points by Cosine Distance \n')
doStats(tps_roc_aucs, tps_opts, tps_alpha, 'Time Points')

%% ========================================================================

% Figure 6 - noise by metric

cwd = [data_dir filesep 'agg'];
load([cwd filesep 'noise_all_dist.mat'])
noise_alpha = 0.05/18;

makeFig_byMetric(noise_cos_dist,noise_opts, noise_alpha, 'SNR', 'Cosine Distance')
saveas(gcf, [fig_dir filesep() '06.1_noise_by_methods.jpg'])
exportgraphics(gcf, [fig_dir filesep() '06.1_noise_by_methods.eps'], 'ContentType', 'vector')

% Alt Figure 6 - noise by SNR bin
makeFig_byParam(noise_cos_dist, noise_opts, noise_alpha, '', 'Cosine Distance', 'SNR')
saveas(gcf, [fig_dir filesep() '06.2_methods_by_noise.jpg'])
exportgraphics(gcf, [fig_dir filesep() '06.2_methods_by_noise.eps'], 'ContentType', 'vector')

%% STATS

clc
cprintf('red', 'Noise by Cosine Distance \n')
doStats(noise_cos_dist, noise_opts, noise_alpha, 'SNR')

%% ROC

cwd = [data_dir filesep 'roc'];
load([cwd filesep 'noise_roc.mat'])
noise_alpha = 0.05/18;

makeFig_byMetric(noise_roc_aucs,noise_opts, noise_alpha, 'SNR', 'AUC of ROC')
saveas(gcf, [fig_dir filesep '06.3_noise_roc_by_metrics.jpg'])
exportgraphics(gcf, [fig_dir filesep() '06.3_noise_roc_by_metrics.eps'], 'ContentType', 'vector')

%% stats
clc
cprintf('red', 'Noise by Cosine Distance \n')
doStats(noise_roc_aucs, noise_opts, noise_alpha, 'SNR')

%% ========================================================================

% Figure 9 - probability of communication by metric

cwd = [data_dir filesep() 'agg'];
load([cwd filesep() 'pcomm_all_dist.mat'])
pcomm_alpha = 0.05/15;

makeFig_byMetric(pcomm_cos_dist,pcomm_opts, pcomm_alpha, 'SNR', 'Cosine Distance')
saveas(gcf, [fig_dir filesep() '09.1_pcomm_by_methods.jpg'])
exportgraphics(gcf, [fig_dir filesep() '09.1_pcomm_by_methods.eps'], 'ContentType', 'vector')

% Alt Figure 6 - communucation probability by comm prob
makeFig_byParam(pcomm_cos_dist, pcomm_opts, pcomm_alpha, 'Metrics', 'Cosine Distance', 'SNR')
saveas(gcf, [fig_dir filesep() '09.2_methods_by_noise.jpg'])
exportgraphics(gcf, [fig_dir filesep() '09.2_methods_by_noise.eps'], 'ContentType', 'vector')

%% STATS

clc
cprintf('red', 'Noise by Cosine Distance \n')
doStats(pcomm_cos_dist, pcomm_opts, pcomm_alpha, 'SNR')

%% ========================================================================

% Figure 7 - nodes node dropping 

cwd = [data_dir filesep() 'agg'];

load([cwd filesep() 'nodes_all_dist.mat'])
ntwkCov_alpha = 0.05/20;

pcts = ["100%","90%","80%","70%","60%","50%","40%","30%","20%","10%"];
makeFig_nodeDrop(nodes_cos_dist, pcts, ntwkCov_alpha, '% of Network Covered', 'Cosine Distance')
saveas(gcf, [fig_dir filesep() '07.1_node_dropping.jpg'])
exportgraphics(gcf, [fig_dir filesep() '07.1_node_dropping.eps'], 'ContentType', 'vector')

pcts = ["100%","90%","80%","70%","60%","50%","40%","30%","20%","10%"];
makeFig_nodeDrop_param(nodes_cos_dist, pcts, ntwkCov_alpha, '', 'Cosine Distance')
saveas(gcf, [fig_dir filesep() '07.2_node_dropping_params.jpg'])
exportgraphics(gcf, [fig_dir filesep() '07.2_node_dropping_params.eps'], 'ContentType', 'vector')

%%
cwd = [data_dir filesep() 'roc'];
load([cwd filesep() 'nodes_roc.mat'])

makeFig_nodeDrop(nodes_roc_aucs(:,:,1:9,:), pcts(1:9), ntwkCov_alpha, '% of Network Covered', 'AUC of ROC')
saveas(gcf, [fig_dir filesep() '07.2_roc_node_dropping.jpg'])
exportgraphics(gcf, [fig_dir filesep() '07.2_roc_node_dropping.eps'], 'ContentType', 'vector')

%% compare methods within metric
for i = 1:10
    [p, tbl, stats] = kruskalwallis(squeeze(nodes_cos_dist(4,:,:,i))); %, pcts);
    disp(labels(i))

    if p < ntwkCov_alpha
        results = multcompare(stats);
        tbl2 = array2table(results,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
        close all 
        disp(tbl2)
    else
        disp('no significant differences')
    end
    disp(' ')
end

%% compare methods by percent of nodes dropped
for i = 1:10
    [p, tbl, stats] = kruskalwallis(squeeze(nodes_cos_dist(4,:,i,:))); %, pcts);
    disp([num2str(100 - (i-1)*10) ' pct covered'])

    if p < ntwkCov_alpha
        results = multcompare(stats, 'CriticalValueType', 'dunn-sidak', 'Alpha', ntwkCov_alpha);
        tbl2 = array2table(results,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
        close all 
        disp(tbl2)
    else
        disp('no significant differences')
    end
    disp(' ')
end

%% compare for roc - by metric
for i = 1:10
    [p, tbl, stats] = kruskalwallis(squeeze(nodes_roc_aucs(4,:,:,i))); %, pcts);
    disp(labels(i))
    %disp([num2str(100 - (i-1)*10) ' pct covered'])

    if p < ntwkCov_alpha
        results = multcompare(stats);
        tbl2 = array2table(results,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
        close all 
        disp(tbl2)
    else
        disp('no significant differences')
    end
    disp(' ')
end

%% compare for roc - by percent covered
for i = 1:10
    [p, tbl, stats] = kruskalwallis(squeeze(nodes_roc_aucs(4,:,i,:))); %, pcts);
    disp([num2str(100 - (i-1)*10) ' pct covered'])

    if p < ntwkCov_alpha
        results = multcompare(stats);
        tbl2 = array2table(results,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
        close all 
        disp(tbl2)
    else
        disp('no significant differences')
    end
    disp(' ')
end

%% compare methods by node dropping - variance

for i = 1:10
    [p, stats] = vartestn(squeeze(nodes_cos_dist(4,:,:,i)), 'TestType', 'LeveneQuadratic'); %, pcts);
    close all 
    disp(labels(i))
    disp(p)
    disp(stats)
    disp(' ')
end

%% ========================================================================

% Figure 8 - runtimes

cwd = [data_dir filesep() 'agg'];
load([cwd filesep() 'nodes_all_rts.mat'])
labels = ["Biv. Cross-Corr", "Pt. Cross-Corr", "Mv. Granger Causality", "Mutual Information",...
    "Biv. Transfer Entropy", "Mv. Transfer Entropy", "Zero-Lag Biv. Cross-Corr", ...
    "Zero-Lag Pt. Cross-Corr", "Zero-Lag Mutual Information" ];

colors = [136 34 85; 102 17 0; 17 119 51; 68 170 153; 102 153 204; 51 34 136; 204 102 119; 170 68 153; 153 153 51; 148 148 148]/255;

f = figure;
f.Position = [100 100 1500 400];

for j = 1:size(nodes_opts,2) 
    subplot(1,5,j)
    for i = 1:6%size(nodes_runtimes,4)
        vp = Violin({squeeze(nodes_runtimes(j,:,1,i))'}, i, 'MarkerSize', 10, 'ViolinColor', {colors(i,:)});
    end

    xticks(1:6)%size(nodes_runtimes,4))
    xticklabels(labels (1:6))
    if j == 1
        ylabel('Runtime (s)')
    end
    %xlabel('Metrics')
    title([num2str(nodes_opts(j)) ' Nodes'])
    ax = gca;
    ax.FontSize=12;
    set(gca, 'Yscale', 'log')
    ylim([10^0, 10^6])
    text(-2.3,10^6.5,[figLabs(j) ')'], 'FontSize', 20)
end

saveas(gcf, [fig_dir filesep() '08.1_runtimes.jpg'])
exportgraphics(gcf, [fig_dir filesep() '08.1_runtimes.eps'], 'ContentType', 'vector')

%% ========================================================================

% Figure 8 - runtimes - no TE

cwd = [data_dir filesep() 'agg'];
load([cwd filesep() 'nodes_all_rts.mat'])

f = figure;
f.Position = [100 100 2000 400];

for j = 2:size(nodes_opts,2)
    subplot(1,5,j)
    for i = 1:4
        vp = Violin({squeeze(nodes_runtimes(j,:,2,i))'}, i, 'MarkerSize', 10, 'ViolinColor', {colors(i,:)});
    end

    xlabel('Method')
    xticks(1:6)
    xticklabels(labels)
    ylabel('Runtime (s)')
    title([num2str(nodes_opts(j)) ' Nodes'])
    ax = gca;
    ax.FontSize=20;
end

sgtitle('Reconstruction Time by Method')
saveas(gcf, [fig_dir filesep() '08.2_runtimes_noTE.jpg'])


%% ========================================================================

% Figure 6 - runtimes

cwd = [data_dir filesep() 'agg'];
load([cwd filesep() 'tps_all_rts.mat'])


f = figure;
f.Position = [100 100 2000 400];

for j = 1:size(tps_opts,2)
    subplot(1,5,j)
    for i = 1:6
        vp = Violin({squeeze(tps_runtimes(j,:,1,i))'}, i, 'MarkerSize', 10);
    end

    xlabel('Method')
    xticks(1:6)
    xticklabels(labels)
    ylabel('Runtime (s)')
    title([num2str(tps_opts(j)) ' Time Points'])
    ax = gca;
    ax.FontSize=14;
end

%sgtitle('Reconstruction Time by Method')
saveas(gcf, [fig_dir filesep() '08.1_runtimes.jpg'])

%% ========================================================================

% FUNCTIONS

function makeFig_byMetric(data,opts, alpha, xAxLabel, yAxLabel)
    
    labels = {{"Biv. Cross-Corr"}, {"Pt. Cross-Corr"}, {"Mv. Granger","Causality"},  {"Mutual","Information"},...
        {"Biv. Transfer","Entropy"}, {"Mv. Transfer","Entropy"}, {"Zero-Lag Biv.","Cross-Corr"}, ...
        {"Zero-Lag Pt.","Cross-Corr"}, {"Zero-Lag Mutual","Information"}, {"Shuffled"}};
    
    colors = [136 34 85; 102 17 0; 17 119 51; 68 170 153; 102 153 204; 51 34 136; 204 102 119; 170 68 153; 153 153 51; 148 148 148]/255;
    
    set(gcf,'renderer','Painters')
    f = figure(1);
    clf
    f.Position = [10 10 1800 650];

    figLabs = 'A':'J';
    
    for i = 1:size(data,4)
    
        [~, ~, stats] = kruskalwallis(squeeze(data(:,:,1,i))', opts);
        results = multcompare(stats, 'CriticalValueType', 'dunn-sidak', 'Alpha', alpha);
        tbl2 = array2table(results,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
        disp(tbl2)
    
        figure(1)
        for j = 1:size(opts,2)
            if all(isnan(squeeze(data(j,:,1,i)))) % edit 6/16/25 KED 
                continue
            end
            subplot(2,5,i)
            vp = Violin({round(squeeze(data(j,:,1,i)),4)'}, j, 'MarkerSize', 10, 'ViolinColor', {colors(i,:)});  
        end
        
        grps = [];
        ps = [];
        for ct_p = 1:size(tbl2,1)
            if tbl2.("P-value")(ct_p) < alpha
                grps = [grps; {[tbl2.("Group A")(ct_p), tbl2.("Group B")(ct_p)]}];
                ps = [ps; tbl2.("P-value")(ct_p)];
            end
        end
    
        mxCompars = size(data,1) * (size(data,1)-1)/2;
        if size(grps,1) == mxCompars
            %text(0.2, 1.15, '*all comparisons significant')
        elseif size(grps,1) == 0
            text(0.2, 0.1, '*no comparisons significant')
        end
    
        if i > 5
            xlabel(xAxLabel)
        end
        xticks(1:size(opts,2))
        xticklabels(opts)
        if mod(i-1,5) == 0 
            ylabel(yAxLabel)
        end
    
        title(labels{i})
        ylim([0, 1.2])
        text(-1,1.3,[figLabs(i) ')'], 'FontSize', 20)
        ax = gca;
        ax.FontSize=14;
    end
end

function makeFig_byParam(data, opts, alpha, xAxLabel, yAxLabel, paramName)

    labels = ["Biv. Cross-Corr", "Pt. Cross-Corr", "Mv. Granger Causality", "Mutual Information", ...
        "Biv. Transfer Entropy", "Mv. Transfer Entropy", "Zero-Lag Biv. Cross-Corr", ...
        "Zero-Lag Pt. Cross-Corr", "Zero-Lag Mutual Information", "Shuffled"];

    figLabs = 'A':'J';
    
    colors = [136 34 85; 102 17 0; 17 119 51; 68 170 153; 102 153 204; 51 34 136; 204 102 119; 170 68 153; 153 153 51; 148 148 148]/255;
    
    set(gcf,'renderer','Painters')
    f = figure(2);
    clf
    if size(opts,2) < 8
        f.Position = [100 100 500*size(opts,2) 500];
    else
        f.Position = [100 100 500*size(opts,2)/2 2*500];
    end
    
    for j = 1:size(opts,2)
    
        [p, tbl, stats] = kruskalwallis(squeeze(data(j,:,1,:)), labels);    
        results = multcompare(stats, 'CriticalValueType', 'dunn-sidak', 'Alpha', alpha);

        tbl2 = array2table(results,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
            
        figure(2)
        if size(opts,2) < 8
            subplot(1,size(opts,2),j)
        else
            subplot(2,size(opts,2)/2,j)
        end
        
        for i = 1:6 %size(nodes_cos_dist,4)
            vp = Violin({round(squeeze(data(j,:,1,i)),4)'}, i, 'MarkerSize', 10, 'ViolinColor', {colors(i,:)});
        end
    
        grps = [];
        ps = [];
        for ct_p = 1:size(tbl2,1)
            if tbl2.("P-value")(ct_p) < alpha && tbl2.("Group A")(ct_p) < 7 && tbl2.("Group B")(ct_p) < 7
                grps = [grps; {[tbl2.("Group A")(ct_p), tbl2.("Group B")(ct_p)]}];
                ps = [ps; tbl2.("P-value")(ct_p)];
            end
        end

        mxCompars = (6*5)/2;%size(data,4) * (size(data,4)-1)/2;
        if size(grps,1) == mxCompars
            %text(0.2, 1.15, '*all comparisons significant')
        elseif size(grps,1) == 0
            text(0.2, 0.1, '*no comparisons significant')
        end
    
        % if size(grps,1) > 0
        %     sigstar(grps, ps)
        % end
        xticks(1:size(data,4))
        xticklabels(labels)
        if j == 1
            ylabel(yAxLabel)
        end
        yticks([0, 0.5, 1])
    
        if size(opts,2) < 8 || j > size(opts,2)/2
            xlabel(xAxLabel)
        end
        title([num2str(opts(j)) ' ' paramName])
        ylim([0, 1.2])
        ax = gca;
        ax.FontSize=14;
        axis square
        text(-1.2,1.2,[figLabs(j) ')'], 'FontSize', 20)
    end
end

function doStats(data, opts, alpha, paramName)

    labels = ["Biv. Cross-Corr", "Pt. Cross-Corr", "Mv. Granger Causality", "Mutual Information",...
        "Biv. Transfer Entropy", "Mv. Transfer Entropy", "Zero-Lag Biv. Cross-Corr", ...
        "Zero-Lag Pt. Cross-Corr", "Zero-Lag Mutual Info.", "Shuffled" ];

    % compare metric by parameter
    for i = 1:size(data,1)
        [p, tbl, stats] = kruskalwallis(squeeze(data(i,:,1,:)), labels);
        results = multcompare(stats, 'CriticalValueType', 'dunn-sidak', 'Alpha', alpha);
        disp([num2str(opts(i)) ' ' paramName])

        if p < alpha
            tbl2 = array2table(results,"VariableNames", ...
                ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
            close all 
            disp(tbl2)
        else
            disp('no significant differences')
        end
        disp(' ')
    end
    
    %% compare parameter by metric
    for i = 1:size(data,4)
        [p, tbl, stats] = kruskalwallis(squeeze(data(:,:,1,i))', opts);
        disp(labels(i))
    
        if p < alpha
            results = multcompare(stats, 'CriticalValueType', 'dunn-sidak', 'Alpha', alpha);
            tbl2 = array2table(results,"VariableNames", ...
                ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
            close all 
            disp(tbl2)
        else 
            disp('no significant differences')
        end
       disp(' ')
    end

end

function makeFig_nodeDrop(data, opts, alpha, xAxLabel, yAxLabel)

    labels = {{"Biv. Cross-Corr"}, {"Pt. Cross-Corr"}, {"Mv. Granger","Causality"},  {"Mutual","Information"},...
        {"Biv. Transfer","Entropy"}, {"Mv. Transfer","Entropy"}, {"Zero-Lag Biv.","Cross-Corr"}, ...
        {"Zero-Lag Pt.","Cross-Corr"}, {"Zero-Lag Mutual","Information"}, {"Shuffled"}};

    colors = [136 34 85; 102 17 0; 17 119 51; 68 170 153; 102 153 204; 51 34 136; 204 102 119; 170 68 153; 153 153 51; 148 148 148]/255;
    figLabs = 'A':'J';

    f = figure(3);
    clf
    f.Position = [10 10 1800 650];
    set(gcf,'renderer','Painters')
    
    for i = 1:size(data,4)
        [p, tbl, stats] = kruskalwallis(squeeze(data(4,:,:,i)), opts);
        results = multcompare(stats, 'CriticalValueType', 'dunn-sidak', 'Alpha', alpha);
        tbl2 = array2table(results,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
        
        figure(3)
        subplot(2,5,i)
        for j = 1:size(data,3)
            vp = Violin({round(squeeze(data(4,:,j,i)),4)'}, j, 'MarkerSize', 10, 'ViolinColor', {colors(i,:)});
        end
    
        grps = [];
        ps = [];
        for ct_p = 1:size(tbl2,1)
            if tbl2.("P-value")(ct_p) < alpha
                grps = [grps; {[tbl2.("Group A")(ct_p), tbl2.("Group B")(ct_p)]}];
                ps = [ps; tbl2.("P-value")(ct_p)];
            end
        end
    
        mxCompars = size(data,3) * (size(data,1)-3)/2;
        if size(grps,1) == mxCompars
            if mean(data(4,:,j,i), 'omitnan') < 0.6
                %text(0.2, 1.15, '*all comparisons significant')
            else
                %text(0.2, 0.1, '*all comparisons significant')
            end
        elseif size(grps,1) == 0
            if mean(data(4,:,j,i), 'omitnan') < 0.6
                text(0.2, 1.15, '*no comparisons significant')
            % if i < 7
            %     text(0.2, 1.15, '*no comparisons significant')
            % else
            else
                text(0.2, 0.1, '*no comparisons significant')
            end
        end
        
        if i > 5
            xlabel(xAxLabel)
        end
        xticks(1:10)
        xticklabels(opts)
        xtickangle(45)
        if mod(i,5) == 1
            ylabel(yAxLabel)
        end
        title(labels{i})
        ylim([0, 1.2])
        yticks([0 0.5 1])
        ax = gca;
        ax.FontSize=13;
        xlim([0 size(data,3)+1])
        text(-1,1.3,[figLabs(i) ')'], 'FontSize', 18)

    end
end

function makeFig_nodeDrop_param(data, opts, alpha, xAxLabel, yAxLabel)

    labels = ["Biv. Cross-Corr", "Pt. Cross-Corr", "Mv. Granger Causality",  "Mutual Information",...
        "Biv. Transfer Entropy", "Mv. Transfer Entropy", "Zero-Lag Biv. Cross-Corr", ...
        "Zero-Lag Pt. Cross-Corr", "Zero-Lag Mutual Information", "Shuffled"];

    colors = [136 34 85; 102 17 0; 17 119 51; 68 170 153; 102 153 204; 51 34 136; 204 102 119; 170 68 153; 153 153 51; 148 148 148]/255;
    figLabs = 'A':'J';

    f = figure(3);
    clf
    f.Position = [100 100 1800 900];
    set(gcf,'renderer','Painters')
    
    for i = 1:size(data,3)
        [p, tbl, stats] = kruskalwallis(squeeze(data(4,:,i,:)), labels);
        results = multcompare(stats, 'CriticalValueType', 'dunn-sidak', 'Alpha', alpha);
        tbl2 = array2table(results,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
        
        figure(3)
        subplot(2,5,i)
        for j = 1:6%size(data,3)
            vp = Violin({round(squeeze(data(4,:,i,j)),4)'}, j, 'MarkerSize', 10, 'ViolinColor', {colors(j,:)});
        end
    
        grps = [];
        ps = [];
        for ct_p = 1:size(tbl2,1)
            if tbl2.("P-value")(ct_p) < alpha
                grps = [grps; {[tbl2.("Group A")(ct_p), tbl2.("Group B")(ct_p)]}];
                ps = [ps; tbl2.("P-value")(ct_p)];
            end
        end
    
        mxCompars = size(data,3) * (size(data,1)-3)/2;
        if size(grps,1) == mxCompars
            if mean(data(4,:,j,i), 'omitnan') < 0.6
                %text(0.2, 1.15, '*all comparisons significant')
            else
                %text(0.2, 0.1, '*all comparisons significant')
            end
        elseif size(grps,1) == 0
            if mean(data(4,:,j,i), 'omitnan') < 0.6
                text(0.2, 1.15, '*no comparisons significant')
            % if i < 7
            %     text(0.2, 1.15, '*no comparisons significant')
            % else
            else
                text(0.2, 0.1, '*no comparisons significant')
            end
        end
        
        if i > 5
            xlabel(xAxLabel)
        end
        xticks(1:6)
        xticklabels(labels(1:6))
        xtickangle(45)
        if mod(i,5) == 1
            ylabel(yAxLabel)
        end
        title([convertStringsToChars(opts(i)), ' Coverage'])
        ylim([0, 1.2])
        yticks([0 0.5 1])
        ax = gca;
        ax.FontSize=13;
        xlim([0 7])
        text(-1,1.3,[figLabs(i) ')'], 'FontSize', 18)

    end
end