%% SubjData
clc;
subj_name = 'S1'; % S1, S2, S3, etc
% (max([myTrials.BlockInd])*10 + length(myTrials) * 2) / 60
%% Figure out if we have the file or not
ext = '_myTrials_practice.mat';
ofn = [subj_name ext];
disp(ofn)
if exist(ofn)
    disp('exists - loading')
    load(ofn)
else
    disp('doesnt exist - creating')
    exp_Began = datetime;
    myTrials = get_practice_myTrials; % get myTrials
end
%% Preference & Set-up
break_after_block = [27];
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'DefaultFontName','Helvetica') % Arial default
Screen('Preference', 'DefaultFontSize',60)
commandwindow
exp_start = GetSecs;
ptb.screens = Screen('Screens');
ptb.screenNumber = max(ptb.screens);
ptb.screenNumber = 0; % to put on main.
ptb.backgroundColor = [125 125 125];
ptb.insSize = 60; % instruction size
ptb.fixCrossSize = 60;
ptb.StimSize = 40; % stimulus size
grey = [255 255 255] * .2; % to grey out text. 
ptb.Win_Size = [];
[win,ptb.ScreenRect]=Screen('OpenWindow',ptb.screenNumber,ptb.backgroundColor,ptb.Win_Size);
text = 'Waiting for Trigger'
[nx, ny, textbounds] = DrawFormattedText(win, text,'center','center',[0 0 0]);
Screen('flip',win)
%% Wait For Trigger
clc
trigger = '5%';

RestrictKeysForKbCheck(KbName(trigger));
wait_for_trigger = 1;
while wait_for_trigger
   [keyIsDown, secs, keyCode] = KbCheck();
   if keyIsDown % only if keyPressed
       keyName = KbName(keyCode);
       if strcmp(keyName,trigger)
           wait_for_trigger = 0;
       end
   end
end
disp('done')

% Restrict to all keys EXCEPT trigger
RestrictKeysForKbCheck([1:length(keyCode)] ~= KbName(trigger));
%% Times
p.InsWaitTime = 4; %Max
p.fixCrossTime = 4; %Max
p.fixCrossTime2 = 2; %Max
p.ISI = 2; %Max
%% Get MyTrials & Main Loop
    numBlocks = max([myTrials.BlockInd]);
    numItemsPerBlock = length(myTrials) / numBlocks;
    
l = sum(~cellfun(@isempty,{myTrials.response})); % Which line did we leave off
current_block = myTrials(l+1).BlockInd; % which block to run

for b_ind = current_block:numBlocks
    max_blocks = max([myTrials.BlockInd]);
    block_trials = find([myTrials.BlockInd]'==b_ind);
    
text = myTrials(block_trials(1)).CatName;

    % Fixation Cross
    Screen('TextSize', win,ptb.fixCrossSize); % Instruction Size;
    DrawFormattedText(win, '+','center','center',[1 1 1]);
    Screen('flip',win);
    fixCrossStart = GetSecs;
    while GetSecs < fixCrossStart + p.fixCrossTime
    end
    % Instructions
    Screen('TextSize', win, ptb.insSize); % Instruction Size;
    DrawFormattedText(win, text,'center','center',[1 1 1]);
    Screen('flip',win);
    ins_on_time = GetSecs;
    
    % Instruction Screen Wait Time
    while GetSecs < ins_on_time + p.InsWaitTime
         [keyIsDown, secs, keyCode] = KbCheck;
    end

    
    DrawFormattedText(win, '+','center','center',[1 1 1]);
    Screen('flip',win);
    fixCrossStart = GetSecs;
    while GetSecs < fixCrossStart + p.fixCrossTime2
    end
    
    
%Screen('flip',win);

Screen('TextSize', win, ptb.StimSize); % Instruction Size;
for i_ind = 1:numItemsPerBlock
    trial_ind = block_trials(i_ind);
    l = l+1;
    
    StimName = myTrials(trial_ind).StimName;
    [nx, ny, textbounds] = DrawFormattedText(win, StimName,'center','center',[0 0 0]);
    Screen('flip',win);
    
    % Check for response
    t_onset = GetSecs;
    keyName = {};
    keyPressTime = []; 
    responded = 0;
    while GetSecs < t_onset + p.ISI;
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown & [GetSecs > t_onset + .2] & ~responded
       keyName = KbName(keyCode);
       keyPressTime = GetSecs;
        %break
    [nx, ny, textbounds] = DrawFormattedText(win, StimName,'center','center',grey);
    Screen('flip',win);
    responded = 1;
    end
    end
    
    Screen('flip',win);
%    while GetSecs < t_onset + p.ISIcooldown;
%    end

% record response
myTrials(trial_ind).response = keyName;
myTrials(trial_ind).RT = keyPressTime - t_onset;


% Fix skipped responses
if isempty(myTrials(trial_ind).response);myTrials(trial_ind).response = NaN;end
if isempty(myTrials(trial_ind).RT);myTrials(trial_ind).RT = NaN;end
end

% Break
if ismember(b_ind,break_after_block)
    
   save(ofn,'myTrials')
   save([subj_name '_wrkpsc'])
   break
end


end
exp_dur = (GetSecs - exp_start) / 60;
exp_ended = datetime;
sca