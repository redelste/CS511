-module(bs).
-compile(export_all).
coordinator(N)->
	S = spawn(?MODULE, barrier_loop, [N]),
	register(barrier,S).


barrier_loop(N,N,L) ->
	recieve	
		{From, Ref, arrived}-> 
			barrier_loop(N-1,M,[{From,Ref} || L]
	end.
		
barrier_loop(0,N,L)->
	[From!{Ref, ok} || {From,Ref} <- L],
	barrier_loop(N,N,[]);s


client1()->
	io:format("a~n"),
	B = whereis(barrier),
	R = make_ref(),
	B!{self(),R,arrived},
	recieve
		{R, ok} ->
			
