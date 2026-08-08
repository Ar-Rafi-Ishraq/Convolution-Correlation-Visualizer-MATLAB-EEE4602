%% =========================================================
%              CONVOLUTION TEST PROGRAM
%   Discrete-Time and Continuous-Time Convolution
% =========================================================

clc;
clear;
close all;


%% =========================================================
%              DISCRETE-TIME CONVOLUTION
% =========================================================

disp('=== Discrete-Time Convolution ===');


%% Input signal x[n]

x = [1 2 1 0];

% Starting index of x[n]
nx_start = -1;

% Index vector of x[n]
nx = nx_start : nx_start + length(x) - 1;


%% Impulse response h[n]

h = [1 1 1];

% Starting index of h[n]
nh_start = 0;

% Index vector of h[n]
nh = nh_start : nh_start + length(h) - 1;


%% Perform discrete-time convolution

y_dt = conv(x, h);


%% Calculate output index

% Starting index of convolution:
%
% ny_start = nx_start + nh_start

ny_start = nx_start + nh_start;


% Length of convolution:
%
% length(y) = length(x) + length(h) - 1

ny = ny_start : ny_start + length(y_dt) - 1;


%% Display result in Command Window

disp('Input signal x[n]:');
disp(x);

disp('Impulse response h[n]:');
disp(h);

disp('Convolution output y[n]:');
disp(y_dt);

disp('Output indices:');
disp(ny);


%% Plot discrete-time signals

figure('Name', 'Discrete-Time Convolution');


% ---------------- Input signal ----------------

subplot(3,1,1);

stem(nx, x, 'filled', 'LineWidth', 1.5);

title('Input Signal x[n]');
xlabel('n');
ylabel('x[n]');

grid on;


% ---------------- Impulse response ----------------

subplot(3,1,2);

stem(nh, h, 'filled', 'LineWidth', 1.5);

title('Impulse Response h[n]');
xlabel('n');
ylabel('h[n]');

grid on;


% ---------------- Convolution output ----------------

subplot(3,1,3);

stem(ny, y_dt, 'filled', 'LineWidth', 1.5);

title('Output y[n] = x[n] * h[n]');
xlabel('n');
ylabel('y[n]');

grid on;



%% =========================================================
%              CONTINUOUS-TIME CONVOLUTION
% =========================================================

disp(' ');
disp('=== Continuous-Time Convolution ===');


%% Sampling interval

dt = 0.01;


%% Time axis for input signal

tx = -5 : dt : 5;


%% Input signal x(t)
%
% Rectangular pulse:
%
% x(t) = 1,     -1 <= t <= 1
%        0,     otherwise

x_ct = double(tx >= -1 & tx <= 1);


%% Time axis for impulse response

th = -5 : dt : 5;


%% Impulse response h(t)
%
% Triangular pulse from t = 0 to t = 2
% Maximum value = 1 at t = 1

h_ct = (1 - abs(th - 1)) .* ...
       double(th >= 0 & th <= 2);


%% Perform continuous-time convolution
%
% Continuous convolution:
%
%               infinity
% y(t) =        integral x(tau) h(t-tau) d(tau)
%              -infinity
%
% MATLAB conv() performs the discrete summation.
% Multiplication by dt approximates the continuous integral.

y_ct = conv(x_ct, h_ct, 'full') * dt;


%% Generate correct output time axis
%
% Earliest output time:
%
% tx_start + th_start
%
% Latest output time:
%
% tx_end + th_end

ty_start = tx(1) + th(1);

ty = ty_start + (0:length(y_ct)-1) * dt;


%% Display information

fprintf('\nContinuous-Time Convolution Information:\n');

fprintf('Sampling interval dt = %.3f s\n', dt);

fprintf('Input signal time range: %.2f to %.2f s\n', ...
        tx(1), tx(end));

fprintf('Impulse response time range: %.2f to %.2f s\n', ...
        th(1), th(end));

fprintf('Output time range: %.2f to %.2f s\n', ...
        ty(1), ty(end));


%% Plot continuous-time signals

figure('Name', 'Continuous-Time Convolution');


% ---------------- Input signal ----------------

subplot(3,1,1);

plot(tx, x_ct, 'LineWidth', 1.5);

title('Input Signal x(t)');
xlabel('t');
ylabel('x(t)');

grid on;


% ---------------- Impulse response ----------------

subplot(3,1,2);

plot(th, h_ct, 'LineWidth', 1.5);

title('Impulse Response h(t)');
xlabel('t');
ylabel('h(t)');

grid on;


% ---------------- Convolution output ----------------

subplot(3,1,3);

plot(ty, y_ct, 'LineWidth', 1.5);

title('Output y(t) = x(t) * h(t)');
xlabel('t');
ylabel('y(t)');

grid on;