% 此脚本在一个使用Excel表格数据的示例上运行k-means函数并可视化其结果。

close all; clear; clc;

%% 输入参数（并打印它们）

k = 3;     % 聚类数量
fprintf('k-Means将使用%d个聚类运行。\n', k);

%% 从Excel表格读取数据

% 读取Excel表格数据
data = readtable('数据1.xlsx');

% 提取前三列数据用于聚类，并转置为行向量
points = data{:, 1:3}'; % 假设Excel表格中的数据在前三列

%%定义函数
function s = silhouette_coefficient(X, labels)
    % X: data points, n-by-m matrix (n points, m dimensions)
    % labels: cluster labels, n-by-1 array
    % s: silhouette coefficient for each point, n-by-1 array

    n = size(X, 1);
    k = max(labels);
    s = zeros(n, 1);

    for i = 1:n
        % Get the points in the same cluster as point i
        same_cluster = X(labels == labels(i), :);
        other_clusters = X(labels ~= labels(i), :);
        
        % Calculate average distance from i to other points in the same cluster (a(i))
        a_i = mean(vecnorm(same_cluster - X(i, :), 2, 2));
        
        % Calculate average distance from i to points in the nearest different cluster (b(i))
        b_i = inf;
        for j = 1:k
            if j ~= labels(i)
                other_cluster_points = X(labels == j, :);
                b_i = min(b_i, mean(vecnorm(other_cluster_points - X(i, :), 2, 2)));
            end
        end
        
        % Calculate silhouette coefficient for point i
        s(i) = (b_i - a_i) / max(a_i, b_i);
    end
end
%% 运行kMeans.m并测量/打印性能

tic;
[cluster, centr, mySSE, silhouette_values] = kMeans(k, points); % 我的k-means
myPerform = toc;
fprintf('kMeans.m的计算时间：%d秒。\n', myPerform);

%% 输出平均轮廓系数

mean_silhouette = mean(silhouette_values);
fprintf('自己实现的k-means的平均轮廓系数：%.2f\n', mean_silhouette);

%% 运行MATLAB的函数kmeans(P,k)并测量/打印性能

tic;
[cluster_mT, centr_m] = kmeans(points', k); % MATLAB的k-means
matlabsPerform = toc;
cluster_m = cluster_mT';
fprintf('MATLAB的kmeans计算时间：%d秒。\n', matlabsPerform);

% Calculate silhouette coefficient for MATLAB's k-means
silhouette_values_m = silhouette_coefficient(points', cluster_mT);
mean_silhouette_m = mean(silhouette_values_m);
fprintf('MATLAB实现的k-means的平均轮廓系数：%.2f\n', mean_silhouette_m);

%% 比较性能

frac = matlabsPerform / myPerform;
fprintf('MATLAB使用的时间是kMeans.m的%d。\n', frac);

%% 写入输出结果到Excel文件

outputTable = table(data{:, 1}, data{:, 2}, data{:, 3}, cluster', cluster_m', ...
    'VariableNames', {'X', 'Y', 'Z', 'MyKMeansCluster', 'MATLABKMeansCluster'});
writetable(outputTable, '输出.xlsx', 'Sheet', 1);

%% 输出误差平方和
fprintf('自己实现的k-means的SSE：%.2f\n', mySSE);

%% 所有可视化

figure('Name', 'Visualizations', 'units', 'normalized', 'outerposition', [0 0 1 1]);

% 可视化聚类
subplot(2, 2, 1);
scatter3(data{:, 1}, data{:, 2}, data{:, 3}, 200, cluster, '.'); % 假设第一列为x，第二列为y，第三列为z
hold on;
scatter3(centr(1, :), centr(2, :), centr(3, :), 'xk', 'LineWidth', 1.5);
xlabel('挥发分');
ylabel('低位发热量');
zlabel('全硫分');
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
scatter3(data{:, 1}, data{:, 2}, data{:, 3}, 200, cluster_m, '.'); % 假设第一列为x，第二列为y，第三列为z
hold on;
scatter3(centr_m(:, 1), centr_m(:, 2), centr_m(:, 3), 'xk', 'LineWidth', 1.5);
xlabel('挥发分');
ylabel('低位发热量');
zlabel('全硫分');
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

% Display silhouette coefficients
figure('Name', 'Silhouette Coefficients', 'units', 'normalized', 'outerposition', [0 0 1 1]);

subplot(1, 2, 1);
bar(silhouette_values);
xlabel('数据点');
ylabel('轮廓系数');
title('自己实现的k-means的轮廓系数');

subplot(1, 2, 2);
bar(silhouette_values_m);
xlabel('数据点');
ylabel('轮廓系数');
title('MATLAB实现的k-means的轮廓系数');