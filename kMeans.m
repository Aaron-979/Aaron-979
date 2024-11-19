function [ cluster, centr, sse, silhouette_values ] = kMeans( k, P )

% kMeans Clusters data points into k clusters.
% Input args: k: number of clusters; 
% points: m-by-n matrix of n m-dimensional data points.
% Output args: cluster: 1-by-n array with values of 1,...,k
% representing in which cluster the corresponding point lies in
% centr: m-by-k matrix of the m-dimensional centroids of the k clusters
% sse: sum of squared errors
% silhouette_values: silhouette coefficient for each point

numP = size(P, 2); % number of points
dimP = size(P, 1); % dimension of points

% Choose k data points as initial centroids using k-means++ initialization
centr = kmeans_plus_plus(P, k);

% Initialize variables
cluster = zeros(1, numP);
clusterPrev = cluster;
iterations = 0;
stop = false;

while ~stop
    % Assign each point to the nearest centroid
    for idxP = 1:numP
        dist = vecnorm(P(:, idxP) - centr, 2, 1);
        [~, clusterP] = min(dist);
        cluster(idxP) = clusterP;
    end
    
    % Recompute the centroids
    for idxC = 1:k
        centr(:, idxC) = mean(P(:, cluster == idxC), 2);
    end
    
    % Check for convergence
    if isequal(clusterPrev, cluster)
        stop = true;
    end
    clusterPrev = cluster;
    iterations = iterations + 1;
end

% Calculate SSE
sse = 0;
for idxC = 1:k
    cluster_points = P(:, cluster == idxC);
    centroid = centr(:, idxC);
    distances = vecnorm(cluster_points - centroid, 2, 1);
    sse = sse + sum(distances.^2);
end

% Calculate silhouette coefficient
silhouette_values = silhouette_coefficient(P', cluster');
fprintf('kMeans.m used %d iterations of changing centroids.\n', iterations);
fprintf('Sum of Squared Errors (SSE): %.2f\n', sse);

end

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

function centroids = kmeans_plus_plus(points, k)
    % kmeans_plus_plus Initializes centroids using k-means++ algorithm
    % points: m-by-n matrix of n m-dimensional data points
    % k: number of clusters
    % centroids: m-by-k matrix of initial centroids

    [m, n] = size(points);
    centroids = zeros(m, k);
    
    % Randomly select the first centroid
    randIdx = randi(n);
    centroids(:, 1) = points(:, randIdx);
    
    % Select the remaining centroids
    for i = 2:k
        distSq = zeros(1, n);
        for j = 1:n
            d = min(vecnorm(points(:, j) - centroids(:, 1:i-1), 2, 1));
            distSq(j) = d^2;
        end
        prob = distSq / sum(distSq);
        cumProb = cumsum(prob);
        r = rand;
        idx = find(cumProb >= r, 1);
        centroids(:, i) = points(:, idx);
    end
end