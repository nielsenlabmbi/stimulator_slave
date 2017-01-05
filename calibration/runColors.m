clear;

screens=Screen('Screens');
screenNumber=max(screens);
mults=8;
[w, rect] = Screen('OpenWindow', screenNumber, [],[],[],[],[],mults,[]);
colmat=round(linspace(0,255,20));

for c=1:3
    for ii=1:length(colmat)
        cm=[0 0 0];
        cm(c)=colmat(ii);
        
        Screen(w, 'FillRect', cm);
        colstr=['C: ' num2str(c) ', step: ' num2str(ii)];
        Screen(w,'DrawText',colstr,40,30,255);
        Screen(w, 'Flip');

        pause;
    end
end

KbWait;
Screen('CloseAll');

