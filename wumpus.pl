% start([1,1], [3,3], [2,3], [[1,2], [3,2], [5,1], [5,5], [2,5]], [5,5], [], 1, 1).

% The gold is found
% [X, Y] - agent's position, [X1, Y1] - gold's position
gold([X, Y], [X1, Y1]) :-
    X = X1,
    Y = Y1.

% Wumpus is near
% [X, Y] - agent's position, [X1, Y1] - Wumpus's position
stench(S, [X1, Y1]) :-
    X2 is X1 + 1,
    S = [X2, Y1];
    X3 is X1 - 1,
    S = [X3, Y1];
    Y2 is Y1 + 1,
    S = [X1, Y2];
    Y3 is Y1 - 1,
    S = [X1, Y3].

% Wumpus is found
% [X, Y] - agent's position, [X1, Y1] - Wumpus's position
wumpus([X, Y], [X1, Y1]) :-
    X = X1,
    Y = Y1.

% Pit is near
% [X, Y] - agent's position, [X1, Y1] - Pits' positions
breeze(S, [X1, Y1]) :-
    X2 is X1 + 1,
    S = [X2, Y1];
    X3 is X1 - 1,
    S = [X3, Y1];
    Y2 is Y1 + 1,
    S = [X1, Y2];
    Y3 is Y1 - 1,
    S = [X1, Y3].

% Pit is found
% [X, Y] - agent's position, [[X1, Y1], ...] - pits' positions
pit(S, P) :-
    member(S, P).

% The wall is hitted
% [X, Y] - agent's position, [W, L] - field size
wall([X, Y], [W, L]) :-
    X1 is W + 1,
    X = X1;
    X = 0;
    Y1 is L + 1,
    Y = Y1;
    Y = 0.

% Wumpus is killed
% [X, Y] - agent's position, W - Wumpus's position
arrow([X, Y], W) :-
    W = [X, Y1],	% shot up
    Y1 > Y;
    W = [X, Y1],	% shot down
    Y1 < Y;    
    W = [X1, Y],	% shot right
    X1 > X;
    W = [X1, Y],	% shot left
	X1 < X.

% Limit the area - don't move on the wall
move(S, _, _, _, Size, _, _, _) :-
    wall(S, Size),
    !.

% Stop moving if the gold is found
move(S, G, _, _, _, R, _, _) :-
    gold(S, G),
    append(R, [S], R1),
    writeln(R1),
    !.

% Don't move on visited cells
move(S, _, _, _, _, R, _, _) :-
    member(S, R),
    !.

% Don't move on Wumpus if he's alive
move(S, _, W, _, _, _, A, _) :-
    A = 1,
    wumpus(S, W),
    !.

% Don't move on pit
move(S, _, _, P, _, _, _, _) :-
    pit(S, P),
    !.

% Try to kill Wumpus while visiting the cell with stench, nice shot!
move([X, Y], G, W, P, S, R, A, Ar) :-
    A = 1, 
    Ar = 1,
    stench([X, Y], W),
    arrow([X, Y], W),
    append(R, [[X, Y]], R1),
    X1 is X + 1,
    Y1 is Y + 1,
    X2 is X - 1,
    Y2 is Y - 1,
    move([X1, Y], G, W, P, S, R1, 0, 0),
    move([X, Y1], G, W, P, S, R1, 0, 0),
    move([X2, Y], G, W, P, S, R1, 0, 0),
    move([X, Y2], G, W, P, S, R1, 0, 0).

% Try to kill Wumpus while visiting the cell with stench, miss shot!
move([X, Y], G, W, P, S, R, A, Ar) :-
	A = 1, 
    Ar = 1,
    stench([X, Y], W),
    not(arrow([X, Y], W)),
    append(R, [[X, Y]], R1),
    X1 is X + 1,
    Y1 is Y + 1,
    X2 is X - 1,
    Y2 is Y - 1,
    move([X1, Y], G, W, P, S, R1, 1, 0),
    move([X, Y1], G, W, P, S, R1, 1, 0),
    move([X2, Y], G, W, P, S, R1, 1, 0),
    move([X, Y2], G, W, P, S, R1, 1, 0).

% Moving to all 4 directions from clear cell
move([X, Y], G, W, P, S, R, A, Ar) :-
    append(R, [[X, Y]], R1),
    X1 is X + 1,
    Y1 is Y + 1,
    X2 is X - 1,
    Y2 is Y - 1,
    move([X1, Y], G, W, P, S, R1, A, Ar),
    move([X, Y1], G, W, P, S, R1, A, Ar),
    move([X2, Y], G, W, P, S, R1, A, Ar),
    move([X, Y2], G, W, P, S, R1, A, Ar).

% Start the program.
% Input description:
%   Start = [X, Y] - starting coordinate of an agent, 
%   Gold = [X, Y] - coordinate of a gold,
%   Wumpus = [X, Y] - coordinate of a Wumpus
%   Pits = [[X, Y], ...] - coordinates of pits
%   Size = [W, L] - size of a field,
%   Route = [[X, Y], ...] - route to the gold
%   Alive = (0 or 1) - Wumpus is Alive
%   Arrow = (0 or 1) - Agent has arrow
start(Start, Gold, Wumpus, Pits, Size, Route, Alive, Arrow) :-
    move(Start, Gold, Wumpus, Pits, Size, Route, Alive, Arrow).