n = 250; % how long to run simulation
paramRange = [1, 4; 1, 4]; % the set S
Na = 1; %1st order
Nb = 1;

% Constant Parameters
% a = [1;1];
% b = [2;1];

% Time-Varying Parameters
a = 2.5 + 1.5*cos(0.01*pi*(0:n-1));
b = 2.5 + 1.5*sin(0.003*pi*(0:n-1));

% Disturbance
w = 0.1*randn(n,1);

% initial condition for plant; rightmost column is t_0, others are previous history
ic = zeros(2,2);
plant = linSystem(ic, a, b);

%% Estimator Selection
initialGuess = mean(paramRange, 2); % initial guess for theta_hat
estimator = SupervisoryEstimator(paramRange, initialGuess, 0.6, 1, false);
% Last 3 params are lambda, dwell time, data filter on/off
% estimator = ProjectionEstimator(paramRange, initialGuess);

%% Certainty Equivalence Controller Selection
controller = dStepAhead(size(a,1), size(b,1));
% controller = integralPolePlacement(size(a,1), size(b,1));

%% Reference
r = sin(0.2*pi*(0:n+10));

%% Main Loop
for t = 1:n-1
  plant.update(w(t)); % find next y using phi and w
  theta_hat = estimator.estimate(plant);
  u = controller.control(theta_hat, plant, r, t+1);
  plant.next_input(u);
end