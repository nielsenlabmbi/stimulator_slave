function IP=getLinuxIP

[~,result]=system('ifconfig eth0');

c1=strfind(result,'inet addr:');
c2=strfind(result,'Bcast');
IP=result(c1+10:c2-3);
