-module(ec).
-compile(export_all).

readlines (FileName) ->
 {ok, Device} = file:open(FileName, [read]) ,
 try get_all_lines(Device)
   after file : close(Device)
 end.

get_all_lines (Device) ->
   case io : get_line (Device, "") of
       eof -> [];
       Line -> Ss=string:tokens(Line ," ,\n"),
       [{hd(Ss), tl(Ss)}] ++ get_all_lines (Device)
   end.
