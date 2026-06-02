% This example demonstrates how to plot directly using SUTRA's mesh format,
% which eliminates the need to adjust mesh geometry for irregularly shaped models.
% 2D case

% 本案例演示了如何直接通过读取sutra的网格格式直接作图，可以免去对不规则形状的模型
% 进行网格形状调整的步骤。2D模型案例。

clear;close all

filename = 'SUTRAkuansmodel2D'; % change file name
dataINP = readINP(filename);
dataNOD = readNOD(filename);

% read the .NOD file result
% 读取浓度数据
n = size(dataNOD, 2);
target_variable = find(strcmp(dataNOD(n).label,'Concentration'));
x_id = strcmp(dataNOD(n).label,'X'); % find x data 寻找x的数据
z_id = strcmp(dataNOD(n).label,'Y'); % find y data 提取Y轴数据
xa = dataNOD(n).terms{x_id}; % x data be careful with the unit 注意x轴的单位
za = dataNOD(n).terms{z_id}; % y data y轴的数据
con = dataNOD(n).terms{target_variable}; % concentration 读取浓度值
pre = dataNOD(n).terms{strcmp(dataNOD(n).label,'Pressure')}; % pressure 读取压力值
sat = dataNOD(n).terms{strcmp(dataNOD(n).label,'Saturation')}; % satuation 读取饱和度

% read the connectivity of the mesh (# Data set 22)
% 读取网格的连接方式
connectivity = [dataINP.ds22{1,2}, dataINP.ds22{1,3}, dataINP.ds22{1,4}, dataINP.ds22{1,5}];

% Draw the graph, 画图 将单元格连接起来
fig = figure('Color', 'w','position', [0 0 1200 400]);
plot([0 200], [30 30], 'k', 'LineStyle', '-', LineWidth=2)
hold on
plot([0 200], [32 32], 'b', 'LineStyle', '--', LineWidth=2)
plot([0 200], [28 28], 'b', 'LineStyle', '--', LineWidth=2)
patch('Faces', connectivity, 'Vertices', [xa, za], 'FaceVertexCData', con, 'FaceColor', 'interp', 'EdgeColor', 'none');
colormap jet
% print('result','-dpng')