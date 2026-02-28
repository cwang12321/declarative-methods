:- lib(ic).
:- lib(branch_and_bound).

solve(MySolution) :-
    Digits = [D0,D1,D2,D3,D4,D5,D6,D7,D8,D9],

    Digits #:: 0..9,
    alldifferent(Digits),

    D0 #\= 0,

    N #= 1000000000*D0 +
        100000000*D1 +
        10000000*D2 +
        1000000*D3 +
        100000*D4 +
        10000*D5 +
        1000*D6 + 
        100*D7 +
        10*D8 + D9,

    K #>= 0,
    K*K #= N,

    minimize(labeling(Digits), N),

    MySolution = N.