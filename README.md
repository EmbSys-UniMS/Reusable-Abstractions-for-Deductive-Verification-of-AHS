# Models and Proofs for the thesis "Reusable Abstractions for Deductive Verification of Autonomous Hybrid Systems"

This repository contains the models and proofs accompanying the thesis.

---

## Proofs dL

Contains all differential dynamic logic (dL) proofs discussed in the thesis.

---

# Simulink Models and Simulation Experiments


## Simulink/FM21/

Simulink Models for the FM21 factory robot case study (Chapter 4).

### Running Experiments

1. Open MATLAB.
2. Load the project by opening one of the models in:  
   `Simulink/FM21/Experiments/FactoryRobot/Simulink`
3. Start the learning experiments by running the script:  
   `Simulink/FM21/Experiments/FactoryRobot/Main/QFunctionLearning/runExp.m`
4. To run the chaotic/crash scenario run the script:  
   `Simulink/FM21/Experiments/FactoryRobot/Main/CrashExperiment/simmainCE.m`

---



## Simulink/ATVA/

Simulink Models for the ATVA Temperature control, ACC and Water tank case studies (Chapter 5). Models for the autonomous robot and IWDS are provided in FM21 and (A)ISoLA.

---

## Simulink/AISoLA/

Simulink models for the (A)ISoLA Intelligent Water Distribution System (IWDS) case study (Chapter 7).

The contents of `Simulink/AISoLA` were developed jointly by the **Embedded Systems Group** and the **Safety-Critical Systems Group**.  
All other repository content was developed by the Embedded Systems Group.

### Running Experiments

1. Open MATLAB.
2. Open the IWDS model and load the project:  
   `Simulink/AISoLA/Model/WaterDistSystem.slx`
3. Run: `Simulink/AISoLA/runExp`

---

## Simulink/ResiliencePatternsSimulation/

Simulink models for the IWDS case study using the resilience patterns introduced in the FM24 paper (Chapter 6).

### Running Experiments

1. Open MATLAB.
2. Open the IWDS model and load the project:  
   `Simulink/ResiliencePatternsSimulation/Model/WaterDistSystem.slx`  
3. Run: `Simulink/ResiliencePatternsSimulation/runExp`

---

## Link to Simulink2dL
https://github.com/EmbSys-WWU/Simulink2dL

---

## RTOSVerification

Contains the student application in UPPAAL, with and without data queues (Chapter 8).

---

