:- lib(ic). 

solve(MySolution) :-
    findall([Base,Side,Side],
        (
            % bounds: chose random upper bound
            Base #>= 1, Base #=< 200,
            Side #>= 1, Side #=< 200,

            % triangle inequality
            2*Side #> Base,

            % compute area
            16*Area*Area #= Base*Base*(4*Side*Side - Base*Base),

            Perimeter #= Base + 2*Side,
            Area #= 6*Perimeter,

            labeling([Base,Side])
        ),
        AllSolutions),
    
    % remove congruent solutions
    sort(AllSolutions, MySolution).