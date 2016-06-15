function [setupID,masterIP]=getSetup

%remote host IP address
if ismac==1
    setupIP=getMacIP;
else
    setupIP=getLinuxIP;
end

%disp(setupIP)

switch setupIP
    case '172.30.11.130'
        setupID='2P';
        masterIP='172.30.11.131';
        
    case '172.30.11.142'
        setupID='EP';
        masterIP='172.30.11.140';

end