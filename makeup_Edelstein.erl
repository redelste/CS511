-module(makeup).
-compile(export_all).


readlines(FileName) ->
 {ok, Device} = file:open(FileName, [read]) ,
 try get_all_lines(Device)
   after file:close(Device)
 end.

get_all_lines(Device) ->
   case io:get_line (Device, "") of
       eof -> [];
       Line -> Ss=string:tokens(Line," ,\n"),
       [{hd(Ss), tl(Ss)}] ++ get_all_lines (Device)
   end.



% each sensor maintains a value representing its current temp reading.
% keys are node and values are list of neighbors, pids are also neighbors
% make a pid for everything in the dict.
% N is representative of the neighborhood
spawnsensors(N) when N /= [] ->
    [{Nodename,Lst}|T] = N,
    Pid = spawn(?MODULE, sensor, [Lst, rand:uniform(100)]),
    register(list_to_atom(Nodename),Pid),
    spawnsensors(T);
spawnsensors(N) when N == []->
  io:fwrite("~n", []).

sensor(Neighbors, Temp)->
  io:format("My reading is ~w~n", [Temp]),
  receive
    {tick}->
      tempCall(Temp,Neighbors),
      UpdatedTemp = getReadings(Neighbors, [], 0),
      sensor(Neighbors, UpdatedTemp);
    {directReading,Temperature}->
      sensor(Neighbors, Temperature)
    end.
tempCall(Temp, Neighbors) when Neighbors /= [] ->
  [Node|T] = Neighbors,
  Pid = whereis(list_to_atom(Node)),
  Pid ! {Temp, sreading},
  tempCall(Temp,T);


tempCall(Temp, Neighbors) when Neighbors == [] ->
  io:fwrite("~n", []).

getReadings(Neighbors, Temps, Count) when length(Neighbors) > Count ->
  receive
    {Temp, sreading}->
      getReadings(Neighbors, lists:append(Temps, [Temp]), Count+1)
  end;

getReadings(Neighbors, Temps, Count) when length(Neighbors) == Count ->
  % io:format("TEMPSLIST: ~w~n", [Temps]),
  lists:sum(Temps)/length(Temps).

timer(N)->
  timer:sleep(1000),
  [{Nodename,Lst}|T] = N,
  tick(N),
  timer(N).

tick(N) when N /= []->
  [{Nodename,Lst}|T] = N,
  Pid = whereis(list_to_atom(Nodename)),
  Pid  ! {tick},
  tick(T);

tick(N) when N == []->
  io:fwrite("~n", []).

start(FileName)->
  N = readlines(FileName),
  spawnsensors(N),
  timer(N).


% init([])->
%   done;
% % call on dictionary / list from input of readlines(FileName) | T
% init([{NodeName, List_of_Neighbors}|T])->
%   % populates DICT_GLOBAL
%   % Setting D to a store in the dictionary, The key of the store is
%   % NodeName, the value is the spawn function.
%   % in the spawn function we spawn a new node, and a nodename which is
%   %  assigne a random value.
%   D = dict:store(NodeName, spawn(?MODULE, new_node, [NodeName,rand:uniform(10)])),
%   DICT_GLOBAL = D,
%   % recursive call on tail end of dictionary
%   init(T).
