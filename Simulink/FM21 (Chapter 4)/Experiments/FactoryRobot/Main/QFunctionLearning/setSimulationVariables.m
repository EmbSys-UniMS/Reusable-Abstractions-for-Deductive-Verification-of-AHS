
%constant declarations
TSRL = 0.5;


%Number of time units until a new goal is chosen by an opponent if the
%current goal is blocked
BLOCKEDTIMER=5;

%constants for opponents
TSA = 0.5;
TSB = 0.5;

SAFETYDISTANCEA=1;
SAFETYDISTANCEB=1;

MAXVELOA = 1;
MAXVELOB = 1;

EPS = 0.01; % epsilon to ensure initial distance is > SAFETYDISTANCE

THRESHOLDA = SAFETYDISTANCEA+TSA*MAXVELOA;
THRESHOLDB = SAFETYDISTANCEB+TSB*MAXVELOB;

simParameters = {TSRL,[MAXVELOA,THRESHOLDA],[MAXVELOB,THRESHOLDB]};