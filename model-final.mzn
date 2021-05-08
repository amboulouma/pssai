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

array[int] of int: minShift = [2, 2, 2];
array[int] of int: maxShift = [6, 6, 4];

int: d_min=minShift[1]; % lower bound for dayshift
int: d_max=maxShift[1]; % upper bound for dayshift
int: a_min=minShift[2]; % lower bound for afternoon shift
int: a_max=maxShift[2]; % upper bound for afternoon shift
int: n_min=minShift[3]; % lower bound for nightshift
int: n_max=maxShift[3]; % upper bound for nightshift

set of int: EMPLOYEE = 1..groups; % Employees

set of int: DAY = 1..m; % Days

% Shifts
set of int: SHIFT = 1..numShifts+1; 
int: day = 1; int: afternoon = 2; int: night = 3; int: dayoff = 4;
array[SHIFT] of string: code = ["D", "A", "N", "-"];

% Demand
array[SHIFT, DAY] of int: demand = [| 5, 5, 5, 5, 5, 5, 0,
                                    | 5, 5, 5, 5, 5, 5, 0,
                                    | 1, 1, 1, 1, 1, 0, 0 |];


% Solution matrix
array[EMPLOYEE,DAY] of var SHIFT: x;
                   
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

% Constraint of lower and upper bonds of day, afternoon, night shifts and dayoff
include "global_cardinality_low_up.mzn";

constraint forall(e in EMPLOYEE)
                 (global_cardinality_low_up([x[e,d] | d in DAY ],
                   [ day ], 
                   [ d_min ], 
                   [ d_max ])) 
           \/ forall(e in EMPLOYEE)
                 (global_cardinality_low_up([x[e,d] | d in DAY ],
                   [ afternoon ], 
                   [ a_min ], 
                   [ a_max ]))
           \/ forall(e in EMPLOYEE)
                 (global_cardinality_low_up([x[e,d] | d in DAY ],
                   [ night ], 
                   [ n_min ], 
                   [ n_max ]))
           \/ forall(e in EMPLOYEE)
                 (global_cardinality_low_up([x[e,d] | d in DAY ],
                   [ dayoff ], 
                   [ minOff ], 
                   [ maxOff ]));

% Constraint on lowe and upper bond of working days

solve satisfy;

output [ code[fix(x[e,d])] 
         ++ if d = m then "\n" else " " endif
       | e in EMPLOYEE, d in DAY];
