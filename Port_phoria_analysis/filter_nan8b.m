function x5 = filter_nan8b(x)


% This filter has the new double filter to attempt to filter out more high
% frequency.  The idea is pass it through a stronger filter with a higher
% cut off and then a second weaker filter with a lower cut off.

% k is no longer used

DEBUG    = 0;
all_nans = 0;





%x3 = x;
x5 = x;

s1 = 1;
i  = 1;
s0 = [];


      
 
D_50 = designfilt('lowpassfir','FilterOrder',50,...
   'PassbandFrequency',10, ...    % 2.0
   'StopbandFrequency',60,...     % 105
   'SampleRate',500,     ...
   'DesignMethod','equiripple');

% D2_50 = designfilt('lowpassfir','FilterOrder',50,...              % 2.5 & 31 good  :  2 & 34.5 good
%    'PassbandFrequency',2,  ...       % 3.0   
%    'StopbandFrequency',30, ...       % 42   
%    'SampleRate',1000,      ...
%    'DesignMethod','equiripple'); %ls

D_20 = designfilt('lowpassfir','FilterOrder',20,...
   'PassbandFrequency',10, ...          % 2.2
   'StopbandFrequency',60,...           % 105
   'SampleRate',500,     ...
   'DesignMethod','equiripple');

% D2_20 = designfilt('lowpassfir','FilterOrder',20,...
%    'PassbandFrequency',2,...       % 3.2
%    'StopbandFrequency',30,...      % 42
%    'SampleRate',1000,      ...
%    'DesignMethod','equiripple'); %ls


% Debugging tools - This code should be what you need to describe the
% filters for publication

% fvtool(D_50, D_20);
% legend(h_filt,'D_50','D2_50');
    
      
% Remember we need to keep track of whether there was a NaN
% if not we need to filter the all thing
once = 0;

while i <= length(x)
   %
   if isnan(x(i));
      once = 1;
      
      % We now have a Nan, so filter just this part
      if length(x(s1:i-1)) > 50 *3
         x4 = filtfilt(D_50,  x(s1:i-1) );
         %x4 = filtfilt(D2_50, x4 );        
         
      elseif length(x(s1:i-1)) > 20*3 
         x4 = filtfilt(D_20,  x(s1:i-1) );
         %x4 = filtfilt(D2_20, x4 );
         
      elseif length(x(s1:i-1)) > 20*3 % Short so use a running average
          x4=filtfilt([0.333 0.333 0.333],1,x(s1:i-1));
          
      else %super short, do nothing
          x4=x(s1:i-1);
      end
      
      x5(s1:i-1)=x4;
      
      
      for j = i : length(x)
         if ~isnan(x(j))
            i  = j-1;
            s0 = j; 
            s1 = j;
            %i is now the starting point of numbers 
            break
         elseif j == length(x) %no more data, just NaN's

            i = length(x); %move i to the end  
            %once = 0; %We are at the end of the data set, set once to zero
                      %because there are no remainders
            all_nans = 1;
            break
         end % if ~isnan
         
      end %for j
      
      
   end %isnan(x(i))
   i = i + 1;
   
end %while



% Filter any remainder after the NaN to the end
if once & ~all_nans
% We now have a Nan, so filter just this part
   if length(x(s0:i-1)) > 50 *3
      x4 = filtfilt(D_50, x(s0:i-1) );
      %x4 = filtfilt(D_50, x4        );      
      
   elseif length(x(s0:i-1)) > 20*3 
      x4 = filtfilt(D_20,  x(s0:i-1) );         
      %x4 = filtfilt(D2_20, x4        );      
      
   elseif length(x(s0:i-1)) > 20*3 % Short so use a running average
      x4=filtfilt([0.333 0.333 0.333],1,x(s0:i-1));
   else %too short, do nothing
      x4=x(s0:i-1);
   end
       
   x5(s0:i-1)=x4;
   
end

% No NAN's where found, just filter
if ~once
   x5 = filtfilt(D_50,    x );
   %x5 = filtfilt(D2_50,   x5);
end


if DEBUG
   figure
   hold on;
   plot(x, 'b-');
   plot(x5,'r-','Linewidth',2);
   keyboard;
end %DEBUG




%disp('filter_nan4_fix Done..');







