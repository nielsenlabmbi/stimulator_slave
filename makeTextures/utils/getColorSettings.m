function [gainvec,basevec]=getColorSettings(colormod,P)

% This function returns the color settings (gains and bases for each
% channel) for generating colored gratings. gainvec and basevec should not
% drive the grating values past 0/1 (see makeTexture file for formula).
% to turn the contribution of a channel off, set gain and base to 0 (sets
% the channels values to 0); otherwise base will usually be 0.5
% positive gains scale the 'white' phase of the grating, negative gains
% scale the 'black' phase
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
        
        basevec(1) = P.redbase;
        basevec(2) = P.greenbase;
        basevec(3) = P.bluebase;
       
    case 2 %red green grating, not isoluminant
        gainvec(1) = 1;
        gainvec(2) = -1;
        gainvec(3) = 0;       
        
        basevec(1) = 0.5;
        basevec(2) = 0.5;
        basevec(3) = 0;
        
        
end

