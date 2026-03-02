typedef struct parameters {
  double DiffAX;
  double DiffAY;
  double DiffBX;
  double DiffBY;
  double MAXVELOA;
  double MAXVELOB;
  double MINDISTA;
  double MINDISTB;
  double STEPTSRL;
} parameters;
typedef struct state {
  double DirMX;
  double DirMY;
  double Velocity;
} state;
//automatically generated monitor function for matlab
int HCMonitor(struct state pre,struct state post,struct parameters params);