function GeometryCalc
    % 1. MAIN UI SETUP
    fig = uifigure('Name', 'Geometric Shape Calculator', ...
        'Position', [100, 100, 1000, 650], 'Color', [0.95 0.95 0.95]);

    gridMain = uigridlayout(fig, [1, 2]);
    gridMain.ColumnWidth = {'1.2x', '2x'}; 

    % LEFT PANEL
    leftPanel = uipanel(gridMain, 'Title', 'Configuration', 'BackgroundColor', 'white');
    leftLayout = uigridlayout(leftPanel, [11, 1]); 
    leftLayout.RowHeight = {30, 30, 30, 30, 30, 30, 'fit', 'fit', 25, '1x', 30};

    % a) Theme
    themeGrid = uigridlayout(leftLayout, [1, 2]);
    themeGrid.ColumnWidth = {'fit', 'fit'}; themeGrid.Padding = [0 0 0 0];
    lblTheme = uilabel(themeGrid, 'Text', 'Dark Mode:', 'FontWeight', 'bold');
    swTheme = uiswitch(themeGrid, 'Items', {'Off', 'On'}, 'ValueChangedFcn', @toggleTheme);

    % b) Selectors
    lblDim = uilabel(leftLayout, 'Text', 'Dimension:', 'FontWeight', 'bold');
    ddDim = uidropdown(leftLayout, 'Items', {'2D Shapes', '3D Shapes'}, 'ValueChangedFcn', @updateShapeList);

    lblShape = uilabel(leftLayout, 'Text', 'Select Shape:', 'FontWeight', 'bold');
    ddShape = uidropdown(leftLayout, 'Items', {}, 'ValueChangedFcn', @updateMethodList);

    lblMethod = uilabel(leftLayout, 'Text', 'Calculation Method:', 'FontWeight', 'bold');
    ddMethod = uidropdown(leftLayout, 'Items', {'Standard'}, 'ValueChangedFcn', @updateInputs);

    % c) Inputs
    inputPanel = uipanel(leftLayout, 'Title', 'Parameters', 'BackgroundColor', 'white');
    inputGrid = uigridlayout(inputPanel, [4, 2]);
    inputGrid.RowHeight = {30, 30, 30, 30};
    
    inputs = struct('lbl', cell(1,4), 'field', cell(1,4));
    
    for i = 1:4
        inputs(i).lbl = uilabel(inputGrid, 'Text', sprintf('Input %d:', i), 'Visible', 'off');
        if i == 1
            inputs(i).field = uieditfield(inputGrid, 'text', 'Visible', 'off');
        else
            inputs(i).field = uieditfield(inputGrid, 'numeric', 'Visible', 'off');
        end
    end

    % d) Equations
    lblEqTitle = uilabel(leftLayout, 'Text', 'Equations Used:', 'FontWeight', 'bold');
    axEq = uiaxes(leftLayout);
    axEq.BackgroundColor = [0.95 0.95 0.95];
    axEq.XColor = 'none'; axEq.YColor = 'none'; axEq.ZColor = 'none';
    axEq.XTick = []; axEq.YTick = []; axEq.Box = 'off'; axEq.Interactions = [];

    % e) Buttons
    uibutton(leftLayout, 'Text', 'CALCULATE', ...
        'BackgroundColor', [0 0.447 0.741], 'FontColor', 'white', ...
        'FontWeight', 'bold', 'ButtonPushedFcn', @calculateResult);

    % f) Results
    txtResult = uitextarea(leftLayout, 'Editable', 'off', ...
        'Value', {'Results will appear here.'}, 'FontName', 'Courier New');
    lblStatus = uilabel(leftLayout, 'Text', 'Ready', 'FontColor', 'black');

    % RIGHT PANEL
    rightPanel = uipanel(gridMain, 'Title', 'Visualization', 'BackgroundColor', 'white');
    rightLayout = uigridlayout(rightPanel, [3, 3]);
    rightLayout.RowHeight = {'1x', 400, '1x'};
    rightLayout.ColumnWidth = {'1x', 400, '1x'};
    rightLayout.Padding = [0 0 0 0];
    
    ax = uiaxes(rightLayout);
    ax.Layout.Row = 2; ax.Layout.Column = 2;
    ax.NextPlot = 'add'; ax.Interactions = []; ax.Toolbar.Visible = 'off';

    % 2. INITIALIZATION
    updateShapeList(ddDim, []);
    toggleTheme(swTheme, []); 

    % 3. LOGIC
    function toggleTheme(~, ~)
        isDark = strcmp(swTheme.Value, 'On');
        if isDark
            colors = struct('main', [0.12 0.12 0.12], 'panel', [0.18 0.18 0.18], ...
                'text', [0.9 0.9 0.9], 'input', [0.25 0.25 0.25], 'ax', [0.2 0.2 0.2], ...
                'grid', [0.4 0.4 0.4], 'eq', [0.18 0.18 0.18]);
        else
            colors = struct('main', [0.95 0.95 0.95], 'panel', [1 1 1], ...
                'text', [0 0 0], 'input', [1 1 1], 'ax', [1 1 1], ...
                'grid', [0.15 0.15 0.15], 'eq', [1 1 1]);
        end

        fig.Color = colors.main;
        leftPanel.BackgroundColor = colors.panel; leftPanel.ForegroundColor = colors.text;
        rightPanel.BackgroundColor = colors.panel; rightPanel.ForegroundColor = colors.text;
        inputPanel.BackgroundColor = colors.panel; inputPanel.ForegroundColor = colors.text;

        labels = [lblTheme, lblDim, lblShape, lblMethod, lblEqTitle, lblStatus];
        for k = 1:length(labels), labels(k).FontColor = colors.text; end
        for k = 1:4, inputs(k).lbl.FontColor = colors.text; end

        txtResult.BackgroundColor = colors.input; txtResult.FontColor = colors.text;
        axEq.BackgroundColor = colors.eq;
        
        for k = 1:4, inputs(k).field.BackgroundColor = colors.input; inputs(k).field.FontColor = colors.text; end
        
        ddDim.BackgroundColor = colors.input; ddDim.FontColor = colors.text;
        ddShape.BackgroundColor = colors.input; ddShape.FontColor = colors.text;
        ddMethod.BackgroundColor = colors.input; ddMethod.FontColor = colors.text;

        ax.BackgroundColor = colors.ax; ax.XColor = colors.text; ax.YColor = colors.text; ax.ZColor = colors.text;
        ax.GridColor = colors.grid;
        
        updateInputs(ddMethod, []);
    end

    function updateShapeList(~, ~)
        if strcmp(ddDim.Value, '2D Shapes')
            ddShape.Items = {'Circle', 'Circular Sector', 'Square', 'Rectangle', ...
                'Parallelogram', 'Rhombus', 'Triangle', 'Regular Polygon', ...
                'Ellipse', 'Parabola', 'Hyperbola', 'Area Under Curve'};
        else
            ddShape.Items = {'Cube', 'Cuboid', 'Sphere', 'Cone', 'Cylinder', 'Pyramid', 'Prism'};
        end
        updateMethodList(ddShape, []);
    end

    function updateMethodList(~, ~)
        shape = ddShape.Value;
        ddMethod.Items = {'Standard'}; ddMethod.Visible = 'off'; lblMethod.Visible = 'off';
        if strcmp(shape, 'Triangle')
            ddMethod.Items = {'Base & Height', 'Heron''s Formula (SSS)', 'SAS (Side-Angle-Side)'};
            ddMethod.Visible = 'on'; lblMethod.Visible = 'on';
        end
        updateInputs(ddMethod, []);
    end

    function renderEquation(latexStr)
        cla(axEq); 
        if strcmp(swTheme.Value, 'On'), col = 'white'; else, col = 'black'; end
        text(axEq, 0.5, 0.5, latexStr, 'Interpreter', 'latex', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', 13, 'Color', col); 
    end

    function updateInputs(~, ~)
        for k=1:4 
            inputs(k).lbl.Visible='off'; 
            inputs(k).field.Visible='off'; 
        end
        
        shape = ddShape.Value; method = ddMethod.Value; 

        switch shape
            % 2D
            case 'Circle'
                setupNumericInput(1, 'Radius (r)'); 
                latexStr = '$$ \begin{array}{c} A = \pi r^2 \\ C = 2 \pi r \end{array} $$';
            case 'Circular Sector'
                setupNumericInput(1, 'Radius (r)'); setupNumericInput(2, 'Angle (deg)'); 
                latexStr = '$$ \begin{array}{c} A = \frac{1}{2} r^2 \theta_{rad} \\ L = r \theta_{rad} \end{array} $$';
            case 'Square'
                setupNumericInput(1, 'Side (a)'); 
                latexStr = '$$ \begin{array}{c} A = a^2 \\ P = 4a \end{array} $$';
            case 'Rectangle'
                setupNumericInput(1, 'Width (w)'); setupNumericInput(2, 'Height (h)'); 
                latexStr = '$$ \begin{array}{c} A = w h \\ P = 2(w+h) \end{array} $$';
            case 'Parallelogram'
                setupNumericInput(1, 'Side A'); setupNumericInput(2, 'Side B'); setupNumericInput(3, 'Angle (deg)');
                latexStr = '$$ \begin{array}{c} A = a \cdot b \cdot \sin(\theta) \\ P = 2(a+b) \end{array} $$';
            case 'Rhombus'
                setupNumericInput(1, 'Diagonal p'); setupNumericInput(2, 'Diagonal q'); 
                latexStr = '$$ \begin{array}{c} A = \frac{p q}{2} \\ P = 2\sqrt{p^2+q^2} \end{array} $$';
            case 'Regular Polygon'
                setupNumericInput(1, 'No. Sides (n)'); setupNumericInput(2, 'Side Length (s)'); 
                latexStr = '$$ \begin{array}{c} A = \frac{n s^2}{4 \tan(\pi/n)} \\ P = n \cdot s \end{array} $$';
            case 'Ellipse'
                setupNumericInput(1, 'Center X (x0)'); setupNumericInput(2, 'Center Y (y0)'); 
                setupNumericInput(3, 'Semi-Major (a)'); setupNumericInput(4, 'Semi-Minor (b)');
                latexStr = '$$ \begin{array}{c} \frac{(x-x_0)^2}{a^2} + \frac{(y-y_0)^2}{b^2} = 1 \\ P \approx \pi(a+b)(1+\frac{3h}{10+\sqrt{4-3h}}) \end{array} $$';
            case 'Hyperbola'
                setupNumericInput(1, 'Center X (x0)'); setupNumericInput(2, 'Center Y (y0)'); 
                setupNumericInput(3, 'Semi-Major (a)'); setupNumericInput(4, 'Semi-Minor (b)');
                latexStr = '$$ \frac{(x-x_0)^2}{a^2} - \frac{(y-y_0)^2}{b^2} = 1 $$';
            case 'Parabola'
                setupNumericInput(1, 'Vertex X (x0)'); setupNumericInput(2, 'Vertex Y (y0)'); 
                setupNumericInput(3, 'Param (p)');
                latexStr = '$$ (x-x_0)^2 = 2p(y-y_0) $$';
            case 'Triangle'
                if strcmp(method, 'Base & Height')
                    setupNumericInput(1, 'Base (b)'); setupNumericInput(2, 'Height (h)'); 
                    latexStr = '$$ A = \frac{1}{2} b h $$';
                elseif strcmp(method, 'Heron''s Formula (SSS)')
                    setupNumericInput(1, 'Side A'); setupNumericInput(2, 'Side B'); setupNumericInput(3, 'Side C'); 
                    latexStr = '$$ \begin{array}{c} A = \sqrt{s(s-a)(s-b)(s-c)} \\ P = a+b+c \end{array} $$';
                elseif strcmp(method, 'SAS (Side-Angle-Side)')
                    setupNumericInput(1, 'Side A'); setupNumericInput(2, 'Side B'); setupNumericInput(3, 'Angle (deg)'); 
                    latexStr = '$$ \begin{array}{c} A = \frac{1}{2} a b \sin(\theta) \\ c^2 = a^2+b^2-2ab\cos\theta \\ P = a+b+c \end{array} $$';
                end
            case 'Area Under Curve'
                setupTextInput(1, 'f(x) (e.g. x.^2)'); 
                setupNumericInput(2, 'Start X (a)'); 
                setupNumericInput(3, 'End X (b)');
                latexStr = '$$ \begin{array}{c} A = \int_{a}^{b} f(x) dx \\ L = \int_{a}^{b} \sqrt{1+[f''(x)]^2} dx \end{array} $$';

            % 3D
            case 'Cube'
                setupNumericInput(1, 'Side (a)'); 
                latexStr = '$$ \begin{array}{c} V = a^3 \\ S = 6a^2 \end{array} $$';
            case 'Cuboid'
                setupNumericInput(1, 'Length (l)'); setupNumericInput(2, 'Width (w)'); setupNumericInput(3, 'Height (h)');
                latexStr = '$$ \begin{array}{c} V = l w h \\ S = 2(lw + lh + wh) \end{array} $$';
            case 'Sphere'
                setupNumericInput(1, 'Radius (r)'); 
                latexStr = '$$ \begin{array}{c} V = \frac{4}{3} \pi r^3 \\ S = 4 \pi r^2 \end{array} $$';
            case 'Cone'
                setupNumericInput(1, 'Radius (r)'); setupNumericInput(2, 'Height (h)'); 
                latexStr = '$$ \begin{array}{c} V = \frac{1}{3} \pi r^2 h \\ S = \pi r (r + \sqrt{h^2+r^2}) \end{array} $$';
            case 'Cylinder'
                setupNumericInput(1, 'Radius (r)'); setupNumericInput(2, 'Height (h)'); 
                latexStr = '$$ \begin{array}{c} V = \pi r^2 h \\ S = 2\pi r(r+h) \end{array} $$';
            case 'Pyramid'
                setupNumericInput(1, 'No. Sides (n)'); setupNumericInput(2, 'Side Len (s)'); setupNumericInput(3, 'Height (h)'); 
                latexStr = '$$ \begin{array}{c} V = \frac{1}{3} B h \\ S = B + \frac{1}{2} P \ell \end{array} $$';
            case 'Prism'
                setupNumericInput(1, 'No. Sides (n)'); setupNumericInput(2, 'Side Len (s)'); setupNumericInput(3, 'Height (h)'); 
                latexStr = '$$ \begin{array}{c} V = B h \\ S = 2B + P h \end{array} $$';
            otherwise
                latexStr = '';
        end
        renderEquation(latexStr);
    end

    function setupNumericInput(idx, label)
        inputs(idx).lbl.Text = label; inputs(idx).lbl.Visible = 'on'; 
        inputs(idx).field.Visible = 'on'; 
        if idx == 1
            inputs(idx).field.Value = '0'; 
        else
            inputs(idx).field.Value = 0;
        end
    end

    function setupTextInput(idx, label)
        inputs(idx).lbl.Text = label; inputs(idx).lbl.Visible = 'on'; 
        inputs(idx).field.Visible = 'on';
        inputs(idx).field.Value = ''; 
    end

    function calculateResult(~, ~)
        try
            lblStatus.Text = 'Calculating...';
            shape = ddShape.Value; method = ddMethod.Value;
            
            % SAFE INPUT EXTRACTION
            v1_raw = inputs(1).field.Value;

            v1_num = 0; funcStr = '';
            
            if strcmp(shape, 'Area Under Curve')
                funcStr = v1_raw;
            else
                v1_num = str2double(v1_raw);
                if isnan(v1_num), error('Input 1 must be a valid number.'); end
            end
            
            v2 = inputs(2).field.Value; 
            v3 = inputs(3).field.Value; 
            v4 = inputs(4).field.Value;
            
            % Negativity check
            isCoordOrFunc = ismember(shape, {'Ellipse', 'Hyperbola', 'Parabola', 'Area Under Curve'});
            if ~isCoordOrFunc
                if (v1_num < 0 || v2 < 0 || v3 < 0), error('Dimensions cannot be negative.'); end
            end
            
            resStr = {};
            cla(ax); ax.NextPlot = 'add'; ax.XGrid = 'on'; ax.YGrid = 'on'; ax.DataAspectRatio = [1 1 1];
            ax.Interactions = []; view(ax, 2);

            switch shape
                % 2D
                case 'Circle'
                    if v1_num<=0, error('Radius > 0'); end
                    A = pi*v1_num^2; C = 2*pi*v1_num; resStr = {sprintf('Area: %.4f', A), sprintf('Circum.: %.4f', C)};
                    t = linspace(0, 2*pi, 100); fill(ax, v1_num*cos(t), v1_num*sin(t), 'c', 'FaceAlpha', 0.4);
                case 'Circular Sector'
                    A = 0.5*v1_num^2*deg2rad(v2); L = v1_num*deg2rad(v2); resStr = {sprintf('Area: %.4f', A), sprintf('Arc Len: %.4f', L)};
                    t = linspace(0, deg2rad(v2), 50); fill(ax, [0, v1_num*cos(t), 0], [0, v1_num*sin(t), 0], 'c', 'FaceAlpha', 0.4);
                case 'Square'
                    A = v1_num^2; P = 4*v1_num; resStr = {sprintf('Area: %.4f', A), sprintf('Perim.: %.4f', P)};
                    fill(ax, [0, v1_num, v1_num, 0], [0, 0, v1_num, v1_num], 'g', 'FaceAlpha', 0.4);
                case 'Rectangle'
                    A = v1_num*v2; P = 2*(v1_num+v2); resStr = {sprintf('Area: %.4f', A), sprintf('Perim.: %.4f', P)};
                    fill(ax, [0, v1_num, v1_num, 0], [0, 0, v2, v2], 'g', 'FaceAlpha', 0.4);
                case 'Parallelogram'
                    if v3 <= 0 || v3 >= 180, error('Angle must be between 0 and 180.'); end
                    A = v1_num * v2 * sind(v3); P = 2 * (v1_num + v2);
                    resStr = {sprintf('Area: %.4f', A), sprintf('Perim.: %.4f', P)};
                    x = [0, v1_num, v1_num + v2*cosd(v3), v2*cosd(v3)]; y = [0, 0, v2*sind(v3), v2*sind(v3)];
                    fill(ax, x, y, 'y', 'FaceAlpha', 0.4);
                case 'Rhombus'
                    A = (v1_num*v2)/2; P = 2*sqrt(v1_num^2 + v2^2);
                    resStr = {sprintf('Area: %.4f', A), sprintf('Perim.: %.4f', P)};
                    fill(ax, [0, v1_num/2, 0, -v1_num/2], [v2/2, 0, -v2/2, 0], 'm', 'FaceAlpha', 0.4);
                case 'Regular Polygon'
                    A = (v1_num*v2^2)/(4*tan(pi/v1_num)); P = v1_num * v2; 
                    resStr = {sprintf('Area: %.4f', A), sprintf('Perim.: %.4f', P)};
                    theta = linspace(0, 2*pi, v1_num+1); r = v2/(2*sin(pi/v1_num)); 
                    fill(ax, r*cos(theta), r*sin(theta), 'r', 'FaceAlpha', 0.4);
                case 'Ellipse'
                    if v3<=0 || v4<=0, error('a and b must be > 0'); end
                    A = pi*v3*v4;
                    h_val = ((v3 - v4)^2) / ((v3 + v4)^2);
                    Circum = pi * (v3 + v4) * (1 + (3 * h_val) / (10 + sqrt(4 - 3 * h_val)));
                    resStr = {sprintf('Center: (%.2f, %.2f)', v1_num, v2), sprintf('Area: %.4f', A), sprintf('Circum.~: %.4f', Circum)};
                    t = linspace(0, 2*pi, 100); X = v1_num + v3*cos(t); Y = v2 + v4*sin(t);
                    fill(ax, X, Y, [0.8 0.8 1], 'EdgeColor', 'b', 'FaceAlpha', 0.4);
                    plot(ax, v1_num, v2, 'k+', 'MarkerSize', 10); 
                case 'Hyperbola'
                    if v3<=0 || v4<=0, error('a and b must be > 0'); end
                    c = sqrt(v3^2+v4^2);
                    resStr = {sprintf('Center: (%.2f, %.2f)', v1_num, v2), sprintf('Foci dist (c): %.2f', c)};
                    t = linspace(-2, 2, 50);
                    X1 = v1_num + v3*cosh(t); Y1 = v2 + v4*sinh(t);
                    X2 = v1_num - v3*cosh(t); Y2 = v2 + v4*sinh(t);
                    plot(ax, X1, Y1, 'b', 'LineWidth', 2); plot(ax, X2, Y2, 'b', 'LineWidth', 2);
                    plot(ax, v1_num, v2, 'k+', 'MarkerSize', 10); 
                case 'Parabola'
                    if v3==0, error('p cannot be 0'); end
                    focusY = v2 + v3/2; 
                    resStr = {sprintf('Vertex: (%.2f, %.2f)', v1_num, v2), sprintf('Focus Y: %.2f', focusY)};
                    x = linspace(v1_num-10, v1_num+10, 100); y = v2 + ((x - v1_num).^2) / (2*v3);
                    plot(ax, x, y, 'b', 'LineWidth', 2); plot(ax, v1_num, v2, 'ro', 'MarkerFaceColor', 'r'); plot(ax, v1_num, focusY, 'kx');
                case 'Triangle'
                    if strcmp(method, 'Base & Height')
                        A = 0.5*v1_num*v2; resStr = {sprintf('Area: %.4f', A)};
                        fill(ax, [0, v1_num, 0], [0, 0, v2], 'g', 'FaceAlpha', 0.4);
                    elseif strcmp(method, 'Heron''s Formula (SSS)')
                        s = (v1_num+v2+v3)/2; A = sqrt(s*(s-v1_num)*(s-v2)*(s-v3)); P = v1_num + v2 + v3;
                        resStr = {sprintf('Area: %.4f', A), sprintf('Perim.: %.4f', P)};
                        text(ax, 0.5, 0.5, 'SSS Triangle', 'HorizontalAlignment','center', 'Color', ax.XColor);
                    elseif strcmp(method, 'SAS (Side-Angle-Side)')
                        A = 0.5*v1_num*v2*sind(v3); sideC = sqrt(v1_num^2 + v2^2 - 2*v1_num*v2*cosd(v3)); P = v1_num + v2 + sideC;
                        resStr = {sprintf('Area: %.4f', A), sprintf('Perim.: %.4f', P)};
                        fill(ax, [0, v1_num, v2*cosd(v3)], [0, 0, v2*sind(v3)], 'g', 'FaceAlpha', 0.4);
                    end
                
                case 'Area Under Curve'
                    f = str2func(['@(x)' funcStr]); 
                    
                    % a) Calculate Area
                    areaVal = integral(f, v2, v3);
                    
                    % b) Calculate Arc Length (Numerical Derivative)
                    h_step = 1e-6; 
                    deriv = @(x) (f(x + h_step) - f(x - h_step)) ./ (2 * h_step);
                    arcLenFunc = @(x) sqrt(1 + deriv(x).^2);
                    lenVal = integral(arcLenFunc, v2, v3, 'ArrayValued', true);
                    
                    resStr = {sprintf('Area: %.4f', areaVal), sprintf('Length: %.4f', lenVal)};
                    
                    x_plot = linspace(v2, v3, 100); y_plot = f(x_plot);
                    x_fill = [v2, x_plot, v3]; y_fill = [0, y_plot, 0];
                    fill(ax, x_fill, y_fill, 'c', 'FaceAlpha', 0.4, 'EdgeColor', 'b');
                    x_full = linspace(v2 - (v3-v2)*0.5, v3 + (v3-v2)*0.5, 150);
                    plot(ax, x_full, f(x_full), 'b--', 'LineWidth', 1);
                    plot(ax, x_plot, y_plot, 'b', 'LineWidth', 2);
                    ax.DataAspectRatioMode = 'auto';

                % 3D
                case 'Cube'
                    V = v1_num^3; SA = 6*v1_num^2; resStr = {sprintf('Vol: %.4f', V), sprintf('SA: %.4f', SA)};
                    view(ax, 3);
                    vert = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1]*v1_num;
                    fac = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
                    patch(ax, 'Vertices', vert, 'Faces', fac, 'FaceColor', 'c', 'FaceAlpha', 0.4);
                case 'Cuboid'
                    V = v1_num*v2*v3; SA = 2*(v1_num*v2 + v1_num*v3 + v2*v3);
                    resStr = {sprintf('Vol: %.4f', V), sprintf('SA: %.4f', SA)};
                    view(ax, 3);
                    vert = [0 0 0; v1_num 0 0; v1_num v2 0; 0 v2 0; 0 0 v3; v1_num 0 v3; v1_num v2 v3; 0 v2 v3];
                    fac = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
                    patch(ax, 'Vertices', vert, 'Faces', fac, 'FaceColor', 'b', 'FaceAlpha', 0.4);
                case 'Sphere'
                    V = (4/3)*pi*v1_num^3; SA = 4*pi*v1_num^2; resStr = {sprintf('Vol: %.4f', V), sprintf('SA: %.4f', SA)};
                    view(ax, 3); [x,y,z] = sphere; surf(ax, x*v1_num, y*v1_num, z*v1_num, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'FaceColor', 'interp');
                case 'Cone'
                    V = pi*v1_num^2*v2/3; slant = sqrt(v1_num^2 + v2^2); SA = pi*v1_num*(v1_num+slant);
                    resStr = {sprintf('Vol: %.4f', V), sprintf('SA: %.4f', SA)};
                    view(ax, 3); [x,y,z] = cylinder([v1_num, 0]); z = z*v2; surf(ax, x, y, z, 'FaceColor', 'm', 'FaceAlpha', 0.4);
                case 'Cylinder'
                    V = pi*v1_num^2*v2; SA = 2*pi*v1_num*(v1_num+v2); resStr = {sprintf('Vol: %.4f', V), sprintf('SA: %.4f', SA)};
                    view(ax, 3); [x,y,z] = cylinder(v1_num); z = z*v2; surf(ax, x, y, z, 'FaceColor', 'b', 'FaceAlpha', 0.4);
                case 'Pyramid'
                    if v1_num < 3, error('Polygon must have at least 3 sides.'); end
                    BaseArea = (v1_num * v2^2) / (4 * tan(pi/v1_num));
                    Vol = (BaseArea * v3) / 3;
                    ap_base = v2 / (2 * tan(pi/v1_num)); SlantHeight = sqrt(v3^2 + ap_base^2);
                    SurfaceArea = BaseArea + (0.5 * (v1_num * v2) * SlantHeight);
                    resStr = {sprintf('Vol: %.4f', Vol), sprintf('SA: %.4f', SurfaceArea)};
                    view(ax, 3);
                    R = v2 / (2*sin(pi/v1_num)); theta = linspace(0, 2*pi, v1_num+1); theta(end) = [];
                    x_base = R * cos(theta); y_base = R * sin(theta);
                    verts = [x_base', y_base', zeros(v1_num,1); 0, 0, v3];
                    faces = zeros(v1_num + 1, v1_num); faces(1, 1:v1_num) = 1:v1_num;
                    for k = 1:v1_num, faces(k+1, 1:3) = [k, mod(k, v1_num) + 1, v1_num + 1]; faces(k+1, 4:end) = NaN; end
                    patch(ax, 'Vertices', verts, 'Faces', faces, 'FaceColor', 'y', 'FaceAlpha', 0.4);

                case 'Prism'
                    if v1_num < 3, error('Polygon must have at least 3 sides.'); end
                    BaseArea = (v1_num * v2^2) / (4 * tan(pi/v1_num));
                    Vol = BaseArea * v3;
                    SurfaceArea = 2*BaseArea + (v1_num*v2*v3);
                    resStr = {sprintf('Vol: %.4f', Vol), sprintf('SA: %.4f', SurfaceArea)};
                    view(ax, 3);
                    R = v2 / (2*sin(pi/v1_num)); theta = linspace(0, 2*pi, v1_num+1); theta(end) = [];
                    x = R * cos(theta)'; y = R * sin(theta)';
                    verts = [x, y, zeros(v1_num,1); x, y, ones(v1_num,1)*v3];
                    faces = []; faces(1, :) = 1:v1_num; faces(2, :) = (v1_num+1):(2*v1_num);
                    for k = 1:v1_num, faces(k+2, :) = [k, mod(k, v1_num) + 1, mod(k, v1_num) + 1 + v1_num, k + v1_num, NaN(1, v1_num-4)]; end
                    patch(ax, 'Vertices', verts, 'Faces', faces, 'FaceColor', 'm', 'FaceAlpha', 0.4);
            end
            
            txtResult.Value = resStr;
            lblStatus.Text = 'Calculation Successful'; lblStatus.FontColor = 'green';
            
        catch ME
            lblStatus.Text = 'Error'; lblStatus.FontColor = 'red'; txtResult.Value = {ME.message};
        end
    end
end