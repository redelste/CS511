/*

two processes server 1 and server 2. Server 1 is blocked on request = 1,
and server 2 is blocked on request = 2.
Client sends request =1 (send message), then it will set request = 0,
and then progress to set request = 2.

If we grab this program and we try to verify it, it will get those invalid
endstates. If we verify this, we get errors:1, invalid endstate.

It becomes deadlocked at line 5 of requtest = 1, and line 12 of request == 2.


Servers are meant to run without stopping.
To indicate to spin, use "endserver: " label

Spin now knows that if it's blocked, it's ok because it's expected from the
point of view of the model.
*/


byte request = 0;

active proctype Server1(){
  /*declaring it a valid endstate from our viewpoint using "endstate:" tag.*/
  endserver1:
  do
  :: request == 1 ->
        printf("Service 1\n");
        request = 0;
  od
}

active proctype Server2(){
  endserver2:
  do
  :: request == 1 ->
        printf("Service 2\n");
        request = 0;
  od
}


active proctype Client(){
/*after processing both requests the requet is done. they are waiting to
recieve both requests. */
  request = 1;
  request == 0;
  request = 2;
  request == 0;
}



/*exercise 7 from EB9, Implement semaphores in promela*/
byte sem = 1;
byte critical=0;
inline acquire (sem) {
    atomic{
      /*If the value of semaphore is greater than zero, then change, otherwise block.*/
      sem >0;
      sem--
    }
  }
inlinerelease (sem) {
  sem++
}
active[2] proctypeuser () {
        acquire (sem);
        printf( "%d is in the CS \n" , _pid );
        critical++;
        assert(critical==1);
        critical--;
        release (sem)

}


/* exercise 8 from EB 9*/

byte sem =1;
byte m =0;
byte w =0;
inline acquire(sem){
  atomic{
    sem>0;
    sem--
  }
}

inlinerelease(sem){
  sem++
}

active proctype man(){
  acquire(mutex);
  acquire(ticket);
  acquire(ticket);
  acquire(mutex);
  m++;
  assert(m*2<=w)
}

active proctype woman(){
  release(ticket);
  w++
}
