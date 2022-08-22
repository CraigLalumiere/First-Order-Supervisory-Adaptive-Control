classdef ProjectionEstimator < handle
  properties
    theta_hat
    paramRange
    filter
  end
  methods
    function obj = ProjectionEstimator(p_range, initialGuess, filter)
      obj.paramRange = p_range;
      obj.theta_hat = initialGuess;
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
      e = y - phi'*obj.theta_hat(:, end); % prediction error
      
      if (norm(phi)^2 == 0) % phi = 0, do nothing
        obj.theta_hat(:, end+1) = obj.theta_hat(:, end);
      else
        obj.theta_hat(:, end+1) = obj.project( obj.theta_hat(:, end) + phi/(norm(phi)^2)*e );
      end
      t_hat = obj.theta_hat(:, end);
    end
    
    function y = project(obj, theta)
      y = max(min(theta, obj.paramRange(:,2)), obj.paramRange(:,1));
    end    
  end
end