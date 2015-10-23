function densePts = drawSpline(cPts,sampleDensity,h,drawCpts,fColor,bColor)
    % drawSpline() constructs a concatenated b-spline shape from the specified
    % control points. It returns the dense points and/or draws the shape on the
    % specified axis with or without the control polygon.
    % Maintained by Ramanujan Srinath
    % Accepts:
    %   cts             - control points - column 1 = x; column 2 = y;
    %   sampleDensity   - sampling density (optional)
    %   h               - axis handle (optional)
    %   drawCpts        - 1 = draw control points; 0 = don't draw control points (optional)
    %   fColor          - foreground color (optional)
    %   bColor          - background color (optional)
    % Returns:
    %   densePts        - concatenated b-spline polygon

    densePts = [];

    if ~exist('sampleDensity','var');           sampleDensity = 200;    end
    if ~exist('h','var');                       plotSpline = 0;         end
    if ~exist('drawCpts','var');                drawCpts = 0;           end  
    if ~exist('fColor','var');                  fColor = [0.7 0.7 0.7]; end
    if ~exist('bColor','var');                  bColor = [0.5 0.5 0.5]; end
    
    % degree = 3 for cubic b-splines; order is degree + 1;
    deg     = 3; 
    order   = deg + 1;
    n       = size(cPts,1); 

    % need overlapping points for completion of the b-spline 
    % such that there are at least 'degree' number of points 
    % and thus at least one overlapping spline
    overlapCPts = [cPts; cPts(1:deg,:)];

    % construct knot vector and the spline points
    knotVec     = linspace(0,1,n+deg+order);
    sp          = spmak(knotVec,overlapCPts');
    x           = linspace(knotVec(4),knotVec(n+deg+1),sampleDensity);
    densePts    = fnval(sp,x)';
    
    if plotSpline
        axes(h); set(h,'color',bColor);
        patch(densePts(:,1),densePts(:,2),fColor,'EdgeColor','None','parent',h); hold on;

        if drawCpts
            color = [0.3 0.3 0.3];
            patch(cPts(:,1),cPts(:,2),color,'facecolor','none','edgecolor',color,'markerfacecolor',color,'marker','o','linestyle','--','parent',h);
        end
    end
end