function ImplicitCognitionRevalue(SubjectID,run)
Screen('Preference', 'SkipSyncTests', 1);

%% Arguments
if nargin < 2, SubjectID = 'test'; run = 1;end
% Clear the workspace and the screen
sca;
close all;

%% preprare the screen
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
%HideCursor;
screens = Screen('Screens');% Get the screen numbers
screenNumber = max(screens);% Draw to the external screen if avaliable
white = WhiteIndex(screenNumber);% Define black and white

[window, ~] = PsychImaging('OpenWindow', screenNumber, white);% Open an on screen window
Screen('Flip', window);


%% Make texture for instruction and dot
if run == 1
    stimDir = fullfile('内隐认知重评实验素材最终版','第一次内隐认知重评材料');
elseif run == 2 
    stimDir = fullfile('内隐认知重评实验素材最终版','第二次内隐认知重评材料');
end
beginInst = Screen('MakeTexture', window, imread(fullfile(stimDir,'指导语','ins.jpg')));
beginInstre = Screen('MakeTexture', window, imread(fullfile(stimDir,'指导语','ins_reappraisal.jpg')));
endInst = Screen('MakeTexture', window, imread(fullfile(stimDir,'指导语','finish.jpg')));
fixation = Screen('MakeTexture', window, imread(fullfile(stimDir,'指导语','black_dot.jpg')));

%% Make texture for motor task
stimName = dir(fullfile(stimDir,'情绪图片','*jpg'));
falsDep = dir(fullfile(stimDir,'虚假描述','*jpg'));
nTask = 3;
stimTexture = zeros(nTask,1);
depTexture = zeros(nTask,1);
for i = 1:nTask
    stiImg = imread(fullfile(stimDir,'情绪图片',stimName(i).name));
    depImg = imread(fullfile(stimDir,'虚假描述',falsDep(i).name));
    stimTexture(i) = Screen('MakeTexture', window,stiImg);
    depTexture(i) = Screen('MakeTexture', window,depImg);
end

%% Set keys
triggerKey = KbName('s');
startKey = KbName('space');
escKey = KbName('ESCAPE');
respondKey1 = KbName('1!');
respondKey2 = KbName('2@');
respondKey3 = KbName('3#');
respondKey4 = KbName('4$');


%% Set duration jitter
a = ones(1,8)*3.5; b = ones(1,18)*4; c = ones(1,9)*4.5;
fixDur = [a,b,c];
fixDur = fixDur(randperm(length(fixDur)));
a = ones(1,8); b = ones(1,18)*1.5; c = ones(1,9)*2;
emptyDur = [a,b,c];
emptyDur = emptyDur(randperm(length(emptyDur)));
%alphabet = [1 1.5 2]; 
%prob = [0.25 0.5 0.25];
%randsrc(35,1,[alphabet;prob]); the function randsrc need Communications Toolbox
depDur = 3;
stimDur = 5;

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
WaitSecs(2);
while 1
    [KD,~,KC]=KbCheck;
    if KC(startKey) && KD
        break;
    elseif KC(escKey) && KD
        sca;return
    end
end
Screen('DrawTexture',window,fixation);
Screen('Flip', window);

%% Wait trigger to begin the (MRI)experiment
while true
    [KD,~,KC] = KbCheck;
    if KD && KC(triggerKey)
        break
    elseif KD && KC(triggerKey)
        Screen('CloseAll');
        disp('ESC is pressed to abort the program.');
        return;
    end
end
fprintf('*****---The MRI is running ---*****\n');

%% present the Stimulation
respRecord = zeros(nTask,1);
response = 0;
for i = 1:nTask
    Screen('DrawTexture',window,fixation);
    Screen('Flip',window);    
    WaitSecs(fixDur(i));
    Screen('DrawTexture',window,depTexture(i));
    Screen('Flip',window);
    WaitSecs(depDur);
    Screen('FillRect',window,white);
    Screen('Flip',window);
    WaitSecs(emptyDur(i));
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
save(outFile,'SubjectID','run','nTask','stimName','respRecord');