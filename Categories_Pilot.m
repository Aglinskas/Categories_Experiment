clear all
myStimuli = get_myStimuli


ptb.opt.ins_text_size = 50;
ptb.opt.wordsize = 100;
ptb.opt.Font = 'Helvetica';


scr_available = Screen('Screens');
scr_this = scr_available(3)
[win,rect] = Screen('OpenWindow',scr_this,[],[0 0 640 480])
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
        while GetSecs < t_onset+3
            % do fuck all
        end
        %[vbl t_onset] = Screen('Flip', win);
            end % ends trial if statement 
    


this_stim = myStimuli(trial_ind).item_name;
Screen('TextSize', win,ptb.opt.wordsize);
[nx, ny, textbounds] = DrawFormattedText(win,this_stim,'center','center',[1]);
[vbl t_onset] = Screen('Flip', win);

            % Collect response
            is_pressed = 0;
            while GetSecs < t_onset+3
                        % do fuck all
            %[keyIsDown, secs, keyCode, deltaSecs] = KbCheck([deviceNumber])
            [keyIsDown, secs, keyCode] = KbCheck();
                    if keyIsDown == 1 && is_pressed == 0
                       myStimuli(trial_ind).resp = KbName(keyCode)
                       is_pressed = 1;
                       %break
                    end
            end

end %ends trial loop
end %ends block loop
