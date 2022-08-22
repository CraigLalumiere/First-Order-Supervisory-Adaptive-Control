classdef dStepAhead<handle
  properties
    Na
    Nb
  end
  methods
    function obj = dStepAhead(Na, Nb)
      obj.Na = Na;
      obj.Nb = Nb;
    end
    function u = control(obj, theta, plant, r, t)
      A = diag(ones(obj.Na+obj.Nb-1,1), -1);
      A(obj.Na+1, :) = NaN;
      A(1,:) = theta';
      phi = plant.phi(:,end);
      d = 1;

      while(theta(obj.Na+d) == 0)
        d = d+1;
        phi(obj.Na+1) = 0;
        phi = A*phi;
      end
      u = r(t+d);

      for i = 1 : obj.Na
        u = u - theta(i)*phi(i);
      end
      for i = obj.Na+d+1 : obj.Na+obj.Nb
        u = u - theta(i)*phi(i);
      end
      u = u/theta(obj.Na+d);
    end
  end
end