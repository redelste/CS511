%Khayyam Saleem, Ryan Edelstein
%We pledge our honors that we have abided by the Stevens Honor System.
-module(guess).
-export([gen/0, cli/2, start/0]).

gen()->
    Num = rand:uniform(101)-1,
    receive
        {From, Ref, N} when N == Num ->
            From!{self(), Ref, gotIt},
            gen();
        {From, Ref, _} ->
            From!{self(), Ref, tryAgain},
            gen();
        stop -> ok
    end.

cli(Top, Pid) ->
    Guess = rand:uniform(101)-1,
    R=make_ref(),
    Pid!{self(),R,Guess},
    receive
        {Pid, R, gotIt} ->
            io:format("Guessed ~w correctly!.~n", [Guess]),
            Top!{self(), done};
        {Pid, R, tryAgain} ->
            io:format("Guessed ~w wrong, trying again.~n", [Guess]),
            cli(Top, Pid)
    end.

start() ->
    G = spawn(?MODULE, gen, []),
    C1 = spawn(?MODULE, cli, [self(), G]),
    C2 = spawn(?MODULE, cli, [self(), G]),
    receive
        {C1, done} ->
            receive
                {C2, done} ->
                    done
            end
    end.


-module(fs).
-compile(eport_all).

start(State,F)->
	S=spawn(?MODULE, server,[State,F]),
	register(server,S).

server(State,F) ->
	receive
		{From, Ref, apply, N}->
			{NewState, Result} = F{State,N},
			From!{self(), Ref, Result},
			server(NewState,F);
		{From, Ref, update,G}->
			From!{self(), Ref,okUpdate},
			server(State,G);
		{From, Ref, getState}->
			From!{self(), Ref,state},
			server(State,F)
	end. 






			

