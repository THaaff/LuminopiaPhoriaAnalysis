% Feb 2021 - Adam and Nick

% This script is checking how well the saccade detector
% Uses
% t1
% sac_bi
% x1, y1, x2, y2

% x1_saccades, x2_saccades, y1_saccades, y2_saccades

% time length of each chunck in millisecs
i1 = 1;
i2 = 2000;

while i1 < length(t1)
   figure
   hold on
   set( gca, 'ylim', [0   1600  ]);
   set( gca, 'xlim', [i1  i2    ]);
   
  %plot(t(i1: i2),x1(i1:i2),'b-');
  %plot(t(i1: i2),y1(i1:i2),'r-');
  
  %% saccades removed
  plot(t1,x1,'-o','MarkerSize',8,'MarkerEdgeColor',GREEN, 'Color',BLUE,'LineWidth',2, ...
    'MarkerIndices', sac_bi(:,1) ) %start of blink
  plot(t1,y1,'-o','MarkerSize',8,'MarkerEdgeColor',GREEN, 'Color',RED, 'LineWidth',2, ...
    'MarkerIndices', sac_bi(:,1) ) %start of blink

  % Other Eye 
  plot(t1,x2,'-o','MarkerSize',8,'MarkerEdgeColor',GREEN, 'Color',CYAN,'LineWidth',2, ...
    'MarkerIndices', sac_bi(:,1) ) %start of blink
  plot(t1,y2,'-o','MarkerSize',8,'MarkerEdgeColor',GREEN, 'Color',MAGENTA, 'LineWidth',2, ...
    'MarkerIndices', sac_bi(:,1) ) %start of blink

  % just the markers
  plot(t1,x1,'o','MarkerSize',8,'MarkerEdgeColor',RED, ...
    'MarkerIndices', sac_bi(:,2) ) %end of blink
  plot(t1,y1,'o','MarkerSize',8,'MarkerEdgeColor',RED, ...
    'MarkerIndices', sac_bi(:,2) ) %end of blink

   plot(t1,x2,'o','MarkerSize',8,'MarkerEdgeColor',RED, ...
    'MarkerIndices', sac_bi(:,2) ) %end of blink
  plot(t1,y2,'o','MarkerSize',8,'MarkerEdgeColor',RED, ...
    'MarkerIndices', sac_bi(:,2) ) %end of blink
   
%% saccades present and marked (comment out if you just want to see the cleaned data
  plot(t1,x1_saccades,'-o','MarkerSize',8,'MarkerEdgeColor',GREEN, 'Color',BLUE,'LineWidth',2, ...
    'MarkerIndices', sac_bi(:,1) ) %start of blink
  plot(t1,y1_saccades,'-o','MarkerSize',8,'MarkerEdgeColor',GREEN, 'Color',RED, 'LineWidth',2, ...
    'MarkerIndices', sac_bi(:,1) ) %start of blink

  % Other Eye 
  plot(t1,x2_saccades,'-o','MarkerSize',8,'MarkerEdgeColor',GREEN, 'Color',CYAN,'LineWidth',2, ...
    'MarkerIndices', sac_bi(:,1) ) %start of blink
  plot(t1,y2_saccades,'-o','MarkerSize',8,'MarkerEdgeColor',GREEN, 'Color',MAGENTA, 'LineWidth',2, ...
    'MarkerIndices', sac_bi(:,1) ) %start of blink
   
  just the markers
  plot(t1,x1_saccades,'o','MarkerSize',8,'MarkerEdgeColor',RED, ...
    'MarkerIndices', sac_bi(:,2) ) %end of blink
  plot(t1,y1_saccades,'o','MarkerSize',8,'MarkerEdgeColor',RED, ...
    'MarkerIndices', sac_bi(:,2) ) %end of blink

   plot(t1,x2_saccades,'o','MarkerSize',8,'MarkerEdgeColor',RED, ...
    'MarkerIndices', sac_bi(:,2) ) %end of blink
  plot(t1,y2_saccades,'o','MarkerSize',8,'MarkerEdgeColor',RED, ...
    'MarkerIndices', sac_bi(:,2) ) %end of blink

%%
  pause(5)
   
   % Increment
   i1 = i2;
   i2 = i2+2000;
   
end

