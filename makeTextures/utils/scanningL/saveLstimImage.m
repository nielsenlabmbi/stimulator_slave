function saveLstimImage(params,imgPath)
    system(['cp ' imgPath '* /media/nielsenlab/Ramanujan/scanningL_spec/']);
        
    oFile = ['/media/nielsenlab/Ramanujan/scanningL_spec/' params.id '_' params.shade '.png'];
    zFile = ['/media/nielsenlab/Ramanujan/scanningL_spec/'  params.id '_drape_' params.shade '.png'];
    while (params.zuckerise && ~exist(zFile,'file')) || ...
        (~params.zuckerise && ~exist(oFile,'file'))
        pause(1);
    end
    
    system(['cp /media/nielsenlab/Ramanujan/scanningL_spec/' params.id '*SHADE.png ~/images/scanningL/']);
    system(['cp /media/nielsenlab/Ramanujan/scanningL_spec/' params.id '*TWOD.png ~/images/scanningL/']);
end