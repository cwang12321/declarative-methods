:- lib(ic).

solve(MySolution) :-
    % collect all possible N values
    findall(N, 
        (
            Vars = [A,B,C,D,E,F,G,H,I],
            Vars :: 1..9,
            alldifferent(Vars),

            % define common sum 
            N #= A + B + C + D,
            N #= B + E + F + G,
            N #= D + G + H + I,

            % search
            labeling(Vars)
        ),
     Ns
    ),
    sort(Ns, MySolution).

