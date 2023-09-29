function NewJobID = ProgressBarList(instruction,arg1,arg2,arg3)

    % Creates and updates a hierachical series of progress bars
    %
    % JobID = ProgressBarList('Add',description) creates a ProgressBarList window
    % containing a job, or adds a new job to an existing window. A unique
    % JobID is returned. Description should be a string describing the job.
    %
    % ProgressBarList('Update', JobID, progress, status) updates the status of
    % a job. progress is a scalar between 0 and 1 indicating the fractional
    % completeness of the job, and status is a string decrbing its status.
    %
    % ProgressBarList('Delete', JobID) deletes a job from the stack. The
    % window is closed if this is the only job.
    %
    % ProgressBarList('DeleteAll') deletes all jobs and closes the window.
    %
    % Created 8th August 2016 by Dr Jonathan A. Hargreaves
    % Last updated 28th Jan 2017 by Dr Jonathan A. Hargreaves
    
    % User-configurable options (constant):
    Opt = struct(...
        'MaxJobs', 5,...    % Maximum allowed number of Jobs to track
        'MinTime', 0.01,... % Minimum update time in seconds       
        'RowH',  18,...     % Row Height
        'DescW', 160,...    % Description field width
        'StatW', 140,...    % Status field width
        'ProgW', 80,...     % Progress bar width
        'TimeW', 100,...    % Estimated completition time field width
        'StrpC',  [1.0 1.0 1.0; 0.9 0.9 0.9],...  % List of row BG striping colours
        'ProgC',  [0.4 0.5 0.7],...               % Progress bar colour
        'FontSize', 10',... % Font Size
        'Units', 'points'); % Units system to use for size and positon coordinates

    % Declare persistent variables:
    persistent hFig         % Handle to figure
    persistent hHeader      % Structure containing handles to header row objects
    persistent hJobs        % Structure array containing handles to job row objects
    persistent JobIDs       % Array of Job IDs
    persistent StartTimes   % Array of start times
    persistent LastUpdate   % Structure containing JobID and time of last update

    % Initialise output variable:
    NewJobID = [];

    % Select behavior based on value of first arg1:
    if ~ischar(instruction)
        error('Instruction must be a string')
    end
    switch instruction

        case 'Add' % Add a row to an exisiting window or open a new window

            % Argument handling:
            if ~ischar(arg1) || ~isvector(arg1)
                error('Job description must be a string')
            end

            % Select behavior based on status of window:
            if isempty(hFig) || ~ishandle(hFig) % Open a new window & resets persistent variables

                % Create a new empty figure:
                hFig = figure('Units', Opt.Units,...
                              'DockControls', 'off',...
                              'MenuBar', 'none',...
                              'Name', 'ProgressBarList',...
                              'NumberTitle', 'off',...
                              'Resize', 'off',...
                              'ToolBar', 'none',...
                              'WindowStyle' , 'normal');
                set(hFig,'Position', get(hFig,'Position') .* [1 1 0 0] + [0 0 Opt.DescW+Opt.StatW+Opt.ProgW+Opt.TimeW Opt.RowH*(Opt.MaxJobs+1)]);

                % Create Header:
                hHeader = CreateRow(hFig, 0, Opt);
                set(hHeader.hDesc, 'String', 'Decription:');   
                set(hHeader.hStat, 'String', 'Status:');   
                set(hHeader.hProgText, 'String', 'Progress:');   
                set(hHeader.hTime, 'String', 'Est. Complemention:');   

                % Reset other persistent variables:
                hJobs = [];
                JobIDs = [];
                StartTimes = [];
                LastUpdate = [];                   

            elseif numel(JobIDs) > Opt.MaxJobs % Check permitted number of jobs hasn't already been reached:
                error('Maximum number of jobs (%u) exceeded', Opt.MaxJobs)
            end

            % Add a new row to existing dialog
            hJob = CreateRow(hFig, numel(JobIDs)+1, Opt);
            set(hJob.hDesc, 'String', arg1);   
            set(hJob.hStat, 'String', 'Commencing...');   
            set(hJob.hTime, 'String', '??/??/?? ??:??');
            set(hJob.hProgText, 'String', sprintf('%0.0f%%', 0), 'HorizontalAlignment', 'center');   
            
            % Add to Job lists:
            NewJobID = rand(1);
            while any(NewJobID==JobIDs)
                NewJobID = rand(1);
            end
            JobIDs = [JobIDs, NewJobID]; % A unique 
            StartTimes = [StartTimes, now()];
            hJobs = [hJobs, hJob];
            
            % Force screen update:
            drawnow;
            
        case 'Update' % Update progress of a job in the list

            if ~(isscalar(arg1) || isfloat(arg1))
                error('When updating a job, the second arg1 must be a JobID')
            end
            
            % Quick check for low computational overhead in fast inner loops:
            if isempty(LastUpdate)
                SkipUpdate = false;
            else
                SkipUpdate = (LastUpdate.JobID==arg1) && ((LastUpdate.Time-now())>(Opt.MinTime/86400));
            end                
                
            if ~SkipUpdate
                
                if ~any(JobIDs==arg1)
                    error('Invalid JobID')
                end
                if ~(isscalar(arg2) || isfloat(arg2)) || any(arg2(:)<0) || any(arg2(:)>1)
                    error('Progress must be a scalar between 0 and 1')
                end
                if ~ischar(arg3) || ~isvector(arg3)
                    error('Status must be a string')
                end
                    
                j = find(JobIDs==arg1);
                set(hJobs(j).hProgBar, 'Position', get(hJobs(j).hProgBar, 'Position') .* [1 1 0 1] + [0 0 Opt.ProgW*0.8*arg2 0]);
                set(hJobs(j).hStat, 'String', arg3);   
                set(hJobs(j).hProgText, 'String', sprintf('%0.0f%%', 100*arg2));

                if arg2==0
                    set(hJobs(j).hTime, 'String', '??/??/?? ??:??');
                elseif arg2==1
                    set(hJobs(j).hTime, 'String', datestr(now, 'dd/mm/yy HH:MM:SS'));
                else
                    set(hJobs(j).hTime, 'String', datestr(StartTimes(j) + (now - StartTimes(j))/arg2, 'dd/mm/yy HH:MM:SS'));
                end
                
                % Update quick-check variables:
                LastUpdate.JobID = arg1;
                LastUpdate.Time = now();
                
                % Force screen update:
                drawnow;
            
            end
            
        case 'Delete' % Delete o job from the list:
            
            if ~(isscalar(arg1) || isfloat(arg1))
                error('When deleting a job, the second arg1 must be a JobID')
            elseif ~any(JobIDs==arg1)
                error('Invalid JobID')
            elseif JobIDs(end)~=arg1
                warning('JobID being deleted is not the last added. Multiple jobs will be deleted')
            end
            
            if JobIDs(1)==arg1

                % Delete all:
                delete(hFig);
                hFig = [];
                hHeader = [];
                hJobs = [];
                JobIDs = [];
                StartTimes = [];
                LastUpdate = [];                

            else
                
                % Delete graphics objects and resize dialog:
                for j = numel(JobIDs):-1:find(JobIDs==arg1)
                    delete(hJobs(j).hDesc);
                    delete(hJobs(j).hStat);
                    delete(hJobs(j).hTime);
                    delete(hJobs(j).hProgBox);
                    delete(hJobs(j).hProgBar);
                    delete(hJobs(j).hProgText);
                end

                % Remove Job data from lists:
                JobIDs = JobIDs(1:j-1);
                StartTimes = StartTimes(1:j-1);
                hJobs = hJobs(1:j-1);
        
            end
            
            % Force screen update:
            drawnow;
            
        case 'DeleteAll' % Delete figure & clear all data from lists:
            
            if ~isempty(hFig)
                if ishandle(hFig)
                    delete(hFig);
                end
            end
            hFig = [];
            hHeader = [];
            hJobs = [];
            JobIDs = [];
            StartTimes = [];
            LastUpdate = [];
            
        otherwise
            error('Invalid Command %s', command);

    end
   
end



function hOut = CreateRow(hFig, RowID, Opt)

    % Create background stripe:
    hOut.hStrp = annotation(hFig, 'rectangle', [0 0 0.1 0.1],...
                                  'Units', Opt.Units,...
                                  'Position', [0 Opt.RowH*(Opt.MaxJobs-RowID) Opt.DescW+Opt.StatW+Opt.ProgW+Opt.TimeW Opt.RowH],...
                                  'LineStyle', 'none',...
                                  'FaceColor', Opt.StrpC(mod(RowID, size(Opt.StrpC,1))+1,:));
    
    % Create text boxes:
    hOut.hDesc = annotation(hFig, 'textbox', [0 0 0.1 0.1],...
                                  'Units', Opt.Units,...
                                  'Position', [0 Opt.RowH*(Opt.MaxJobs-RowID) Opt.DescW Opt.RowH],...
                                  'LineStyle', 'none');
    hOut.hStat = annotation(hFig, 'textbox', [0 0 0.1 0.1],...
                                  'Units', Opt.Units,...
                                  'Position', [Opt.DescW Opt.RowH*(Opt.MaxJobs-RowID) Opt.StatW Opt.RowH],...
                                  'LineStyle', 'none');
    hOut.hTime = annotation(hFig, 'textbox', [0 0 0.1 0.1],...
                                  'Units', Opt.Units,...
                                  'Position', [Opt.DescW+Opt.StatW+Opt.ProgW Opt.RowH*(Opt.MaxJobs-RowID) Opt.TimeW Opt.RowH],...
                                  'LineStyle', 'none');

    % Create progress bar and/or title:
    if RowID>0
        hOut.hProgBar = annotation(hFig, 'rectangle', [0 0 0.1 0.1],...
                                         'Units', Opt.Units,...
                                         'Position', [Opt.DescW+Opt.StatW+Opt.ProgW*0.08 Opt.RowH*(Opt.MaxJobs-RowID+0.1) Opt.ProgW*0.8 Opt.RowH*0.8],...
                                         'LineStyle', 'none',...
                                         'FaceColor', Opt.ProgC);
        hOut.hProgBox = annotation(hFig, 'rectangle', [0 0 0.1 0.1],...
                                         'Units', Opt.Units,...
                                         'Position', [Opt.DescW+Opt.StatW+Opt.ProgW*0.08 Opt.RowH*(Opt.MaxJobs-RowID+0.1) Opt.ProgW*0.8 Opt.RowH*0.8],...
                                         'LineStyle', '-');
    end        
    hOut.hProgText = annotation(hFig, 'textbox', [0 0 0.1 0.1],...
                                      'Units', Opt.Units,...
                                      'Position', [Opt.DescW+Opt.StatW Opt.RowH*(Opt.MaxJobs-RowID) Opt.ProgW Opt.RowH],...
                                      'LineStyle', 'none');
                               
end