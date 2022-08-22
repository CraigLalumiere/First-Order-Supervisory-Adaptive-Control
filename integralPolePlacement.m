classdef integralPolePlacement<handle
  properties
    Na
    Nb
  end
  methods
    function obj = integralPolePlacement(Na, Nb)
      obj.Na = Na;
      obj.Nb = Nb;
    end
    function u = control(obj, theta, plant, r, t)

      varphi = zeros(obj.Na+obj.Nb+1, 1);
      varphi(obj.Na+2:end) = plant.phi(obj.Na+1:end,end-1) - plant.phi(obj.Na+1:end,end-2);

      R = r(1)*ones(obj.Na+1, 1);
      for i = 1:obj.Na+1
        try
          R(i) = r(t-i);
        catch
        end
      end
      varphi(1:obj.Na+1) = [plant.phi(1,end-1); plant.phi(1:obj.Na,end-2)] - R;

      syms q 'real';

      A = 1-q.^(1:obj.Na)*theta(1:obj.Na);
      B = q.^(1:obj.Nb)*theta(obj.Na+1:end);
      l = sym('l_', [obj.Nb, 1], 'real');
      p = sym('p_', [obj.Na+1, 1], 'real');
      L = 1-q.^(1:obj.Nb)*l;
      P = -q.^(1:obj.Na+1)*p;

      charpoly = (1-q)*A*L + B*P;
      S = solve(coeffs(charpoly, q) == [1 zeros(1, obj.Na+obj.Nb+1)]);
      result = [subs(p, S); subs(l, S)];

      last_u = plant.phi(plant.Na+1,end-1);
      delta_u = result'*varphi;
      u = last_u + delta_u;
    end
  end
end