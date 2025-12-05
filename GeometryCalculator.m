function GeometryCalculator
    % Geometry Calculator GUI (2D & 3D shapes + conics + curve area)
    
    %% MAIN WINDOW
    fig = uifigure('Name','Geometric Calculator','Position',[300 150 600 500]);
    
    % Dropdown for category
    uilabel(fig,'Text','Select Category:','Position',[20 450 200 22]);
    categoryMenu = uidropdown(fig,'Items',{'2D Shapes','3D Shapes','Conic Sections','Area Under Curve'},...
        'Position',[20 420 200 30],'Value','2D Shapes','ValueChangedFcn',@updateShapeMenu);
    
    % Dropdown for shape
    uilabel(fig,'Text','Select Shape:','Position',[250 450 200 22]);
    shapeMenu = uidropdown(fig,'Position',[250 420 200 30],'ValueChangedFcn', @updateInputs);
    
    % Panel for input fields
    inputPanel = uipanel(fig,'Title','Inputs','Position',[20 200 560 200]);
    
    % Output
    outputArea = uitextarea(fig,'Position',[20 20 560 160],'Editable','off','FontSize',12);
    
    % Compute button
    uibutton(fig,'Text','Compute','Position',[470 420 100 30],'ButtonPushedFcn',@computePressed);

    %% Initialize shape menu
    updateShapeMenu();
    
    %% FUNCTIONS ----------------------------------------------------------
    
    function updateShapeMenu(~,~)
        cat = categoryMenu.Value;
        switch cat
            case '2D Shapes'
                shapeMenu.Items = {'Square','Rectangle','Circle','Triangle','Trapezoid','Ellipse (2D)'};
            case '3D Shapes'
                shapeMenu.Items = {'Cube','Cuboid','Sphere','Cylinder','Cone'};
            case 'Conic Sections'
                shapeMenu.Items = {'Parabola','Ellipse (Conic)','Hyperbola'};
            case 'Area Under Curve'
                shapeMenu.Items = {'Definite Integral'};
        end
        updateInputs();
    end

    function updateInputs(~,~)
        delete(inputPanel.Children); 
        shape = shapeMenu.Value;
        switch shape
            
            %% 2D SHAPES ----------------------------------------------
            case 'Ellipse (2D)'
                addInput('Semi-major (a)');
                addInput('Semi-minor (b)');
                
            case 'Square'
                addInput('Side (a)');
            case 'Rectangle'
                addInput('Length (L)');
                addInput('Width (W)');
            case 'Circle'
                addInput('Radius (r)');
            case 'Triangle'
                addInput('Base (b)');
                addInput('Height (h)');
            case 'Trapezoid'
                addInput('Base1 (b1)');
                addInput('Base2 (b2)');
                addInput('Height (h)');

            %% 3D SHAPES ----------------------------------------------
            case 'Cube'
                addInput('Side (a)');
            case 'Cuboid'
                addInput('Length (L)');
                addInput('Width (W)');
                addInput('Height (H)');
            case 'Sphere'
                addInput('Radius (r)');
            case 'Cylinder'
                addInput('Radius (r)');
                addInput('Height (h)');
            case 'Cone'
                addInput('Radius (r)');
                addInput('Height (h)');

            %% CONIC SECTIONS -----------------------------------------
            case 'Ellipse (Conic)'
                addInput('Semi-major (a)');
                addInput('Semi-minor (b)');
            case 'Parabola'
                addInput('Parameter p');
            case 'Hyperbola'
                addInput('a');
                addInput('b');

            %% AREA UNDER CURVE --------------------------------------
            case 'Definite Integral'
                addInput('Function f(x)');
                addInput('Lower bound a');
                addInput('Upper bound b');
        end
    end

    function addInput(label)
        N = length(inputPanel.Children)/2;
        y = 150 - 40*N;
        uilabel(inputPanel,'Text',label,'Position',[20 y 200 22]);
        uieditfield(inputPanel,'text','Position',[220 y 200 22]);
    end

    function computePressed(~,~)
        fields = inputPanel.Children;
        labels = fields(arrayfun(@(x) isa(x,'matlab.ui.control.Label'),fields));
        edits  = fields(arrayfun(@(x) isa(x,'matlab.ui.control.EditField'),fields));
        
        labels = flip(labels);
        edits = flip(edits);

        % extract numeric inputs
        inputs = containers.Map;
        for i = 1:length(labels)
            name = labels(i).Text;
            raw = edits(i).Value;
            val = str2num(raw); %#ok<ST2NM>
            inputs(name) = val;
        end
        
        shape = shapeMenu.Value;
        out = "";
        
        try
            switch shape
                
                %% 2D -----------------------------------------------------
                case 'Square'
                    a = inputs('Side (a)');
                    out = sprintf("Area = %.4f\nPerimeter = %.4f", a^2, 4*a);

                case 'Rectangle'
                    L = inputs('Length (L)'); W = inputs('Width (W)');
                    out = sprintf("Area = %.4f\nPerimeter = %.4f", L*W, 2*(L+W));

                case 'Circle'
                    r = inputs('Radius (r)');
                    out = sprintf("Area = %.4f\nCircumference = %.4f", pi*r^2, 2*pi*r);

                case 'Triangle'
                    b = inputs('Base (b)'); h = inputs('Height (h)');
                    out = sprintf("Area = %.4f", 0.5*b*h);

                case 'Trapezoid'
                    b1 = inputs('Base1 (b1)'); b2 = inputs('Base2 (b2)'); h = inputs('Height (h)');
                    out = sprintf("Area = %.4f", 0.5*(b1+b2)*h);

                case 'Ellipse (2D)'
                    a = inputs('Semi-major (a)'); b = inputs('Semi-minor (b)');
                    out = sprintf("Area = %.4f\nApprox Circumference = %.4f", ...
                        pi*a*b, pi*(3*(a+b)-sqrt((3*a+b)*(a+3*b))));

                %% 3D -----------------------------------------------------
                case 'Cube'
                    a = inputs('Side (a)');
                    out = sprintf("Volume = %.4f\nSurface Area = %.4f", a^3, 6*a^2);

                case 'Cuboid'
                    L = inputs('Length (L)'); W = inputs('Width (W)'); H = inputs('Height (H)');
                    out = sprintf("Volume = %.4f\nSurface Area = %.4f", L*W*H, 2*(L*W+W*H+H*L));

                case 'Sphere'
                    r = inputs('Radius (r)');
                    out = sprintf("Volume = %.4f\nSurface Area = %.4f", (4/3)*pi*r^3, 4*pi*r^2);

                case 'Cylinder'
                    r = inputs('Radius (r)'); h = inputs('Height (h)');
                    out = sprintf("Volume = %.4f\nSurface Area = %.4f", pi*r^2*h, 2*pi*r*(r+h));

                case 'Cone'
                    r = inputs('Radius (r)'); h = inputs('Height (h)');
                    out = sprintf("Volume = %.4f\nSurface Area = %.4f", ...
                        (1/3)*pi*r^2*h, pi*r*(r+sqrt(h^2+r^2)));

                %% CONICS -------------------------------------------------
                case 'Parabola'
                    p = inputs('Parameter p');
                    out = sprintf("Standard form: y^2 = 4px\np = %.4f\nFocus = (%.4f, 0)\nDirectrix: x = %.4f", ...
                        p, p, -p);

                case 'Hyperbola'
                    a = inputs('a'); b = inputs('b');
                    out = sprintf("Standard form: x^2/a^2 - y^2/b^2 = 1\nEccentricity = %.4f", ...
                        sqrt(1 + (b^2)/(a^2)));

                case 'Ellipse (Conic)'
                    a = inputs('Semi-major (a)'); b = inputs('Semi-minor (b)');
                    e = sqrt(1 - (b^2)/(a^2));
                    out = sprintf("Standard form: x^2/a^2 + y^2/b^2 = 1\nEccentricity = %.4f", e);

                %% AREA UNDER CURVE --------------------------------------
                case 'Definite Integral'
                    fstr = edits(1).Value;
                    a = inputs('Lower bound a');
                    b = inputs('Upper bound b');

                    f = str2func(['@(x)' fstr]);
                    val = integral(f,a,b);
                    out = sprintf("∫[%g to %g] f(x) dx = %.6f", a,b,val);

            end

        catch ME
            out = "Error: " + ME.message;
        end
        
        outputArea.Value = out;
    end

end
