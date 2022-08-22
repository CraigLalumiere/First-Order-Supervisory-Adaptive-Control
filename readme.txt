This is the supplementary MATLAB simulation code for the 2022 Master's thesis "Supervisory Adaptive Control Revisited: Linear-like Convolution Bounds" by Craig Lalumiere for the Electrical and Computer Engineering department at the University of Waterloo. 

This code is developed for MATLAB R2022a. 

Execute 'Main.m' and then run "plant.print_phi" to print the plant's output 'y' and input 'u' over time. 

'plant' is an object of the 'linSystem' class, which simulates the plant dynamics. 

The adaptive controller is made up of two components: the 'estimator' and 'controller'. 'estimator' is either an object of the 'SupervisoryEstimator' class or the 'ProjectionEstimator' class. The Supervisory Estimator is of course the subject of the thesis, the Projection Estimator is another widely used parameter estimator, and is provided here for the sake of comparing the performance of the two methods. The 'controller' is either an object of the 'dStepAhead' class (for control of minimum phase plants) or the 'integralPolePlacement' class (for control of possibly non-minimum phase plants, and for rejection of a constant disturbance). 