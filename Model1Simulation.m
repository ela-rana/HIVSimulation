%% NOTE

% Total runtime for this code was about 1-3 minutes on the personal 
% computer used by the original researcher
% This runtime is expected to vary from device to device, and is being used 
% here to obtain a general comparison for runtime for the different
% models. It is not for a universal runtime value

%% Documentation

% n             size of each dimension of our square cellular automata grid
% P_HIV         fraction (probability) of cells initially infected by virus
% P_i           probability of a healthy cell becoming infected if its
%               neighborhood contains 1 I1 cell or X I2 cells
% P_v           probability of a healthy cell becoming infected by coming
%               in contact with a virus randomly (not from its
%               neighborhood)
% P_rep          Probability of a dead cell becoming replaced by a healthy
%               cell
% P_repI          Probability of a dead cell becoming replaced by an infected
%               cell
% X             Number of I2 cells in the neighborhood of an H cell that
%               can cause it to become infected
% tau1          tau1 is the number of timesteps it takes for an acute
%               infected cell to become latent.
% tau2          tau2 is the number of timesteps it takes for a latent
%               infected cell to become dead.
% totalsteps    totalsteps is the total number of steps of the CA (the
%               total number of weeks of simulations)
% grid          our cellular automata (CA) grid
% tempgrid      tempgrid is a temporary grid full of random numbers that is
%               used to randomly add different states to our CA grid.
% taugrid       taugrid is a grid the same size as our CA grid that stores
%               the number of timesteps that a cell has been in state I_1.
%               If the number reaches tau1, then the state changes to I_2.
% state         state is a [5 x totalsteps] size matrix that stores
%               the total number of cells in each state at each timestep
%               and the last row stores sum of I_1 and I_2 at each timestep
% timestep      each simulation step of the cellular automata
%               1 timestep = 1 week of time in the real world
% nextgrid      nextgrid is a temporary grid. It is a copy of the CA grid
%               from the previous simulation. It stores all the CA rule
%               updates of the current timestep and stores it all back to
%               the grid to display.

%% Clean-up

clc;            % clears command window
clear all;      % clears workspace and deletes all variables
close all;      % closes all open figures

%% Parameters

n = 100;            % meaning that our grid will have the dimensions n x n
P_HIV = 0.05;      % initial grid will have P_hiv acute infected cells
P_i = 0.997;        % probability of infection by neighbors
P_v = 0.00001;      % probability of infection by random viral contact
P_rep = 0.99;        % probability of dead cell being replaced by healthy
P_repI = 0.00001;     % probability of dead cell being replaced by infected
X = 4;              % there must be at least X I_2 neighbors to infect cell
tau1 = 4;           % time delay for I_1 cell to become I_2 cell
tau2 = 1;           % time delay for I_2 cell to become D cell
totalsteps = 600 ;  % total number of weeks of simulation to be performed
savesteps = [3 7 11 15 20 25 50 100 150 200 250 300 350 400 450 500]; 
                    %timesteps for which we want to save simulation image

%% States

% State 1: H:   Healthy          (Color- Green)
% State 4: I_1: Active Infected  (Color- Cyan)
% State 3: I_2: Latent Infected  (Color- Blue)
% State 2: D:   Dead             (Color- Black)

%% Initial Grid


grid = ones(n);     % creates our initial n x n matrix and fills all cells
% with value 1 (meaning H state - Healthy cell)
tempgrid = rand(n); % creates a grid of random values of the same size as
% our CA grid. Used to randomly add I_1 state to our grid
grid(tempgrid(:,:)<=P_HIV) = 4;  % I_1 state added with probability  P_HIV

% The following sets the edge values of the grid to H state
grid(:,[1 n]) = 1;   % to set every value in the first and last column to 1
grid([1 n],:) = 1;   % to set every value in the first and last row to 1

% NOTE: Our CA only simulates from rows 2 to n-1, and columns 2 to n-1.
%       This is to prevent the edge row and column cells from having an
%       out-of-bounds error when checking the neighbors around them.
%       The edge values are all set to H state so that it does not affect
%       Rule 1 of the CA for cells next to them

% set(figure, 'OuterPosition', [100 30 740 740]) % sets figure window size
% % outerposition values are [left, bottom, width, height]
% print1(grid);   % prints the initial grid
% saveas(gcf,strcat('Model1Timestep0.pdf'));

%% Simulation

taugrid = zeros(n); % to initially set number of timesteps that a cell has
% been in I_1 state to zero for every cell
state = zeros(4,totalsteps);    % initializes a grid to keep count of cells
% in every state
timestep = 1;
while timestep <= totalsteps
    nextgrid = grid;
    for x=2:n-1
        for y=2:n-1
            
            % Rule 1
            % If the cell is in H state and at least one of its neighbors
            % is in I_1 state, or X of its neighbors is in I_2 state, then
            % the cell becomes I_1 with a probability of P_i
            % The cell may also becomes I_1 by randomly coming in
            % contact with a virus from outside its neighborhood with a
            % probability of P_v
            if(grid(x,y)==1)
                if((rand<=P_i && (grid(x-1,y-1)==4 || grid(x-1,y)==4 || ...
                        grid(x-1,y+1)==4 || grid(x,y-1)==4 || ...
                        grid(x,y+1)==4 || grid(x+1,y-1)==4 || ...
                        grid(x+1,y)==4 || grid(x+1,y+1)==4 || ...
                        ((grid(x-1,y-1)==3) + (grid(x-1,y)==3) + ...
                        (grid(x-1,y+1)==3) + (grid(x,y-1)==3) + ...
                        (grid(x,y+1)==3) + (grid(x+1,y-1)==3) + ...
                        (grid(x+1,y)==3) + (grid(x+1,y+1)==3))>=X ))...
                        || rand<=P_v)                    
                    nextgrid(x,y)=4;
                end
                continue;
            end
            
            % Rule 2
            % If the cell is in state I_1, and has been in this state for
            % tau1 timesteps, the cell becomes I_2 state (latent infected)
            if((grid(x,y)==4))
                taugrid(x,y) = taugrid(x,y)+1;
                if(taugrid(x,y)==tau1)
                    nextgrid(x,y)=3;
                    taugrid(x,y)=0;
                end
                continue;
            end
            
            % Rule 3
            % If the cell is in I_2 state, and has been in this state for
            % tau2 timesteps, the cell becomes D state (dead)
            % Since tau2=1, this rule is implemented every timestep
            if((grid(x,y)==3))
                nextgrid(x,y)=2;
                continue;
            end
            
            % Rule 4 a and b
            % If the cell is in D state, then the cell will become H state
            % with probability P_rep (4.a) or I_1 state with probability
            % P_repI (4.b)
            if(grid(x,y)==2 && rand<=P_rep)
                if(rand<=P_repI)
                    nextgrid(x,y)=4;
                    continue;
                else
                    nextgrid(x,y)=1;
                end
            end
            
        end
    end
    % to assign the updates of this timestep in nextgrid back to our grid
    grid=nextgrid;          
    % to display the grid at the end of each timestep
    print1(grid);
    % to save the image of the simulation every 25 timesteps as a pdf
    if(find(savesteps==timestep))
        saveas(gcf,strcat('Model1Timestep',num2str(timestep),'.pdf'));
    end
    
    state(1,timestep) = sum(sum(grid(2:n-1,2:n-1)==1));
    state(2,timestep) = sum(sum(grid(2:n-1,2:n-1)==2));
    state(3,timestep) = sum(sum(grid(2:n-1,2:n-1)==3));
    state(4,timestep) = sum(sum(grid(2:n-1,2:n-1)==4));
    
    timestep=timestep+1;    % to move to the next timestep
end

% The following lines of code are to display a graph of each state of
% cells during simulation
set(figure, 'OuterPosition', [200 100 700 500]) % sets figure window size
plot( 1:totalsteps , state(1,:), 'g', ...
    1:totalsteps , state(4,:), 'c', ...
    1:totalsteps , state(3,:), 'b', ...
    1:totalsteps , state(2,:), 'k' , 'linewidth', 2 );
legend( 'Healthy', 'Acute Infected', 'Latent Infected', 'Dead', ...
    'Location' ,'NorthEast' );
saveas(gcf,strcat('Model1GraphSingleRun.pdf'));

