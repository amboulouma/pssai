% Project Topic D: Rotating Workforce Scheduling
% Problem Solving and Search in AI: Programming Exercises
% Mohamed Amine Boulouma
% 

% Input variables
int: m=7; % number of days
set of int: DAY = 1..m; % Days

int: minOn; % lower bound for working day
int: maxOn; % upper bound for working day

int: minOff; % lower bound for dayoff
int: maxOff; % upper bound for dayoff

int: numShifts; % Number of shift types
int: groups; % Number of employees

array[int] of int: minShift; % Lower bound shifts
array[int] of int: maxShift; % Upper bound shifts

array[int] of set of int: forbidden; % Forbidden set 1
array[int, int] of int: forbidden3; % Forbidden set 3

float: lf = length(forbidden);
float: lf_3=length(forbidden3)/3;

array[1..numShifts, DAY] of int: demand; % Demand

set of int: EMPLOYEE = 1..groups; % Employees

int: d_min=minShift[1]; % lower bound for dayshift
int: d_max=maxShift[1]; % upper bound for dayshift
int: a_min=minShift[2]; % lower bound for afternoon shift
int: a_max=maxShift[2]; % upper bound for afternoon shift
int: n_min=minShift[3]; % lower bound for nightshift
int: n_max=maxShift[3]; % upper bound for nightshift

% Shifts
int: shifts = numShifts+1;
set of int: SHIFT = 1..shifts; 
int: day = 1; int: afternoon = 2; int: night = 3; int: dayoff = 4;
array[SHIFT] of string: code = ["D", "A", "N", "-"];

% Solution matrix
array[EMPLOYEE,DAY] of var SHIFT: x;

% Demand constraints
constraint forall(d in 1..m)(
                 sum(e in EMPLOYEE)(x[e,d] == day) == demand[1, d] /\
                 sum(e in EMPLOYEE)(x[e,d] == afternoon) == demand[2, d] /\
                 sum(e in EMPLOYEE)(x[e,d] == night) == demand[3, d]
                 );

% Forbidden (if forbidden)
%% Forbidden afternoon
constraint if lf == 3 then forall(e in EMPLOYEE, d in 1..m-1)
                 (x[e,d] = afternoon -> x[e,d+1] != day) endif;

%% Forbidden nights
constraint if lf == 3 then forall(e in EMPLOYEE, d in 1..m-1)
                 (x[e,d] = night -> x[e,d+1] != day) endif;

constraint if lf == 3 then forall(e in EMPLOYEE, d in 1..m-1)
                 (x[e,d] = night -> x[e,d+1] != afternoon) endif;

% Forbidden 3 (if forbidden3)
constraint if lf_3 == 4 then forall(e in EMPLOYEE, d in 1..m-2)
                 (x[e,d] = night /\ x[e,d+1] = dayoff -> x[e,d+2] != night) endif;
constraint if lf_3 == 4 then forall(e in EMPLOYEE, d in 1..m-2)
                 (x[e,d] = night /\ x[e,d+1] = dayoff -> x[e,d+2] != day) endif;
constraint if lf_3 == 4 then forall(e in EMPLOYEE, d in 1..m-2)
                 (x[e,d] = night /\ x[e,d+1] = dayoff -> x[e,d+2] != afternoon) endif;
constraint if lf_3 == 4 then forall(e in EMPLOYEE, d in 1..m-2)
                 (x[e,d] = afternoon /\ x[e,d+1] = dayoff -> x[e,d+2] != day) endif;                 

% Constraint on lower and upper bonds of consecutive working days
%% Lower bond
constraint forall(e in EMPLOYEE)
              (exists(d in 1..m-minOn+1)(
                    forall(i in d..d+minOn-1)(
                      x[e,i] != dayoff 
                  )
               )
           ); 
%% Upper bond
constraint forall(e in EMPLOYEE, d in 1..m-maxOn+1)(
                  forall(i in d..d+maxOn-1)(
                      x[e,i] != dayoff 
                  ) -> if d+maxOn <= m then x[e,d+maxOn] == dayoff endif
           ); 
           
% Constraint on lowe and upper bond of days off
constraint forall(e in EMPLOYEE)(
                 % Day off
                 sum(d in DAY)(x[e,d] == dayoff) >= minOff /\
                 sum(d in DAY)(x[e,d] == dayoff) <= maxOff
                 );
                 
% Constraint on lowe and upper bond of shifts
constraint forall(e in EMPLOYEE)(
                  % Day shifts
                 (
                 sum(d in DAY)(x[e,d] == day) >= d_min /\
                 sum(d in DAY)(x[e,d] == day) <= d_max
                 ) \/
                 % Afternoon shifts
                 (
                 sum(d in DAY)(x[e,d] == afternoon) >= a_min /\
                 sum(d in DAY)(x[e,d] == afternoon) <= a_max
                 ) \/
                 % Night shifts
                 (
                 sum(d in DAY)(x[e,d] == night) >= n_min /\
                 sum(d in DAY)(x[e,d] == night) <= n_max
                 )
                 );
solve satisfy;

output [ code[fix(x[e,d])] 
         ++ if d = m then "\n" else " " endif
       | e in EMPLOYEE, d in DAY];
