:- lib(ic).			% include the standard interval constraint library
:- lib(branch_and_bound).	% include the branch and bound library for minimization
:- lib(ic_edge_finder).		% include the cumulative constraint library needed for resource constraints
:- lib(lists).		% for printing ordered solution

sortTasksByStart(Tasks, Sorted) :-
    % decorate with Start as key
    ( foreach(task(N,S,F),Tasks), foreach(S-key-task(N,S,F),Deco) do true ),
    keysort(Deco, DecoSorted),
    % undecorate
    ( foreach(_K-task(N,S,F),DecoSorted), foreach(task(N,S,F),Sorted) do true ).

schedule(EndTime) :-

		% for each task, we will have a variable which corresponds to its finish time
		% and one that corresponds to its start time
		% for example, the value of PG is the time at which you finish the 'preheat grill' task
	TaskFinishTimes = [F_DS, F_PG, F_DO, F_TB, F_GS, F_ASMO, F_GO, F_PBS],	
	TaskStartTimes = [S_DS, S_PG, S_DO, S_TB, S_GS, S_ASMO, S_GO, S_PBS],


		% constrain each task to finish between minute #0 and minute #100
	TaskFinishTimes :: 0..100,
	TaskStartTimes :: 0..100,

		% duration constraints
		% if it takes N minutes to do task X, then the finish time of X is greater than N
	F_DS - S_DS #= 2,
	F_PG - S_PG #= 20,
	F_DO - S_DO #= 3,
	F_TB - S_TB #= 1,
	F_GS - S_GS #= 10,
	F_ASMO - S_ASMO #= 1,
	F_GO - S_GO #= 8,
	F_PBS - S_PBS #= 15,


		% precedence constraints
		% if X must be done before Y, then the start time of Y must be after the finish time of X
	S_TB #>= F_PG,		% preheat grill before toast buns
	S_GS #>= F_PG,		% preheat grill before grilling sausage
	S_GS #>= F_DS,		% defrost sausage before grilling it
	S_GS #>= F_PBS,		% pan-broil sausage before grilling it
	S_ASMO #>= F_GS,	% grill sausage before putting condiments on it
	S_ASMO #>= F_PBS,	% pan-broil sausage before putting condiments on it
	S_ASMO #>= F_GO,	% grill onions before putting them on sausage
	S_ASMO #>= F_TB,	% toast buns before adding condiments
	S_GO #>= F_PG,		% preheat grill before grilling onions
	S_GO #>= F_DO,		% dice onions before grilling them
	S_PBS #>= F_DS,		% defrost sausages before pan-broiling them


		% resource constraints
		% if X and Y use the same resource, they cannot be done at the same time
	% grill
	%   This constraint takes 4 parameters:
	%	- a list of task start times
	%	- a list of task durations
	%	- a list of how much of the resource is being consumed
	%	- an integer representing the total amount of resource available
	%   So this says that the tasks of preheating the grill, toasting the buns, grilling the sausage, and grilling the onion
	%    each require 1 unit of grill space, and there is only 1 unit available to share among them.
	cumulative([S_PG, S_TB, S_GS, S_GO], [20, 1, 10, 8], [1,1,1,1], 1),

	% microwave - only one task needs it, so this constraint is trivial
	cumulative([S_DS], [2], [1], 1),	

	% stove - only one task needs it, so this constraint is trivial
	cumulative([S_PBS], [15],[1], 1),

		% stuff for computing minimal ordering
	% constrain end time to be the finish time of the final task
	EndTime #= max(TaskFinishTimes),

		% define "AllVars" to be a new variable that is simply a flat list 
		%   of all the variables in TaskStartTimes and TaskFinishTimes, plus the variable EndTime
	flatten([TaskStartTimes,TaskFinishTimes,EndTime], AllVars),

		% find a labeling (aka assignment) of values to TaskFinishTimes that minimizes EndTime
	minimize(labeling(AllVars), EndTime),

	
	% Build list of task(Name, Start, Finish)
    Tasks = [
        task('Defrost sausages',     S_DS,  F_DS),
        task('Preheat grill',        S_PG,  F_PG),
        task('Dice onions',          S_DO,  F_DO),
        task('Toast buns',           S_TB,  F_TB),
        task('Grill sausages',       S_GS,  F_GS),
        task('Add condiments',       S_ASMO,F_ASMO),
        task('Grill onions',         S_GO,  F_GO),
        task('Pan-broil sausages',   S_PBS, F_PBS)
    ],

    % Sort by start time
    sortTasksByStart(Tasks, Sorted),

    % Print in order
    ( foreach(task(Name,S,F), Sorted) do
        printf("%s: %d - %d%n", [Name, S, F])
    ),
    printf("%nEndTime = %d%n", [EndTime]).
	