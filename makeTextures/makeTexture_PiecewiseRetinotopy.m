function makeTexture_PiecewiseRetinotopy()
    global screenPTROff screenNum positions
    
    P = getParamStruct;

    fore_col = [P.color_r P.color_g P.color_b 1];
    back_col = P.background;
    
    stimIds = eval(P.stimIds);
    
    positions = getPositions(P);
    
    for ii=1:length(stimIds)
        for jj=1:length(positions.s)
            screenPTROff(ii,jj) = Screen('OpenOffscreenWindow',screenNum,back_col,[0 0 offScreenSize offScreenSize],[],[],8);
            Screen(screenPTROff(ii,jj),'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen(screenPTROff(ii,jj),'FillRect',back_col);
            offScreenSize = positions.s(jj);
            polygon = getShape_p26(stimIds(ii),offScreenSize/2,offScreenSize/2,offScreenSize,0);
            Screen('FillPoly',screenPTROff(ii,jj),fore_col, polygon,0);
        end
    end

end

function positions = getPositions(P)
    global screenNum
    screenRes = Screen('Resolution',screenNum);
    
    blockWidth = screenRes.width/(P.n_vStrips);
    blockHeight = screenRes.height/(P.n_hStrips);
    xCenters = (blockWidth/2)  : blockWidth  : (screenRes.width-blockWidth/2);
    yCenters = (blockHeight/2) : blockHeight : (screenRes.height-blockHeight/2);

    if P.b
        y = yCenters;
        x = repmat(xCenters(P.a),length(yCenters),1)';
    else
        x = xCenters;
        y = repmat(yCenters(P.a),length(xCenters),1)';
    end
    
    nPos = length(y);
    s = min([blockWidth blockHeight]) * linspace(0.25,1,P.nsize);
    
    positions.x = x;
    positions.y = y;
    positions.s = s;
    positions.nPos = nPos;
end

%%% ==================== GENERATE SHAPE ====================================

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

%%% ===================== HELPER FUNCTIONS =================================

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
