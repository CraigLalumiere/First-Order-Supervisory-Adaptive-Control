classdef linSystem<handle
  properties
    phi
    transferfunction
    a
    b
    Na
    Nb
    t
    t_offset
  end
  methods
    function obj = linSystem(ic, a, b)
      obj.phi = ic;
      obj.a = a;
      obj.b = b;
      obj.Na = size(a,1);
      obj.Nb = size(b,1);
      obj.transferfunction = tf(b(:, 1)', [1 -a(:, 1)'], 1); % True plant tf
      obj.t = 1;
      obj.t_offset = size(ic, 2) - 1;
    end
    function update(obj, w)
      if (size(obj.a,2) == 1) % if constant parameters
        theta = [obj.a; obj.b];
      else % if time-varying parameters
        theta = [obj.a(:,obj.t); obj.b(:,obj.t)];
        obj.transferfunction = tf(obj.b(:, obj.t)', [1 -obj.a(:, obj.t)'], 1); % True plant tf
      end
      A = diag(ones(obj.Na+obj.Nb-1,1), -1);
      A(obj.Na+1, :) = NaN;
      A(1,:) = theta';
      B = [1; zeros(obj.Na + obj.Nb - 1, 1)];
      obj.phi(:, end+1) = A*obj.phi(:,end) + B*w;

      obj.t = obj.t+1;
    end

    function next_input(obj, u)
      obj.phi(obj.Na+1, end) = u;
    end

    function print_phi(obj)
      fprintf("  t,  y,    u\n");
      fprintf("-----------------------\n");
      fprintf("%3d, %8.4f, %8.4f \n", [(1-obj.t_offset: size(obj.phi, 2) - obj.t_offset); obj.phi(1, :); obj.phi(obj.Na+1, :)]);
    end
  end
end