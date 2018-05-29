function makeTexture_ImgScanning
    global screenPTR Gtxtr Mstate IDim params

    if ~isempty(Gtxtr)
        for ii=1:length(Gtxtr)
            Screen('Close',Gtxtr(ii));
        end
    end

    % get parameters
    P = getParamStruct;

    params = makeParams(P,Mstate);

    % create image if needed
    imgPath = [P.imgpath '/' P.imgbase '/' params.id];
    oFile = [imgPath '_' params.shade '_' params.texture '.png'];
    zFile = [imgPath '_drape_' params.shade '.png'];
    if ~params.zuckerise && ~exist(oFile,'file')
        if ~exist([imgPath '_vert.txt'],'file')
            saveLstimParams(params,imgPath);
        end
        saveLstimImage(params,imgPath);
    elseif params.zuckerise && ~exist(zFile,'file')
        saveLstimImage(params,imgPath);
    end

    % read image
    if params.zuckerise
        img = imread(zFile);
    else
        img = imread(oFile);
    end
    img = double(img);
    img = img/255;

    % make output image
    imgout = img;

    c = P.contrast/100;
    imgout = imgout .* c; % + P.background*(1-c);

    IDim = size(imgout);

    % generate texture
    Gtxtr = Screen(screenPTR, 'MakeTexture', imgout);
end

function params = makeParams(P,Mstate)
    params.rf_box_deg = P.rf_box_size;
    params.rf_protrude_deg = P.rf_protrude;
    params.tube_diam_deg = P.tube_diam;
    params.tube_sep_deg = P.tube_sep;
    params.arc_rad_deg = P.arc_rad;
    params.tilt = P.tilt_angle;
    params.repeats = ceil(P.strip_width / (P.tube_diam+P.tube_sep));
    params.zuckerise = P.zuckerise;
    params.screenDist = Mstate.screenDist*10;
    params.ori_deg = P.ori_inplane;
    params.nDisp = P.nShifts;
    params.nDriftCycles = P.nDriftCycles;
    params.id = makeId(params);
    if P.threeD;  params.shade   = 'SHADE'; else params.shade   = 'TWOD'; end
    if P.texture; params.texture = 'GRID';  else params.texture = 'NONE'; end
end

function id = makeId(params)
    id = ['scanningL_' num2str(params.rf_box_deg) '_' num2str(params.rf_protrude_deg) '_' ...
            num2str(params.tube_diam_deg) '_' num2str(params.tube_sep_deg) '_' ...
            num2str(params.arc_rad_deg) '_' num2str(params.tilt) '_' ...
            num2str(params.repeats) '_' num2str(params.screenDist)];
end

