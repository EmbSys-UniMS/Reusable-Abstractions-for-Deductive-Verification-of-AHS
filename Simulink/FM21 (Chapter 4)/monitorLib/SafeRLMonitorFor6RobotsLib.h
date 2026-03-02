typedef struct parameters {
  double DiffAX;
  double DiffAY;
  double DiffBX;
  double DiffBY;
  double DiffCX;
  double DiffCY;
  double DiffDX;
  double DiffDY;
  double DiffEX;
  double DiffEY;
  double DiffFX;
  double DiffFY;
  double MAXVELOA;
  double MAXVELOB;
  double MAXVELOC;
  double MAXVELOD;
  double MAXVELOE;
  double MAXVELOF;
  double MINDISTA;
  double MINDISTB;
  double MINDISTC;
  double MINDISTD;
  double MINDISTE;
  double MINDISTF;
  double STEPTSRL;
} parameters;
typedef struct state {
  double DirMX;
  double DirMY;
  double Velocity;
} state;
//automatically generated monitor function for matlab
int HCMonitor(struct state pre,struct state post,struct parameters params);