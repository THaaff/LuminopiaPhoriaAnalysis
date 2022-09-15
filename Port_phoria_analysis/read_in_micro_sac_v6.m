function [d, edf_d] = read_in_micro_sac_v6(dir, fn, od_os )


DEBUG  = 0;
DEBUG2 = 0;
edf_d = [];
PIX2DEG = 13.3/800; 
DEG2PIX = 800/13.2;

load([dir,'/',fn]);

USE_OLD_SAC_DETECT = 1;

if strcmp(fn(2),'_')
   s2 = 1;
elseif strcmp(fn(3),'_')
   s2 = 2;
elseif strcmp(fn(4),'_');
   s2 = 3;
elseif strcmp(fn(5),'_');
   s2 = 4;
else
   keyboard;
end

%keyboard;

if exist([dir '/' fn(1:s2) '.edf'],'file')
   data2=edfmex([dir '/' fn(1:s2) '.edf']);
   
   
   
   % Parse the EDF file
   type       = 0;
   
   
   % First the times of the events from our experiment
   for i = 1:length(data2.FEVENT)
      %disp(data2.FEVENT(i).message);
      
      % Find the word type
      if ~isempty(data2.FEVENT(i).message)
         
         if strcmp(data2.FEVENT(i).message(1:4), 'type')
            type       = type + 1;
            edf_d(type).type_time = data2.FEVENT(i).sttime;
         elseif strcmp(data2.FEVENT(i).message(1:6), 'step_2')
            edf_d(type).step2_time = data2.FEVENT(i).sttime;
            
         elseif strcmp(data2.FEVENT(i).message(1:6), 'step_3')
            edf_d(type).step3_time = data2.FEVENT(i).sttime;
            %if type == 17
            %   keyboard
            %end
         elseif strcmp(data2.FEVENT(i).message(1:6), 'step_3')
            edf_d(type).step3_time = data2.FEVENT(i).sttime;
            
         elseif strcmp(data2.FEVENT(i).message(1:6), 'step_5')
            edf_d(type).step5_time = data2.FEVENT(i).sttime;
            
         elseif strcmp(data2.FEVENT(i).message, 'step_6')
            edf_d(type).step6_time = data2.FEVENT(i).sttime;
            
         elseif strcmp(data2.FEVENT(i).message, 'step_error')
            % When there is an error, store the time in step6_time
            % This will be the end of the trial, the subject probably didn't
            % finish the trial, trial was to hard
            edf_d(type).step_error = data2.FEVENT(i).sttime;
            edf_d(type).step6_time = data2.FEVENT(i).sttime;
            %keyboard;
            
         end
         
      else
         
         if strcmp(data2.FEVENT(i).codestring, 'ENDSAMPLES') && type >= 1 %skip the first endsamples before the experiment has begun
            edf_d(type).endsamples_time = data2.FEVENT(i).sttime;
         end
         
      end %~isemtpy
      
   end
   
   %Parse EDF eye data
   type = 1;
   start_i = 1;
   fprintf('%s',' Parse EDF file:');
   for type = 1:length(edf_d)
      fprintf('%1.0f',type);
      j = 0;
      for i = start_i : length(data2.FSAMPLE.time);
         
         %disp(data2.FSAMPLE.time(i));
         if data2.FSAMPLE.time(i) > edf_d(type).step2_time & ...
               data2.FSAMPLE.time(i) < edf_d(type).step6_time
            j = j + 1;
            edf_d(type).t(j)  = data2.FSAMPLE.time(i);
            edf_d(type).x1(j) = data2.FSAMPLE.gx(1,i);
            edf_d(type).x2(j) = data2.FSAMPLE.gx(2,i);
            edf_d(type).y1(j) = data2.FSAMPLE.gy(1,i);
            edf_d(type).y2(j) = data2.FSAMPLE.gy(2,i);
            
            
         elseif  data2.FSAMPLE.time(i) > edf_d(type).step6_time
            start_i = i;
            break
         end
         
      end %i
   end %type
   fprintf('\n');
   
   
   
   
else
   %do nothing
   
end



for type = 1:length(edf_d)
   
   %   EXAMPLE CODE FROM ELI
   %    % concatenate vertical and horizontal gaze position
   %    eyepos = cat(2, xPos, yPos);
   %    % compute eye velocity
   %    vel = vecvel(eyepos, 1000, 3);
   %    % detect microsaccades
   %    mindur = 9;
   %    vthresh = 6;
   %    sacs = microsacc(eyepos, vel, vthresh, mindur);
   %
   
  
   %
   % In Pixels
   %
   
   % Make sure there is data and it not bogus (all missing signal)
   if ~isempty(edf_d(type).x1) && ...
        ~(max(edf_d(type).x1)==-32768 ) && ...
     length(edf_d(type).x1) > 99
     
  
  
       % Get the EDF eye signals
      t  = double( edf_d(type).t  );
      x1 = double( edf_d(type).x1 ); % OS Eye
      x2 = double( edf_d(type).x2 ); % OD EYE
      y1 = double( edf_d(type).y1 );
      y2 = double( edf_d(type).y2 );
      
      % Better do some processing to fill-in and smooth
      x1 = fill_nan3(x1, 50 );
      x2 = fill_nan3(x2, 50 );
      y1 = fill_nan3(y1, 50 );
      y2 = fill_nan3(y2, 50 );
      
      % Remove blinks
      [edf_d(type).blinks1, x1, y1] = blink_remove5(t,x1,y1);
      [edf_d(type).blinks2, x2, y2] = blink_remove5(t,x2,y2);
      
      
      
      % Now Filter
      x1 = filter_nan5(double(x1), .2 ); % 0.005
      x2 = filter_nan5(double(x2), .2 ); % 0.005
      y1 = filter_nan5(double(y1), .2 ); % 0.005
      y2 = filter_nan5(double(y2), .2 ); % 0.005
      
      % June 5, 2013
      % Make outlier data points NaN's
     
      x1(x1 > 2000) = NaN;
      y1(y1 > 2000) = NaN;
      x2(x2 > 2000) = NaN;
      y2(y2 > 2000) = NaN;
      
     
      
      
      edf_d(type).x1 = x1; %filter_nan5(double(x1), .2 ); % 0.005
      edf_d(type).x2 = x2; %filter_nan5(double(x2), .2 ); % 0.005
      edf_d(type).y1 = y1; %filter_nan5(double(y1), .2 ); % 0.005
      edf_d(type).y2 = y2; %filter_nan5(double(y2), .2 ); % 0.005

      %%Step 1
      %%
      
       % Make Velocity Strcutres
       vel  = vecvel([edf_d(type).x1' edf_d(type).y1'], 1000,2);% type was 3
       vel2 = vecvel([edf_d(type).x2' edf_d(type).y2'], 1000,2); %type was 3
       
       
       
       % DEBUGING for VELOCITY  - The Engbert Velocity system gives similar results to gradient
       % Save for future testingg
       %figure
       %hold on
       %plot(t-t(1),gradient(x1,t)*1000,'g-');
       %plot(t-t(1), vel(:,1),'b-');
       %set(gca,'xlim',[0 1000]);
       %keyboard;
       
       
       %inits 
       edf_d(type).sac    = [];
       edf_d(type).sac2   = [];
       edf_d(type).sac_bi = [];
       
       edf_d(type).radius  = [];
       edf_d(type).radius2 = [];
       
       % START CHECKING THIS VELOCITY STUFF - THE VEL VECTORS ARE NOT THE SAME
       % LENGTH AS THE POSITION VECTORS
       
       % Monocular Microsaccade Dector
       if strcmp(od_os, 'OU') || strcmp(od_os, 'OS')
          if USE_OLD_SAC_DETECT
             [ edf_d(type).sac, edf_d(type).radius] = ...
                microsacc2([edf_d(type).x1' edf_d(type).y1'], vel,10,9); %Was ...vel2,6,9 ), tring 8,9, trying 10, 11
             
          else
             [ edf_d(type).sac, edf_d(type).radius] = ...
                microsacc2_nlp2([edf_d(type).x1' edf_d(type).y1'], vel,10,9); %Was ...vel2,6,9 ), tring 8,9, trying 10, 11
          end
       end
       
       if strcmp(od_os, 'OU') || strcmp(od_os, 'OD')
          if USE_OLD_SAC_DETECT
             [ edf_d(type).sac2, edf_d(type).radius2] = ...
                microsacc2([edf_d(type).x2' edf_d(type).y2'], vel2,10,9); %Was ...vel2,6,9 ), trying 8,9
          else
             [ edf_d(type).sac2, edf_d(type).radius2] = ...
                microsacc2_nlp2([edf_d(type).x2' edf_d(type).y2'], vel2,10,9); %Was ...vel2,6,9 ), trying 8,9
          end
       end
       
       if strcmp(od_os, 'OU') 
          edf_d(type).sac_bi = binsacc(edf_d(type).sac, edf_d(type).sac2);
       end
       
       % Store values
       edf_d(type).vel  = vel;
       edf_d(type).vel2 = vel2;

       
       
       % Do Some Eye Kinematic anaylsis
       for i = 1:size(edf_d(type).sac_bi,1)
          s1 = edf_d(type).sac_bi(i,1); % Sac Onset
          s2 = edf_d(type).sac_bi(i,2); % Sac Onset
          
          
          
          % Starting eye positions
          x1_s1 = edf_d(type).x1(s1);
          y1_s1 = edf_d(type).y1(s1);
          x2_s1 = edf_d(type).x2(s1);
          y2_s1 = edf_d(type).y2(s1);
          % Ending eye positions
          x1_s2 = edf_d(type).x1(s2);
          y1_s2 = edf_d(type).y1(s2);
          x2_s2 = edf_d(type).x2(s2);
          y2_s2 = edf_d(type).y2(s2);
          % Saccade Size
          xs1=mean([x1_s1 x2_s1]);
          ys1=mean([y1_s1 y2_s1]);
          xs2=mean([x1_s2 x2_s2]);
          ys2=mean([y1_s2 y2_s2]);
             
          % Saccade Amplitude
          edf_d(type).sac_amp(i) = sqrt( (ys2-ys1).^2 + (xs2-xs1).^2 ); %Can be NaN because saccade stop is in a blink
          
          % Saccade Direction
          %edf_d(type).sac_dir(i) = 180/pi * ...
          %   atan2( ys2 - ys1, xs2 - xs1 );
          edf_d(type).sac_dir(i) = atan2d( (1200-ys2) - (1200-ys1), xs2 - xs1 );
          
          
          if edf_d(type).sac_dir(i) < 0
             edf_d(type).sac_dir(i) = 360 + edf_d(type).sac_dir(i);
          end
          
          %Store Eye Staring Position
          edf_d(type).x1_s1(i) = x1_s1;
          edf_d(type).y1_s1(i) = y1_s1;
          edf_d(type).x2_s1(i) = x2_s1;
          edf_d(type).y2_s1(i) = y2_s1;
          %Store Eye Ending Position
          edf_d(type).x1_s2(i) = x1_s2;
          edf_d(type).y1_s2(i) = y1_s2;
          edf_d(type).x2_s2(i) = x2_s2;
          edf_d(type).y2_s2(i) = y2_s2;
          % Store Binoccular Eye Start and End Positions
          edf_d(type).xs1(i) = xs1;
          edf_d(type).ys1(i) = ys1;
          edf_d(type).xs2(i) = xs2;
          edf_d(type).ys2(i) = ys2;
          
          % Store Time Values
          edf_d(type).sac_start(i) = s1; 
          edf_d(type).sac_stop(i) = s2; 
          edf_d(type).sac_dur(i) = edf_d(type).t(s2)-edf_d(type).t(s1);  %Sac Duration
          if i == 1
             edf_d(type).sac_isi(i) = NaN ; %Inter Saccade Interval
          else
             edf_d(type).sac_isi(i) = edf_d(type).t(s1) - ...
                edf_d(type).t( edf_d(type).sac_stop(i-1) );
          end
          
          % Find the Peak Velocities
          edf_d(type).sac_pv_a(i) = edf_d(type).sac_bi(i,3);
          %
          x_ = nanmean([x1(s1:s2)' x1(s1:s2)'],2);
          y_ = nanmean([y1(s1:s2)' y1(s1:s2)'],2);
          d_ = sqrt( (y_-y_(1)).^2 + (x_-x_(1)).^2 );
          t_ = t(s1):t(s2);
          v_ = gradient(d_,t_)*1000;
          edf_d(type).sac_pv_b(i) = max(v_);
          
          
          if DEBUG2
             figure; hold on;
             plot(t_,x_,'b-');
             plot(t_,y_,'r-');
             figure
             plot(t_,v_);
             keyboard;
          end
          
          
          clear x_ y_ d_ t_ v_
          %clear x1 x2 y1 y2
          

       end
       
       
   else
      edf_d(type).sac    = [];
      edf_d(type).sac2   = [];
      edf_d(type).sac_bi = [];
      
      edf_d(type).radius  = [];
      edf_d(type).radius2 = [];
      
   end
    % In DEG of visual angle
   % vel    = vecvel([edf_d(type).x1'*PIX2DEG edf_d(type).y1'*PIX2DEG], 1000,3);
   % [ edf_d(type).sac edf_d(type).radius] = ...
   %    microsacc([edf_d(type).x1' edf_d(type).y1'], vel,6*PIX2DEG,9*PIX2DEG);



end


%
if DEBUG
   for type = 1:20
      

      
      
    
      t  = double(edf_d(type).t);
      x1 =        edf_d(type).x1;
      x2 =        edf_d(type).x2;
      y1 =        edf_d(type).y1;
      y2 =        edf_d(type).y2;
      
      
      hf1 = figure;
      subplot(3,1,1);
      hold on
      set(gca,'ylim',[0 1600]);
      title('Eye #1')
      plot(t, x1,'b-')
      plot(t, y1,'r-')

      if ~isempty(edf_d(type).sac)
         sac_onset = edf_d(type).sac(:,1); %Onset
         for i = 1:length(sac_onset)
            plot([t(sac_onset(i)) t(sac_onset(i))],[0 1600],'g-' );
            text(t(sac_onset(i)),200,num2str(i));
         end
      end
      
            
      subplot(3,1,2);
      hold on
      set(gca,'ylim',[0 1600]);
      title('Eye #2')
      plot(t, x2,'b-')
      plot(t, y2,'r-')
      
      if ~isempty(edf_d(type).sac2)
         sac_onset = edf_d(type).sac2(:,1);
         for i = 1:length(sac_onset)
            plot([t(sac_onset(i)) t(sac_onset(i))],[0 1600],'g-' );
         end
      end
      
      subplot(3,1,3);
      hold on
      set(gca,'ylim',[0 1600]);
      title('BOTH #2')
      plot(t, x1,'b-')
      plot(t, x2,'c-')
      plot(t, y1,'r-')
      plot(t, y2,'m-')
      
      if ~isempty(edf_d(type).sac_bi)
         
         %sac_onset  = edf_d(type).sac_bi(:,1);
         %sac_offset = edf_d(type).sac_bi(:,2);
         
         sac_x = edf_d(type).sac_bi(:,4);
         sac_y = edf_d(type).sac_bi(:,5);
         sac_dx = edf_d(type).sac_bi(:,6);
         sac_dy = edf_d(type).sac_bi(:,7);
         
         for i = 1:size(edf_d(type).sac_bi,1)
            
            sac_onset  = edf_d(type).sac_start(i);
            sac_offset = edf_d(type).sac_stop( i);
            
            
            plot([t(sac_onset ) t(sac_onset ) ],[0 1600],'g-' );
            plot([t(sac_offset) t(sac_offset) ],[0 1600],'k-' );
            
            
            %text(t(sac_offset),1000,num2str(sac_x(i), '%4.1f') );
            %text(t(sac_offset),900, num2str(sac_y(i), '%4.1f') );
            %text(t(sac_offset),800, num2str(sac_dx(i),'%4.1f') );
            %text(t(sac_offset),700, num2str(sac_dy(i),'%4.1f') );
            text(t(sac_offset),600, num2str(edf_d(type).sac_amp(i),'%4.1f') );

            plot(t(sac_onset ), edf_d(type).x1_s1(i),'g.','MarkerSize',16);
            plot(t(sac_onset ), edf_d(type).x2_s1(i),'g.','MarkerSize',16);
            plot(t(sac_onset ), edf_d(type).y1_s1(i),'g.','MarkerSize',16);
            plot(t(sac_onset ), edf_d(type).y2_s1(i),'g.','MarkerSize',16);
            
            plot(t(sac_offset ), edf_d(type).x1_s2(i),'k.','MarkerSize',16);
            plot(t(sac_offset ), edf_d(type).x2_s2(i),'k.','MarkerSize',16);
            plot(t(sac_offset ), edf_d(type).y1_s2(i),'k.','MarkerSize',16);
            plot(t(sac_offset ), edf_d(type).y2_s2(i),'k.','MarkerSize',16);
            
            
         end %for i
      end %if ~isempty sac_bi
      
      
      figure
      hold on
      set(gca,'xlim',[0 1600])
      axis equal
      plot(nanmean([x1' x2'],2),nanmean([y1' y2'],2),'k-');
      for i = 1:size(edf_d(type).sac_bi,1)
         plot( [ edf_d(type).xs1(i) edf_d(type).xs2(i) ], ...
               [ edf_d(type).ys1(i) edf_d(type).ys2(i) ], 'r-','LineWidth',2);
         plot(  edf_d(type).xs1(i), edf_d(type).ys1(i),'r.','MarkerSize',12); 
         text( edf_d(type).xs2(i)+20, edf_d(type).ys2(i), ...
            num2str(edf_d(type).sac_dir(i),'%3.0f'),'FontSize',14);
      end
      %keyboard;
      
   end
end

%d.edf_d = edf_d;
%d.edf_

%keyboard;























%
