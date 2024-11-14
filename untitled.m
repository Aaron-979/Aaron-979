% 示例调用
% 假设数据存储在一个名为 "数据1" 的Excel文件中
data = readtable('数据1.xlsx');
data = table2array(data); % 将表转换为数组
num_clusters = 3; % 假设我们希望将数据分为6类
coal_quality_clustering(data, num_clusters);

function coal_quality_clustering(data, num_clusters)
    % data: 样本数据矩阵，每行是一个样本
    % num_clusters: 最终的分类数目

    % Step 1: 计算任意两个样本点间的距离
    distances = pdist(data, 'euclidean');

    % Step 2-4: 使用层次聚类算法进行聚类
    linkage_tree = linkage(distances, 'single');

    % Step 5: 根据最终的分类数目进行聚类划分
    cluster_labels = cluster(linkage_tree, 'maxclust', num_clusters);

    % 可视化结果（如果数据是二维的）
    if size(data, 2) == 2
        figure;
        gscatter(data(:,1), data(:,2), cluster_labels);
        title('Coal Quality Clustering');
        xlabel('Feature 1');
        ylabel('Feature 2');
    end

    % 输出分类结果
    disp('Cluster labels for each sample:');
    disp(cluster_labels);

    % 将分类结果添加到数据中
    data_with_labels = [data, cluster_labels];

    % 转换为表格形式
    data_table = array2table(data_with_labels, 'VariableNames', ...
        ['Feature' + string(1:size(data, 2)), 'ClusterLabel']);

    % 导出到Excel文件
    writetable(data_table, '输出.xlsx');
end

