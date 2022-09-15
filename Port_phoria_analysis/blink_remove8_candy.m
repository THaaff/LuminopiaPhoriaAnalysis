function [blink_count, xx2, yy2] = blink_remove8_candy(t,x,y)

DEBUG1  = 0;
DEBUG2  = 0;
DEBUG3  = 0;

t = double(t - t(1));

% 1/12/2011
% First filter x y to remove noise


% Remove all large values % With the SR Research tools (circa 2020) missing
% data goes postive to 10,0000 (or something like that)



% fixing blink_remove 2/15/2021
% if DEBUG 
%    keyboard
% end

ix=find(x>2000);
iy=find(y>2000);
x2 = double(x);
y2 = double(y);
x2(ix)=NaN;
y2(iy)=NaN;
k_list = [];

k = 0;
for i = 2:length(y2)-1
   
%    if ~isnan(y2(i-1)) && isnan(y2(i))
%       x2(i-49:i) = NaN;
%       y2(i-49:i) = NaN;
%    end
   if ~isnan(y2(i-1)) && isnan(y2(i))
       if i-49 < 1 % in case index is too close to beginning
            x2(1:i) = NaN;
            y2(1:i) = NaN;          
       else % number of samples before blink turned to NaN's
            x2(i-49:i) = NaN;
            y2(i-49:i) = NaN;
       end
   end
   if isnan(y2(i)) && ~isnan(y2(i+1))
      k = k + 1;
      k_list(k,1) = i+1;
      k_list(k,2) = i+100;
   end
end

for i = 1:length(k_list)
   x2(k_list(i,1) :k_list(i,2) ) = NaN;
   y2(k_list(i,1) :k_list(i,2) ) = NaN;
end


x3 = filter_nan8b(x2);
y3 = filter_nan8b(y2);

dx  = gradient(x3,t).*1000;
dy  = gradient(y3,t).*1000;

%dx2 = filter_nan8(dx);
%dy2 = filter_nan8(dy);

ddx  = gradient(dx,t).*1000;
ddy  = gradient(dy,t).*1000;


if DEBUG1
   dh1 = figure;
   hold on
   
   %plot(t,x,'b--');
   %plot(t,y,'r--');
   
   plot(t,x3,'g-','LineWidth',2);
   plot(t,y3,'m-','LineWidth',2);
   
   set(gca,'ylim',[0 1600]);
   %set(gca,'xlim',[280000 284000])

end

if DEBUG2
   dh2 = figure;
   hold on
   plot(t,dx, 'b-');
   plot(t,dy, 'r-');
   
   dh3 = figure;
   hold on
   plot(t,ddx, 'b-');
   plot(t,ddy, 'r-');
   
   %plot(t,dx2,'c-');
   %plot(t,dy2,'m-');
   
end

% Not currently needed 

% x  = filtfilt(fir1(50, 0.250), 1, double(x) );
% y  = filtfilt(fir1(50, 0.250), 1, double(y) );
% 
% 
% 
% dx  = gradient(x,t).*1000;
% dy  = gradient(y,t).*1000;
% dx  = filtfilt(fir1(50, 0.250), 1, dx );
% dy  = filtfilt(fir1(50, 0.250), 1, dy );
    

% if DEBUG
%    figure(dh1);
%    hold on
%    plot(t,x,'b-');
%    plot(t,y,'r-');
%    %set(gca,'ylim',[0 1600]);
%    %set(gca,'ylim',[0 1600]);
%    dh2 = figure;
%    hold on
%    plot(dx,'b-');
%    plot(dy,'r-');
%    set(gca,'ylim',[-20000 20000]);
% 
%    
% end


% Not Needed
         
i = 1;
blink_count = 0;


%keyboard

% Not needed for the cleaner data files

%{  

while i < length(y2) 
   
   i = i + 1;
   if isnan(y2(i)) % We have trimmed the blinks/signal loss to NAN
      
      % Go backwards and search for the zero cross
      for j = i:-1:1
         if ddy(j) <= 0
            s1 = j;
            break
         end
      end
      
      y2(s1:i) = NaN;
      
      %keyboard
   end %isnan
   
   if isnan(y2(i-1)) && ~isnan(y2(i))         
      
      % Go forward and search for the zero cross
      for j = i:1:length(y2)
         if ddy(j) <= 0
            s2 = j;
            %keyboard
            break
         end
      end
      
      y2(i:s2) = NaN;
      
      i = s2+1;
      
   end
   
end


%}




if DEBUG2
   
   figure
   hold on
   plot(t,x2,'c-');
   plot(t,y2,'m-','LineWidth',2);
   
   %plot(t,x,'b.');
   %plot(t,y,'r.');
   
   set(gca,'ylim',[0 1600]);


   keyboard;

end







% This loop shows the data in managable chunks
if DEBUG3
   
    % chunks in terms of indices, each index is 2 milliseconds!
   i1 = 1;
   i2 = 1000;
   
   while i1 < length(t)
      figure
      hold on
%       plot(t(i1: i2),x2(i1:i2),'b-');
%       plot(t(i1: i2),y2(i1:i2),'r-');
%       plot(t(i1: i2),x3(i1:i2),'g-');
%       plot(t(i1: i2),y3(i1:i2),'m-');

      plot(t(i1: i2),x(i1:i2),'b-'); % data with blinks
      plot(t(i1: i2),y(i1:i2),'r-'); % data with blinks
      plot(t(i1: i2),x3(i1:i2),'g-'); % data with blinks removed
      plot(t(i1: i2),y3(i1:i2),'m-'); % data with blinks removed
      
      set(gca,'ylim',[0 1600])
      
      pause(3)
      
      % Increment
      i1 = i2;
      i2 = i2+1000;
      
   end
   
   
end



%keyboard

% What to pass back - x2,y2 the unsmoothed data

xx2 = x2;
yy2 = y2;

% fini

