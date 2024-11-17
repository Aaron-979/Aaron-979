% 此脚本在一个使用Excel表格数据的示例上运行k-means函数并可视化其结果。

close all; clear; clc;

%% 输入参数（并打印它们）

k = 3;     % 聚类数量
fprintf('k-Means将使用%d个聚类运行。\n', k);

%% 从Excel表格读取数据

% 读取Excel表格数据
data = readtable('数据1.xlsx');

% 提取第二列数据用于聚类
points = data{:, 2}; % 假设Excel表格中的数据在第二列

%% 运行kMeans.m并测量/打印性能

tic;
[cluster, centr] = kMeans(k, points); % 我的k-means
myPerform = toc;
fprintf('kMeans.m的计算时间：%d秒。\n', myPerform);

%% 运行MATLAB的函数kmeans(P,k)并测量/打印性能

tic;
[cluster_mT, centr_m] = kmeans(points', k); % MATLAB的k-means
matlabsPerform = toc;
cluster_m = cluster_mT';
fprintf('MATLAB的kmeans计算时间：%d秒。\n', matlabsPerform);

%% 比较性能

frac = matlabsPerform / myPerform;
fprintf('MATLAB使用的时间是kMeans.m的%d。\n', frac);

%% 所有可视化

figure('Name', 'Visualizations', 'units', 'normalized', 'outerposition', [0 0 1 1]);

% 可视化聚类
subplot(2, 2, 1);
scatter(data{:, 1}, data{:, 2}, 200, cluster, '.'); % 假设第一列为x，第二列为y
hold on;
scatter(centr(1, :), centr(2, :), 'xk', 'LineWidth', 1.5);
axis([min(data{:, 1}) max(data{:, 1}) min(data{:, 2}) max(data{:, 2})]);
daspect([1 1 1]);
xlabel('x');
ylabel('y');
title('Excel数据点聚类（自己实现的）');
grid on;

% 每个聚类中的点数量
subplot(2, 2, 2);
histogram(cluster);
axis tight;
[num, ~] = histcounts(cluster);
yticks(round(linspace(0, max(num), k)));
xlabel('聚类');
ylabel('数据点数量');
title('聚类点的直方图（自己实现的）');

% 可视化MATLAB的聚类
subplot(2, 2, 3);
scatter(data{:, 1}, data{:, 2}, 200, cluster_m, '.'); % 假设第一列为x，第二列为y
hold on;
scatter(centr_m(:, 1), centr_m(:, 2), 'xk', 'LineWidth', 1.5);
axis([min(data{:, 1}) max(data{:, 1}) min(data{:, 2}) max(data{:, 2})]);
daspect([1 1 1]);
xlabel('x');
ylabel('y');
title('Excel数据点聚类（MATLAB实现的）');
grid on;

% 每个MATLAB聚类中的点数量
subplot(2, 2, 4);
histogram(cluster_m);
axis tight;
[num_m, ~] = histcounts(cluster_m);
yticks(round(linspace(0, max(num_m), k)));
xlabel('聚类');
ylabel('数据点数量');
title('聚类点的直方图（MATLAB实现的）');