function [gainvec,basevec]=getColorSettings(colormod,P)

% This function returns the color settings (gains and base for each
% channel) for generating colored gratings. gainvec and basevec should not
% drive the grating values past 0/1 (see makeTexture file for formula).
% Accepts:
%   colormod:   color type, used in looper to randomize colors
% Returns:
%   gainvec: vector of color gains (order: r, g, b)
%   basevec: vector of color bases (order: r, g, b)

switch colormod
    case 1 %this obeys the input gain and base values
        gainvec(1) = P.redgain;
        gainvec(2) = P.greengain;
        gainvec(3) = P.bluegain;       
        
        sevec(1) = P.redbase;
        basevec(2) = P.greenbase;
        basevec(3) = P.bluebase;
        
        
        
end

