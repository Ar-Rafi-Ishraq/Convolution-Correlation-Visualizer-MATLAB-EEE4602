%% =========================================================
%          CONVOLUTION REAL-TIME PLOTTING
%     Discrete-Time and Continuous-Time Animation
% =========================================================

clc;
clear;
close all;


%% =========================================================
%          PART 1: DISCRETE-TIME CONVOLUTION
% =========================================================

disp('=== Discrete-Time Convolution Animation ===');


%% ---------------------------------------------------------
% Input signal x[n]
% ---------------------------------------------------------

x = [1 2 1 0];

% Starting index of x[n]
nx_start = -1;

% Ending index of x[n]
nx_end = nx_start + length(x) - 1;

% Index vector of x[n]
nx = nx_start:nx_end;


%% ---------------------------------------------------------
% Impulse response h[n]
% ---------------------------------------------------------

h = [1 1 1];

% Starting index of h[n]
nh_start = 0;

% Ending index of h[n]
nh_end = nh_start + length(h) - 1;

% Index vector of h[n]
nh = nh_start:nh_end;


%% ---------------------------------------------------------
% Flip impulse response
%
% Convolution:
%
% y[n] = sum x[k] h[n-k]
%
% Therefore h[k] is flipped first and then shifted.
% ---------------------------------------------------------

h_flipped = fliplr(h);


%% ---------------------------------------------------------
% Determine output indices
% ---------------------------------------------------------

ny_start = nx_start + nh_start;

ny_end = nx_end + nh_end;

ny = ny_start:ny_end;


%% ---------------------------------------------------------
% Initialize convolution output
% ---------------------------------------------------------

y_dt = zeros(1, length(ny));


%% ---------------------------------------------------------
% Pad input signal
%
% Padding allows h[n-k] to move completely across x[k].
% ---------------------------------------------------------

padding = length(h) - 1;

x_padded = [zeros(1, padding), ...
            x, ...
            zeros(1, padding)];

n_padded = (nx_start - padding):(nx_end + padding);


%% ---------------------------------------------------------
% Reference result using MATLAB conv()
%
% Used only to check our animated calculation.
% ---------------------------------------------------------

y_dt_reference = conv(x, h);


%% ---------------------------------------------------------
% Fixed plot limits
% ---------------------------------------------------------

x_min = min(n_padded) - 1;
x_max = max(n_padded) + 1;

x_ymin = min([0 x]) - 0.5;
x_ymax = max([0 x]) + 0.5;

h_ymin = min([0 h]) - 0.5;
h_ymax = max([0 h]) + 0.5;

y_ymin = min([0 y_dt_reference]) - 0.5;
y_ymax = max([0 y_dt_reference]) + 0.5;


%% ---------------------------------------------------------
% Create discrete-time figure
% ---------------------------------------------------------

figure('Name', 'Discrete-Time Convolution Animation', ...
       'NumberTitle', 'off');


%% =========================================================
% DISCRETE-TIME ANIMATION LOOP
% =========================================================

for i = 1:length(ny)

    %% Current shift

    shift = i - 1;


    %% -----------------------------------------------------
    % Construct flipped and shifted h[n-k]
    % -----------------------------------------------------

    h_shifted = zeros(1, length(x_padded));

    h_shifted(shift + 1 : shift + length(h_flipped)) = ...
        h_flipped;


    %% -----------------------------------------------------
    % Multiply overlapping samples
    % -----------------------------------------------------

    product = x_padded .* h_shifted;


    %% -----------------------------------------------------
    % Sum products
    %
    % y[n] = sum x[k]h[n-k]
    % -----------------------------------------------------

    y_dt(i) = sum(product);


    %% =====================================================
    % Plot 1: Fixed input x[k]
    % =====================================================

    subplot(3,1,1);

    stem(n_padded, ...
         x_padded, ...
         'filled', ...
         'LineWidth', 1.5);

    title('Input Signal x[k]');

    xlabel('k');
    ylabel('x[k]');

    grid on;

    xlim([x_min x_max]);
    ylim([x_ymin x_ymax]);


    %% =====================================================
    % Plot 2: Flipped and shifted h[n-k]
    % =====================================================

    subplot(3,1,2);

    stem(n_padded, ...
         h_shifted, ...
         'r', ...
         'filled', ...
         'LineWidth', 1.5);

    title(['Shifted Impulse Response h[n-k],  n = ', ...
           num2str(ny(i))]);

    xlabel('k');
    ylabel('h[n-k]');

    grid on;

    xlim([x_min x_max]);
    ylim([h_ymin h_ymax]);


    %% =====================================================
    % Plot 3: Output buildup
    % =====================================================

    subplot(3,1,3);

    stem(ny(1:i), ...
         y_dt(1:i), ...
         'g', ...
         'filled', ...
         'LineWidth', 1.5);

    title('Output y[n] = x[n] * h[n]');

    xlabel('n');
    ylabel('y[n]');

    grid on;

    xlim([min(ny)-1 max(ny)+1]);
    ylim([y_ymin y_ymax]);


    %% -----------------------------------------------------
    % Force figure update
    % -----------------------------------------------------

    drawnow;


    %% -----------------------------------------------------
    % Animation speed
    % -----------------------------------------------------

    pause(0.8);

end


%% =========================================================
% VERIFY DISCRETE-TIME RESULT
% =========================================================

disp(' ');
disp('Discrete-Time Animated Result:');
disp(y_dt);

disp('MATLAB conv() Reference Result:');
disp(y_dt_reference);


if isequal(y_dt, y_dt_reference)

    disp('DT CHECK: Animated convolution is CORRECT.');

else

    disp('DT CHECK: Results do NOT match.');

end



%% =========================================================
%          PART 2: CONTINUOUS-TIME CONVOLUTION
% =========================================================

disp(' ');
disp('=== Continuous-Time Convolution Animation ===');


%% ---------------------------------------------------------
% Time resolution
% ---------------------------------------------------------

dt = 0.01;


%% ---------------------------------------------------------
% Integration variable tau
%
% Continuous-time convolution:
%
% y(t) = integral x(tau) h(t-tau) d(tau)
%
% The horizontal axis of plots 1 and 2 is therefore tau.
% ---------------------------------------------------------

tau = -5:dt:5;


%% ---------------------------------------------------------
% Input signal x(tau)
%
% Rectangular pulse:
%
% x(tau) = 1    for -1 <= tau <= 1
%          0    otherwise
% ---------------------------------------------------------

x_start = -1;
x_end   = 1;
x_amp   = 1;

x_ct = x_amp .* ...
       double(tau >= x_start & tau <= x_end);


%% ---------------------------------------------------------
% Impulse response h(tau)
%
% Triangular pulse:
%
% Support = 0 to 2
% Peak = 1 at tau = 1
% ---------------------------------------------------------

h_start = 0;
h_end   = 2;
h_amp   = 1;

h_ct = h_amp .* ...
       (1 - abs(tau - 1)) .* ...
       double(tau >= h_start & tau <= h_end);


%% =========================================================
% ACTUAL CONVOLUTION SUPPORT
%
% x(t) exists from -1 to 1
% h(t) exists from 0 to 2
%
% Therefore convolution exists from:
%
% (-1 + 0) to (1 + 2)
%
% = -1 to 3
% =========================================================

ty_support_start = x_start + h_start;

ty_support_end = x_end + h_end;


%% =========================================================
% ANIMATION TIME MARGIN
%
% We intentionally start before overlap and finish after
% overlap so the viewer can see:
%
% 1. No overlap
% 2. Beginning of overlap
% 3. Partial overlap
% 4. Full overlap
% 5. Decreasing overlap
% 6. No overlap again
% =========================================================

time_margin = 1;


%% ---------------------------------------------------------
% Full animation time range
%
% Actual convolution support = -1 to 3
%
% Animation range with margin = -2 to 4
% ---------------------------------------------------------

ty_start = ty_support_start - time_margin;

ty_end = ty_support_end + time_margin;

ty = ty_start:dt:ty_end;


%% ---------------------------------------------------------
% Initialize continuous-time output
% ---------------------------------------------------------

y_ct = zeros(1, length(ty));


%% ---------------------------------------------------------
% Reference continuous-time convolution
%
% MATLAB conv() performs summation.
%
% Multiplication by dt approximates the continuous integral.
% ---------------------------------------------------------

y_ct_reference_full = conv(x_ct, h_ct, 'full') * dt;


%% ---------------------------------------------------------
% Fixed plot limits
% ---------------------------------------------------------

tau_min = min(tau);
tau_max = max(tau);


% Input signal vertical limits
x_ylim = [-0.2, max(x_ct) + 0.2];


% Impulse response vertical limits
h_ylim = [-0.2, max(h_ct) + 0.2];


% Output vertical limits
maximum_reference = max(y_ct_reference_full);

y_ylim = [-0.1, maximum_reference * 1.15];


%% ---------------------------------------------------------
% Create continuous-time figure
% ---------------------------------------------------------

figure('Name', 'Continuous-Time Convolution Animation', ...
       'NumberTitle', 'off');


%% =========================================================
% CONTINUOUS-TIME ANIMATION LOOP
% =========================================================

for i = 1:length(ty)

    %% -----------------------------------------------------
    % Current output time
    % -----------------------------------------------------

    t_current = ty(i);


    %% =====================================================
    % Construct h(t-tau)
    %
    % Original triangular impulse response:
    %
    % h(s) = 1 - |s-1|       for 0 <= s <= 2
    %
    % For convolution:
    %
    % s = t - tau
    %
    % Therefore this correctly creates h(t-tau).
    % =====================================================

    s = t_current - tau;


    h_shifted = h_amp .* ...
                (1 - abs(s - 1)) .* ...
                double(s >= h_start & s <= h_end);


    %% -----------------------------------------------------
    % Multiply overlapping signals
    % -----------------------------------------------------

    product = x_ct .* h_shifted;


    %% -----------------------------------------------------
    % Numerical convolution integral
    %
    % y(t)  sum[x(tau)h(t-tau)] dt
    % -----------------------------------------------------

    y_ct(i) = sum(product) * dt;


    %% =====================================================
    % Plot 1: Fixed input x(tau)
    % =====================================================

    subplot(3,1,1);

    plot(tau, ...
         x_ct, ...
         'b', ...
         'LineWidth', 1.5);

    title('Input Signal x(\tau)');

    xlabel('\tau');
    ylabel('x(\tau)');

    grid on;

    xlim([tau_min tau_max]);
    ylim(x_ylim);


    %% =====================================================
    % Plot 2: Flipped and shifted impulse response h(t-tau)
    % =====================================================

    subplot(3,1,2);

    plot(tau, ...
         h_shifted, ...
         'r', ...
         'LineWidth', 1.5);

    title(['Shifted Impulse Response h(t-\tau),  t = ', ...
           num2str(t_current, '%.2f')]);

    xlabel('\tau');
    ylabel('h(t-\tau)');

    grid on;

    xlim([tau_min tau_max]);
    ylim(h_ylim);


    %% =====================================================
    % Plot 3: Real-time convolution output
    % =====================================================

    subplot(3,1,3);

    plot(ty(1:i), ...
         y_ct(1:i), ...
         'g', ...
         'LineWidth', 1.5);

    title('Output y(t) = x(t) * h(t)');

    xlabel('t');
    ylabel('y(t)');

    grid on;

    % Full range including the zero-output portions
    xlim([ty_start ty_end]);

    ylim(y_ylim);


    %% -----------------------------------------------------
    % Force MATLAB to refresh the animation
    % -----------------------------------------------------

    drawnow;


    %% -----------------------------------------------------
    % Animation speed
    %
    % Smaller pause = faster animation
    % -----------------------------------------------------

    pause(0.005);

end



%% =========================================================
% CONTINUOUS-TIME VERIFICATION INFORMATION
% =========================================================

disp(' ');
disp('Continuous-Time Animation Completed.');


fprintf('Actual convolution support: %.2f to %.2f\n', ...
        ty_support_start, ty_support_end);


fprintf('Animation time range: %.2f to %.2f\n', ...
        ty_start, ty_end);


fprintf('Maximum animated y(t): %.4f\n', ...
        max(y_ct));


fprintf('Reference maximum approximately: %.4f\n', ...
        maximum_reference);

