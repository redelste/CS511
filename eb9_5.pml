byte np = 0;
byte nq = 0;

active proctype P(){
  do
  :: np = np + 1;
  :: np = 0;
  od
}

active proctype Q(){
  do
  :: nq = np + 1;
  :: np = 0;
  od
}
