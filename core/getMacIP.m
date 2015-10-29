function IP=getMacIP

[~,result]=system('ifconfig en0 inet');

c1=strfind(result,'inet');
c2=strfind(result,'netmask');
IP=result(c1+5:c2-2);
