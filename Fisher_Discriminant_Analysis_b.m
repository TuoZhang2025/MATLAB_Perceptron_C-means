% Fisher判别法分类程序
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

%% 计算Fisher判别法参数
% 计算各类的均值向量
m1 = mean(w1);
m2 = mean(w2);

% 计算类内离散度矩阵
S1 = zeros(2, 2);
S2 = zeros(2, 2);

for i = 1:size(w1, 1)
    diff = w1(i, :) - m1;
    S1 = S1 + diff' * diff;
end

for i = 1:size(w2, 1)
    diff = w2(i, :) - m2;
    S2 = S2 + diff' * diff;
end

% 计算总类内离散度矩阵
Sw = S1 + S2;

% 计算最优投影方向
w = inv(Sw) * (m2 - m1)';
w = w / norm(w);  % 归一化

% 计算阈值
m1_proj = m1 * w;
m2_proj = m2 * w;
w0 = -0.5 * (m1_proj + m2_proj);

% 分界面方程
% 对于二维情况，分界面是一条直线：w1*x1 + w2*x2 + w0 = 0

%% 可视化结果
figure('Position', [100, 100, 1200, 800]);

% 绘制样本点
subplot(1, 2, 1);
plot(w1(:,1), w1(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'w1');
hold on;
plot(w2(:,1), w2(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'DisplayName', 'w2');

% 绘制分界面
x_range = min([w1(:,1); w2(:,1)])-1 : 0.1 : max([w1(:,1); w2(:,1)])+1;
y_range = (-w(1)*x_range - w0) / w(2);
plot(x_range, y_range, 'k-', 'LineWidth', 2, 'DisplayName', '分界面');

% 绘制投影轴
mid_point = (m1 + m2) / 2;
axis_length = 3;
proj_axis_x = mid_point(1) + [-axis_length, axis_length] * w(1);
proj_axis_y = mid_point(2) + [-axis_length, axis_length] * w(2);
plot(proj_axis_x, proj_axis_y, 'g-', 'LineWidth', 2, 'DisplayName', '投影轴');

% 绘制均值点
plot(m1(1), m1(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
plot(m2(1), m2(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2);

% 计算并绘制样本点的投影方向
for i = 1:size(w1, 1)
    % 计算投影长度
    proj_length = (w1(i,:) - mid_point) * w;
    
    % 绘制投影方向线（垂直于投影轴）
    proj_point = mid_point + proj_length * w';
    line([w1(i,1), proj_point(1)], [w1(i,2), proj_point(2)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
end

for i = 1:size(w2, 1)
    % 计算投影长度
    proj_length = (w2(i,:) - mid_point) * w;
    
    % 绘制投影方向线（垂直于投影轴）
    proj_point = mid_point + proj_length * w';
    line([w2(i,1), proj_point(1)], [w2(i,2), proj_point(2)], 'Color', 'b', 'LineStyle', '--', 'LineWidth', 1);
end

% 分类阈值应该是两类均值在投影轴上的中点
% 计算w1和w2在投影轴上的投影长度
w1_proj_length = (m1 - mid_point) * w;
w2_proj_length = (m2 - mid_point) * w;

% 计算阈值点在投影轴上的位置
threshold_proj_length = (w1_proj_length + w2_proj_length) / 2;
threshold_proj = mid_point + threshold_proj_length * w';
plot(threshold_proj(1), threshold_proj(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'DisplayName', '分类阈值');

% 设置图表属性
grid on;
axis equal;
xlim([min([w1(:,1); w2(:,1)])-1, max([w1(:,1); w2(:,1)])+1]);
ylim([min([w1(:,2); w2(:,2)])-1, max([w1(:,2); w2(:,2)])+1]);
title('Fisher判别法 - 特征空间中的投影');
xlabel('x_1');
ylabel('x_2');

% 调整图例位置，避免覆盖
legend('Location', 'northeastoutside', 'Orientation', 'vertical');

% 调整信息显示位置，避免遮挡图像
annotation('textbox', [0.02, 0.02, 0.25, 0.1], ...
    'String', sprintf('分界面方程:\n%.4f*x1 + %.4f*x2 + %.4f = 0', w(1), w(2), w0), ...
    'EdgeColor', 'none', 'BackgroundColor', [1 1 1 0.7], ...
    'FontSize', 10, 'HorizontalAlignment', 'left');

annotation('textbox', [0.02, 0.12, 0.25, 0.1], ...
    'String', sprintf('投影轴方向:\n[%.4f, %.4f]', w(1), w(2)), ...
    'EdgeColor', 'none', 'BackgroundColor', [1 1 1 0.7], ...
    'FontSize', 10, 'HorizontalAlignment', 'left');

%% 绘制投影空间
subplot(1, 2, 2);

% 计算投影值
w1_proj_val = zeros(size(w1, 1), 1);
w2_proj_val = zeros(size(w2, 1), 1);

for i = 1:size(w1, 1)
    w1_proj_val(i) = (w1(i,:) - mid_point) * w;
end

for i = 1:size(w2, 1)
    w2_proj_val(i) = (w2(i,:) - mid_point) * w;
end

% 绘制投影点
scatter(w1_proj_val, zeros(size(w1_proj_val)), 64, 'r', 'filled', 'DisplayName', 'w1投影');
hold on;
scatter(w2_proj_val, zeros(size(w2_proj_val)), 64, 'b', 'filled', 'DisplayName', 'w2投影');

% 绘制均值点的投影
m1_proj_val = (m1 - mid_point) * w;
m2_proj_val = (m2 - mid_point) * w;
scatter(m1_proj_val, 0, 100, 'r', 'x', 'LineWidth', 2, 'DisplayName', 'w1均值投影');
scatter(m2_proj_val, 0, 100, 'b', 'x', 'LineWidth', 2, 'DisplayName', 'w2均值投影');

% 计算正确的分类阈值
threshold_val = (m1_proj_val + m2_proj_val) / 2;

% 绘制分界面（在投影空间中是一个点）
plot(threshold_val, 0, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'LineWidth', 2, 'DisplayName', '分类阈值');

% 绘制投影轴
x_range_proj = [min([w1_proj_val; w2_proj_val])-1, max([w1_proj_val; w2_proj_val])+1];
y_range_proj = [-0.5, 0.5];
plot(x_range_proj, [0, 0], 'k-', 'LineWidth', 1);
plot([threshold_val, threshold_val], y_range_proj, 'k--', 'LineWidth', 1);

% 标注投影轴
text(m1_proj_val, 0.1, sprintf('%.2f', m1_proj_val), 'HorizontalAlignment', 'center', 'FontSize', 9);
text(m2_proj_val, 0.1, sprintf('%.2f', m2_proj_val), 'HorizontalAlignment', 'center', 'FontSize', 9);
text(threshold_val, 0.1, sprintf('%.2f', threshold_val), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);

% 设置图表属性
grid on;
xlim(x_range_proj);
ylim(y_range_proj);
title('Fisher判别法 - 投影空间');
xlabel('投影值');
axis off;  % 隐藏坐标轴，只显示投影轴

% 调整图例位置，避免覆盖
legend('Location', 'northeastoutside', 'Orientation', 'vertical');

% 调整信息显示位置
annotation('textbox', [0.6, 0.8, 0.3, 0.1], ...
    'String', sprintf('投影轴方向:\n[%.4f, %.4f]', w(1), w(2)), ...
    'EdgeColor', 'none', 'BackgroundColor', [1 1 1 0.7], ...
    'FontSize', 10, 'HorizontalAlignment', 'left');

%% 不同样本顺序的影响分析
% Fisher判别法是一种确定性算法，结果不依赖于初始权向量
% 但样本顺序可能影响数值计算的稳定性

% 尝试不同的样本顺序
sample_orders = {
    1:size(w1,1),        % 原始顺序
    randperm(size(w1,1)), % 随机顺序1
    randperm(size(w1,1))  % 随机顺序2
};

% 为每个样本顺序创建一个窗口
figure('Position', [100, 100, 1200, 800]);

for j = 1:length(sample_orders)
    % 获取当前样本顺序
    order = sample_orders{j};
    w1_ordered = w1(order, :);
    w2_ordered = w2(order, :);
    
    % 计算Fisher判别法参数
    m1_ordered = mean(w1_ordered);
    m2_ordered = mean(w2_ordered);
    
    S1_ordered = zeros(2, 2);
    S2_ordered = zeros(2, 2);
    
    for i = 1:size(w1_ordered, 1)
        diff = w1_ordered(i, :) - m1_ordered;
        S1_ordered = S1_ordered + diff' * diff;
    end
    
    for i = 1:size(w2_ordered, 1)
        diff = w2_ordered(i, :) - m2_ordered;
        S2_ordered = S2_ordered + diff' * diff;
    end
    
    Sw_ordered = S1_ordered + S2_ordered;
    w_ordered = inv(Sw_ordered) * (m2_ordered - m1_ordered)';
    w_ordered = w_ordered / norm(w_ordered);  % 归一化
    
    m1_proj_ordered = m1_ordered * w_ordered;
    m2_proj_ordered = m2_ordered * w_ordered;
    w0_ordered = -0.5 * (m1_proj_ordered + m2_proj_ordered);
    
    % 绘制结果子图
    subplot(2, 2, j);
    
    % 绘制样本点
    plot(w1_ordered(:,1), w1_ordered(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    hold on;
    plot(w2_ordered(:,1), w2_ordered(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    
    % 绘制分界面
    x_range = min([w1_ordered(:,1); w2_ordered(:,1)])-1 : 0.1 : max([w1_ordered(:,1); w2_ordered(:,1)])+1;
    y_range = (-w_ordered(1)*x_range - w0_ordered) / w_ordered(2);
    plot(x_range, y_range, 'k-', 'LineWidth', 2);
    
    % 绘制投影轴
    mid_point = (m1_ordered + m2_ordered) / 2;
    axis_length = 3;
    proj_axis_x = mid_point(1) + [-axis_length, axis_length] * w_ordered(1);
    proj_axis_y = mid_point(2) + [-axis_length, axis_length] * w_ordered(2);
    plot(proj_axis_x, proj_axis_y, 'g-', 'LineWidth', 2);
    
    % 绘制均值点
    plot(m1_ordered(1), m1_ordered(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
    plot(m2_ordered(1), m2_ordered(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2);
    
    % 设置图表属性
    grid on;
    axis equal;
    xlim([min([w1_ordered(:,1); w2_ordered(:,1)])-1, max([w1_ordered(:,1); w2_ordered(:,1)])+1]);
    ylim([min([w1_ordered(:,2); w2_ordered(:,2)])-1, max([w1_ordered(:,2); w2_ordered(:,2)])+1]);
    title(sprintf('样本顺序 %d', j));
    xlabel('x_1');
    ylabel('x_2');
    
    % 调整图例位置
    legend('Location', 'best');
    
    % 保存结果
    results(j).w = w_ordered;
    results(j).w0 = w0_ordered;
    results(j).m1 = m1_ordered;
    results(j).m2 = m2_ordered;
end

% 结果详情子图
subplot(2, 2, 4);
title('不同样本顺序的结果比较');
axis off;

% 显示所有样本顺序的详细结果
y_pos = 0.9;
y_step = 0.25;

for j = 1:length(sample_orders)
    % 获取当前实验结果
    w = results(j).w;
    w0 = results(j).w0;
    
    % 显示文本信息
    text(0.05, y_pos, sprintf('样本顺序 %d:', j), 'FontWeight', 'bold', 'FontSize', 10);
    text(0.05, y_pos-0.05, sprintf('  投影方向: [%.4f, %.4f]', w(1), w(2)), 'FontSize', 9);
    text(0.05, y_pos-0.10, sprintf('  分界面方程: %.4f*x1 + %.4f*x2 + %.4f = 0', w(1), w(2), w0), 'FontSize', 9);
    
    y_pos = y_pos - y_step;
end

%% 实验结果分析报告
fprintf('\nFisher判别法实验结果分析报告\n');
fprintf('=================================\n');

fprintf('\n1. 基本结果\n');
fprintf('最优投影方向: [%.4f, %.4f]\n', w(1), w(2));
fprintf('分界面方程: %.4f*x1 + %.4f*x2 + %.4f = 0\n', w(1), w(2), w0);
fprintf('类别w1均值: [%.4f, %.4f]\n', m1(1), m1(2));
fprintf('类别w2均值: [%.4f, %.4f]\n', m2(1), m2(2));

fprintf('\n2. 不同样本顺序的影响\n');
for j = 1:length(sample_orders)
    fprintf('\n  样本顺序 %d:\n', j);
    fprintf('    投影方向: [%.4f, %.4f]\n', results(j).w(1), results(j).w(2));
    fprintf('    分界面方程: %.4f*x1 + %.4f*x2 + %.4f = 0\n', ...
        results(j).w(1), results(j).w(2), results(j).w0);
    fprintf('    类别w1均值: [%.4f, %.4f]\n', results(j).m1(1), results(j).m1(2));
    fprintf('    类别w2均值: [%.4f, %.4f]\n', results(j).m2(1), results(j).m2(2));
end

fprintf('\n3. 结论\n');
fprintf('   - Fisher判别法是一种确定性算法，理论上结果不依赖于初始权向量\n');
fprintf('   - 不同样本顺序可能会导致数值计算上的微小差异，但总体分界面基本一致\n');
fprintf('   - 样本顺序对结果的影响主要体现在计算精度上，而非算法本质\n');
fprintf('   - 实验结果验证了Fisher判别法的稳定性和一致性\n');
