function GeometryCalc()
    % GEOCALCADVANCED 
    % A GUI Calculator with Shape Plotting, LaTeX Equations, and Alternative Methods.

    % --- 1. Main Window Setup ---
    fig = uifigure('Name', 'Advanced Shape Calculator', ...
        'Position', [100, 100, 900, 600], ...
        'Color', [0.95 0.95 0.95]);

    % Grid Layout for clean organization
    grid = uigridlayout(fig, [1, 2]);
    grid.ColumnWidth = {300, '1x'}; % Left panel (controls), Right panel (plots)

    % --- 2. Left Panel: Controls & Results ---
    leftPanel = uipanel(grid);
    leftPanel.Title = 'Configuration';
    leftPanel.BackgroundColor = [0.95 0.95 0.95];
    
    % Shape Selector
    uilabel(leftPanel, 'Text', 'Select Shape:', 'Position', [20, 520, 100, 22]);
    shapeDropDown = uidropdown(leftPanel, ...
        'Items', {'Circle', 'Rectangle', 'Triangle', ...
                  'Sphere', 'Cube', 'Cylinder', 'Cone'}, ...
        'Position', [20, 500, 260, 22], ...
        'ValueChangedFcn', @(src, event) updateInterface());

    % Method Selector (Initially Hidden, for alternative formulas)
    lblMethod = uilabel(leftPanel, 'Text', 'Calculation Method:', ...
        'Position', [20, 470, 150, 22], 'Visible', 'off');
    methodDropDown = uidropdown(leftPanel, ...
        'Items', {'Standard (Base/Height)', 'SAS (Side-Angle-Side)', 'SSS (Herons Formula)'}, ...
        'Position', [20, 450, 260, 22], ...
        'Visible', 'off', ...
        'ValueChangedFcn', @(src, event) updateInterface());

    % Input Fields (Dynamic)
    lbl1 = uilabel(leftPanel, 'Text', 'Input 1:', 'Position', [20, 400, 100, 22]);
    field1 = uieditfield(leftPanel, 'numeric', 'Position', [120, 400, 160, 22]);

    lbl2 = uilabel(leftPanel, 'Text', 'Input 2:', 'Position', [20, 360, 100, 22]);
    field2 = uieditfield(leftPanel, 'numeric', 'Position', [120, 360, 160, 22]);

    lbl3 = uilabel(leftPanel, 'Text', 'Input 3:', 'Position', [20, 320, 100, 22]);
    field3 = uieditfield(leftPanel, 'numeric', 'Position', [120, 320, 160, 22]);

    % Calculate Button
    uibutton(leftPanel, ...
        'Text', 'Calculate & Plot', ...
        'Position', [50, 260, 200, 40], ...
        'BackgroundColor', [0.30, 0.75, 0.93], ...
        'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(src, event) runCalculation());

    % Text Results
    uilabel(leftPanel, 'Text', 'Numeric Results:', 'Position', [20, 220, 200, 22], 'FontWeight', 'bold');
    resultArea = uitextarea(leftPanel, ...
        'Position', [20, 20, 260, 200], ...
        'Editable', 'off', 'FontSize', 13);

    % --- 3. Right Panel: Visuals ---
    rightPanel = uipanel(grid);
    rightPanel.Title = 'Visualization & Equations';
    rightPanel.BackgroundColor = 'white';

    % Axes for Shape Plot (Top 2/3)
    axPlot = uiaxes(rightPanel, ...
        'Position', [10, 200, 550, 350], ...
        'Box', 'on');
    title(axPlot, 'Shape Visualization');

    % Axes for LaTeX Equations (Bottom 1/3)
    axEq = uiaxes(rightPanel, ...
        'Position', [10, 10, 550, 180], ...
        'Visible', 'off'); % Axis lines hidden, only text shown

    % --- 4. Helper Functions ---

    % Initialize Interface
    updateInterface();

    function updateInterface()
        % Reset visibility
        lblMethod.Visible = 'off'; methodDropDown.Visible = 'off';
        lbl3.Visible = 'off'; field3.Visible = 'off';
        field1.Value = 0; field2.Value = 0; field3.Value = 0;
        
        shape = shapeDropDown.Value;
        
        switch shape
            case 'Circle'
                lbl1.Text = 'Radius (r):';
                lbl2.Visible = 'off'; field2.Visible = 'off';
            case 'Rectangle'
                lbl1.Text = 'Length (l):';
                lbl2.Text = 'Width (w):';
                lbl2.Visible = 'on'; field2.Visible = 'on';
            case 'Triangle'
                lblMethod.Visible = 'on'; methodDropDown.Visible = 'on';
                method = methodDropDown.Value;
                if strcmp(method, 'Standard (Base/Height)')
                    lbl1.Text = 'Base (b):';
                    lbl2.Text = 'Height (h):';
                    lbl2.Visible = 'on'; field2.Visible = 'on';
                elseif strcmp(method, 'SAS (Side-Angle-Side)')
                    lbl1.Text = 'Side A (a):';
                    lbl2.Text = 'Side B (b):';
                    lbl3.Text = 'Angle (deg):';
                    lbl2.Visible = 'on'; field2.Visible = 'on';
                    lbl3.Visible = 'on'; field3.Visible = 'on';
                elseif strcmp(method, 'SSS (Herons Formula)')
                    lbl1.Text = 'Side A (a):';
                    lbl2.Text = 'Side B (b):';
                    lbl3.Text = 'Side C (c):';
                    lbl2.Visible = 'on'; field2.Visible = 'on';
                    lbl3.Visible = 'on'; field3.Visible = 'on';
                end
            case 'Sphere'
                lbl1.Text = 'Radius (r):';
                lbl2.Visible = 'off'; field2.Visible = 'off';
            case 'Cube'
                lbl1.Text = 'Side (s):';
                lbl2.Visible = 'off'; field2.Visible = 'off';
            case 'Cylinder'
                lbl1.Text = 'Radius (r):';
                lbl2.Text = 'Height (h):';
                lbl2.Visible = 'on'; field2.Visible = 'on';
            case 'Cone'
                lbl1.Text = 'Radius (r):';
                lbl2.Text = 'Height (h):';
                lbl2.Visible = 'on'; field2.Visible = 'on';
        end
    end

    function runCalculation()
        shape = shapeDropDown.Value;
        v1 = field1.Value; v2 = field2.Value; v3 = field3.Value;
        
        % --- ERROR FIX: RESETTING AXES SAFELY ---
        % Instead of cla(axEq), we delete children directly to avoid conflicts
        delete(axEq.Children); 
        delete(axPlot.Children);
        
        % Instead of axis(axPlot, 'equal') and grid(axPlot, 'on')
        % We set properties directly:
        axPlot.DataAspectRatio = [1 1 1]; % Replaces axis equal
        axPlot.XGrid = 'on';
        axPlot.YGrid = 'on';
        axPlot.ZGrid = 'on';
        axPlot.Box = 'on';
        
        hold(axPlot, 'on'); 
        
        % Default to 3D view
        axPlot.View = [-37.5, 30]; 
        
        eqStr = ''; 
        resText = {};
        
        try
            switch shape
                case 'Circle'
                    area = pi*v1^2; circ = 2*pi*v1;
                    resText = {sprintf('Area: %.2f', area), sprintf('Circumference: %.2f', circ)};
                    eqStr = {'$$ Area = \pi r^2 $$', '$$ Circ = 2\pi r $$'};
                    
                    % Plot
                    t = linspace(0, 2*pi, 100);
                    fill(axPlot, v1*cos(t), v1*sin(t), 'c', 'FaceAlpha', 0.3);
                    axPlot.View = [0, 90]; % 2D View
                    
                case 'Rectangle'
                    area = v1*v2; perim = 2*(v1+v2);
                    resText = {sprintf('Area: %.2f', area), sprintf('Perimeter: %.2f', perim)};
                    eqStr = {'$$ Area = l \times w $$', '$$ Perim = 2(l + w) $$'};
                    
                    % Plot
                    rectangle(axPlot, 'Position', [0,0,v1,v2], 'FaceColor', [0.3 0.7 0.9]);
                    axPlot.View = [0, 90]; % 2D View
                    
                case 'Triangle'
                    method = methodDropDown.Value;
                    if strcmp(method, 'Standard (Base/Height)')
                        area = 0.5*v1*v2;
                        hyp = sqrt(v1^2 + v2^2); 
                        resText = {sprintf('Area: %.2f', area), sprintf('Hypotenuse (if right): %.2f', hyp)};
                        eqStr = {'$$ Area = \frac{1}{2} b h $$', '$$ (Plot assumes right \Delta) $$'};
                        patch(axPlot, [0 v1 0], [0 0 v2], 'g', 'FaceAlpha', 0.3);
                        
                    elseif strcmp(method, 'SAS (Side-Angle-Side)')
                        rads = deg2rad(v3);
                        area = 0.5 * v1 * v2 * sin(rads);
                        sideC = sqrt(v1^2 + v2^2 - 2*v1*v2*cos(rads)); 
                        resText = {sprintf('Area: %.2f', area), sprintf('Side C: %.2f', sideC)};
                        eqStr = {'$$ Area = \frac{1}{2}ab \sin(\gamma) $$', '$$ c^2 = a^2 + b^2 - 2ab \cos(\gamma) $$'};
                        x2 = v2*cos(rads); y2 = v2*sin(rads);
                        patch(axPlot, [0 v1 x2], [0 0 y2], 'y', 'FaceAlpha', 0.3);
                        
                    elseif strcmp(method, 'SSS (Herons Formula)')
                        s = (v1+v2+v3)/2;
                        area = sqrt(s*(s-v1)*(s-v2)*(s-v3));
                        if ~isreal(area) || area <= 0
                            error('Invalid Triangle Dimensions');
                        end
                        resText = {sprintf('Area: %.2f', area), sprintf('Semi-perimeter (s): %.2f', s)};
                        eqStr = {'$$ s = \frac{a+b+c}{2} $$', '$$ Area = \sqrt{s(s-a)(s-b)(s-c)} $$'};
                        alpha = acos((v2^2 + v3^2 - v1^2)/(2*v2*v3));
                        x3 = v2; y3 = 0; 
                        x1 = v3*cos(alpha); y1 = v3*sin(alpha);
                        patch(axPlot, [0 v1 x1], [0 0 y1], 'm', 'FaceAlpha', 0.3);
                    end
                    axPlot.View = [0, 90]; % 2D View
                    
                case 'Sphere'
                    vol = (4/3)*pi*v1^3; sa = 4*pi*v1^2;
                    resText = {sprintf('Volume: %.2f', vol), sprintf('Surf Area: %.2f', sa)};
                    eqStr = {'$$ V = \frac{4}{3}\pi r^3 $$', '$$ SA = 4\pi r^2 $$'};
                    [x,y,z] = sphere(30);
                    surf(axPlot, x*v1, y*v1, z*v1, 'FaceColor', 'c', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
                    light(axPlot,'Position',[-1 -1 1],'Style','infinite');
                    
                case 'Cube'
                    vol = v1^3; sa = 6*v1^2;
                    resText = {sprintf('Volume: %.2f', vol), sprintf('Surf Area: %.2f', sa)};
                    eqStr = {'$$ V = s^3 $$', '$$ SA = 6s^2 $$'};
                    vert = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
                    vert = (vert - 0.5) * v1;
                    fac = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
                    patch(axPlot, 'Vertices', vert, 'Faces', fac, 'FaceColor', 'r', 'FaceAlpha', 0.5);
                    
                case 'Cylinder'
                    vol = pi*v1^2*v2; sa = 2*pi*v1*(v1+v2);
                    resText = {sprintf('Volume: %.2f', vol), sprintf('Surf Area: %.2f', sa)};
                    eqStr = {'$$ V = \pi r^2 h $$', '$$ SA = 2\pi r(r+h) $$'};
                    [x,y,z] = cylinder(v1, 30);
                    z = z * v2;
                    surf(axPlot, x, y, z, 'FaceColor', 'b', 'FaceAlpha', 0.5);
                    
                case 'Cone'
                    vol = pi*v1^2*(v2/3); slant = sqrt(v1^2+v2^2);
                    sa = pi*v1*(v1+slant);
                    resText = {sprintf('Volume: %.2f', vol), sprintf('Surf Area: %.2f', sa)};
                    eqStr = {'$$ V = \frac{1}{3} \pi r^2 h $$', '$$ SA = \pi r(r + \sqrt{h^2+r^2}) $$'};
                    [x,y,z] = cylinder([0 v1], 30);
                    z = z * v2; 
                    z = -z + v2;
                    surf(axPlot, x, y, z, 'FaceColor', 'm', 'FaceAlpha', 0.5);
            end
            
            % Render Equations
            text(axEq, 0.5, 0.5, eqStr, ...
                'Interpreter', 'latex', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 18);
            
            resultArea.Value = resText;
            
        catch ME
            resultArea.Value = {'Error calculating:', ME.message};
        end
    end
end