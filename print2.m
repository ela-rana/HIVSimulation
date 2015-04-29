function print2(x)

% % to place a title over the image
% title('\fontsize{30}HIV Model 2 Simulation');

% displays a grid in a graphical view of an image where each cell
% value is represented by a color
imagesc(x);

% removes row and columns number values on the axis
axis off;

% to create a list of possible colors for each grid state
% each row of the clist represents R, G & B value of one color
% row number corresponds to the state that will have that color
clist = [0 1 0; 1 0 0; 0 1 1; 0 0 1; 0 0 0];  
% means [green; red; cyan; blue; black]
colormap(clist);    % maps our created color list to the grid

% hold on;            % to remain on figure while creating legend
% 
% % NOTE: The grid, an imagesc, cannot have a legend.
% %       Thus a line L is used to create legend. Both share the same
% %       color list. Thus the legend for the line applies to grid also.
% 
% L = line(ones(5), ones(5), 'LineWidth', 4);          % create line
% set(L,{'color'},mat2cell(clist,ones(1,5),3));      % set clist to line
% legend('Healthy (H)', 'Healthy with therapy (H_T1)', 'Acute Infected (I_1)', ...
%     'Latent Infected(I_2)', 'Dead (D)',  ... % create legend
%     'Location', 'northeastoutside'); % to display legend outside the
%                                      % grid on north-east side
pause(0.00000000001);
