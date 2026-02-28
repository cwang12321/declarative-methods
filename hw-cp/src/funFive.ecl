:- lib(ic).

solve(MySolution) :-
    findall(1,
        (
            A #>= 1, A #=< 9,
            B #>= 0, B #=< 9,
            C #>= 0, C #=< 9,
            D #>= 0, D #=< 9,

            % number must be even
            E :: [0,2,4,6,8],
            A + B + C + D #= E,

            labeling([A,B,C,D,E])
        ),
        L),
    length(L, MySolution).