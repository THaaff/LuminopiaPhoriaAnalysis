function x3 = filter_nan5(x, k)

DEBUG = 0;
all_nans = 0;

b  = fir1( 50, k);
b2 = fir1( 20, k);

x3 = x;
s1 = 1;
i  = 1;
s0 = [];

% Remember we need to keep track of whether there was a NaN
% if not we need to filter the all thing
once = 0;

while i <= length(x)
   %
   if isnan(x(i));
      once = 1;
      
      %keyboard;
      
      % We now have a Nan, so filter just this part
      if length(x(s1:i-1)) > 50 *3
         x2 = filtfilt(b, 1, x(s1:i-1));
      elseif length(x(s1:i-1)) > 20*3 
         x2 = filtfilt(b2, 1, x(s1:i-1));         
      elseif length(x(s1:i-1)) > 20*3 % Short so use a running average
          x2=filtfilt([0.333 0.333 0.333],1,x(s1:i-1));
      else %suprt short, do nothing
          x2=x(s1:i-1);
      end
      
      x3(s1:i-1)=x2;
      %keyboard
      
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
            %keyboard;
            all_nans = 1;
            break
         end % if ~isnan
         
      end %for j
      
      
   end %isnan(x(i))
   i = i + 1;
   
end %while

%if ~once
%   x3 = filtfilt(b,1,x);
%end
%keyboard;

% Filter any remainder after the NaN to the end
if once & ~all_nans
% We now have a Nan, so filter just this part
   if length(x(s0:i-1)) > 50 *3
      x2 = filtfilt(b, 1, x(s0:i-1));
   elseif length(x(s0:i-1)) > 20*3 
      x2 = filtfilt(b2, 1, x(s0:i-1));         
   elseif length(x(s0:i-1)) > 20*3 % Short so use a running average
      x2=filtfilt([0.333 0.333 0.333],1,x(s0:i-1));
   else %suprt short, do nothing
      x2=x(s0:i-1);
   end
    
   %keyboard;
   x3(s0:i-1)=x2;
   %keyboard;
end

% No NAN's where found, just filter
if ~once
   x3 = filtfilt(b,1,x);
end

%keyboard;

if DEBUG
   figure
   hold on;
   plot(x, 'b-');
   plot(x3,'r-');
end %DEBUG
%keyboard;

%disp('filter_nan4_fix Done..');




