clear all
sca
commandwindow
myStimuli = get_myStimuli

% a = arrayfun(@(x) dir([im_dir myStimuli(x).item_name '*']) , 1:length(myStimuli),'UniformOutput',0)

ptb.opt.ins_text_size = 50;
ptb.opt.wordsize = 100;
ptb.opt.fix_crossSize = 100
ptb.opt.Font = 'Helvetica';
ptb.ScreenSize = [0 0 640 480]

exp_opts.t_fixCross = 1;
exp_opts.t_query= 10;
exp_opts.t_to_respond= 5;

scr_available = Screen('Screens');
scr_this = scr_available(3)
[win,rect] = Screen('OpenWindow',scr_this,[],ptb.ScreenSize)
Screen('TextFont', win,ptb.opt.Font); % font set

blocks = unique([myStimuli.b_ind]);
block_length = length(myStimuli) / max(blocks);

for b_ind = blocks
    b_trials = find([myStimuli.b_ind] == b_ind);
for trial_ind = b_trials
    
            if trial_ind == b_trials(1)
            ins_string = myStimuli(trial_ind).query;
            Screen('TextSize', win,ptb.opt.ins_text_size);
        [nx, ny, textbounds] = DrawFormattedText(win,ins_string,'center','center',[]);
        [vbl t_onset] = Screen('Flip', win);
        
        %is_pressed = 0;
        keyIsDown = 0;
        while GetSecs < t_onset + exp_opts.t_query & ~keyIsDown
        [keyIsDown, secs, keyCode] = KbCheck();
            if keyIsDown
                pause(.5)
            end
        end% ends while checking
            end % ends trial if statement 

% fixation cross
Screen('TextSize', win,ptb.opt.fix_crossSize);
[nx, ny, textbounds] = DrawFormattedText(win,'+','center','center',[1]);
[vbl t_onset] = Screen('Flip', win);

while GetSecs < t_onset + exp_opts.t_fixCross
   % does fuck all 
end


this_stim = myStimuli(trial_ind).item_name;
Screen('TextSize', win,ptb.opt.wordsize);
[nx, ny, textbounds] = DrawFormattedText(win,this_stim,'center','center',[1]);
[vbl t_onset] = Screen('Flip', win);

            % Collect response
            is_pressed = 0;
            while GetSecs < t_onset + exp_opts.t_to_respond & ~is_pressed
            [keyIsDown, secs, keyCode] = KbCheck();
                    if keyIsDown && ~is_pressed
                       myStimuli(trial_ind).resp = KbName(keyCode)
                       is_pressed = 1;
                            % If key is presssed light up the word
                            [nx, ny, textbounds] = DrawFormattedText(win,this_stim,'center','center',[0 255 0]);
                            [vbl t_onset] = Screen('Flip', win);
                            pause(.5)
                    end
            end

end %ends trial loop
end %ends block loop