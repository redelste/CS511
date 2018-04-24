-module(ts).
-export([start/0,counter/1,turnstile/3]).

counter(N)->
    receive
        {From,Ref,bump} ->
            From!{self(),Ref,ok},
            counter(N+1);
        {From,Ref,read}->
            From!{self(),Ref,N},
            counter(N);
        stop -> ok
    end.

turnstile(Top,_Pid,0)->
    Top!{self(),done};
turnstile(Top,Pid, N)->
    timer:sleep(rand:uniform(200)),
    R=make_ref(),
    Pid!{self(), R, bump},
    receive
        {Pid,R,ok} ->
            turnstile(Top, Pid,N-1)
    end.



start() ->
    C = spawn(?MODULE, counter, [0]),
    T1 = spawn(?MODULE, turnstile, [self(),C,50]),
    T2 = spawn(?MODULE, turnstile, [self(),C,50]),
    receive
        {T1,done} ->
            receive
                {T2,done} ->
                    done
            end
    end,
    R = make_ref(),
    C!{self(), R,read},
    receive
        {C,R,N} ->
            io:format("The value of the counter is ~w~n",[N])
    end,
    C!stop.
