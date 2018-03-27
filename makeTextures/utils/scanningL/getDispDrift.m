% uses the number of displacements, size of RF etc. to evaluate the drift
% direction and the x,y positions of the center of the image for all
% possible displacements

function [pos,finalPos] = getDispDrift(params)
    % nDisp = 2*params.nDisp + 1;
    nDisp = params.nDisp;

    posDir = deg2rad(mod(params.ori_deg + 90,360));
    
    rMax = params.screenDist * tan(deg2rad(params.rf_box_deg + params.rf_protrude_deg));
    rMin = -rMax;
    
    x = round(linspace(rMax,rMin,nDisp)*cos(posDir),4);
    y = round(linspace(rMax,rMin,nDisp)*sin(posDir),4);
    
    pos = [x;y];
    
    finalPosDeg = params.nDriftCycles * (params.tube_sep_deg + params.tube_diam_deg);
    finalPos = round(rotate_z([params.screenDist*tan(deg2rad(finalPosDeg)) 0 0],...
        -deg2rad(params.ori_deg)),5); % -z rotation is correct dir
end

function vert = rotate_z(vert,angle)    
    Rz = [  cos(angle)  -sin(angle) 0;...
            sin(angle)   cos(angle) 0;...
            0            0          1];
        
    vert = vert*Rz; 
end
