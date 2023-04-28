classdef SackState < handle
   properties
      outliers; 
      fit_segs_start = []; 
      fit_segs_end = []; 
      fit_circle_origins = []; 
      fit_circle_radii = [];
      circle_found = 0;
     

      % robot position
      x = -.84; 
      y = -.93; 
      commands = [];


      % gradient equations 
      symb_x = -1;
      symb_y = -1; 
      symb_f = 0;
      num_f = [];

   end
   properties(Constant)
      debug_mode = 1; % whether to plot or not while iterating  
      color_map = 1;
      quiver_map = 0;
      theoretical_map = 0;
      plot_fit_lines = 0;

      % RANSACK LINE FIT --------------------------------------------------
      line_vertical_thresh = 0.1; % inlier threhold for vertical line fit
      line_horizontal_gap_thresh = 0.1; % inlier threshold for line fit gap
      line_min_pints = 5; % minimum point requirements for line model
      line_num_iters = 500; % how many times to sample for line fit
      % RANSACK LINE FIT --------------------------------------------------

      % RANSACK CIRCLE FIT --------------------------------------------------
      circle_distance_thresh = 0.1; % inlier threshold for distance to circle model
      circle_min_pints = 5; % minimum point requirements for circle model
      circle_num_iters = 500; % how many times to sample for circle fit
      % RANSACK CIRCLE FIT --------------------------------------------------

   end
   methods(Static)
       % initialize ransack from polar coords
       function obj = FromPolar(r, theta)
           obj = SackState();
           obj.outliers = [r .* cosd(theta), r .* sind(theta)];
           obj.outliers = filter_by_row(obj.outliers, @(x) (x(1)));
       end
       % initialize ransack from global (x, y) cords
       function obj = FromGlobal(x, y)
           obj = SackState();
           obj.outliers = [x, y];
       end
   end
   methods
      % constructor
      function self = SackState()
            syms symb_x symb_y;
            self.symb_x = symb_x;
            self.symb_y = symb_y;
      end
      function [res] = logn(self,x,n)
          res = log(x)/log(n);
      end
      function [model_found] = sack_iter(self)
            %{
            while(self.circle_found ~= 1)
                [fit_circle_start, fit_circle_rad, circle_fit_inliers, circle_fit_outliers] = sack_circle(self.outliers, SackState.circle_distance_thresh, SackState.circle_min_pints, SackState.circle_num_iters);
                if(fit_circle_rad ~= -1)
                    self.circle_found = 1;
                    self.fit_circle_origins = [self.fit_circle_origins; fit_circle_start(1) fit_circle_start(2)];
                    self.fit_circle_radii = [self.fit_circle_radii; fit_circle_rad];
                    self.outliers = circle_fit_outliers;
                    fprintf("found circle at %f and %f with radius %f!\n", fit_circle_start(1), fit_circle_start(2), fit_circle_rad);
        
                    % visualize output fit to plot if in debug mode
                    if(self.debug_mode)
                       color = [rand,rand,rand];
                       scatter(circle_fit_inliers(:,1), circle_fit_inliers(:,2), 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
                       plot_circle(fit_circle_start(1), fit_circle_start(2), fit_circle_rad, color);
                    end
                end
          
            end 
            %}
           
            [fit_seg_start, fit_seg_end, line_fit_inliers, line_fit_outliers] = sack_line(self.outliers, SackState.line_vertical_thresh, SackState.line_horizontal_gap_thresh, SackState.line_min_pints, SackState.line_num_iters);
            if(size(line_fit_inliers,1) == 0)
                % no suitable model left in data
                model_found = 0;
                return;
            else
               % line has a better fit
               self.fit_segs_start = [self.fit_segs_start; fit_seg_start(1) fit_seg_start(2)];
               self.fit_segs_end = [self.fit_segs_end; fit_seg_end(1) fit_seg_end(2)];
               self.outliers = line_fit_outliers;
               
               % visualize output fit to plot if in debug mode
               if(self.debug_mode)
                   color = [rand,rand,rand];
                   add_source_line(self, fit_seg_start, fit_seg_end);
                   scatter(line_fit_inliers(:,1), line_fit_inliers(:,2), 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
                   if(self.plot_fit_lines)
                        plot([fit_seg_start(1), fit_seg_end(1)], [fit_seg_start(2), fit_seg_end(2)], 'Color', color);
                   end
               end
            end

            % some model was found
            model_found = 1;
      end
      % marks a point in the gauntlet as a place to seek
      function [] = add_sink(self, x, y, rad)
        scalar = 1000;
        syms u; 
        pos = [x + rad*cos(2*pi*u); y + rad*sin(2*pi*u)];
        expr = scalar*((sqrt( (self.symb_x - pos(1)).^2 +  (self.symb_y - pos(2)).^2 )) .^ (-4));
        res = int(expr, u, [0,1], 'Hold', true);
        self.symb_f = self.symb_f + res;
      end
      function [] = add_source_line(self, line_start, line_end)
          scalar = 0.1;
          syms u; 
          pos = line_start + (line_end - line_start) .* u;
          expr = -1*scalar*((sqrt( (self.symb_x - pos(1)).^2 +  (self.symb_y - pos(2)).^2 )) .^ (-3.5));
          res = int(expr, u, [0,1], 'Hold', true);
          self.symb_f = self.symb_f + res;
      end
      function [] = bias_center(self)
          scalar = 1500;
          expr = -1*scalar*(sqrt((self.symb_x+0.2).^2 +  self.symb_y.^2));
          self.symb_f = self.symb_f + expr;
      end
      function [] = move_neato(self)
         eps = 0.000001;
         num_f = matlabFunction(self.symb_f);
         dx = @(x_,y_) ((num_f(x_+eps,y_) - num_f(x_,y_))/ eps);
         dy = @(x_,y_) ((num_f(x_,y_+eps) - num_f(x_,y_))/ eps);

         step = 0.15;

         dir = [dx(self.x,self.y) dy(self.x,self.y)];
         dir = dir ./ norm(dir);
         dir = dir * step;


         % move the actual neato

         % stop moving the neato

         % update our position where we think we are
         self.x = self.x + dir(1);
         self.y = self.y + dir(2);

      end
      function [] = goal(self)
          for iter=1:30
              self.commands = [self.commands; self.x self.y];
              move_neato(self);
          end
          if(self.theoretical_map)
              plt = plot(self.commands(:,1), self.commands(:,2), 'black', 'LineWidth', 10);
          end
      end
      % run iterative RANSACK with multiple models
      function [] = sack_multi(self)
          % visualize output fit to plot if in debug mode
          if(self.debug_mode)
              figure(); hold on; axis equal; shading interp;
          end
          % resolve iteratively
          while(sack_iter(self))
              size(self.outliers)
          end
          % plot out contour if in debug mode
          if(self.debug_mode)
              scatter(self.outliers(:,1), self.outliers(:,2))
              add_sink(self,1.05,-0.35, 0.135);
              bias_center(self);
              add_source_line(self,[0.235; -0.55], [0.50; -0.87]); % our scans are bad
              add_source_line(self,[-0.09; -0.53], [-0.27; -0.31]); % our scans are bad
              goal(self);

              axis equal; xlim([-1.5,1.5]); ylim([-1.5,1.5]);

              %[X,Y] = meshgrid(-1.5:0.01:1.5,-1.5:0.01:1.5);
              %Z = 
              
              if(self.color_map)
                  fcontour(matlabFunction(self.symb_f), [-1.5 1.5], 'Fill','on');
                  colormap('turbo');
                  %surf(self.mesh_grid_x,self.mesh_grid_y, self.mesh_grid_z);
                  %contourf(X,X,Z, 1000, 'edgecolor','none', 'Fill','on');
                  %colormap('hot');
              end

              % send contour plot to background by flipping plot elements
              % https://www.mathworks.com/matlabcentral/answers/30212-how-to-bring-a-plot-to-the-front-or-back-among-multiple-plots
              h = get(gca,'Children');
              set(gca,'Children',flip(h))

              if(self.quiver_map)
                  eps = 0.000001;
                  num_f = matlabFunction(self.symb_f);
                  dx = @(x_,y_) ((num_f(x_+eps,y_) - num_f(x_,y_))/ eps);
                  dy = @(x_,y_) ((num_f(x_,y_+eps) - num_f(x_,y_))/ eps);
                  for qx=-1.5:0.05:1.5
                      for qy=-1.5:0.05:1.5                      
                            qvec = [dx(qx,qy), dy(qx,qy)];
                            qvec = qvec ./ norm(qvec);
                            qvec = qvec / 20;
                            obj = quiver(qx, qy, qvec(1), qvec(2), 'Color', 'white');
                            obj.Annotation.LegendInformation.IconDisplayStyle = "off";

                      end
                  end
                  
                  legend("Gradient");


                  %[Dx, Dy] = gradient(self.mesh_grid_z);
                  %quiver(self.mesh_grid_x, self.mesh_grid_y, Dx, Dy)
              end
              

          end
      end

   end
end