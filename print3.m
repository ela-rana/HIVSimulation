function print3(x)

% displays a grid in a graphical view of an image where each cell
% value is represented by a color
imagesc(x);

% removes row and columns number values on the axis
axis off;

% to create a list of possible colors for each grid state
% each row of the clist represents R, G & B value of one color
% row number corresponds to the state that will have that color
clist = [0 1 0; 1 0 0; 1 0 1 ; 1 1 0; 0 1 1; 0 0 1; 0 0 0];  
% means [green; red ; magenta; yellow; cyan; blue; black]

% [ 0 0 0 ; 0 0 1 ; 0 1 0 ; 0 1 1 ; 1 0 0 ; 1 0 1   ; 1 1 0  ;  1 1 1 ];  
% [ black ; blue  ; green ; cyan  ; red   ; magenta ; yellow ;  white ];

colormap(clist);    % maps our created color list to the grid

pause(0.00000000001);
