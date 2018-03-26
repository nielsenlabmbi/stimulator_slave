function saveLstimParams(params,imgPath)
    if ~exist('params','var'); load('sampleParams.mat','params'); end
    if ~exist('imgPath','var'); imgPath = 'spec/L_1'; end
    doPlots = false;
    
    % the MA box is larger than the RF box because of protrusion
    ma_box_deg = params.rf_box_deg + 2*params.rf_protrude_deg;
    
    % MA box in mm
    params.ma_box = params.screenDist*tan(deg2rad(ma_box_deg/sqrt(2)));
    
    % arc rad in mm
    params.ma_arc_rad = params.screenDist*tan(deg2rad(params.arc_rad_deg));
    
    % tube rad in mm
    params.tube_rad = params.screenDist*tan(deg2rad(params.tube_diam_deg/2));
    
    % convert inter stimulus distance to distance between tube centers as a
    % multiple of the tube radius
    params.tube_sep = 2 + 2*params.tube_sep_deg/params.tube_diam_deg;
    
    % initialize the number of points in the MA and surface
    params.ma_nSegPts = 30;
    params.ma_nArcPts = 30;
    params.tube_nCircPts = 64;
    
    % for easier access
    id            = params.id;
    ma_box        = params.ma_box;
    ma_arc_rad    = params.ma_arc_rad;
    ma_nSegPts    = params.ma_nSegPts;
    ma_nArcPts    = params.ma_nArcPts;
    tube_rad      = params.tube_rad;
    tube_nCircPts = params.tube_nCircPts;
    angle         = [0 deg2rad(params.tilt) 0];
    repeats       = 2*params.repeats + 1;

    % get the medial axis and the tangent to every surface circle
    [ma,zRot] = getMAPts(ma_box,ma_arc_rad,tube_rad,ma_nSegPts,ma_nArcPts);
    
    % get vert and face for the tube only
    tube = getTubePts(ma,zRot,tube_rad,tube_nCircPts);
    tubeFaces = getTubeFaces(tube,tube_nCircPts);
    
    % get vert and face for the full L shape including the end-caps
    [sph,sphFaces] = addSpheres(ma_box,tube,tubeFaces,tube_rad,tube_nCircPts);

    % plot the L shape before rotation and translation
    if doPlots
        scatter3(sph(:,1),sph(:,2),sph(:,3),50,'r.'); 
        set(gca,'XLim',[0 ma_box],'YLim',[0 ma_box],'zlim',[-ma_box/2 ma_box/2]); axis square; view(0,90);
    end
    
    % rotate L shape so that the elbow is pointing to 0deg
    sph = rotate_z(sph,pi/4); 
    
    % center the elbow at origin
    cc = [max(sph(:,1)) 0 0]; % (max(sph)+min(sph))/2;
    sph = sph-repmat(cc,size(sph,1),1);
    
    % rotate the shape to the required tilt
    if ~exist('angle','var'); angle = [0 pi/2 0]; end
    sph = rotate_x(sph,angle(1));
    sph = rotate_y(sph,angle(2));
    sph = rotate_z(sph,angle(3)); 
    
    % get the positions for the repetitions
    pos = getGratingPositions(angle,tube_rad,repeats,params.tube_sep);
    
    if doPlots
        figure('color','w'); set(gca,'color','w'); hold on;  
        for ii=1:size(pos,1)
            sph1 = sph + repmat([pos(ii,:) 0],size(sph,1),1);
            patch('faces',sphFaces,'vertices',sph1,'FaceColor','none');
        end
        set(gca,'XLim',[-5 5],'YLim',[-5 5],'zlim',[-5 5]); axis square; view(0,90);
    end
    
    % save vert, face, and positions
    disp(['Saving all parameters for ' id]);
    dlmwrite([imgPath '_vert.txt'],round(sph,5));
    dlmwrite([imgPath '_face.txt'],sphFaces);
    dlmwrite([imgPath '_face_quad.txt'],sphFaces);
    dlmwrite([imgPath '_pos.txt'],pos);
    save([imgPath '_params.mat'],'params');
    
    % use blender to save the normals. opengl requires this for smooth rendering
    system(['/usr/local/bin/blender/blender --python /home/nielsenlab/stimulator_slave/makeTextures/utils/scanningL/saveNormals.py --background -- ' imgPath]);
    
    % use java to render the grating
    % system(['java -Djava.library.path=native/macos -jar generateStimuli.jar ' params.shade ' ' imgPath]);
    
    % if zucker manipulation is to be saved, use blender to get the visible
    % vertices, then calculate the depth map, then use blender to convert
    % the depth map to a drape, then convert the drape to the zucker images
    % if params.zuckerise
    %     saveDrape(imgPath);
    % end

end

function [ma,zRot] = getMAPts(ma_box,ma_arc_rad,tube_rad,ma_nSegPts,ma_nArcPts)
    ma_seg = ma_box - ma_arc_rad;
    
    pts1 = [linspace(tube_rad,ma_seg,ma_nSegPts)' ma_box*ones(ma_nSegPts,1)]; 
    pts1(end,:) = [];

    th = linspace(pi/2,0,ma_nArcPts); th(end) = [];
    [x,y] = pol2cart(th,ma_arc_rad*ones(1,ma_nArcPts-1));
    x = x + ma_seg; y = y + ma_seg;
    pts2 = [x' y']; 

    pts3 = [ma_box*ones(ma_nSegPts,1) linspace(ma_seg,tube_rad,ma_nSegPts)'];

    ma = [pts1;pts2;pts3];
    
    zRot = [zeros(1,ma_nSegPts-1) ((pi/2)-th) (pi/2)*ones(1,ma_nSegPts)];
end

function tube = getTubePts(ma,zRot,tube_rad,tube_nCircPts)
    th = linspace(0,2*pi,tube_nCircPts+1); th(end) = [];
    [x,y] = pol2cart(th,tube_rad*ones(1,tube_nCircPts));
    
    tube = nan(size(ma,1)*tube_nCircPts,3);
    
    for ii=1:size(ma,1)
        circ = rotate_y([x' y' zeros(tube_nCircPts,1)],pi/2);
        circ = rotate_z(circ,zRot(ii));
        circ(:,1) = circ(:,1) + ma(ii,1);
        circ(:,2) = circ(:,2) + ma(ii,2);
        tube((((ii-1)*tube_nCircPts) + 1):ii*tube_nCircPts,:) = circ;
    end
    tube(1:tube_nCircPts,:) = [];
    tube((end-tube_nCircPts+1):end,:) = [];
end

function tubeFaces = getTubeFaces(tube,tube_nCircPts)
    tubeFaces = [];
    for jj=1:size(tube,1)/tube_nCircPts - 1
        adder = (jj-1)*tube_nCircPts;
        f = nan(tube_nCircPts,4);
        for ii=1:tube_nCircPts
            f(ii,:) = [ii tube_nCircPts+ii tube_nCircPts+ii+1 ii+1];
        end
        f(tube_nCircPts,3) = f(tube_nCircPts,3) - tube_nCircPts;
        f(tube_nCircPts,4) = f(tube_nCircPts,4) - tube_nCircPts;
        tubeFaces = [tubeFaces;f+adder];
    end
end

function [sph,sphFaces] = addSpheres(ma_box,tube,tubeFaces,tube_rad,tube_nCircPts)
    [sph1,sph1Faces] = getSphere1(tube_rad,tube_nCircPts);
    sph1 = rotate_y(sph1,pi/2);
    sph1(:,1) = tube_rad + sph1(:,1);
    sph1(:,2) = ma_box + sph1(:,2);
    
    [sph2,sph2Faces] = getSphere2(tube_rad,tube_nCircPts,size(tube,1));
    sph2 = rotate_y(sph2,pi/2);
    sph2 = rotate_z(sph2,-pi/2);
    sph2(:,2) = tube_rad + sph2(:,2);
    sph2(:,1) = ma_box + sph2(:,1);
    
    tubeFaces = tubeFaces + size(sph1,1);
    
    sph = [sph1; tube; sph2];
    sphFaces = [sph1Faces; tubeFaces;sph2Faces];
end

function [sph,sphFaces] = getSphere1(tube_rad,tube_nCircPts)
    th = linspace(0,2*pi,tube_nCircPts+1); th(end) = [];
    th = repmat(th,1,tube_nCircPts/2-1);
    
    ph = linspace(pi/2,0,tube_nCircPts/2); ph(1) = [];
    ph = repmat(ph,tube_nCircPts,1);
    ph = ph(:);
    
    [x,y,z] = sph2cart(th,ph',tube_rad*ones(1,length(ph)));
    sph = [x' y' z'];
    sph = [[0 0 tube_rad] ; sph];
    
    sphFaces = [];
    count = 0;
    % cap
    for ii=2:2:tube_nCircPts
        count = count + 1;
        sphFaces(count,:) = [1 ii ii+1 ii+2];
    end
    sphFaces(count,4) = sphFaces(count,4) - tube_nCircPts;

    for jj=1:tube_nCircPts/2 - 2
        adder = (jj-1)*tube_nCircPts;
        f = nan(tube_nCircPts,4);
        for ii=1:tube_nCircPts
            f(ii,:) = [ii+1 ii+2 tube_nCircPts+ii+2 tube_nCircPts+ii+1];
        end
        f(tube_nCircPts,2) = f(tube_nCircPts,2) - tube_nCircPts;
        f(tube_nCircPts,3) = f(tube_nCircPts,3) - tube_nCircPts;
        sphFaces = [sphFaces;f+adder];
    end
    
    f = nan(tube_nCircPts,4);
    st = size(sph,1) - tube_nCircPts;
    for ii=1:tube_nCircPts
        f(ii,:) = [st+ii st+ii+1 size(sph,1)+ii+1 size(sph,1)+ii];
    end
    f(tube_nCircPts,2) = f(tube_nCircPts,2) - tube_nCircPts;
    f(tube_nCircPts,3) = f(tube_nCircPts,3) - tube_nCircPts;
    sphFaces = [sphFaces;f];
end

function [sph,sphFaces] = getSphere2(tube_rad,tube_nCircPts,tube_nPts)
    th = linspace(2*pi,0,tube_nCircPts+1); th(end) = [];
    th = repmat(th,1,tube_nCircPts/2-1);
    
    ph = linspace(0,pi/2,tube_nCircPts/2); ph(end) = [];
    ph = repmat(ph,tube_nCircPts,1);
    ph = ph(:);
    
    [x,y,z] = sph2cart(th,ph',tube_rad*ones(1,length(ph)));
    sph = [x' y' z'];
    sph(end+1,:) = [0 0 tube_rad];
    
    sphFaces = nan(tube_nCircPts,4);
    
    lastTubePt = tube_nPts + size(sph,1);
    firstSphPt = lastTubePt + 1;
    st = lastTubePt - tube_nCircPts;
    for ii=1:tube_nCircPts
        sphFaces(ii,:) = [st+ii st+ii+1 firstSphPt+ii firstSphPt+ii-1];
    end
    sphFaces(tube_nCircPts,2) = sphFaces(tube_nCircPts,2) - tube_nCircPts;
    sphFaces(tube_nCircPts,3) = sphFaces(tube_nCircPts,3) - tube_nCircPts;

    for jj=1:tube_nCircPts/2 - 2
        adder = (jj-1)*tube_nCircPts + tube_nPts + size(sph,1);
        f = nan(tube_nCircPts,4);
        for ii=1:tube_nCircPts
            f(ii,:) = [ii ii+1 tube_nCircPts+ii+1 tube_nCircPts+ii];
        end
        f(tube_nCircPts,2) = f(tube_nCircPts,2) - tube_nCircPts;
        f(tube_nCircPts,3) = f(tube_nCircPts,3) - tube_nCircPts;
        sphFaces = [sphFaces;f+adder];
    end
    
    count = 0;
    st = lastTubePt+size(sph,1)-tube_nCircPts-2;
    capPt = tube_nPts + 2*size(sph,1);
    f = [];
    % cap
    for ii=2:2:tube_nCircPts
        count = count + 1;
        f(count,:) = [capPt ii ii+1 ii+2];
    end
    f(count,4) = f(count,4) - tube_nCircPts;
    f(:,2:4) = f(:,2:4) + st;
    sphFaces = [sphFaces;f];
end

function driftDir = getDriftDir(angles)
    canonicalDir = [1 0 0];
    secondaryDir = [0 0 1];
    mainDir = rotate_x(canonicalDir,angles(1));
    mainDir = rotate_y(mainDir,angles(2));
    mainDir = rotate_z(mainDir,angles(3));
    secoDir = rotate_x(secondaryDir,angles(1));
    secoDir = rotate_y(secoDir,angles(2));
    secoDir = rotate_z(secoDir,angles(3));
    
    if (round(mainDir(1),4) == 0 && round(mainDir(2),4) == 0) || (round(mainDir(1),4) == 0 && abs(round(mainDir(2),4)) ~= 1) || (abs(round(mainDir(1),4)) ~= 1 && round(mainDir(2),4) == 0)
        driftDir = rad2deg(atan2(secoDir(2),secoDir(1)));
    else
        driftDir = rad2deg(atan2(mainDir(2),mainDir(1)));
    end
    
    if driftDir < 0
        driftDir = driftDir + 360;
    end
    driftDir = round(driftDir,4);
end

function pos = getGratingPositions(angle,tube_rad,repeats,tube_sep)
    driftDir = getDriftDir(angle);
    pos = nan(repeats,2);
    rep = (repeats-1)/2;
    for ii=-rep:rep
        pos(ii+rep+1,:) = [tube_sep*ii*tube_rad*cos(deg2rad(driftDir)) tube_sep*ii*tube_rad*sin(deg2rad(driftDir))];
    end
end

function vert = rotate_x(vert,angle)    
    Rx = [   1 0            0;...
             0 cos(angle)  -sin(angle);...
             0 sin(angle)   cos(angle)];
        
    vert = vert*Rx; 
end

function vert = rotate_y(vert,angle)    
    Ry = [   cos(angle)  0   sin(angle);...
             0           1   0;...
            -sin(angle)  0   cos(angle)];
        
    vert = vert*Ry; 
end

function vert = rotate_z(vert,angle)    
    Rz = [  cos(angle)  -sin(angle) 0;...
            sin(angle)   cos(angle) 0;...
            0            0          1];
        
    vert = vert*Rz; 
end