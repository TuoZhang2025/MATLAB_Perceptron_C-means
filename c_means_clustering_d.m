% C均值聚类算法(Ⅰ)实现
% 针对给定的二维模式样本集进行聚类分析

% 定义数据集
X = [0.5, 0.5;
     1.0, 0.5;
     1.0, 0.0;
     1.0, 1.0;
     5.0, 5.0;
     6.0, 5.5;
     6.0, 6.0;
     7.0, 0.0;
     6.0, 0.5;
     7.0, -1.0;
     8.0, -0.5];

% 定义不同的类别数量
C_values = [2, 3, 4];

% 定义不同的初始聚类中心选择方法
init_methods = {'fixed', 'random1', 'random2'};
method_names = {'固定初始化', '随机初始化1', '随机初始化2'};

% 为每个类别数量创建一个窗口
for C = C_values
    % 创建一个足够大的图形窗口
    figure('Position', [100, 100, 1200, 800]);
    title_text = sprintf('C均值聚类: C = %d', C);
    sgtitle(title_text, 'FontSize', 16);
    
    % 对每种初始化方法创建子图
    for method_idx = 1:length(init_methods)
        method = init_methods{method_idx};
        
        % 设置随机种子，确保结果可重复且不同初始化方法选择不同的样本点
        if strcmp(method, 'random1')
            rng(101);  % 随机初始化1的种子
        elseif strcmp(method, 'random2')
            rng(202);  % 随机初始化2的种子
        else
            rng(0);    % 固定初始化的种子
        end
        
        % 根据不同方法初始化聚类中心
        switch method
            case 'fixed'
                % 固定初始聚类中心（手动选择样本点）
                if C == 2
                    idx = [1, 5];  % 选择X1和X5作为初始中心
                elseif C == 3
                    idx = [1, 5, 8];  % 选择X1、X5和X8作为初始中心
                else
                    idx = [1, 5, 8, 11];  % 选择X1、X5、X8和X11作为初始中心
                end
                initial_centers = X(idx, :);
            case 'random1'
                % 第一个随机初始化方法
                valid = false;
                attempts = 0;
                max_attempts = 100;
                
                while ~valid && attempts < max_attempts
                    idx = randperm(size(X, 1), C);
                    initial_centers = X(idx, :);
                    attempts = attempts + 1;
                    
                    % 检查是否与固定初始化相同
                    if strcmp(method, 'random1') && C <= 3
                        fixed_idx = get_fixed_indices(C);
                        valid = ~isequal(sort(idx), sort(fixed_idx));
                    else
                        valid = true;
                    end
                end
                
                if attempts >= max_attempts
                    warning('无法找到与固定初始化不同的随机初始点');
                end
            case 'random2'
                % 第二个随机初始化方法
                valid = false;
                attempts = 0;
                max_attempts = 100;
                
                while ~valid && attempts < max_attempts
                    idx = randperm(size(X, 1), C);
                    initial_centers = X(idx, :);
                    attempts = attempts + 1;
                    
                    % 检查是否与固定初始化或随机初始化1相同
                    if C <= 3
                        fixed_idx = get_fixed_indices(C);
                        random1_idx = get_random_indices(C, 101);
                        valid = ~isequal(sort(idx), sort(fixed_idx)) && ~isequal(sort(idx), sort(random1_idx));
                    else
                        valid = true;
                    end
                end
                
                if attempts >= max_attempts
                    warning('无法找到与固定初始化和随机初始化1不同的随机初始点');
                end
        end
        
        % 执行C均值聚类
        [labels, centers, iterations] = c_means(X, initial_centers, C);
        
        % 找出初始聚类中心对应的样本点编号
        init_sample_indices = idx;
        
        % 创建子图位置（3x2布局：上排为聚类结果，下排为聚类过程）
        if method_idx == 1
            % 固定初始化
            subplot(2, 3, 1);
            plot_clustering_with_regions(X, labels, centers, initial_centers, init_sample_indices);
            title(sprintf('聚类结果 - %s\n迭代次数: %d', method_names{method_idx}, iterations));
            
            subplot(2, 3, 4);
            plot_clustering_process(X, labels, centers, initial_centers, init_sample_indices);
            title(sprintf('聚类过程 - %s', method_names{method_idx}));
        elseif method_idx == 2
            % 随机初始化1
            subplot(2, 3, 2);
            plot_clustering_with_regions(X, labels, centers, initial_centers, init_sample_indices);
            title(sprintf('聚类结果 - %s\n迭代次数: %d', method_names{method_idx}, iterations));
            
            subplot(2, 3, 5);
            plot_clustering_process(X, labels, centers, initial_centers, init_sample_indices);
            title(sprintf('聚类过程 - %s', method_names{method_idx}));
        else
            % 随机初始化2
            subplot(2, 3, 3);
            plot_clustering_with_regions(X, labels, centers, initial_centers, init_sample_indices);
            title(sprintf('聚类结果 - %s\n迭代次数: %d', method_names{method_idx}, iterations));
            
            subplot(2, 3, 6);
            plot_clustering_process(X, labels, centers, initial_centers, init_sample_indices);
            title(sprintf('聚类过程 - %s', method_names{method_idx}));
        end
    end
end

% 获取固定初始化的索引
function idx = get_fixed_indices(C)
    if C == 2
        idx = [1, 5];
    elseif C == 3
        idx = [1, 5, 8];
    else
        idx = [1, 5, 8, 11];
    end
end

% 获取随机初始化的索引
function idx = get_random_indices(C, seed)
    old_seed = rng;
    rng(seed);
    idx = randperm(11, C);
    rng(old_seed);
end

% C均值聚类算法实现
function [labels, centers, iterations] = c_means(X, initial_centers, C)
    [n, d] = size(X);
    labels = zeros(n, 1);
    old_labels = ones(n, 1) * -1;  % 初始化不同的标签值
    iterations = 0;
    max_iterations = 100;
    centers = initial_centers;
    
    % 迭代直到收敛或达到最大迭代次数
    while ~isequal(labels, old_labels) && iterations < max_iterations
        old_labels = labels;
        iterations = iterations + 1;
        
        % 分配阶段：计算每个点到各聚类中心的距离
        distances = zeros(n, C);
        for i = 1:C
            distances(:, i) = sum((X - repmat(centers(i, :), n, 1)).^2, 2);
        end
        
        % 分配每个点到最近的聚类中心
        [~, labels] = min(distances, [], 2);
        
        % 更新阶段：重新计算聚类中心
        for i = 1:C
            idx = (labels == i);
            if sum(idx) > 0
                centers(i, :) = mean(X(idx, :), 1);
            else
                % 如果某个聚类为空，随机选择一个样本点作为新的聚类中心
                rand_idx = randi(n);
                centers(i, :) = X(rand_idx, :);
            end
        end
    end
end

% 绘制聚类结果（含聚类区域）
function plot_clustering_with_regions(X, labels, centers, initial_centers, init_sample_indices)
    colors = lines(max(labels));
    
    % 创建网格用于绘制聚类区域
    [x_grid, y_grid] = meshgrid(linspace(min(X(:,1))-1, max(X(:,1))+1, 100), ...
                               linspace(min(X(:,2))-1, max(X(:,2))+1, 100));
    grid_points = [x_grid(:), y_grid(:)];
    
    % 对网格点进行分类
    grid_labels = zeros(size(grid_points, 1), 1);
    for i = 1:size(grid_points, 1)
        distances = zeros(1, size(centers, 1));
        for j = 1:size(centers, 1)
            distances(j) = sum((grid_points(i,:) - centers(j,:)).^2);
        end
        [~, grid_labels(i)] = min(distances);
    end
    
    % 绘制聚类区域
    grid_labels = reshape(grid_labels, size(x_grid));
    hold on;
    
    % 直接使用grid_labels作为颜色数据，确保是数值类型
    pcolor(x_grid, y_grid, double(grid_labels));
    shading interp;  % 平滑颜色过渡
    
    % 创建自定义颜色映射
    cluster_colormap = zeros(max(labels), 3);
    for i = 1:max(labels)
        cluster_colormap(i, :) = colors(i, :);
    end
    cluster_colormap(cluster_colormap == 0) = 1;  % 确保没有完全黑色的区域
    
    % 应用颜色映射并设置透明度
    colormap(cluster_colormap);
    alpha(0.3);  % 增加透明度以更好地显示数据点
    
    % 绘制数据点
    for i = 1:max(labels)
        idx = (labels == i);
        plot(X(idx, 1), X(idx, 2), 'o', 'Color', colors(i, :), 'MarkerSize', 8, 'MarkerFaceColor', colors(i, :));
    end
    
    % 绘制最终聚类中心（统一使用黑色×标记）
    final_centers = plot(centers(:, 1), centers(:, 2), 'kx', 'MarkerSize', 10, 'LineWidth', 2);
    
    % 绘制初始聚类中心（统一使用样本点加黑边标记）
    initial_centers_handles = gobjects(size(initial_centers, 1), 1);
    for i = 1:size(initial_centers, 1)
        % 找出对应的样本点在原始数据中的位置
        sample_idx = find(ismember(X, initial_centers(i,:), 'rows'));
        if ~isempty(sample_idx)
            % 标记初始中心对应的样本点编号
            text(X(sample_idx, 1)+0.1, X(sample_idx, 2)+0.1, ...
                 sprintf('X%d', init_sample_indices(i)), ...
                 'FontWeight', 'bold', 'Color', colors(i, :));
            
            % 使用加黑边的样本点标记初始中心
            initial_centers_handles(i) = plot(X(sample_idx, 1), X(sample_idx, 2), 'o', 'Color', colors(i, :), ...
                 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(i, :), 'LineWidth', 1.5);
        end
    end
    
    % 设置图形属性
    xlabel('X轴');
    ylabel('Y轴');
    axis equal;
    grid on;
    
    % 创建图例对象
    legend_objects = cell(max(labels) + 2, 1);
    legend_str = cell(max(labels) + 2, 1);
    
    % 添加类别图例
    for i = 1:max(labels)
        legend_objects{i} = plot(nan, nan, 'o', 'Color', colors(i, :), 'MarkerSize', 8, 'MarkerFaceColor', colors(i, :));
        legend_str{i} = ['类别 ', num2str(i)];
    end
    
    % 添加初始中心和最终中心图例
    legend_objects{max(labels)+1} = initial_centers_handles(1);
    legend_str{max(labels)+1} = '初始聚类中心';
    
    legend_objects{max(labels)+2} = final_centers;
    legend_str{max(labels)+2} = '最终聚类中心';
    
    % 创建图例 - 修正参数顺序
    legend([legend_objects{:}], legend_str, 'Location', 'best');
    hold off;
end

% 绘制聚类过程（初始中心和最终中心对比）
function plot_clustering_process(X, labels, centers, initial_centers, init_sample_indices)
    colors = lines(max(labels));
    
    % 绘制数据点
    hold on;
    for i = 1:max(labels)
        idx = (labels == i);
        plot(X(idx, 1), X(idx, 2), 'o', 'Color', colors(i, :), 'MarkerSize', 8, 'MarkerFaceColor', colors(i, :));
    end
    
    % 绘制初始聚类中心（统一使用样本点加黑边标记）
    initial_centers_handles = gobjects(size(initial_centers, 1), 1);
    for i = 1:size(initial_centers, 1)
        % 找出对应的样本点在原始数据中的位置
        sample_idx = find(ismember(X, initial_centers(i,:), 'rows'));
        if ~isempty(sample_idx)
            % 标记初始中心对应的样本点编号
            text(X(sample_idx, 1)+0.1, X(sample_idx, 2)+0.1, ...
                 sprintf('X%d', init_sample_indices(i)), ...
                 'FontWeight', 'bold', 'Color', colors(i, :));
            
            % 使用加黑边的样本点标记初始中心
            initial_centers_handles(i) = plot(X(sample_idx, 1), X(sample_idx, 2), 'o', 'Color', colors(i, :), ...
                 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(i, :), 'LineWidth', 1.5);
        end
    end
    
    % 绘制最终聚类中心（统一使用黑色×标记）
    final_centers = plot(centers(:, 1), centers(:, 2), 'kx', 'MarkerSize', 10, 'LineWidth', 2);
    
    % 连接初始中心和最终中心
    for i = 1:size(centers, 1)
        % 找出对应的样本点在原始数据中的位置
        sample_idx = find(ismember(X, initial_centers(i,:), 'rows'));
        if ~isempty(sample_idx)
            plot([X(sample_idx, 1), centers(i, 1)], ...
                 [X(sample_idx, 2), centers(i, 2)], ...
                 '--', 'Color', colors(i, :), 'LineWidth', 1);
        end
    end
    
    % 设置图形属性
    xlabel('X轴');
    ylabel('Y轴');
    axis equal;
    grid on;
    
    % 创建图例对象
    legend_objects = cell(max(labels) + 2, 1);
    legend_str = cell(max(labels) + 2, 1);
    
    % 添加类别图例
    for i = 1:max(labels)
        legend_objects{i} = plot(nan, nan, 'o', 'Color', colors(i, :), 'MarkerSize', 8, 'MarkerFaceColor', colors(i, :));
        legend_str{i} = ['类别 ', num2str(i)];
    end
    
    % 添加初始中心和最终中心图例
    legend_objects{max(labels)+1} = initial_centers_handles(1);
    legend_str{max(labels)+1} = '初始聚类中心';
    
    legend_objects{max(labels)+2} = final_centers;
    legend_str{max(labels)+2} = '最终聚类中心';
    
    % 创建图例 - 修正参数顺序
    legend([legend_objects{:}], legend_str, 'Location', 'best');
    hold off;
end
