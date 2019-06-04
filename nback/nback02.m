%Stimulations can be present as random sequence perfectly.
%Add the recording process
startime = GetSecs;
Screen('Preference', 'SkipSyncTests', 1);
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

%----------------------------------------------------------------------
%                       Screen setup
%----------------------------------------------------------------------
% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);


% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
%Screen('DrawLines', window, allCoords,...
%

% Flip to the screen
%Screen('Flip', window);
%WaitSecs(2);

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------
% Keybpard setup
triggerKey = KbName('s');
respondKey1 = KbName('1!');
escKey = KbName('ESCAPE');

%----------------------------------------------------------------------
%                        Result Matrix
%----------------------------------------------------------------------
% Make a  matrix which which will hold all of our results
trial = 14;
resMat = nan(trial , 4);

% Make a directory for the results
%----------------------------------------------------------------------
%                      Experimental Loop
%----------------------------------------------------------------------
%% Make texture for instruction and dot
Inst0  = Screen('MakeTexture', window, imread(fullfile('materials','0.jpg')));
Inst1  = Screen('MakeTexture', window, imread(fullfile('materials','1.jpg')));
Inst2  = Screen('MakeTexture', window, imread(fullfile('materials','2.jpg')));
fixation = Screen('MakeTexture', window, imread(fullfile('materials','fixation.jpg')));
theImageList =  dir(fullfile('numbers','*jpg'));

Screen('DrawTexture',window,Inst0);
Screen('Flip',window);
WaitSecs(4);

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
Screen('Fillrect',window,black);
Screen('Flip',window);
WaitSecs(2);

for block = 1:4
    if block == 1 || block == 4
        nback = 0;
    elseif block == 2 || block == 3
        nback = 2;
    end
    
    if nback == 0
        Inst = Inst1;
    elseif nback == 2
        Inst  = Inst2;
    end

    Screen('DrawTexture',window,Inst);
    Screen('Flip',window);
    WaitSecs(12);
    disp('jiankemanhuying')
    for i = 1:trial 
        % Here we load in an image from file. This one is a image of rabbits 
        % that is included with PTB
        num = randi(9);
        theImage = imread(fullfile('numbers',theImageList(num).name));
        % Get the size of the image
        
        Screen('DrawTexture',window,fixation);
        Screen('Flip',window);
        WaitSecs(1);
        % Make the image into a texture
        imageTexture = Screen('MakeTexture', window, theImage);

        % Draw the image to the screen, unless otherwise specified PTB will 
        % draw the texture full size in the center of the screen. We first draw
        % the image in its correct orientation.
        
        Screen('DrawTexture', window, imageTexture);
        Screen('Flip',window);
        WaitSecs(0.5);
        Screen('Fillrect',window,black);    
        Screen('Flip',window);
        response = 0;
        keypress = 0;
        ReacTime = 0;
        stimStr = GetSecs;
        while (GetSecs - stimStr) < 2.5
            [KD,~,KC]=KbCheck;
            if KC(respondKey1) && KD
                response = 1;     
            elseif KC(escKey)
                sca;return;
            end   
        end
        
        % Record the trial data into out data matrix
        resMat(i, 1) = num;
        resMat(i, 2) = keypress;
        resMat(i, 3) = response;
        resMat(i, 4) = ReacTime;
    end
    outFile = fullfile('data',sprintf('nbacktest_%d.mat',block));
    fprintf('Data were saved to: %s\n',outFile);
    save(outFile,'resMat','nback');
    Screen('Fillrect',window,black);
    WaitSecs(14);
end
endtime = GetSecs;
totoltime = endtime - startime;
disp(totoltime)
% Clear the screen
sca;