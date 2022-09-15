function x3 = pur_filter_nan2(x, k)

b  = fir1( 150, k);
b2 = fir1( 75,  k);
b3 = fir1( 20,  k);

x3 = x;
s1 = 1;
i  = 1;
s0 = [];

% Remember we need to keep track of whether there was a NaN
% if not we need to filter the all thing
once = 0;

while i <= length(x)
   %
   if isnan(x(i))
      once = 1;
      
      %keyboard;
      
      % We now have a Nan, so filter just this part
      if length(x(s1:i-1)) > 150 *3
         x2 = filtfilt(b, 1, x(s1:i-1));
         
      elseif length(x(s1:i-1)) > 75*3 
         x2 = filtfilt(b2, 1, x(s1:i-1)); 
         
      elseif length(x(s1:i-1)) > 20*3 
         x2 = filtfilt(b3, 1, x(s1:i-1)); 
         
      elseif length(x(s1:i-1)) > 20*3 % Short so use a running average
          x2=filtfilt([0.333 0.333 0.333],1,x(s1:i-1));
          
      else %super short, do nothing
          x2=x(s1:i-1);
          
      end
      
      x3(s1:i-1)=x2;
      
      for j = i : length(x)
         if ~isnan(x(j))
            i  = j-1;
            s0 = j; 
            s1 = j;
            %i is now the starting point of numbers 
            break
         end %
      end %for j            
   end
   i = i + 1;
   
end %while

if ~once
   x3 = filtfilt(b,1,x);
end

% Filter any remainder after the NaN to the end
if once
% We now have a Nan, so filter just this part
   if length(x(s0:i-1)) > 150 *3
      x2 = filtfilt(b, 1, x(s0:i-1));
      
   elseif length(x(s0:i-1)) > 75*3 
      x2 = filtfilt(b2, 1, x(s0:i-1)); 
      
   elseif length(x(s0:i-1)) > 20*3 
      x2 = filtfilt(b3, 1, x(s0:i-1)); 
      
   elseif length(x(s0:i-1)) > 20*3 % Short so use a running average
      x2=filtfilt([0.333 0.333 0.333],1,x(s0:i-1));
      
   else %super short, do nothing
      x2=x(s0:i-1);
      
   end
    
   %keyboard;
   x3(s0:i-1)=x2;
   %keyboard;
end




