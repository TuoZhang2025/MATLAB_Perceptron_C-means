%% 感知器算法求解分界面方程
clear all; close all; clc;

%% 定义样本集
% 类别w1
w1 = [1, 0;
      1, 1;
      0, 2];

% 类别w2
w2 = [2, 1;
      2, 2;
      1, 3];

%% 数据预处理 - 增广特征向量并将w2取负
% 增广w1 (添加x0=1)
w1_augmented = [ones(size(w1,1),1), w1];

% 增广w2并取负
w2_augmented = -[ones(size(w2,1),1), w2];

% 合并所有样本
samples = [w1_augmented; w2_augmented];

%% 实验参数设置
% 初始权向量设置
initial_weights = {
    [1; 1; 1],        % 初始权向量1
    [0; 0; 0],        % 初始权向量2
    [-1; -1; -1]      % 初始权向量3
};

% 样本顺序设置
sample_orders = {
    1:size(samples,1),        % 原始顺序
    randperm(size(samples,1)), % 随机顺序1
    randperm(size(samples,1))  % 随机顺序2
};

% 学习率
learning_rate = 1;

%% 执行实验
figure('Position', [100, 100, 1200, 800]);

for i = 1:length(initial_weights)
    for j = 1:length(sample_orders)
        % 获取当前初始权向量和样本顺序
        w = initial_weights{i};
        ordered_samples = samples(sample_orders{j}, :);
        
        % 迭代次数上限
        max_iterations = 100;
        iteration = 0;
        misclassified = true;
        
        % 记录每次迭代的权向量
        weight_history = w;
        
        % 感知器算法迭代
        while misclassified && iteration < max_iterations
            iteration = iteration + 1;
            misclassified = false;
            
            % 遍历所有样本
            for k = 1:size(ordered_samples, 1)
                x = ordered_samples(k, :)';
                
                % 如果样本被误分类
                if w' * x <= 0
                    % 更新权向量
                    w = w + learning_rate * x;
                    weight_history = [weight_history, w];
                    misclassified = true;
                end
            end
        end
        
        % 绘制结果
        subplot(length(initial_weights), length(sample_orders), (i-1)*length(sample_orders)+j);
        
        % 绘制样本点
        plot(w1(:,1), w1(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
        hold on;
        plot(w2(:,1), w2(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
        
        % 绘制决策边界
        x_range = min([w1(:,1); w2(:,1)])-1 : 0.1 : max([w1(:,1); w2(:,1)])+1;
        y_range = (-w(1) - w(2)*x_range) / w(3);
        
        % 检查是否为垂直线
        if abs(w(3)) < 1e-10
            plot(ones(size(y_range))*(-w(1)/w(2)), y_range, 'k-', 'LineWidth', 2);
        else
            plot(x_range, y_range, 'k-', 'LineWidth', 2);
        end
        
        % 设置图表属性
        grid on;
        axis equal;
        xlim([min([w1(:,1); w2(:,1)])-1, max([w1(:,1); w2(:,1)])+1]);
        ylim([min([w1(:,2); w2(:,2)])-1, max([w1(:,2); w2(:,2)])+1]);
        title(sprintf('初始权向量: [%d, %d, %d], 样本顺序: %d, 迭代次数: %d', ...
            initial_weights{i}(1), initial_weights{i}(2), initial_weights{i}(3), j, iteration));
        xlabel('x_1');
        ylabel('x_2');
        legend('w1', 'w2', '决策边界');
        
        % 显示最终权向量和分界面方程
        text(min(x_range)+0.5, min(y_range)+0.5, ...
            sprintf('最终权向量: [%.2f, %.2f, %.2f]', w(1), w(2), w(3)), ...
            'BackgroundColor', 'white', 'EdgeColor', 'black');
        
        % 保存结果
        results(i,j).initial_weight = initial_weights{i};
        results(i,j).sample_order = sample_orders{j};
        results(i,j).final_weight = w;
        results(i,j).iterations = iteration;
    end
end

%% 实验结果分析报告
fprintf('\n感知器算法实验结果分析报告\n');
fprintf('=================================\n');

for i = 1:length(initial_weights)
    for j = 1:length(sample_orders)
        fprintf('\n实验 %d-%d:\n', i, j);
        fprintf('初始权向量: [%.2f, %.2f, %.2f]\n', ...
            results(i,j).initial_weight(1), results(i,j).initial_weight(2), results(i,j).initial_weight(3));
        fprintf('样本顺序: ');
        fprintf('%d ', results(i,j).sample_order);
        fprintf('\n最终权向量: [%.2f, %.2f, %.2f]\n', ...
            results(i,j).final_weight(1), results(i,j).final_weight(2), results(i,j).final_weight(3));
        fprintf('迭代次数: %d\n', results(i,j).iterations);
        fprintf('分界面方程: %.2f + %.2f*x1 + %.2f*x2 = 0\n', ...
            results(i,j).final_weight(1), results(i,j).final_weight(2), results(i,j).final_weight(3));
    end
end

fprintf('\n结论:\n');
fprintf('1. 当初始权向量不同时，感知器算法可能需要不同的迭代次数才能收敛。\n');
fprintf('2. 样本呈现的顺序可能影响算法的收敛速度，但只要样本是线性可分的，最终都会收敛到一个解。\n');
fprintf('3. 尽管初始条件不同，最终得到的决策边界可能不同，但它们都能正确分类训练样本。\n');    