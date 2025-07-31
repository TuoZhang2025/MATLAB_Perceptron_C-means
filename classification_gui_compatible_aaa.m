function classification_gui_compatible
    % 创建主窗口
    fig = figure('Name', '模式识别分类器演示', ...
                'Position', [100, 100, 900, 600], ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'ToolBar', 'none');
    
    % 在基础工作区初始化共享变量
    assignin('base', 'class1', []);
    assignin('base', 'class2', []);
    assignin('base', 'selectedAlgo', 1);
    assignin('base', 'currentClass', 1);
    
    % 创建输入区域（左侧）
    inputPanel = uipanel('Parent', fig, 'Title', '样本输入', ...
                        'Position', [0.02, 0.1, 0.55, 0.85]);
    
    % 创建分类结果区域（右侧）
    resultPanel = uipanel('Parent', fig, 'Title', '分类结果', ...
                        'Position', [0.6, 0.1, 0.38, 0.85]);
    
    % 在输入区域创建坐标轴
    axInput = axes('Parent', inputPanel, 'Position', [0.02, 0.02, 0.96, 0.96], ...
                  'XLim', [-5, 5], 'YLim', [-5, 5], ...
                  'XTick', -5:1:5, 'YTick', -5:1:5, ...
                  'GridLineStyle', '--', 'GridAlpha', 0.3, ...
                  'Box', 'on', 'DataAspectRatio', [1, 1, 1]);
    hold(axInput, 'on');
    
    % 在结果区域创建坐标轴
    axResult = axes('Parent', resultPanel, 'Position', [0.05, 0.02, 0.9, 0.96], ...
                   'XTick', [], 'YTick', []);
    
    % 创建类别选择下拉菜单
    classDropdown = uicontrol('Parent', fig, 'Style', 'popupmenu', ...
                             'Position', [20, 20, 100, 22], ...
                             'String', {'类别1', '类别2'}, ...
                             'Value', 1, ...
                             'Callback', @set_selected_class);
    
    % 创建清除按钮
    clearButton = uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                           'Position', [140, 20, 80, 22], ...
                           'String', '清除样本', ...
                           'Callback', @(~,~) clear_samples(axInput));
    
    % 创建训练按钮
    trainButton = uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                          'Position', [230, 20, 80, 22], ...
                          'String', '开始训练', ...
                          'Callback', @(~,~) train_classifiers(axInput, axResult));
    
    % 创建算法选择下拉菜单
    algoDropdown = uicontrol('Parent', fig, 'Style', 'popupmenu', ...
                            'Position', [320, 20, 120, 22], ...
                            'String', {'感知器算法', 'H-K算法', 'Fisher线性判别'}, ...
                            'Value', 1, ...
                            'Callback', @set_selected_algo);
    
    % 创建测试按钮
    testButton = uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                          'Position', [450, 20, 80, 22], ...
                          'String', '测试分类', ...
                          'Callback', @(~,~) test_classifier(axInput, axResult));
    
    % 创建随机样本按钮
    randomButton = uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                           'Position', [540, 20, 100, 22], ...
                           'String', '随机生成样本', ...
                           'Callback', @(~,~) generate_random_samples(axInput, classDropdown));
    
    % 创建交互控制按钮
    panButton = uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                         'Position', [650, 20, 60, 22], ...
                         'String', '平移', ...
                         'Callback', @pan_view);
    
    zoomButton = uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                          'Position', [720, 20, 60, 22], ...
                          'String', '缩放', ...
                          'Callback', @zoom_view);
    
    resetButton = uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                           'Position', [790, 20, 60, 22], ...
                           'String', '重置', ...
                           'Callback', @reset_view);
    
    % 显示初始提示
    text(axInput, 0, 0, '点击此处添加样本点', ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'middle', ...
         'FontSize', 12, 'Color', [0.5 0.5 0.5]);
    
    % 设置鼠标点击回调函数
    set(axInput, 'ButtonDownFcn', @handle_mouse_click);
    
    % 鼠标点击处理函数
    function handle_mouse_click(~, ~)
        class1 = evalin('base', 'class1');
        class2 = evalin('base', 'class2');
        currentClass = evalin('base', 'currentClass');
        
        % 使用gca获取当前活动坐标轴
        currentAxes = gca;
        point = get(currentAxes, 'CurrentPoint');
        
        % 检查point是否为非空
        if ~isempty(point) && size(point, 1) >= 1 && size(point, 2) >= 3
            % 正确获取2D坐标 (第一行的前两个元素)
            x = point(1, 1);  % x坐标
            y = point(1, 2);  % y坐标
            
            % 检查是否在坐标轴范围内
            xlim = get(currentAxes, 'XLim');
            ylim = get(currentAxes, 'YLim');
            if x >= xlim(1) && x <= xlim(2) && y >= ylim(1) && y <= ylim(2)
                if currentClass == 1
                    class1 = [class1; x, y];
                    plot(currentAxes, x, y, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
                else
                    class2 = [class2; x, y];
                    plot(currentAxes, x, y, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
                end
                
                assignin('base', 'class1', class1);
                assignin('base', 'class2', class2);
            end
        end
    end
    
    % 平移视图函数
    function pan_view(~, ~)
        % 激活平移工具
        pan(axInput);
        
        % 添加一个鼠标点击回调，在平移结束后恢复自定义回调
        addlistener(axInput, 'ButtonDownFcn', @(~,~) reset_to_custom_callback);
    end
    
    % 缩放视图函数
    function zoom_view(~, ~)
        % 激活缩放工具
        zoom(axInput);
        
        % 添加一个鼠标点击回调，在缩放结束后恢复自定义回调
        addlistener(axInput, 'ButtonDownFcn', @(~,~) reset_to_custom_callback);
    end
    
    % 恢复自定义回调函数
    function reset_to_custom_callback(~, ~)
        % 关闭所有交互工具
        pan('off');
        zoom('off');
        
        % 恢复自定义鼠标点击回调
        set(axInput, 'ButtonDownFcn', @handle_mouse_click);
    end
    
    % 重置视图函数
    function reset_view(~, ~)
        % 关闭所有交互工具
        pan('off');
        zoom('off');
        
        % 重置坐标轴范围
        set(axInput, 'XLim', [-5, 5], 'YLim', [-5, 5]);
        
        % 恢复自定义鼠标点击回调
        set(axInput, 'ButtonDownFcn', @handle_mouse_click);
    end
    
    % 清除样本函数
    function clear_samples(src)
        cla(src);
        assignin('base', 'class1', []);
        assignin('base', 'class2', []);
        text(src, 0, 0, '点击此处添加样本点', ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', ...
             'FontSize', 12, 'Color', [0.5 0.5 0.5]);
    end
    
    % 设置选中的类别
    function set_selected_class(~, ~)
        src = gcbo;
        currentClass = get(src, 'Value');
        assignin('base', 'currentClass', currentClass);
    end
    
    % 设置选中的算法
    function set_selected_algo(~, ~)
        selectedAlgo = get(algoDropdown, 'Value');
        assignin('base', 'selectedAlgo', selectedAlgo);
        
        % 清除之前的算法结果
        cla(axInput);
        hold(axInput, 'on');
        
        % 重新绘制样本点
        class1 = evalin('base', 'class1');
        class2 = evalin('base', 'class2');
        
        if ~isempty(class1) && size(class1, 2) >= 2
            plot(axInput, class1(:,1), class1(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
        end
        
        if ~isempty(class2) && size(class2, 2) >= 2
            plot(axInput, class2(:,1), class2(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
        end
        
        % 如果没有样本，显示提示信息
        if isempty(class1) && isempty(class2)
            text(axInput, 0, 0, '点击此处添加样本点', ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', ...
                 'FontSize', 12, 'Color', [0.5 0.5 0.5]);
        end
        
        % 重新设置鼠标回调函数
        set(axInput, 'ButtonDownFcn', @handle_mouse_click);
    end
    
    % 随机生成样本函数
    function generate_random_samples(src, classDropdown)
        clear_samples(src);
        class1 = randn(15, 2) * 0.8 + [-1, -1];
        class2 = randn(15, 2) * 0.8 + [1, 1];
        plot(src, class1(:,1), class1(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
        plot(src, class2(:,1), class2(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
        assignin('base', 'class1', class1);
        assignin('base', 'class2', class2);
    end
    
    % 训练分类器函数
    function train_classifiers(srcInput, srcResult)
        class1 = evalin('base', 'class1');
        class2 = evalin('base', 'class2');
        selectedAlgo = evalin('base', 'selectedAlgo');
        
        if isempty(class1) || isempty(class2)
            errordlg('请先添加两类样本！', '错误');
            return;
        end
        
        cla(srcResult);
        
        switch selectedAlgo
            case 1 % 感知器算法
                [w, iterations] = perceptron_algorithm(class1, class2);
                plot_classification_result(srcInput, srcResult, class1, class2, w, '感知器算法');
                text(srcResult, 0.5, 0.1, sprintf('迭代次数: %d', iterations), ...
                     'HorizontalAlignment', 'center', 'Parent', srcResult, ...
                     'FontSize', 10, 'Units', 'normalized');
                
            case 2 % H-K算法
                [w, iterations] = hk_algorithm(class1, class2);
                plot_classification_result(srcInput, srcResult, class1, class2, w, 'H-K算法');
                text(srcResult, 0.5, 0.1, sprintf('迭代次数: %d', iterations), ...
                     'HorizontalAlignment', 'center', 'Parent', srcResult, ...
                     'FontSize', 10, 'Units', 'normalized');
                
            case 3 % Fisher线性判别
                [w, threshold, proj1, proj2] = fisher_algorithm(class1, class2);
                plot_fisher_result(srcInput, srcResult, class1, class2, w, threshold, proj1, proj2);
        end
    end
    
    % 测试分类器函数
    function test_classifier(srcInput, srcResult)
        class1 = evalin('base', 'class1');
        class2 = evalin('base', 'class2');
        selectedAlgo = evalin('base', 'selectedAlgo');
        
        if isempty(class1) || isempty(class2)
            errordlg('请先添加两类样本并训练分类器！', '错误');
            return;
        end
        
        dlg = figure('Position', [300, 300, 300, 200], ...
                    'Name', '测试样本', ...
                    'NumberTitle', 'off', ...
                    'MenuBar', 'none', ...
                    'ToolBar', 'none', 'Visible', 'off');
        
        uicontrol('Parent', dlg, 'Style', 'text', ...
                 'Position', [20, 140, 80, 22], 'String', 'X坐标:');
        editX = uicontrol('Parent', dlg, 'Style', 'edit', ...
                         'Position', [110, 140, 160, 22], 'Tag', 'editX');
        
        uicontrol('Parent', dlg, 'Style', 'text', ...
                 'Position', [20, 100, 80, 22], 'String', 'Y坐标:');
        editY = uicontrol('Parent', dlg, 'Style', 'edit', ...
                         'Position', [110, 100, 160, 22], 'Tag', 'editY');
        
        uicontrol('Parent', dlg, 'Style', 'pushbutton', ...
                 'Position', [50, 50, 80, 22], 'String', '分类', ...
                 'Callback', @(~,~) classify_point(editX, editY, dlg));
        
        uicontrol('Parent', dlg, 'Style', 'pushbutton', ...
                 'Position', [170, 50, 80, 22], 'String', '取消', ...
                 'Callback', @(~,~) delete(dlg));
        
        dlg.Visible = 'on';
        
        function classify_point(xEdit, yEdit, parent)
            x = str2double(get(xEdit, 'String'));
            y = str2double(get(yEdit, 'String'));
            
            if isnan(x) || isnan(y)
                errordlg('请输入有效的数值！', '错误');
                return;
            end
            
            switch selectedAlgo
                case 1 % 感知器算法
                    [w, ~] = perceptron_algorithm(class1, class2);
                    result = classify_with_perceptron([x, y], w);
                    
                case 2 % H-K算法
                    [w, ~] = hk_algorithm(class1, class2);
                    result = classify_with_perceptron([x, y], w);
                    
                case 3 % Fisher线性判别
                    [w, threshold, ~, ~] = fisher_algorithm(class1, class2);
                    result = classify_with_fisher([x, y], w, threshold);
            end
            
            % 显示分类结果
            if result == 1
                msgbox(sprintf('点 (%.2f, %.2f) 属于类别1', x, y), '分类结果');
                plot(srcInput, x, y, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
            else
                msgbox(sprintf('点 (%.2f, %.2f) 属于类别2', x, y), '分类结果');
                plot(srcInput, x, y, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
            end
            
            % 关闭对话框
            delete(parent);
        end
    end
    
    % 其余函数保持不变...
end

% 感知器算法实现
function [w, iterations] = perceptron_algorithm(class1, class2)
    % 增广特征向量
    class1_augmented = [ones(size(class1,1),1), class1];
    class2_augmented = -[ones(size(class2,1),1), class2];
    
    % 合并样本
    samples = [class1_augmented; class2_augmented];
    
    % 初始化权向量
    w = [0; 0; 0];
    
    % 设置最大迭代次数
    max_iterations = 100;
    iterations = 0;
    misclassified = true;
    
    % 感知器迭代
    while misclassified && iterations < max_iterations
        iterations = iterations + 1;
        misclassified = false;
        
        % 遍历所有样本
        for i = 1:size(samples, 1)
            x = samples(i, :)';
            
            % 如果样本被误分类
            if w' * x <= 0
                % 更新权向量
                w = w + x;
                misclassified = true;
            end
        end
    end
end

% H-K算法实现
function [w, iterations] = hk_algorithm(class1, class2)
    % 增广特征向量
    class1_augmented = [ones(size(class1,1),1), class1];
    class2_augmented = -[ones(size(class2,1),1), class2];
    
    % 合并样本
    samples = [class1_augmented; class2_augmented];
    
    % 初始化权向量
    w = [0; 0; 0];
    
    % 设置参数
    max_iterations = 100;
    iterations = 0;
    epsilon = 0.01;  % 收敛阈值
    eta = 0.1;      % 学习率
    
    % H-K算法迭代
    while iterations < max_iterations
        iterations = iterations + 1;
        error = 0;
        
        % 遍历所有样本
        for i = 1:size(samples, 1)
            x = samples(i, :)';
            
            % 如果样本被误分类
            if w' * x <= 0
                % 计算误差
                error = error + (w' * x)^2;
                
                % 更新权向量
                w = w + eta * (1 - w' * x) * x;
            end
        end
        
        % 检查收敛
        if error < epsilon
            break;
        end
    end
end

% Fisher线性判别实现
function [w, threshold, proj1, proj2] = fisher_algorithm(class1, class2)
    % 计算均值向量
    m1 = mean(class1);
    m2 = mean(class2);
    
    % 计算类内散度矩阵
    S1 = zeros(2, 2);
    S2 = zeros(2, 2);
    
    for i = 1:size(class1, 1)
        diff = (class1(i,:) - m1)';
        S1 = S1 + diff * diff';
    end
    
    for i = 1:size(class2, 1)
        diff = (class2(i,:) - m2)';
        S2 = S2 + diff * diff';
    end
    
    % 总类内散度矩阵
    Sw = S1 + S2;
    
    % 计算Fisher投影方向
    w = inv(Sw) * (m2 - m1)';
    w = w / norm(w);  % 归一化
    
    % 计算阈值（两类投影的均值中点）
    proj1 = class1 * w;
    proj2 = class2 * w;
    threshold = (mean(proj1) + mean(proj2)) / 2;
end

% 使用感知器分类
function result = classify_with_perceptron(point, w)
    % 增广特征向量
    x = [1; point'];
    
    % 计算判别函数值
    g = w' * x;
    
    % 分类决策
    if g > 0
        result = 1;  % 类别1
    else
        result = 2;  % 类别2
    end
end

% 使用Fisher分类
function result = classify_with_fisher(point, w, threshold)
    % 计算投影值
    proj = point * w;
    
    % 分类决策
    if proj < threshold
        result = 1;  % 类别1
    else
        result = 2;  % 类别2
    end
end

% 绘制分类结果
function plot_classification_result(srcInput, srcResult, class1, class2, w, titleText)
    % 在输入区域绘制决策边界
    x_range = min([class1(:,1); class2(:,1)])-1 : 0.1 : max([class1(:,1); class2(:,1)])+1;
    y_range = (-w(1) - w(2)*x_range) / w(3);
    
    % 绘制样本点和决策边界
    cla(srcInput);
    hold(srcInput, 'on');
    plot(srcInput, class1(:,1), class1(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    plot(srcInput, class2(:,1), class2(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    
    % 检查是否为垂直线
    if abs(w(3)) < 1e-10
        plot(srcInput, ones(size(y_range))*(-w(1)/w(2)), y_range, 'k-', 'LineWidth', 2);
    else
        plot(srcInput, x_range, y_range, 'k-', 'LineWidth', 2);
    end
    
    % 设置图表属性
    grid(srcInput, 'on');
    axis(srcInput, 'equal');
    xlim(srcInput, [min([class1(:,1); class2(:,1)])-1, max([class1(:,1); class2(:,1)])+1]);
    ylim(srcInput, [min([class1(:,2); class2(:,2)])-1, max([class1(:,2); class2(:,2)])+1]);
    title(srcInput, titleText);
    xlabel(srcInput, 'x_1');
    ylabel(srcInput, 'x_2');
    legend(srcInput, '类别1', '类别2', '决策边界');
    
    % 在结果区域显示信息
    text(srcResult, 0.5, 0.8, titleText, ...
         'HorizontalAlignment', 'center', 'FontSize', 14, ...
         'FontWeight', 'bold', 'Parent', srcResult, 'Units', 'normalized');
    
    text(srcResult, 0.5, 0.6, sprintf('权向量: [%.2f, %.2f, %.2f]', w(1), w(2), w(3)), ...
         'HorizontalAlignment', 'center', 'Parent', srcResult, 'Units', 'normalized');
    
    text(srcResult, 0.5, 0.5, sprintf('分界面: %.2f + %.2f*x1 + %.2f*x2 = 0', w(1), w(2), w(3)), ...
         'HorizontalAlignment', 'center', 'Parent', srcResult, 'Units', 'normalized');
end

% 绘制Fisher线性判别结果
function plot_fisher_result(srcInput, srcResult, class1, class2, w, threshold, proj1, proj2)
    cla(srcInput);
    hold(srcInput, 'on');
    
    % 绘制原始样本点
    plot(srcInput, class1(:,1), class1(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    plot(srcInput, class2(:,1), class2(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    
    % 计算均值和决策边界
    m1 = mean(class1);
    m2 = mean(class2);
    perpendicular = [-w(2); w(1)];
    scale = 5;
    mid_point = (m1 + m2) / 2;
    line_points = [mid_point' - perpendicular*scale, mid_point' + perpendicular*scale];
    
    % 绘制决策边界（黑色实线）
    plot(srcInput, line_points(1,:), line_points(2,:), 'k-', 'LineWidth', 2);
    
    % 绘制投影轴（绿色实线，过原点）
    axis_limit = max(max(abs(class1)), max(abs(class2))) * 1.5;
    proj_axis = [-axis_limit*w(1), axis_limit*w(1); -axis_limit*w(2), axis_limit*w(2)];
    plot(srcInput, proj_axis(1,:), proj_axis(2,:), 'g-', 'LineWidth', 2);
    
    % 绘制样本到投影轴的连线
    for i = 1:size(class1,1)
        proj_point = proj1(i) * w';
        plot(srcInput, [class1(i,1), proj_point(1)], [class1(i,2), proj_point(2)], 'r:', 'LineWidth', 0.8);
    end
    
    for i = 1:size(class2,1)
        proj_point = proj2(i) * w';
        plot(srcInput, [class2(i,1), proj_point(1)], [class2(i,2), proj_point(2)], 'b:', 'LineWidth', 0.8);
    end
    
    % 绘制阈值点（紫色菱形）
    threshold_point = threshold * w';
    plot(srcInput, threshold_point(1), threshold_point(2), 'md', 'MarkerSize', 10, 'MarkerFaceColor', 'm');
    text(srcInput, threshold_point(1)+0.3, threshold_point(2)+0.3, 'Threshold', ...
         'Color', 'm', 'FontSize', 10, 'Parent', srcInput);
    
    % 设置图表属性
    grid(srcInput, 'on');
    axis(srcInput, 'equal');
    xlim(srcInput, [min([class1(:,1); class2(:,1)])-1, max([class1(:,1); class2(:,1)])+1]);
    ylim(srcInput, [min([class1(:,2); class2(:,2)])-1, max([class1(:,2); class2(:,2)])+1]);
    title(srcInput, 'Fisher线性判别 (含投影连线)');
    xlabel(srcInput, 'x₁');
    ylabel(srcInput, 'x₂');
    legend(srcInput, '类别1', '类别2', '决策边界', '投影轴', 'Location', 'southeast');
    
    % 在结果区域显示信息
    cla(srcResult);
    text(srcResult, 0.5, 0.8, 'Fisher线性判别', ...
         'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold', 'Units', 'normalized');
    text(srcResult, 0.5, 0.6, sprintf('投影方向: [%.2f, %.2f]', w(1), w(2)), ...
         'HorizontalAlignment', 'center', 'Units', 'normalized');
    text(srcResult, 0.5, 0.5, sprintf('阈值: %.2f', threshold), ...
         'HorizontalAlignment', 'center', 'Units', 'normalized');
end