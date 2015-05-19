%% NOTE

% Total runtime for this code was about 11 hours on the computer used by
% the original researcher (for 100 run average)
% This runtime is expected to vary from device to device, and is being used
% here to obtain a general comparison for runtime for the different
% models. It is not for a universal runtime value

% When run, this code does not display anything till the end of the 11
% hours.

%% Documentation

% n             size of each dimension of our square cellular automata grid
% P_HIV         fraction (probability) of cells initially infected by virus
% P_i           probability of a healthy cell becoming infected if its
%               neighborhood contains 1 I1 cell or X I2 cells
% P_v           probability of a healthy cell becoming infected by coming
%               in contact with a virus randomly (not from its
%               neighborhood)
% P_RH          Probability of a dead cell becoming replaced by a healthy
%               cell
% P_RI          Probability of a dead cell becoming replaced by an infected
%               cell
% P_T1          Probability of a healthy cell receiving therapy 1
% P_iT1         Probability of a healthy cell receiving therapy 1 of
%               becoming infected
% P_T2          Probability of a healthy cell receiving therapy 2
% P_iT2         Probability of a healthy cell receiving therapy 2 of
%               becoming infected
% P_adh         Fraction of treatment during which adherence is shown
% X             Number of I2 cells in the neighborhood of an H cell that
%               can cause it to become infected
% tau1          tau1 is the number of timesteps it takes for an acute
%               infected cell to become latent.
% tau2          tau2 is the number of timesteps it takes for a latent
%               infected cell to become dead.
% tau3          tau3 is the number of timesteps after which a healthy
%               cell receiving dual therapy becomes a healthy cell again
% totalsteps    totalsteps is the total number of steps of the CA (the
%               total number of weeks of simulations)
% grid          our cellular automata (CA) grid
% tempgrid      tempgrid is a temporary grid full of random numbers that is
%               used to randomly add different states to our CA grid.
% taugrid       taugrid is a grid the same size as our CA grid that stores
%               the number of timesteps that a cell has been in state I_1.
%               If the number reaches tau1, then the state changes to I_2.
% state         state is a [9 x totalsteps] size matrix that stores
%               the total number of cells in each state at each timestep
%               and the last 2 rows store total healthy and total infected
%               cells
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
P_HIV = 0.05;       % initial grid will have P_hiv acute infected cells
P_i = 0.997;        % probability of infection by neighbors
P_v = 0.00001;      % probability of infection by random viral contact
P_RH = 0.99;        % probability of dead cell being replaced by healthy
P_RI = 0.00001;     % probability of dead cell being replaced by infected
P_T1 = 0.70;        % probability of cell receiving therapy 1
P_iT1 = 0.07;       % probability of infection of healthy with therapy 1
P_T2 = 0.50;        % probability of cell receiving therapy 2
P_iT2 = 0.05;       % probability of infection of healthy with therapy 2
X = 4;              % there must be at least X I_2 neighbors to infect cell
tau1 = 4;           % time delay for I_1 cell to become I_2 cell
tau2 = 1;           % time delay for I_2 cell to become D cell
tau3 = 1;           % time delay for H_Tb cell to become H cell
totalsteps = 600;   % total number of weeks of simulation to be performed
T_start = 20;       % The medication therapy will start on week T_start
totalruns = 100;      % total number of times to run the simulation to get an
% average
totaladherences= 100;

%% States

% State 1: H:       Healthy                     (Color- Green)
% State 2: H_T1:    Healthy with therapy 1      (Color- Red)
% State 3: H_T2:    Healthy with therapy 2      (Color- Red)
% State 4: H_Tb:    Healthy with dual therapy   (Color- Red)
% State 5: I_1:     Active Infected             (Color- Cyan)
% State 6: I_2:     Latent Infected             (Color- Blue)
% State 7: D:       Dead                        (Color- Black)

%% Simulation

state1 = zeros(totalruns,totaladherences);
state2 = zeros(totalruns,totaladherences);
state3 = zeros(totalruns,totaladherences);
state4 = zeros(totalruns,totaladherences);
state5 = zeros(totalruns,totaladherences);
state6 = zeros(totalruns,totaladherences);
state7 = zeros(totalruns,totaladherences);

for P_adh = 0.01:0.01:1
    
    for run = 1:totalruns
        
        grid = ones(n);     % creates our initial n x n matrix and fills all cells
        % with value 1 (meaning H state - Healthy cell)
        tempgrid = rand(n); % creates a grid of random values of the same size as
        % our CA grid. Used to randomly add I_1 state to our grid
        grid(tempgrid(:,:)<=P_HIV) = 5;  % I_1 state added with probability  P_HIV
        
        % The following sets the edge values of the grid to H state
        grid(:,[1 n]) = 1;   % to set every value in the first and last column to 1
        grid([1 n],:) = 1;   % to set every value in the first and last row to 1
        
        % NOTE: Our CA only simulates from rows 2 to n-1, and columns 2 to n-1.
        %       This is to prevent the edge row and column cells from having an
        %       out-of-bounds error when checking the neighbors around them.
        %       The edge values are all set to H state so that it does not affect
        %       Rule 1 of the CA for cells next to them
        
        taugrid = zeros(n); % to initially set number of timesteps that a cell has
        % been in acute infected state to zero for every cell
        
        timestep = 1;
        while timestep<=totalsteps
            nextgrid = grid;
            for x=2:n-1
                for y=2:n-1
                    
                    % Rule 1
                    % If a cell is in healthy state, it can transition into one of
                    % the three healthy with therapy states or become infected
                    if(grid(x,y)==1)
                        random1=rand;
                        random2=rand;
                        random3=rand;
                        % If there is probability of receiving therapy 1 but not
                        % therapy 2, then it becomes healthy with therapy 1
                        if(random1 <= P_T1 && random2 > P_T2 && ...
                                timestep >= T_start && random3 <= P_adh)
                            nextgrid(x,y)=2;
                            continue;
                            % If there is probability of receiving therapy 2 but not
                            % therapy 1, then it becomes healthy with therapy 2
                        elseif(random1 > P_T1 && random2 <= P_T2 && ...
                                timestep >= T_start && random3 <= P_adh)
                            nextgrid(x,y)=3;
                            continue;
                            % If there is probability of receiving therapy 1 and 2,
                            % then it becomes healthy with both therapies
                        elseif(random1 <= P_T1 && random2 <= P_T2 && ...
                                timestep >= T_start && random3 <= P_adh)
                            nextgrid(x,y)=4;
                            continue;
                            % If there is no probability of receiving either therapy,
                            % then it becomes infected if probability of infection and
                            % neighbor condition is met, or if probability of infection
                            % by random virus is met
                        elseif(((random1 <= P_i) && ...
                                (grid(x-1,y-1)==5 || grid(x-1,y)==5 || ...
                                grid(x-1,y+1)==5 || grid(x,y-1)==5 || ...
                                grid(x,y+1)==5 || grid(x+1,y-1)==5 || ...
                                grid(x+1,y)==5 || grid(x+1,y+1)==5 || ...
                                ((grid(x-1,y-1)==6) + (grid(x-1,y)==6) + ...
                                (grid(x-1,y+1)==6) + (grid(x,y-1)==6) + ...
                                (grid(x,y+1)==6) + (grid(x+1,y-1)==6) + ...
                                (grid(x+1,y)==6) + (grid(x+1,y+1)==6))>=X )) ...
                                || (random2 <= P_v) )
                            nextgrid(x,y)=5;
                        end
                        continue;
                    end
                    
                    % Rule 2
                    % If a cell is in H_T1 state, it can transition into H_T2,
                    % H_Tb, get infected, or return to healthy state
                    if(grid(x,y)==2)
                        random1=rand;
                        random2=rand;
                        random3=rand;
                        % Rule 2.a
                        % If there is probability of receiving therapy 1 and 2,
                        % then it becomes healthy with both therapies
                        if(random1 <= P_T1 && random2 <= P_T2 && random3 <= P_adh)
                            nextgrid(x,y)=4;
                            continue;
                            % Rule 2.b
                            % Otherwise, it becomes I_1 with probability P_iT1 if
                            % neighbor condition and P_i is met or if P_v is met
                        elseif((random1 <= P_iT1) && (((random1 <= P_i) && ...
                                (grid(x-1,y-1)==5 || grid(x-1,y)==5 || ...
                                grid(x-1,y+1)==5 || grid(x,y-1)==5 || ...
                                grid(x,y+1)==5 || grid(x+1,y-1)==5 || ...
                                grid(x+1,y)==5 || grid(x+1,y+1)==5 || ...
                                ((grid(x-1,y-1)==6) + (grid(x-1,y)==6) + ...
                                (grid(x-1,y+1)==6) + (grid(x,y-1)==6) + ...
                                (grid(x,y+1)==6) + (grid(x+1,y-1)==6) + ...
                                (grid(x+1,y)==6) + (grid(x+1,y+1)==6))>=X )) ...
                                || (random2 <= P_v) ))
                            nextgrid(x,y)=5;
                            continue;
                            % Rule 2.c
                            % If there is probability of receiving therapy 2 but not
                            % therapy 1, then it becomes healthy with therapy 2
                        elseif(random1 > P_T1 && random2 <= P_T2 && random3 <= P_adh)
                            nextgrid(x,y)=3;
                            continue;
                            % Rule 2.d
                            % If there is no probability of therapy and it has not
                            % become infected, then it turns into H state
                        elseif((random1 > P_T1 && random2 > P_T2)|| random3 > P_adh)
                            nextgrid(x,y)=1;
                        end
                        continue;
                    end
                    
                    % Rule 3
                    % If a cell is in H_T2 state, it can transition into H_T1,
                    % H_Tb, get infected, or return to healthy state
                    if(grid(x,y)==3)
                        random1=rand;
                        random2=rand;
                        random3=rand;
                        % Rule 3.a
                        % If there is probability of receiving therapy 1 and 2,
                        % then it becomes healthy with both therapies
                        if(random1 <= P_T1 && random2 <= P_T2 && random3 <= P_adh)
                            nextgrid(x,y)=4;
                            continue;
                            % Rule 3.b
                            % Otherwise, it becomes I_1 with probability P_iT1 if
                            % neighbor condition and P_i is met or if P_v is met
                        elseif((random1 <= P_iT2) && (((random1 <= P_i) && ...
                                (grid(x-1,y-1)==5 || grid(x-1,y)==5 || ...
                                grid(x-1,y+1)==5 || grid(x,y-1)==5 || ...
                                grid(x,y+1)==5 || grid(x+1,y-1)==5 || ...
                                grid(x+1,y)==5 || grid(x+1,y+1)==5 || ...
                                ((grid(x-1,y-1)==6) + (grid(x-1,y)==6) + ...
                                (grid(x-1,y+1)==6) + (grid(x,y-1)==6) + ...
                                (grid(x,y+1)==6) + (grid(x+1,y-1)==6) + ...
                                (grid(x+1,y)==6) + (grid(x+1,y+1)==6))>=X )) ...
                                || (random2 <= P_v) ))
                            nextgrid(x,y)=5;
                            continue;
                            % Rule 3.c
                            % If there is probability of receiving therapy 1 but not
                            % therapy 2, then it becomes healthy with therapy 1
                        elseif(random1 <= P_T1 && random2 > P_T2 && random3 <= P_adh)
                            nextgrid(x,y)=2;
                            continue;
                            % Rule 3.d
                            % If there is no probability of therapy and it has not
                            % become infected, then it turns into H state
                        elseif((random1 > P_T1 && random2 > P_T2)|| random3 > P_adh)
                            nextgrid(x,y)=1;
                        end
                        continue;
                    end
                    
                    % Rule 4
                    % If the cell is in state H_Tb, and has been in this state for
                    % tau3 timesteps, the cell becomes H state
                    % Since tau3=1, this rule is implemented every timestep
                    if(grid(x,y)==4)
                        nextgrid(x,y)=1;
                        continue;
                    end
                    
                    % Rule 5
                    % If the cell is in state I_1, and has been in this state for
                    % tau1 timesteps, the cell becomes I_2 state (latent infected)
                    if(grid(x,y)==5)
                        taugrid(x,y) = taugrid(x,y)+1;
                        if(taugrid(x,y)==tau1)
                            nextgrid(x,y)=6;
                            taugrid(x,y)=0;
                        end
                        continue;
                    end
                    
                    % Rule 6
                    % If the cell is in I_2 state, and has been in this state for
                    % tau2 timesteps, the cell becomes D state (dead)
                    % Since tau2=1, this rule is implemented every timestep
                    if(grid(x,y)==6)
                        nextgrid(x,y)=7;
                        continue;
                    end
                    
                    % Rule 7
                    % If the cell is in D state, it can be replaced by a
                    % healthy cell with probability P_RH (7.a), and then
                    % the replaced cell can be further replaced by an I_1
                    % infected cell with probability P_RI (7.b)
                    if(grid(x,y)==7 && rand<=P_RH)
                        if(rand<=P_RI)
                            nextgrid(x,y)=5;
                            continue;
                        else
                            nextgrid(x,y)=1;
                        end
                    end
                    
                end
            end
            grid=nextgrid;      % to assign the updates of this timestep in
            % nextgrid back to our grid
            
            timestep=timestep+1;    % to move to the next timestep
        end
        state1(run,uint8(P_adh/0.01)) = sum(sum(grid(2:n-1,2:n-1)==1)); % H
        state2(run,uint8(P_adh/0.01)) = sum(sum(grid(2:n-1,2:n-1)==2)); % H_T1
        state3(run,uint8(P_adh/0.01)) = sum(sum(grid(2:n-1,2:n-1)==3)); % H_T2
        state4(run,uint8(P_adh/0.01)) = sum(sum(grid(2:n-1,2:n-1)==4)); % H_Tb
        state5(run,uint8(P_adh/0.01)) = sum(sum(grid(2:n-1,2:n-1)==5)); % I_1
        state6(run,uint8(P_adh/0.01)) = sum(sum(grid(2:n-1,2:n-1)==6)); % I_2
        state7(run,uint8(P_adh/0.01)) = sum(sum(grid(2:n-1,2:n-1)==7)); % D
        
    end
end

state1dev = std(state1);
state2dev = std(state2);
state3dev = std(state3);
state4dev = std(state4);
state5dev = std(state5);
state6dev = std(state6);
state7dev = std(state7);

state1mean = mean(state1);
state2mean = mean(state2);
state3mean = mean(state3);
state4mean = mean(state4);
state5mean = mean(state5);
state6mean = mean(state6);
state7mean = mean(state7);

% The following lines of code are to display a graph of each state of
% cells during simulation
set(figure, 'OuterPosition', [200 100 700 500]) % sets figure window size
plot( 1:totaladherences , state1mean, 'g', ...
    1:totaladherences , state2mean, 'r', ...
    1:totaladherences , state3mean, 'm', ...
    1:totaladherences , state4mean, 'y', ...
    1:totaladherences , state5mean, 'c', ...
    1:totaladherences , state6mean, 'b', ...
    1:totaladherences , state7mean, 'k' , 'linewidth', 2 );
xlim([0 100]);
ylim([0 6000]);
hold on;
errorbar( 1:3:totaladherences , state1mean(1:3:totaladherences), state1dev(1:3:totaladherences), 'g');
errorbar( 1:3:totaladherences , state2mean(1:3:totaladherences), state2dev(1:3:totaladherences), 'r');
errorbar( 1:3:totaladherences , state3mean(1:3:totaladherences), state3dev(1:3:totaladherences), 'm');
errorbar( 1:3:totaladherences , state4mean(1:3:totaladherences), state4dev(1:3:totaladherences), 'y');
errorbar( 1:3:totaladherences , state5mean(1:3:totaladherences), state5dev(1:3:totaladherences), 'c');
errorbar( 1:3:totaladherences , state6mean(1:3:totaladherences), state6dev(1:3:totaladherences), 'b');
errorbar( 1:3:totaladherences , state7mean(1:3:totaladherences), state7dev(1:3:totaladherences), 'k');
legend( 'Healthy', 'Healthy with Therapy1', 'Healthy with Therapy2', ...
    'Healthy with dual Therapy', 'Acute Infected', 'Latent Infected', ...
    'Dead', 'Location' ,'NorthEast' );
saveas(gcf,strcat('Model3withAdherenceWeek600Graph.pdf'));

