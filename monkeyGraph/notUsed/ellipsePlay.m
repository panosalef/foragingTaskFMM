% Define parameters.
fontSize = 15;
x1 = 0;
x2 = 20;
y1 = 10;
y2 = 10;
eccentricity = .85;
numPoints = 300; % Less for a coarser ellipse, more for a finer resolution.

% Make equations:
a = (1/2) * sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
b = a * sqrt(1-eccentricity^2);
t = linspace(0, 2 * pi, numPoints); % Absolute angle parameter
X = a * cos(t);
Y = b * sin(t);
% Compute angles relative to (x1, y1).
angles = atan2(y2 - y1, x2 - x1);
x = (x1 + x2) / 2 + X * cos(angles) - Y * sin(angles);
y = (y1 + y2) / 2 + X * sin(angles) + Y * cos(angles);

% Plot the ellipse as a blue curve.
subplot(2, 1, 1);
plot(x,y,'b-', 'LineWidth', 2);	% Plot ellipse
grid on;
axis equal
% Plot the two vertices with a red spot:
hold on;
plot(x1, y1, 'r.', 'MarkerSize', 25);
plot(x2, y2, 'r.', 'MarkerSize', 25);
caption = sprintf('Ellipse with vertices at (%.1f, %.1f) and (%.1f, %.1f)', x1, y1, x2, y2);
title(caption, 'FontSize', fontSize);
xlabel('x', 'FontSize', fontSize);
ylabel('y', 'FontSize', fontSize);

% Plot the x and y.  x in blue and y in red.
subplot(2, 1, 2);
plot(t, x, 'b-', 'LineWidth', 2);
grid on;
hold on;
plot(t, y, 'r-', 'LineWidth', 2);
legend('x', 'y', 'Location', 'north');
title('x and y vs. t', 'FontSize', fontSize);
xlabel('t', 'FontSize', fontSize);
ylabel('x or y', 'FontSize', fontSize);
% Set up figure
g = gcf;
g.WindowState = 'maximized';
g.NumberTitle = 'off';
g.Name = 'Ellipse Demo by Roger Stafford and Image Analyst'