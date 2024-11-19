function [ cluster, centr, sse ] = kMeans( k, P )

%kMeans Clusters data points into k clusters.
%   Input args: k: number of clusters; 
%   points: m-by-n matrix of n m-dimensional data points.
%   Output args: cluster: 1-by-n array with values of 1,...,k
%   representing in which cluster the corresponding point lies in
%   centr: m-by-k matrix of the m-dimensional centroids of the k clusters
%   sse: sum of squared errors

numP = size(P, 2); % number of points
dimP = size(P, 1); % dimension of points

% Choose k data points as initial centroids
randIdx = randperm(numP, k);
centr = P(:, randIdx);

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

fprintf('kMeans.m used %d iterations of changing centroids.\n', iterations);
fprintf('Sum of Squared Errors (SSE): %.2f\n', sse);

end