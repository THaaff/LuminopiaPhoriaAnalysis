%{
adjustment of code written w/ Nick Port for the Luminopia protocol analysis

changed to only analyze data received from pre-phoria test

Need signal processing toolbox and mac OS laptop to run this script
Also need Statistics and Machine Learning Toolbox
%}

close all;
clear all;

dbstop if error


%COLORS
RED       = [0.90 0.00 0.15 ];
MAGENTA   = [0.80 0.00 0.80 ];
ORANGE    = [1.00 0.50 0.00 ];
YELLOW    = [1.00 0.68 0.26 ];
GREEN     = [0.10 0.90 0.10 ];
CYAN      = [0.28 0.82 0.80 ];
BLUE      = [0.00 0.00 1.00 ];
BLACK     = [0.00 0.00 0.05 ];
GREY      = [0.46 0.44 0.42 ];
D_RED     = [0.63 0.07 0.18 ];
D_MAGENTA = [0.55 0.00 0.55 ];
D_ORANGE  = [1.00 0.30 0.10 ];
D_YELLOW  = [0.72 0.53 0.04 ];
D_GREEN   = [0.09 0.27 0.23 ];
D_BLUE    = [0.00 0.20 0.60 ];
D_CYAN    = [0.00 0.55 0.55 ];

% change to '1' when you decide to finally save the subject data
USE_BIG_DATA = 0;

% Feburary Debugging with Adam
% 2-15-2021


if ~USE_BIG_DATA
   
    % change to appropriate file names for phoria test
    % make sure old file folder 'testing_things' is NOT on the path
   sub(1).fn  = 'zlkn_p.edf';
   sub(1).t   = 'zlkn_p_time.mat';
   sub(1).str = 'zlkn_p-26-Apr-2022.mat';
   
   sub(2).fn  = 'zlkn2_p.edf';
   sub(2).t   = 'zlkn2_p_time.mat';
   sub(2).str = 'zlkn2_p-26-Apr-2022.mat';
   
   sub(3).fn  = 'rgbz_p.edf';
   sub(3).t   = 'rgbz_p_time.mat';
   sub(3).str = 'rgbz_p-27-Apr-2022.mat';
   
   sub(4).fn  = 'rgbz2_p.edf';
   sub(4).t   = 'rgbz2_p_time.mat';
   sub(4).str = 'rgbz2_p-27-Apr-2022.mat';
   
   for i = 1:2
      
      % Read in raw data
      sub(i).raw_edf=edfmex(sub(i).fn);
      load(sub(i).t);
      load(sub(i).str);
      
      % Find sync & stop time
      
      for j = 1:length(sub(i).raw_edf.FEVENT)
      
      
         if strcmp(sub(i).raw_edf.FEVENT(j).message,'SYNCTIME')
            sync_time = sub(i).raw_edf.FEVENT(j).sttime;
         end
         if strcmp(sub(i).raw_edf.FEVENT(j).message,'Stop Time')
            stop_time = sub(i).raw_edf.FEVENT(j).sttime;
         end
         
      end
      
      sync_time_ind = find(sub(i).raw_edf.FSAMPLE.time >= sync_time,1);
      stop_time_ind = find(sub(i).raw_edf.FSAMPLE.time >= stop_time,1);
      
      
      t1 = sub(i).raw_edf.FSAMPLE.time(  sync_time_ind : stop_time_ind );
      x1 = sub(i).raw_edf.FSAMPLE.gx(1,  sync_time_ind : stop_time_ind );
      x2 = sub(i).raw_edf.FSAMPLE.gx(2,  sync_time_ind : stop_time_ind );
      y1 = sub(i).raw_edf.FSAMPLE.gy(1,  sync_time_ind : stop_time_ind );
      y2 = sub(i).raw_edf.FSAMPLE.gy(2,  sync_time_ind : stop_time_ind );
      
      % Set the time to start at 0
      t1 = (t1-t1(1)); % units of millisecs
      
      % switch sign for horizontal signal to accurately diagnose eso/exo
      % deviations
      % with this change, eso = positive and exo = negative
      x1 = -(x1);
      x2 = -(x2);
      
      
      % Do preprocessing
      
      % remove blinks
      [~, x1, y1]=blink_remove8_candy(t1, x1, y1);
      [~, x2, y2]=blink_remove8_candy(t1, x2, y2);
      
      % versions of the eye signal BEFORE saccades are removed (for
      % visualization later)
      x1_saccades = x1;
      y1_saccades = y1;
      x2_saccades = x2;
      y2_saccades = y2;
      
      vel  = vecvel([x1' y1'], 500,2);
      vel2 = vecvel([x2' y2'], 500,2);
      
      % detect saccades for each eye
      [sac_1, radius_1] = ...
         microsacc2_nlp2([x1' y1'], vel,7,7); % 2-16-21 - 8,7 %started with 10,9 % Vel, Duration
      [sac_2, radius_2] = ...
         microsacc2_nlp2([x2' y2'], vel,7,7); % 2-16-21 - 8,7 %started with 10,9 % Vel, Duration
      % binocular
      sac_bi = binsacc(sac_1, sac_2);      
      
      
      % Put NaNs in place of the saccade
      
      for i = 1:size(sac_bi,1)
         x1(sac_bi(i,1) : sac_bi(i,2) )=NaN;
         y1(sac_bi(i,1) : sac_bi(i,2) )=NaN;
         x2(sac_bi(i,1) : sac_bi(i,2) )=NaN;
         y2(sac_bi(i,1) : sac_bi(i,2) )=NaN;
      end
      
      % filtfilt filter
      x1 = filter_nan8b( x1 );
      y1 = filter_nan8b( y1 );
      x2 = filter_nan8b( x2 );
      y2 = filter_nan8b( y2 );
      
      % Check the saccade dector - this script shows saccades in meaningful
      % chunks
%       plot_saccades
      
      % Check vergence angle
      % plot_vergence
      
%       keyboard
      
      %% Time setup
      % time files were named 'ans' while we were manuall saving them after each
      % trial
      % now that we automated the process, time files are named 'tyme' as they
      % are reffered in the actual script
      % so, these few lines simply account for the possibilities of there being
      % different names for the same time file since we don't want to have to go
      % back and change all of the trials we've already run
      
      if exist('tyme','var') == 1
          ans = tyme;
      end
      
      t = (ans - ans(1))*1000; % start at 0 and convert to millisecs
      
%       keyboard
      
      %% NEED TO ADJUST THIS PART!!
      % Only take time values that represent stimulus presentation
      disp_t = t(15:26);
      % Append next logical value as next element to solve for difference later
      disp_t(13) = t(29);
      disp_t = disp_t - disp_t(1);
      disp_len = disp_t(end) - disp_t(1);
      
      %% plotting
      % Legend won't contain every element of patient.conditions
      set(0,'DefaultLegendAutoUpdate','off')
      
      %% Find and plot medians of each condition from time(condition(i)+1sec:condition(i+1)-1sec)
      x_diff = x1 - x2;
      y_diff = y1 - y2;
      
      % preallocating space
      results_medianx = [];
      results_mediany = [];
      perc25_x = [];
      perc75_x = [];
      perc25_y = [];
      perc75_y = [];
      
      for i = 1:length(disp_t)-1
          % Adding 1 seccond to account for vergence transition at
          % beginning of each viewing condition
          % datainterval = [disp_t(i)+1000 disp_t(i+1)];
          datainterval = [disp_t(i+1)-3000 disp_t(i+1)]; % only want the last 3 seconds of each condition

          % convert to double so interp1 can read
          double_t1 = double(t1);
          
          % find nearest index of time for the beginning and end of one
          % condition
          timeindices1 = interp1(double_t1,1:length(double_t1),datainterval(1),'nearest');
          timeindices2 = interp1(double_t1,1:length(double_t1),datainterval(2),'nearest');         
          
          %%
          % The data for ONE condition is between the two time indices
          ourdata_x = x_diff(timeindices1:timeindices2);
          ourdata_y = y_diff(timeindices1:timeindices2);
          
          %%
          % Convert pixels to degrees to prism diopters and plot
          %Dimensions of screen in pixels and centimeters
          screen_xpix = 1920;
          screen_xcm = 93;
          screen_ypix = 1080;
          screen_ycm = 52.5;
          
          %Distance from screen to subject's eyes in centimeters
          view_distance_cm = 70; %1/27/21 viewing distance is closer to 71-72 with new mirror setup
          
          %Convert pixels to centimeters
          ourdata_x = ourdata_x*(screen_xcm/screen_xpix);
          ourdata_y = ourdata_y*(screen_ycm/screen_ypix);
          
          %Convert centimeters to degrees
          xdegrees = atand(ourdata_x/view_distance_cm);
          ydegrees = atand(ourdata_y/view_distance_cm);
          
          %Convert degrees to prism diopters
          xprism = xdegrees*1.785;
          yprism = ydegrees*1.785;
          
          
          % check vergence for each viewing condition
          %           plot_vergence
          
          %           keyboard
          
          %% Interquartile range
          % upper and lower percentiles
          perc25_x(i) = prctile(xprism,25);
          perc75_x(i) = prctile(xprism,75);
          perc25_y(i) = prctile(yprism,25);
          perc75_y(i) = prctile(yprism,75);
          
          
          %%
          results_medianx(i) = nanmedian(xprism); % median value, ignoring NaN's
          results_mediany(i) = nanmedian(yprism); % median value, ignoring NaN's
          
      end
      
%       keyboard
      
      %% Normalize the data around the binocular full contrast viewing condition
      
      normalize_index = find(contains(patient.conditions,'bino_cross')); % find the index of the binocular full contrast condition within the random list of presented conditions
      normalize_index = normalize_index(1); % only take first occurence
      % subtract the binocular FC condition value from all other values to
      % normalize all conditions around the binocular FC condition
      normalize_medianx = results_medianx - results_medianx(normalize_index);
      normalize_mediany = results_mediany - results_mediany(normalize_index);
      
      
      %% Flip the axis if the subject had an exo deviation
      % x
      if mean(normalize_medianx) < 0
          normalize_medianx = normalize_medianx * (-1);
      end
      
      % y
      if mean(normalize_mediany) < 0
          normalize_mediany = normalize_mediany * (-1);
      end
      
      %% Figures
      
      % Median bins
      figure
      subplot(2,1,1)
      % Convert struct entries to categoricals so they can be used as labels and
      % are ordered
      bar(categorical(patient.conditions), normalize_medianx)
      hold on
      title('Normalized Median X Dissociation') % 'dissociation' and not just 'difference' because we flipped the axis if the subject tended to deviate outward (negative)
      xlabel('Conditions')
      ylabel('Prism Diopters')
      ylim([-10 20])
      er = errorbar(categorical(patient.conditions), normalize_medianx,perc25_x,perc75_x);
      er.Color = [0 0 0];
      er.LineStyle = 'none';
      hold off
      
      subplot(2,1,2)
      bar(categorical(patient.conditions), normalize_mediany)
      %bar(categorical(patient.conditions), results_mediany)
      hold on
      title('Normalized Median Y Dissociation')
      xlabel('Conditions')
      ylabel('Prism Diopters')
      ylim([-10 20])
      er = errorbar(categorical(patient.conditions), normalize_mediany,perc25_y,perc75_y);
      er.Color = [0 0 0];
      er.LineStyle = 'none';
      hold off
      
      keyboard
      
      %% CSV export
      
      % commenting this part out for now
      % don't currently need to export this data to csv format
      
%       stimulus = {};
%       contrast = {};
%       
%       for j = 1:length(patient.conditions)
%           temp_string = patient.conditions{j};
%       
%           stimulus{j} = temp_string(1:end-2);
%           if length(stimulus{j}) > 3 % remove the extra '_' at the end of some stimuli names
%               stimulus{j} = stimulus{j}(1:end-1);
%           end
%           contrast{j} = temp_string(end-1:end);
%           if contrast{j} == 'FC' % make it so all contrast levels are numbers
%               contrast{j} = replace(contrast{j},'FC','100');
%           end
%       
%       end
%       
%       name_trial = strcat(patient.name, '_', patient.trial);
%       
%       % compile data of median difference into cell array
%       excel_data = {'Subject', 'Dissociation_X', 'Dissociation_Y', 'Condition', 'Stimulus', 'Contrast';repmat({name_trial},1,30).', normalize_medianx.', normalize_mediany.', patient.conditions.', stimulus.', contrast.'};
%       
%       % designate the contents of each column so they are no longer nested
%       Name= excel_data{2,1};
%       Diss_X=excel_data{2,2};
%       Diss_Y=excel_data{2,3};
%       Condition=excel_data{2,4};
%       Stimulus=excel_data{2,5};
%       Contrast=excel_data{2,6};
%       
%       % combine designated contents into a single array
%       Combined_Matrix= [Name,  num2cell(Diss_X),  num2cell(Diss_Y), Condition, Stimulus, Contrast];
%       % re-define the titles of each column and add them to the top of each
%       % column
%       Titles={'Subject', 'Dissociation_X', 'Dissociation_Y', 'Condition', 'Stimulus', 'Contrast'};
%       Combined_Matrix=vertcat(Titles,Combined_Matrix);
%       
%       % change directory to desired save location
%       oldFolder = cd('~/Documents/Luminopia/Data/Data_analysis/Port_analysis/csv'); % save previous directory at the same time
%       
%       % save the array as a csv
%       filename = strcat(patient.name, '_', patient.trial, '.csv');
%       % writecell(Combined_Matrix, filename);
%       % add this comment back in when you're ready to save the files
%       
%       cd(oldFolder) % return to the previous directory so you don't have to keep navigating back to the subject's folder
%       
%       keyboard
   end
   
   % Save data structure
   % save BIG_DATA_2 sub
   
else
    
    load('BIG_DATA')
    
    % Do Analysis
    
    
end