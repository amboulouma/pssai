% Number of shift types
int: numShifts = 3;
% Number of employees
int: groups = 13;
% number of days
int: m=7; 

int: minOn=3; % lower bound for working day
int: maxOn=7; % upper bound for working day
int: minOff=1; % lower bound for dayoff
int: maxOff=4; % upper bound for dayoff

set of int: EMPLOYEE = 1..groups;
set of int: DAY = 1..m;

set of int: SHIFT = 1..numShifts+1;
int: day = 1; int: afternoon = 2; int: night = 3; int: dayoff = 4;
array[SHIFT] of string: code = ["D", "A", "N", "-"];



int: d_min=2; % lower bound for dayshift
int: d_max=5; % upper bound for dayshift
int: a_min=2; % lower bound for afternoon shift
int: a_max=4; % upper bound for afternoon shift
int: n_min=2; % lower bound for nightshift
int: n_max=3; % upper bound for nightshift


array[EMPLOYEE,DAY] of var SHIFT: x;

constraint forall(e in EMPLOYEE, d in 1..m-2)
                 ( x[e,d] = night /\ x[e,d+1] = night 
                   -> x[e,d+2] = dayoff);
% Forbidden (if forbidden)
%% Forbidden afternoon
constraint forall(e in EMPLOYEE, d in 1..m-1)
                 (x[e,d] = afternoon -> x[e,d+1] != day);

%% Forbidden nights
constraint forall(e in EMPLOYEE, d in 1..m-1)
                 (x[e,d] = night -> x[e,d+1] != day);

constraint forall(e in EMPLOYEE, d in 1..m-1)
                 (x[e,d] = night -> x[e,d+1] != afternoon);

% Forbidden 3 (if forbidden3)
constraint forall(e in EMPLOYEE, d in 1..m-2)
                 (x[e,d] = night /\ x[e,d+1] = dayoff -> x[e,d+2] != night);
constraint forall(e in EMPLOYEE, d in 1..m-2)
                 (x[e,d] = night /\ x[e,d+1] = dayoff -> x[e,d+2] != day);
constraint forall(e in EMPLOYEE, d in 1..m-2)
                 (x[e,d] = night /\ x[e,d+1] = dayoff -> x[e,d+2] != afternoon);
constraint forall(e in EMPLOYEE, d in 1..m-2)
                 (x[e,d] = afternoon /\ x[e,d+1] = dayoff -> x[e,d+2] != day);                 


include "global_cardinality_low_up.mzn";
constraint forall(e in EMPLOYEE)
                 (global_cardinality_low_up([x[e,d] | d in DAY ],
                   [ day, afternoon, night, dayoff ], 
                   [ d_min, a_min, n_min, minOff ], 
                   [ d_max, a_max, n_max, maxOff ])); 

solve satisfy;

output [ code[fix(x[e,d])] 
         ++ if d = m then "\n" else " " endif
       | e in EMPLOYEE, d in DAY];
