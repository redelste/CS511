-module(eb8ex2).
-compile(export_all).
% {start}:  client wishes to send a number of strings to be concatenated;
% {add,S}:  concatenate stringSto the current result;
% {done}:  done sending strings, send back result.


server()->
  receive
    io:fwrite("Server ~w is ready to concatonate some strings", [self()]),
    {start}-> server2("")
  end.

server2(S1)->
  receive
    {add,S}->
       io:fwrite("recieved ~w", [S]),
       server2(S1 ++ S);
    {done}->
      io:fwrite("concatenated results~w", [S1])
  end.
