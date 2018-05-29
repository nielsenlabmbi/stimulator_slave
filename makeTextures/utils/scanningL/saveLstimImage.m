function saveLstimImage(params,imgPath)
    system(['cp ' imgPath '* /home/nielsenlab/Zdrive/Ramanujan/scanningL_spec/']);
        
    oFile = ['/home/nielsenlab/Zdrive/Ramanujan/scanningL_spec/' params.id '_' params.shade '_' params.texture '.png'];
    zFile = ['/home/nielsenlab/Zdrive/Ramanujan/scanningL_spec/'  params.id '_drape_' params.shade '.png'];
    while (params.zuckerise && ~exist(zFile,'file')) || ...
        (~params.zuckerise && ~exist(oFile,'file'))
        pause(1);
    end
    
    system(['cp /home/nielsenlab/Zdrive/Ramanujan/scanningL_spec/' params.id '*.png ~/images/scanningL/']);
end