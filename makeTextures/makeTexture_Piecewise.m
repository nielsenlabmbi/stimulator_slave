function makeTexture_Piecewise(isManual)
    global   screenPTROff screenNum movement
    % global polygon fore_col
    % tried using the framebuffer instead of the backbuffer. That makes the
    % shapes look bad. pixels around the edge. backbuffer makes the shape
    % look smooth.
    
    if ~exist('isManual','var'); isManual = false; end
    
    %get parameters set in GUI
    P = getParamStruct;

    fore_col = [P.color_r P.color_g P.color_b P.contrast/100];
    back_col = P.background;
    
    offScreenSize = deg2pix(P.size,'ceil')*2;

    if isManual
        polygon = getShapeById(P.stimId);
        polygon = movePts(polygon,P.x_pos,P.y_pos,deg2pix(P.size,'none'),P.ori,[0 0]);
        
        Screen(screenPTROff,'FillRect',back_col);
        Screen('FillPoly',screenPTROff,fore_col, polygon,0);
    else
        polygon = getShape_p26(P.stimId,offScreenSize/2,offScreenSize/2,deg2pix(P.size,'none'),P.ori);
        
        movement = getMovement(P,offScreenSize);
        movement.offScreenSize = offScreenSize;

        screenPTROff = Screen('OpenOffscreenWindow',screenNum,back_col,[0 0 offScreenSize offScreenSize],[],[],8);
        Screen(screenPTROff,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen(screenPTROff,'FillRect',back_col);
        Screen('FillPoly',screenPTROff,fore_col, polygon,0);
    end
end

function movement = getMovement(P,offScreenSize)
    movement.cycleLength = P.t_period;
    movement.major       = P.movement_x;
    movement.minor       = P.movement_y;
    movement.move        = movement.major > 0 || movement.minor > 0;
    movement.spin        = P.spin;
    
    t = linspace(0,2*pi,movement.cycleLength+1); t(end) = [];
    x = movement.major * cos(t);
    y = movement.minor * sin(t);
    
    movement.center = repmat([P.x_pos P.y_pos],length(x),1) + [x' y'];
    movement.rect   = [movement.center(:,1)-offScreenSize/2 ...
                       movement.center(:,2)-offScreenSize/2 ...
                       movement.center(:,1)+offScreenSize/2 ...
                       movement.center(:,2)+offScreenSize/2];
          
    % movement.rect   = getSpin(movement.spin,movement.rect,movement.center,movement.cycleLength);
end

function rectSpun = getSpin(dir,rectAll,centerAll,cl)
    rectSpun = nan(size(rectAll));
    if strcmp(dir,'counter')
        th = linspace(0,2*pi,cl+1); th(end) = [];
    elseif strcmp(dir,'clockwise')
        th = linspace(2*pi,0,cl+1); th(end) = [];
    else
        th = linspace(0,0,cl+1); th(end) = [];
    end
        
    for ii=1:cl
        spin(1,1) =  cos(th(cl));
        spin(1,2) = -sin(th(cl));
        spin(2,1) =  sin(th(cl));
        spin(1,2) =  cos(th(cl));
        
        rect = rectAll(ii,:);
        center = repmat(centerAll(ii,:),4,1);
        
        mat = [rect(1) rect(2); rect(1) rect(4); rect(3) rect(4); rect(3) rect(2)];
        mat = center + (mat-center)*spin;
        
        rectSpun(ii,1) = mat(1,1);
        rectSpun(ii,2) = mat(1,2);
        rectSpun(ii,3) = mat(1,1);
        rectSpun(ii,4) = mat(1,1);
        
    end
end

%% ==================== GENERATE SHAPE ====================================

function pts = getShape_p26(id,x,y,s,o)
    if id <= 16
        temp = mod(id,4); temp(temp == 0) = 4;
        o = o + 90*(temp-1);
        id = floor(id/4) + 1;
        if temp == 4; id = id -1; end
    elseif id <=18
        id = id - 12;
    else
        id = id - 18;
        temp = mod(id,2); temp(temp == 0) = 2;
        o = o + 90*(temp-1);
        id = 6 + floor(id/2) + 1;
        if temp == 2; id = id - 1; end
            
    end
        
    pts = getShapeById(id);
    pts = movePts(pts,x,y,s,o,[0 0]);
end

function [pts,ori] = getShapeById(id)
    switch(id)
        case 1;
            p{1} = getCircle([-2 -2],2,pi/2,2*pi,75);
            p{2} = getCircle([2 -2],2,pi,2*pi,50);
            p{3} = getLine([4 -2],[4 4],50);
            p{4} = flipud(getCircle([0 4],4,3*pi/2,2*pi,25));
            p{5} = getLine([0 0],[-2 0],10);
            ori = 0:45:359;
        case 2;
            p{1} = getLine([-4 4],[-4 2],50);
            p{2} = getCircle([-2 -2],2,pi,2*pi,50);
            p{3} = getCircle([2 -2],2,pi,5*pi/2,50);
            p{4} = getLine([2 0],[0 0],10);
            p{5} = flipud(getCircle([0 4],4,pi,3*pi/2,25));
            ori = 0:45:359;
        case 3;
            p{1} = getCircle([2 -2],2,3*pi/2-pi/3,2*pi+pi/2,50);
            p{2} = getCircle([2 2],2,3*pi/2,2*pi+pi/2+pi/3,50);
            p1 = [2*cos(5*pi/6)+2 2*sin(5*pi/6)+2]; t1 = tan(pi/3);
            p2 = [-4 0]; t2 = 0;
            p{3} = getCubicFit(p1(1),p1(2),t1,p2(1),p2(2),t2,50); p{3}(end,:) = [];
            % p1 = [-4 0]; t2 = 0;
            % p2 = [2*cos(5*pi/6)+2 -2*sin(5*pi/6)-2]; t1 = tan(pi/2+pi/3);
            p{4} = flipud(p{3}); p{4}(:,2) = -p{4}(:,2);
            
            % p{3} = getLine(2*[cos(pi/3) sin(pi/3)]+[2 -2],2*[cos(pi/3)-sin(pi/3) cos(pi/3)+sin(pi/3)]+[2 -2],20);
            % p{4} = getLine(2*[cos(pi/3)-sin(pi/3) cos(pi/3)+sin(pi/3)]+[2 -2],[0 4],20);
            % p{5} = getLine([0 4],2*[cos(pi/6)-sin(pi/6) cos(pi/3)+sin(pi/3)]+[-2 -2],20);
            % p{6} = getLine(2*[cos(pi/6)-sin(pi/6) cos(pi/3)+sin(pi/3)]+[-2 -2],2*[cos(pi-pi/3) sin(pi-pi/3)]+[-2 -2],20);
            % p{3} = flipud(getCircle([2 2],2,pi,3*pi/2,30));
            % p{4} = flipud(getCircle([-2 2],2,3*pi/2,2*pi,30));
            % p{3} = flipud(getEllipse([2 4],2,4,0,pi,3*pi/2,30));
            % p{4} = flipud(getEllipse([-2 4],2,4,0,3*pi/2,2*pi,30));
            ori = 0:45:359;
        case 4;
            p{1} = getCircle([2 -2],2,pi,3*pi/2,25);
            p{2} = getLine([2 -4],[4 -4],10);
            % p{1} = getEllipse([-4 -2],4,2,0,3*pi/2,2*pi,50);
            % p{2} = getEllipse([4 -2],4,2,0,pi,3*pi/2,50);
            p{3} = flipud(getEllipse([4 4],4,8,0,pi,3*pi/2,50));
            p{4} = flipud(getEllipse([-4 4],4,8,0,3*pi/2,2*pi,50));
            p{5} = getLine([-4 -4],[-2 -4],10);
            p{6} = getCircle([-2 -2],2,3*pi/2,2*pi,25);
            ori = 0:45:359;
        case 5;
            p{1} = getCircle([4 4],4,pi,3*pi/2,50);
            p{2} = getCircle([4 -4],4,pi/2,pi,50);
            p{3} = getCircle([-4 -4],4,0,pi/2,50);
            p{4} = getCircle([-4 4],4,3*pi/2,2*pi,50);
            ori = [0 45];
        case 6;
            p{1} = getCircle([-2 -2],2,pi/2,2*pi,75);
            p{2} = getCircle([2 -2],2,pi,5*pi/2,75);
            p{3} = getCircle([2 2],2,3*pi/2,3*pi,75);
            p{4} = getCircle([-2 2],2,0,3*pi/2,75);
            ori = [0 45];
        case 7;
            p{1} = getCircle([2 -2],2,pi,3*pi/2,25);
            p{2} = getLine([2 -4],[4 -4],10);
            p{3} = flipud(getEllipse([4 0],3,4,0,pi/2,3*pi/2,50));
            p{4} = getLine([4 4],[2 4],10);
            p{5} = getCircle([2 2],2,pi/2,pi,25);
            p{6} = getCircle([-2 2],2,0,pi/2,25);
            p{7} = getLine([-2 4],[-4 4],10);
            p{8} = flipud(getEllipse([-4 0],3,4,0,3*pi/2,5*pi/2,50));
            p{9} = getLine([-4 -4],[-2 -4],10);
            p{10} = getCircle([-2 -2],2,3*pi/2,2*pi,25);
            ori = 0:45:179;
        case 8;
            ang = atan(4/7);
            p{1} = getCircle([7 0],sqrt(65),pi-ang,pi+ang,50); p{1}(end,:) = [];
            p{2} = getCircle([-7 0],sqrt(65),2*pi-ang,2*pi+ang,50);
            ori = 0:45:179;
        case 9;
            tt = atan(24/7);
            p{1} = getLine([2 -4],[4 -4],10);
            p{2} = flipud(getCircle([31/6 0],25/6,pi,pi+tt,25));
            p{3} = getEllipse([-2 0],3,4,0,0,pi/2,25);
            p{4} = getLine([-2 4],[-4 4],10);
            p{5} = flipud(getCircle([-31/6 0],25/6,0,tt,25));
            p{6} = getEllipse([2 0],3,4,0,pi,3*pi/2,25);
            ori = 0:45:179;
        case 10;
            tt = atan(24/7);
            p{1} = getLine([2 4],[4 4],10);
            p{2} = flipud(getCircle([31/6 0],25/6,pi,pi-tt,25));
            p{3} = flipud(getEllipse([-2 0],3,4,0,3*pi/2,2*pi,25));
            p{4} = getLine([-2 -4],[-4 -4],10);
            p{5} = getCircle([-31/6 0],25/6,2*pi-tt,2*pi,25);
            p{6} = flipud(getEllipse([2 0],3,4,0,pi/2,pi,25));
            ori = 0:45:179;
    end

    pts = cell2mat(p')/8;
    pts(:,2) = -pts(:,2);
end

%% ===================== HELPER FUNCTIONS =================================

function pts = getCircle(center,rad,thStart,thEnd,nPts)
    ang = linspace(thStart,thEnd,nPts); 
    x = center(1) + rad * cos(ang);
    y = center(2) + rad * sin(ang);
    
    pts = [x' y'];
end

function pts = getLine(startPt, endPt, nPts)
    m = (endPt(2) - startPt(2)) / (endPt(1) - startPt(1));
    
    if isinf(m)
        y = linspace(startPt(2),endPt(2),nPts);
        pts = [startPt(1)*ones(nPts,1) y'];
    else
        c = (startPt(2)*endPt(1) - endPt(2)*startPt(1)) / (endPt(1) - startPt(1));

        x = linspace(startPt(1),endPt(1),nPts);
        y = m*x + c;

        pts = [x;y]';
    end
end

function pts = getCubicFit(x1,y1,t1,x2,y2,t2,nPts)
    A = [3*x1^2 2*x1    1 0;...
         3*x2^2 2*x2    1 0;...
           x1^3   x1^2 x1 1;...
           x2^3   x2^2 x2 1;];
    B = [t1;t2;y1;y2];
    
    beta = A\B;
    
    x = linspace(x1,x2,nPts);
    
    y = beta(1)*x.^3 + beta(2)*x.^2 + beta(3)*x + beta(4);
    
    pts = [x' y'];
end

function pts = getEllipse(center,major,minor,ang,thStart,thEnd,nPts)
    co = cos(ang);
    si = sin(ang);
    the = linspace(thStart,thEnd,nPts);
  
    x = major*cos(the)*co - si*minor*sin(the) + center(1);
    y = major*cos(the)*si + co*minor*sin(the) + center(2);
  
    pts = [x' y'];
end
