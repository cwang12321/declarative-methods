:- lib(lists).

printSolution(MySolution) :-
    ( is_list(MySolution) ->
        ( foreach(El, MySolution) do
            printf("%w%n", [El])
        );
        printf("%w%n", [MySolution])
    ).