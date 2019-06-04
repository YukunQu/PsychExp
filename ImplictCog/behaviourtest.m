Screen('Preference', 'SkipSyncTests', 1);
% Clear the workspace and the screen
sca;
close all;
clearvars;

%% preprare the screen
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
screens = Screen('Screens');% Get the screen numbers
screenNumber = max(screens);% Draw to the external screen if avaliable
white = WhiteIndex(screenNumber);% Define black and white
grey = white / 2;

[window, ~] = PsychImaging('OpenWindow', screenNumber, grey);% Open an on screen window
Screen('Flip', window);

%% Make texture for instruction
stimDir = fullfile('内隐认知重评实验素材最终版','核磁外情绪唤起评价材料');
beginInst = Screen('MakeTexture', window, imread(fullfile(stimDir,'指导语','ins.jpg')));
beginInstre = Screen('MakeTexture', window, imread(fullfile(stimDir,'指导语','ins_evaluation.jpg')));
endInst = Screen('MakeTexture', window, imread(fullfile(stimDir,'指导语','finish.jpg')));
fixation = Screen('MakeTexture', window, imread(fullfile(stimDir,'指导语','next.jpg')));

%% Make texture for motor task
stimName = dir(fullfile(stimDir,'情绪图片','*jpg'));
nTask = 70;
stimTexture = zeros(nTask,1);
for i = 1:nTask
    stiImg = imread(fullfile(stimDir,'情绪图片',stimName(i).name));
    stimTexture(i) = Screen('MakeTexture', window,stiImg);
end

%% Set keys
startKey = KbName('space');
escKey = KbName('ESCAPE');
respondKey1 = KbName('1!');
respondKey2 = KbName('2@');
respondKey3 = KbName('3#');
respondKey4 = KbName('4$');

%% Set duration
cueDur=2;stimDur=5;

%% present the instruction
Screen('DrawTexture', window, beginInst);
Screen('Flip', window);
while 1
    [KD,~,KC]=KbCheck;
    if KC(startKey) && KD
        break;
    elseif KC(escKey) && KD 
        sca;return
    end
end
Screen('DrawTexture', window, beginInstre);
Screen('Flip', window);
WaitSecs(2)
while 1
    [KD,~,KC]=KbCheck;
    if KC(startKey) && KD
        break;
    elseif KC(escKey) && KD
        sca;return
    end
end

%% present the Stimulation
respRecord = zeros(nTask,1);
response = 0;
for i = 1:nTask
    Screen('DrawTexture',window,fixation)
    Screen('Flip',window);
    WaitSecs(cueDur);
    Screen('DrawTexture',window,stimTexture(i));
    Screen('Flip',window);
    stimStr = GetSecs;
    while (GetSecs - stimStr) < stimDur
        [KD,~,KC]=KbCheck;
        if KC(respondKey1) && KD
            response = 1;     
        elseif KC(respondKey2) && KD
            response = 2;
        elseif KC(respondKey3) && KD
            response = 3;
        elseif KC(respondKey4) && KD
            response = 4;
        elseif KC(escKey)
            sca;return;
        end   
    end
    respRecord(i) = response;
end

%% present the ending instrcution
Screen('DrawTexture', window, endInst);
Screen('Flip', window);
WaitSecs(3);
sca;

%% Save data
date =  strrep(strrep(datestr(clock),':','-'),' ','-');
outFile = fullfile('data',sprintf('behaviourtest_%s.mat',date));
fprintf('Data were saved to: %s\n',outFile);
save(outFile,'stimName','nTask','respRecord');
