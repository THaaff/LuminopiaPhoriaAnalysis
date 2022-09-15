% plot vergence angles on edf files with no associated struct or time file

%%
% Uses
% t1
% x1, y1, x2, y2
% datainterval
% xprism, yprism
% timeindices1, timeindices2

%%
% x_diff = x1 - x2;
% y_diff = y1 - y2;
% 
% %% convert to pd
% 
% %%
% % Convert pixels to degrees to prism diopters
% % Dimensions of screen in pixels and centimeters
% screen_xpix = 1920;
% screen_xcm = 93;
% screen_ypix = 1080;
% screen_ycm = 52.5;
% 
% %Distance from screen to subject's eyes in centimeters
% view_distance_cm = 70; %1/27/21 viewing distance is closer to 71-72 with new mirror setup
% 
% %Convert pixels to centimeters
% ourdata_x = x_diff*(screen_xcm/screen_xpix);
% ourdata_y = y_diff*(screen_ycm/screen_ypix);
% 
% %Convert centimeters to degrees
% xdegrees = atand(ourdata_x/view_distance_cm);
% ydegrees = atand(ourdata_y/view_distance_cm);
% 
% %Convert degrees to prism diopters
% xprism = xdegrees*1.785;
% yprism = ydegrees*1.785;

%% plot

% time length of each chunck in millisecs
i1 = datainterval(1);
i2 = datainterval(2);
%
% while i1 < length(t1)
%     figure
%     hold on
%     set( gca, 'ylim', [-10   10  ]);
%     set( gca, 'xlim', [i1  i2    ]);
%
%     plot(t1,xprism,'b-'); % x = blue
%     plot(t1,yprism,'r-'); % y = red
%
%
%     pause(5)
%
%     % Increment
%     i1 = i2;
%     i2 = i2+2000;
%
% end

% figure
% hold on
% set( gca, 'ylim', [-10   10  ]);
%
% plot(t1,xprism,'b-'); % x = blue
% plot(t1,yprism,'r-'); % y = red

figure
hold on
set( gca, 'ylim', [-10   10  ]);
set( gca, 'xlim', [i1  i2    ]);

plot(t1(timeindices1:timeindices2),xprism,'b-'); % x = blue
% plot(t1(timeindices1:timeindices2),yprism,'r-'); % y = red


pause(5)
