:- lib(ic). 

solve(MySolution) :-
    findall([X,Y],
        (
            % constraints on valid 3-digit integer 
            X #>= 100, X #=< 999,
            Y #>= 100, Y #=< 999,

            % (x||y) can be expressed as 1000x + y 
            6*(1000*X + Y) #= 1000*Y + X,
            labeling([X,Y])
        ),
        MySolution).