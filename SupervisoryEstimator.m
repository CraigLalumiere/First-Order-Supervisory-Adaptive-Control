classdef SupervisoryEstimator < handle
  properties
    theta_hat
    paramRange
    W
    lambda
    dwellTimer
    dwellTime
    filter
  end
  methods
    function obj = SupervisoryEstimator(p_range, initialGuess, lambda, dwellTime, filter)
      obj.paramRange = p_range;
      obj.theta_hat = initialGuess;
      obj.W = zeros(length(initialGuess)+1, length(initialGuess)+1);
      obj.lambda = lambda;
      obj.dwellTime = dwellTime;
      obj.dwellTimer = dwellTime-1;
      obj.filter = filter;
    end

    function t_hat = estimate(obj, plant)
      if obj.filter % disturbance annihilation filter
        y = plant.phi(1, end) - plant.phi(1, end-1);
        phi = plant.phi(:, end-1) - plant.phi(:, end-2);
      else
        y = plant.phi(1, end);
        phi = plant.phi(:, end-1);
      end

      obj.W(:,:,end+1) = obj.lambda*obj.W(:,:,end) + [phi;y]*[phi' y];
      w = obj.W(:,:,end);

      if (obj.dwellTimer > 0) % if dwelling
        obj.dwellTimer = obj.dwellTimer - 1;
        obj.theta_hat(:, end+1) = obj.theta_hat(:, end);
      else % if not dwelling
        H = 2*[w(1,1) w(2,1); w(2,1) w(2,2)];
        f = [-2*w(3,1); -2*w(3,2)];
  %       offset = w(3,3);
        A = [-1 0; 1 0; 0 -1; 0 1];
        b = [-obj.paramRange(1, 1); obj.paramRange(1, 2); -obj.paramRange(2, 1); obj.paramRange(2, 2)];
				
				% Optimize for positive HF gain
        options = optimoptions('quadprog','Display','off');
        x = quadprog(H,f,A,b,[],[],[],[],[],options);
  
        b = [-obj.paramRange(1, 1); obj.paramRange(1, 2); obj.paramRange(2, 2); -obj.paramRange(2, 1)];
				% Optimize for negative HF gain
        x2 = quadprog(H,f,A,b,[],[],[],[],[],options);
				
				% Choose the best of the two
        if (0.5*x2'*H*x2 + f'*x2 < 0.5*x'*H*x + f'*x)
          x = x2;
        end

        if (0.5*x'*H*x + f'*x < 0.5*obj.theta_hat(:, end)'*H*obj.theta_hat(:, end) + f'*obj.theta_hat(:, end))
          obj.theta_hat(:, end+1) = x;
          obj.dwellTimer = obj.dwellTime - 1; % Resume dwelling
        else
          obj.theta_hat(:, end+1) = obj.theta_hat(:, end);
        end
      end
      t_hat = obj.theta_hat(:, end);
    end
  end
end