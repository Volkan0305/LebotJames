classdef EnvironmentSetup
    properties
        kukaRobot           % Instance of KUKA robot
        linearUR5Robot      % Instance of Linear UR5 robot
        hoopPosition        % Position of the basketball hoop
        ballPosition        % Initial position of the basketball
        transferPosition    % Position where KUKA transfers the ball to Linear UR5
        hoopPlyFile         % File name of the hoop's .ply model
        ballPlyFile         % File name of the basketball's .ply model
        hoopMesh            % Mesh data for hoop
        ballMesh            % Mesh data for basketball
    end
    
    methods
        function self = EnvironmentSetup(baseTrKUKA, baseTrUR5, hoopPlyFile, ballPlyFile)
            % Constructor to initialize the environment
            
            % Initialize robots with their base transformations
            self.kukaRobot = KUKA(baseTrKUKA);
            self.linearUR5Robot = LinearUR5(baseTrUR5);
            
            % Set positions for key elements
            self.hoopPosition = [1.5, 0, 2];      % Example hoop position
            self.ballPosition = [0.3, 0.2, 0.5];  % Initial ball position
            self.transferPosition = [0.7, 0, 1.2]; % Transfer position
            
            % Set file paths for the environment .ply files
            self.hoopPlyFile = hoopPlyFile;
            self.ballPlyFile = ballPlyFile;
            
            % Configure the workspace and plot both robots and objects
            self.configure_environment();
        end
        
        function configure_environment(self)
            % Sets up the workspace and plots robots and environment objects
            
            % Plot robots
            disp('Plotting KUKA robot...');
            self.kukaRobot.model.plot3d(zeros(1, self.kukaRobot.model.n), ...
                'noarrow', 'workspace', [-2 2 -2 2 0 3]);
            drawnow;
            
            disp('Plotting Linear UR5 robot...');
            self.linearUR5Robot.model.plot3d(zeros(1, self.linearUR5Robot.model.n), ...
                'noarrow', 'workspace', [-2 2 -2 2 0 3]);
            drawnow;
            
            % Load and plot environment objects
            self.load_and_plot_object(self.hoopPlyFile, self.hoopPosition, 'hoop');
            self.load_and_plot_object(self.ballPlyFile, self.ballPosition, 'ball');
        end
        
        function load_and_plot_object(self, plyFile, position, objectName)
            % Load and plot a .ply object at a specified position
            if exist(plyFile, 'file') == 2
                [f, v, plyData] = plyread(plyFile, 'tri');  % Load .ply file
                % Create a patch for the object in 3D space
                objectMesh = trisurf(f, v(:,1) + position(1), v(:,2) + position(2), v(:,3) + position(3), ...
                                     'FaceVertexCData', plyData.vertex.red / 255, 'EdgeColor', 'none');
                
                % Store mesh data for reference (useful for adjustments)
                if strcmp(objectName, 'hoop')
                    self.hoopMesh = objectMesh;
                elseif strcmp(objectName, 'ball')
                    self.ballMesh = objectMesh;
                end
                
                hold on;
                disp([objectName, ' positioned at: ', num2str(position)]);
            else
                error(['PLY file not found for ', objectName, ': ', plyFile]);
            end
        end
        
        % Accessor methods for retrieving positions or robot instances
        function pos = get_hoop_position(self)
            pos = self.hoopPosition;
        end
        
        function pos = get_ball_position(self)
            pos = self.ballPosition;
        end
        
        function pos = get_transfer_position(self)
            pos = self.transferPosition;
        end
        
        function robot = get_robot(self, name)
            % Returns reference to the requested robot
            if strcmp(name, 'kuka')
                robot = self.kukaRobot;
            elseif strcmp(name, 'linearUR5')
                robot = self.linearUR5Robot;
            else
                error('Unknown robot name specified');
            end
        end
    end
end
