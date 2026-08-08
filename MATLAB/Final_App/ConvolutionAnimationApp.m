classdef ConvolutionAnimationApp < matlab.apps.AppBase

    % =========================================================
    % UI COMPONENT PROPERTIES
    % =========================================================
    properties (Access = public)

        UIFigure                       matlab.ui.Figure
        TitleLabel                     matlab.ui.control.Label

        % Mode selection
        ModeButtonGroup                matlab.ui.container.ButtonGroup
        DiscreteTimeButton             matlab.ui.control.RadioButton
        ContinuousTimeButton           matlab.ui.control.RadioButton

        % Input signal panels
        InputDTPanel                   matlab.ui.container.Panel
        InputCTPanel                   matlab.ui.container.Panel

        % Discrete-Time Input
        InputVectorEditField           matlab.ui.control.EditField
        InputStartIndexEditField       matlab.ui.control.NumericEditField

        % Continuous-Time Input
        InputSignalTypeDropDown        matlab.ui.control.DropDown
        InputStartTimeEditField        matlab.ui.control.NumericEditField
        InputEndTimeEditField          matlab.ui.control.NumericEditField
        InputAmplitudeEditField        matlab.ui.control.NumericEditField

        % Impulse response panels
        ImpulseDTPanel                 matlab.ui.container.Panel
        ImpulseCTPanel                 matlab.ui.container.Panel

        % Discrete-Time Impulse Response
        ImpulseVectorEditField         matlab.ui.control.EditField
        ImpulseStartIndexEditField     matlab.ui.control.NumericEditField

        % Continuous-Time Impulse Response
        ImpulseSignalTypeDropDown      matlab.ui.control.DropDown
        ImpulseStartTimeEditField      matlab.ui.control.NumericEditField
        ImpulseEndTimeEditField        matlab.ui.control.NumericEditField
        ImpulseAmplitudeEditField      matlab.ui.control.NumericEditField

        % Controls
        AnimationSpeedSlider           matlab.ui.control.Slider
        ComputeConvolutionButton       matlab.ui.control.Button
        ComputeCorrelationButton       matlab.ui.control.Button
        ResetButton                    matlab.ui.control.Button
        StatusLabel                    matlab.ui.control.Label

        % Axes
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes3                        matlab.ui.control.UIAxes
    end


    % =========================================================
    % INTERNAL VARIABLES
    % =========================================================
    properties (Access = private)

        StopRequested = false;

    end


    % =========================================================
    % CALLBACKS AND CALCULATION FUNCTIONS
    % =========================================================
    methods (Access = private)


        %% =====================================================
        % MODE SELECTION
        % =====================================================
        function ModeSelectionChanged(app, event)

            app.StopRequested = true;

            updateModeUI(app);

            clearPlots(app);

            app.StatusLabel.Text = 'Ready';

        end


        %% =====================================================
        % INPUT SIGNAL TYPE CHANGED
        % =====================================================
        function InputSignalTypeChanged(app, event)

            if strcmp( ...
                    app.InputSignalTypeDropDown.Value, ...
                    'Impulse')

                app.InputEndTimeEditField.Enable = 'off';

            else

                app.InputEndTimeEditField.Enable = 'on';

            end

        end


        %% =====================================================
        % IMPULSE RESPONSE TYPE CHANGED
        % =====================================================
        function ImpulseSignalTypeChanged(app, event)

            if strcmp( ...
                    app.ImpulseSignalTypeDropDown.Value, ...
                    'Impulse')

                app.ImpulseEndTimeEditField.Enable = 'off';

            else

                app.ImpulseEndTimeEditField.Enable = 'on';

            end

        end


        %% =====================================================
        % COMPUTE CONVOLUTION BUTTON
        % =====================================================
        function ComputeConvolutionButtonPushed(app, event)

            app.StopRequested = false;

            app.ComputeConvolutionButton.Enable = 'off';
            app.ComputeCorrelationButton.Enable = 'off';

            app.StatusLabel.Text = 'Calculating convolution...';

            try

                if app.DiscreteTimeButton.Value

                    animateDiscreteConvolution(app);

                else

                    animateContinuousConvolution(app);

                end

            catch ME

                app.StatusLabel.Text = 'Error';

                uialert( ...
                    app.UIFigure, ...
                    ME.message, ...
                    'Convolution Error');

            end

            app.ComputeConvolutionButton.Enable = 'on';
            app.ComputeCorrelationButton.Enable = 'on';

        end


        %% =====================================================
        % COMPUTE CORRELATION BUTTON
        % =====================================================
        function ComputeCorrelationButtonPushed(app, event)

            app.StopRequested = false;

            app.ComputeConvolutionButton.Enable = 'off';
            app.ComputeCorrelationButton.Enable = 'off';

            app.StatusLabel.Text = 'Calculating correlation...';

            try

                if app.DiscreteTimeButton.Value

                    animateDiscreteCorrelation(app);

                else

                    animateContinuousCorrelation(app);

                end

            catch ME

                app.StatusLabel.Text = 'Error';

                uialert( ...
                    app.UIFigure, ...
                    ME.message, ...
                    'Correlation Error');

            end

            app.ComputeConvolutionButton.Enable = 'on';
            app.ComputeCorrelationButton.Enable = 'on';

        end


        %% =====================================================
        % RESET BUTTON
        % =====================================================
        function ResetButtonPushed(app, event)

            app.StopRequested = true;


            % Mode
            app.DiscreteTimeButton.Value = true;


            % DT Input
            app.InputVectorEditField.Value = ...
                '[1 2 1 0]';

            app.InputStartIndexEditField.Value = -1;


            % DT Impulse Response
            app.ImpulseVectorEditField.Value = ...
                '[1 1 1]';

            app.ImpulseStartIndexEditField.Value = 0;


            % CT Input
            app.InputSignalTypeDropDown.Value = ...
                'Rectangular Pulse';

            app.InputStartTimeEditField.Value = -1;

            app.InputEndTimeEditField.Value = 1;

            app.InputAmplitudeEditField.Value = 1;


            % CT Impulse Response
            app.ImpulseSignalTypeDropDown.Value = ...
                'Triangular Pulse';

            app.ImpulseStartTimeEditField.Value = 0;

            app.ImpulseEndTimeEditField.Value = 2;

            app.ImpulseAmplitudeEditField.Value = 1;


            % Animation Speed
            app.AnimationSpeedSlider.Value = 70;


            % Update
            updateModeUI(app);

            InputSignalTypeChanged(app, []);

            ImpulseSignalTypeChanged(app, []);

            clearPlots(app);

            app.StatusLabel.Text = 'Ready';

        end



        %% =====================================================
        % DISCRETE-TIME CONVOLUTION
        % =====================================================
        function animateDiscreteConvolution(app)


            %% Read x[n]

            x = parseVector( ...
                app, ...
                app.InputVectorEditField.Value, ...
                'Input signal x[n]');


            %% Read h[n]

            h = parseVector( ...
                app, ...
                app.ImpulseVectorEditField.Value, ...
                'Impulse response h[n]');


            nx_start = ...
                app.InputStartIndexEditField.Value;


            nh_start = ...
                app.ImpulseStartIndexEditField.Value;


            %% Validate start indices

            if ~isfinite(nx_start) || ...
                    nx_start ~= round(nx_start)

                error( ...
                    'Starting index of x[n] must be an integer.');

            end


            if ~isfinite(nh_start) || ...
                    nh_start ~= round(nh_start)

                error( ...
                    'Starting index of h[n] must be an integer.');

            end


            %% Signal indices

            nx_end = ...
                nx_start + length(x) - 1;


            nh_end = ...
                nh_start + length(h) - 1;


            %% Output indices

            ny_start = ...
                nx_start + nh_start;


            ny_end = ...
                nx_end + nh_end;


            ny = ...
                ny_start:ny_end;


            %% Reference result

            y_reference = ...
                conv(x, h);


            %% Flip impulse response

            h_flipped = ...
                fliplr(h);


            %% Padding

            padding = ...
                length(h) - 1;


            x_padded = [ ...
                zeros(1, padding), ...
                x, ...
                zeros(1, padding)];


            n_padded = ...
                (nx_start-padding):(nx_end+padding);


            %% Initialize output

            y = ...
                zeros(1, length(ny));


            %% Axis limits

            horizontal_min = ...
                min(n_padded) - 1;


            horizontal_max = ...
                max(n_padded) + 1;


            x_ylim = ...
                getYLimits(app, x_padded);


            h_ylim = ...
                getYLimits(app, h);


            y_ylim = ...
                getYLimits(app, y_reference);


            %% Clear old plots

            cla(app.UIAxes);

            cla(app.UIAxes2);

            cla(app.UIAxes3);


            %% =================================================
            % PLOT 1 — INPUT x[k]
            % =================================================

            stem( ...
                app.UIAxes, ...
                n_padded, ...
                x_padded, ...
                'filled', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes, ...
                'Input Signal x[k]');


            xlabel(app.UIAxes, 'k');

            ylabel(app.UIAxes, 'x[k]');

            grid(app.UIAxes, 'on');


            xlim( ...
                app.UIAxes, ...
                [horizontal_min horizontal_max]);


            ylim( ...
                app.UIAxes, ...
                x_ylim);


            %% =================================================
            % PLOT 2 — h[n-k]
            % =================================================

            hStem = stem( ...
                app.UIAxes2, ...
                n_padded, ...
                zeros(size(n_padded)), ...
                'r', ...
                'filled', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes2, ...
                'Shifted Impulse Response h[n-k]');


            xlabel(app.UIAxes2, 'k');

            ylabel(app.UIAxes2, 'h[n-k]');

            grid(app.UIAxes2, 'on');


            xlim( ...
                app.UIAxes2, ...
                [horizontal_min horizontal_max]);


            ylim( ...
                app.UIAxes2, ...
                h_ylim);


            %% =================================================
            % PLOT 3 — OUTPUT y[n]
            % =================================================

            yStem = stem( ...
                app.UIAxes3, ...
                ny(1), ...
                0, ...
                'g', ...
                'filled', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes3, ...
                'Convolution y[n] = x[n] * h[n]');


            xlabel(app.UIAxes3, 'n');

            ylabel(app.UIAxes3, 'y[n]');

            grid(app.UIAxes3, 'on');


            xlim( ...
                app.UIAxes3, ...
                [min(ny)-1 max(ny)+1]);


            ylim( ...
                app.UIAxes3, ...
                y_ylim);


            %% Animation delay

            frameDelay = ...
                getFrameDelay( ...
                    app, ...
                    length(ny));


            app.StatusLabel.Text = ...
                'Running discrete-time convolution...';


            %% =================================================
            % DT ANIMATION LOOP
            % =================================================

            for i = 1:length(ny)


                if app.StopRequested

                    app.StatusLabel.Text = ...
                        'Animation stopped.';

                    return;

                end


                %% Shift

                shift = ...
                    i - 1;


                %% Construct h[n-k]

                h_shifted = ...
                    zeros(1, length(x_padded));


                h_shifted( ...
                    shift+1 : ...
                    shift+length(h_flipped)) = ...
                    h_flipped;


                %% Product

                product = ...
                    x_padded .* h_shifted;


                %% Sum

                y(i) = ...
                    sum(product);


                %% Update h[n-k]

                hStem.YData = ...
                    h_shifted;


                title( ...
                    app.UIAxes2, ...
                    ['Shifted Impulse Response h[n-k], n = ', ...
                    num2str(ny(i))]);


                %% Update y[n]

                yStem.XData = ...
                    ny(1:i);


                yStem.YData = ...
                    y(1:i);


                drawnow;

                pause(frameDelay);

            end


            %% Verification

            tolerance = 1e-12;


            if max(abs(y-y_reference)) < tolerance

                app.StatusLabel.Text = ...
                    ['DT Complete: y[n] = ', ...
                    mat2str(y)];

            else

                app.StatusLabel.Text = ...
                    'DT verification failed.';


                uialert( ...
                    app.UIFigure, ...
                    ['Animated result does not match ', ...
                    'MATLAB conv().'], ...
                    'Verification Error');

            end

        end



        %% =====================================================
        % DISCRETE-TIME CORRELATION
        %
        % Convention used in the project report/presentation:
        %
        % r_xh[n] = sum_k x[k] h[k-n]
        %
        % The second signal is shifted without the explicit
        % flip used in the convolution animation.
        % =====================================================
        function animateDiscreteCorrelation(app)


            %% Read x[n]

            x = parseVector( ...
                app, ...
                app.InputVectorEditField.Value, ...
                'Input signal x[n]');


            %% Read second signal h[n]

            h = parseVector( ...
                app, ...
                app.ImpulseVectorEditField.Value, ...
                'Second signal h[n]');


            nx_start = ...
                app.InputStartIndexEditField.Value;


            nh_start = ...
                app.ImpulseStartIndexEditField.Value;


            %% Validate start indices

            if ~isfinite(nx_start) || ...
                    nx_start ~= round(nx_start)

                error( ...
                    'Starting index of x[n] must be an integer.');

            end


            if ~isfinite(nh_start) || ...
                    nh_start ~= round(nh_start)

                error( ...
                    'Starting index of h[n] must be an integer.');

            end


            %% Signal index limits

            nx_end = ...
                nx_start + length(x) - 1;


            nh_end = ...
                nh_start + length(h) - 1;


            %% Correlation lag/index range
            %
            % For r_xh[n] = sum_k x[k] h[k-n]:
            %
            % n_min = nx_start - nh_end
            % n_max = nx_end   - nh_start

            nr_start = ...
                nx_start - nh_end;


            nr_end = ...
                nx_end - nh_start;


            nr = ...
                nr_start:nr_end;


            %% Independent reference result
            %
            % For real-valued sequences, this convention is
            % equivalent to convolution with a reversed h.

            r_reference = ...
                conv( ...
                    x, ...
                    fliplr(h));


            %% Padding for animation

            padding = ...
                length(h) - 1;


            x_padded = [ ...
                zeros(1, padding), ...
                x, ...
                zeros(1, padding)];


            n_padded = ...
                (nx_start-padding):(nx_end+padding);


            %% Initialize output

            r = ...
                zeros(1, length(nr));


            %% Axis limits

            horizontal_min = ...
                min(n_padded) - 1;


            horizontal_max = ...
                max(n_padded) + 1;


            x_ylim = ...
                getYLimits(app, x_padded);


            h_ylim = ...
                getYLimits(app, h);


            r_ylim = ...
                getYLimits(app, r_reference);


            %% Clear old plots

            cla(app.UIAxes);
            cla(app.UIAxes2);
            cla(app.UIAxes3);


            %% =================================================
            % PLOT 1 — INPUT x[k]
            % =================================================

            stem( ...
                app.UIAxes, ...
                n_padded, ...
                x_padded, ...
                'filled', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes, ...
                'Input Signal x[k]');


            xlabel(app.UIAxes, 'k');
            ylabel(app.UIAxes, 'x[k]');
            grid(app.UIAxes, 'on');


            xlim( ...
                app.UIAxes, ...
                [horizontal_min horizontal_max]);


            ylim( ...
                app.UIAxes, ...
                x_ylim);


            %% =================================================
            % PLOT 2 — SHIFTED SECOND SIGNAL h[k-n]
            % =================================================

            hStem = stem( ...
                app.UIAxes2, ...
                n_padded, ...
                zeros(size(n_padded)), ...
                'r', ...
                'filled', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes2, ...
                'Shifted Second Signal h[k-n]');


            xlabel(app.UIAxes2, 'k');
            ylabel(app.UIAxes2, 'h[k-n]');
            grid(app.UIAxes2, 'on');


            xlim( ...
                app.UIAxes2, ...
                [horizontal_min horizontal_max]);


            ylim( ...
                app.UIAxes2, ...
                h_ylim);


            %% =================================================
            % PLOT 3 — CORRELATION r_xh[n]
            % =================================================

            rStem = stem( ...
                app.UIAxes3, ...
                nr(1), ...
                0, ...
                'g', ...
                'filled', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes3, ...
                'Correlation r_{xh}[n]');


            xlabel(app.UIAxes3, 'n');
            ylabel(app.UIAxes3, 'r_{xh}[n]');
            grid(app.UIAxes3, 'on');


            xlim( ...
                app.UIAxes3, ...
                [min(nr)-1 max(nr)+1]);


            ylim( ...
                app.UIAxes3, ...
                r_ylim);


            %% Animation delay

            frameDelay = ...
                getFrameDelay( ...
                    app, ...
                    length(nr));


            app.StatusLabel.Text = ...
                'Running discrete-time correlation...';


            %% =================================================
            % DT CORRELATION ANIMATION LOOP
            % =================================================

            for i = 1:length(nr)


                if app.StopRequested

                    app.StatusLabel.Text = ...
                        'Animation stopped.';

                    return;

                end


                %% Current correlation lag/index

                n_current = ...
                    nr(i);


                %% Build h[k-n] on the common k-axis

                h_shifted = ...
                    zeros(1, length(n_padded));


                h_argument = ...
                    n_padded - n_current;


                valid = ...
                    h_argument >= nh_start & ...
                    h_argument <= nh_end;


                h_indices = ...
                    h_argument(valid) - nh_start + 1;


                h_shifted(valid) = ...
                    h(h_indices);


                %% Multiply and sum overlap

                product = ...
                    x_padded .* h_shifted;


                r(i) = ...
                    sum(product);


                %% Update shifted h[k-n]

                hStem.YData = ...
                    h_shifted;


                title( ...
                    app.UIAxes2, ...
                    ['Shifted Second Signal h[k-n], n = ', ...
                    num2str(n_current)]);


                %% Update correlation output

                rStem.XData = ...
                    nr(1:i);


                rStem.YData = ...
                    r(1:i);


                drawnow;
                pause(frameDelay);

            end


            %% Verification

            tolerance = 1e-12;


            if max(abs(r-r_reference)) < tolerance

                app.StatusLabel.Text = ...
                    ['DT Correlation Complete: r[n] = ', ...
                    mat2str(r)];

            else

                app.StatusLabel.Text = ...
                    'DT correlation verification failed.';


                uialert( ...
                    app.UIFigure, ...
                    ['Animated correlation result does not ', ...
                    'match the reference calculation.'], ...
                    'Verification Error');

            end

        end



        %% =====================================================
        % CONTINUOUS-TIME CONVOLUTION
        % =====================================================
        function animateContinuousConvolution(app)


            %% Time resolution

            dt = 0.01;


            %% Input signal values

            x_type = ...
                app.InputSignalTypeDropDown.Value;


            x_start = ...
                app.InputStartTimeEditField.Value;


            x_end = ...
                app.InputEndTimeEditField.Value;


            x_amp = ...
                app.InputAmplitudeEditField.Value;


            %% Impulse response values

            h_type = ...
                app.ImpulseSignalTypeDropDown.Value;


            h_start = ...
                app.ImpulseStartTimeEditField.Value;


            h_end = ...
                app.ImpulseEndTimeEditField.Value;


            h_amp = ...
                app.ImpulseAmplitudeEditField.Value;


            %% Validation

            validateContinuousSignal( ...
                app, ...
                x_type, ...
                x_start, ...
                x_end, ...
                x_amp, ...
                'Input signal');


            validateContinuousSignal( ...
                app, ...
                h_type, ...
                h_start, ...
                h_end, ...
                h_amp, ...
                'Impulse response');


            %% Input support

            [x_support_start, x_support_end] = ...
                getContinuousSupport( ...
                    app, ...
                    x_type, ...
                    x_start, ...
                    x_end);


            %% Impulse response support

            [h_support_start, h_support_end] = ...
                getContinuousSupport( ...
                    app, ...
                    h_type, ...
                    h_start, ...
                    h_end);


            %% =================================================
            % ACTUAL CONVOLUTION SUPPORT
            % =================================================

            ty_support_start = ...
                x_support_start + ...
                h_support_start;


            ty_support_end = ...
                x_support_end + ...
                h_support_end;


            %% =================================================
            % EXTRA TIME BEFORE AND AFTER OVERLAP
            % =================================================

            time_margin = 1;


            ty_start = ...
                ty_support_start - time_margin;


            ty_end = ...
                ty_support_end + time_margin;


            ty = ...
                ty_start:dt:ty_end;


            %% =================================================
            % INTEGRATION VARIABLE tau RANGE
            % =================================================

            tau_min = min([ ...
                x_support_start, ...
                ty_start-h_support_end]) - 0.5;


            tau_max = max([ ...
                x_support_end, ...
                ty_end-h_support_start]) + 0.5;


            tau = ...
                tau_min:dt:tau_max;


            %% Generate x(tau)

            x_ct = ...
                generateContinuousSignal( ...
                    app, ...
                    x_type, ...
                    tau, ...
                    x_start, ...
                    x_end, ...
                    x_amp, ...
                    dt);


            %% Generate h(tau)

            h_ct = ...
                generateContinuousSignal( ...
                    app, ...
                    h_type, ...
                    tau, ...
                    h_start, ...
                    h_end, ...
                    h_amp, ...
                    dt);


            %% Initialize output

            y = ...
                zeros(1, length(ty));


            %% Reference convolution

            y_reference_full = ...
                conv(x_ct, h_ct, 'full') * dt;


            %% Axis limits

            x_ylim = ...
                getYLimits(app, x_ct);


            h_ylim = ...
                getYLimits(app, h_ct);


            y_ylim = ...
                getYLimits( ...
                    app, ...
                    y_reference_full);


            %% Clear axes

            cla(app.UIAxes);

            cla(app.UIAxes2);

            cla(app.UIAxes3);


            %% =================================================
            % PLOT 1 — x(tau)
            % =================================================

            plot( ...
                app.UIAxes, ...
                tau, ...
                x_ct, ...
                'b', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes, ...
                'Input Signal x(\tau)');


            xlabel(app.UIAxes, '\tau');

            ylabel(app.UIAxes, 'x(\tau)');

            grid(app.UIAxes, 'on');


            xlim( ...
                app.UIAxes, ...
                [tau_min tau_max]);


            ylim( ...
                app.UIAxes, ...
                x_ylim);


            %% =================================================
            % PLOT 2 — h(t-tau)
            % =================================================

            hLine = plot( ...
                app.UIAxes2, ...
                tau, ...
                zeros(size(tau)), ...
                'r', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes2, ...
                'Shifted Impulse Response h(t-\tau)');


            xlabel(app.UIAxes2, '\tau');

            ylabel(app.UIAxes2, 'h(t-\tau)');

            grid(app.UIAxes2, 'on');


            xlim( ...
                app.UIAxes2, ...
                [tau_min tau_max]);


            ylim( ...
                app.UIAxes2, ...
                h_ylim);


            %% =================================================
            % PLOT 3 — OUTPUT y(t)
            % =================================================

            yLine = plot( ...
                app.UIAxes3, ...
                ty(1), ...
                0, ...
                'g', ...
                'LineWidth', 1.8);


            title( ...
                app.UIAxes3, ...
                'Convolution y(t) = x(t) * h(t)');


            xlabel(app.UIAxes3, 't');

            ylabel(app.UIAxes3, 'y(t)');

            grid(app.UIAxes3, 'on');


            xlim( ...
                app.UIAxes3, ...
                [ty_start ty_end]);


            ylim( ...
                app.UIAxes3, ...
                y_ylim);


            %% Animation delay

            frameDelay = ...
                getFrameDelay( ...
                    app, ...
                    length(ty));


            app.StatusLabel.Text = ...
                'Running continuous-time convolution...';


            %% =================================================
            % CT ANIMATION LOOP
            % =================================================

            for i = 1:length(ty)


                if app.StopRequested

                    app.StatusLabel.Text = ...
                        'Animation stopped.';

                    return;

                end


                %% Current time

                t_current = ...
                    ty(i);


                %% Correct convolution argument
                %
                % h(t-tau)

                argument = ...
                    t_current - tau;


                %% Generate shifted impulse response

                h_shifted = ...
                    generateContinuousSignal( ...
                        app, ...
                        h_type, ...
                        argument, ...
                        h_start, ...
                        h_end, ...
                        h_amp, ...
                        dt);


                %% Product

                product = ...
                    x_ct .* h_shifted;


                %% Numerical integration

                y(i) = ...
                    sum(product) * dt;


                %% Update h(t-tau)

                hLine.YData = ...
                    h_shifted;


                title( ...
                    app.UIAxes2, ...
                    ['Shifted Impulse Response h(t-\tau), t = ', ...
                    num2str(t_current, '%.2f')]);


                %% Update y(t)

                yLine.XData = ...
                    ty(1:i);


                yLine.YData = ...
                    y(1:i);


                drawnow;

                pause(frameDelay);

            end


            %% Finished

            app.StatusLabel.Text = ...
                sprintf( ...
                    ['CT Complete | Actual support: ', ...
                    '%.2f to %.2f'], ...
                    ty_support_start, ...
                    ty_support_end);

        end



        %% =====================================================
        % CONTINUOUS-TIME CORRELATION
        %
        % Convention used in the project report/presentation:
        %
        % r_xh(t) = integral x(tau) h(tau-t) d(tau)
        %
        % Continuous signals are numerically sampled with dt.
        % =====================================================
        function animateContinuousCorrelation(app)


            %% Time resolution

            dt = 0.01;


            %% Input signal values

            x_type = ...
                app.InputSignalTypeDropDown.Value;


            x_start = ...
                app.InputStartTimeEditField.Value;


            x_end = ...
                app.InputEndTimeEditField.Value;


            x_amp = ...
                app.InputAmplitudeEditField.Value;


            %% Second signal values

            h_type = ...
                app.ImpulseSignalTypeDropDown.Value;


            h_start = ...
                app.ImpulseStartTimeEditField.Value;


            h_end = ...
                app.ImpulseEndTimeEditField.Value;


            h_amp = ...
                app.ImpulseAmplitudeEditField.Value;


            %% Validation

            validateContinuousSignal( ...
                app, ...
                x_type, ...
                x_start, ...
                x_end, ...
                x_amp, ...
                'Input signal');


            validateContinuousSignal( ...
                app, ...
                h_type, ...
                h_start, ...
                h_end, ...
                h_amp, ...
                'Second signal');


            %% Input support

            [x_support_start, x_support_end] = ...
                getContinuousSupport( ...
                    app, ...
                    x_type, ...
                    x_start, ...
                    x_end);


            %% Second-signal support

            [h_support_start, h_support_end] = ...
                getContinuousSupport( ...
                    app, ...
                    h_type, ...
                    h_start, ...
                    h_end);


            %% =================================================
            % ACTUAL CORRELATION SUPPORT
            %
            % For r_xh(t) = integral x(tau)h(tau-t)d(tau):
            %
            % t_min = x_start - h_end
            % t_max = x_end   - h_start
            % =================================================

            tr_support_start = ...
                x_support_start - h_support_end;


            tr_support_end = ...
                x_support_end - h_support_start;


            %% Extra time before and after overlap

            time_margin = 1;


            tr_start = ...
                tr_support_start - time_margin;


            tr_end = ...
                tr_support_end + time_margin;


            tr = ...
                tr_start:dt:tr_end;


            %% Integration-variable tau range

            tau_min = min([ ...
                x_support_start, ...
                tr_start+h_support_start]) - 0.5;


            tau_max = max([ ...
                x_support_end, ...
                tr_end+h_support_end]) + 0.5;


            tau = ...
                tau_min:dt:tau_max;


            %% Generate x(tau)

            x_ct = ...
                generateContinuousSignal( ...
                    app, ...
                    x_type, ...
                    tau, ...
                    x_start, ...
                    x_end, ...
                    x_amp, ...
                    dt);


            %% Generate h(tau) for reference scaling

            h_ct = ...
                generateContinuousSignal( ...
                    app, ...
                    h_type, ...
                    tau, ...
                    h_start, ...
                    h_end, ...
                    h_amp, ...
                    dt);


            %% Initialize output

            r = ...
                zeros(1, length(tr));


            %% Reference magnitude for output-axis limits

            r_reference_full = ...
                conv( ...
                    x_ct, ...
                    fliplr(h_ct), ...
                    'full') * dt;


            %% Axis limits

            x_ylim = ...
                getYLimits(app, x_ct);


            h_ylim = ...
                getYLimits(app, h_ct);


            r_ylim = ...
                getYLimits( ...
                    app, ...
                    r_reference_full);


            %% Clear axes

            cla(app.UIAxes);
            cla(app.UIAxes2);
            cla(app.UIAxes3);


            %% =================================================
            % PLOT 1 — x(tau)
            % =================================================

            plot( ...
                app.UIAxes, ...
                tau, ...
                x_ct, ...
                'b', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes, ...
                'Input Signal x(\tau)');


            xlabel(app.UIAxes, '\tau');
            ylabel(app.UIAxes, 'x(\tau)');
            grid(app.UIAxes, 'on');


            xlim( ...
                app.UIAxes, ...
                [tau_min tau_max]);


            ylim( ...
                app.UIAxes, ...
                x_ylim);


            %% =================================================
            % PLOT 2 — h(tau-t)
            % =================================================

            hLine = plot( ...
                app.UIAxes2, ...
                tau, ...
                zeros(size(tau)), ...
                'r', ...
                'LineWidth', 1.5);


            title( ...
                app.UIAxes2, ...
                'Shifted Second Signal h(\tau-t)');


            xlabel(app.UIAxes2, '\tau');
            ylabel(app.UIAxes2, 'h(\tau-t)');
            grid(app.UIAxes2, 'on');


            xlim( ...
                app.UIAxes2, ...
                [tau_min tau_max]);


            ylim( ...
                app.UIAxes2, ...
                h_ylim);


            %% =================================================
            % PLOT 3 — CORRELATION r_xh(t)
            % =================================================

            rLine = plot( ...
                app.UIAxes3, ...
                tr(1), ...
                0, ...
                'g', ...
                'LineWidth', 1.8);


            title( ...
                app.UIAxes3, ...
                'Correlation r_{xh}(t)');


            xlabel(app.UIAxes3, 't');
            ylabel(app.UIAxes3, 'r_{xh}(t)');
            grid(app.UIAxes3, 'on');


            xlim( ...
                app.UIAxes3, ...
                [tr_start tr_end]);


            ylim( ...
                app.UIAxes3, ...
                r_ylim);


            %% Animation delay

            frameDelay = ...
                getFrameDelay( ...
                    app, ...
                    length(tr));


            app.StatusLabel.Text = ...
                'Running continuous-time correlation...';


            %% =================================================
            % CT CORRELATION ANIMATION LOOP
            % =================================================

            for i = 1:length(tr)


                if app.StopRequested

                    app.StatusLabel.Text = ...
                        'Animation stopped.';

                    return;

                end


                %% Current correlation lag/time

                t_current = ...
                    tr(i);


                %% Correlation argument h(tau-t)

                argument = ...
                    tau - t_current;


                %% Generate shifted second signal

                h_shifted = ...
                    generateContinuousSignal( ...
                        app, ...
                        h_type, ...
                        argument, ...
                        h_start, ...
                        h_end, ...
                        h_amp, ...
                        dt);


                %% Multiply signals

                product = ...
                    x_ct .* h_shifted;


                %% Numerical integration

                r(i) = ...
                    sum(product) * dt;


                %% Update h(tau-t)

                hLine.YData = ...
                    h_shifted;


                title( ...
                    app.UIAxes2, ...
                    ['Shifted Second Signal h(\tau-t), t = ', ...
                    num2str(t_current, '%.2f')]);


                %% Update correlation output

                rLine.XData = ...
                    tr(1:i);


                rLine.YData = ...
                    r(1:i);


                drawnow;
                pause(frameDelay);

            end


            %% Finished

            app.StatusLabel.Text = ...
                sprintf( ...
                    ['CT Correlation Complete | Actual support: ', ...
                    '%.2f to %.2f'], ...
                    tr_support_start, ...
                    tr_support_end);

        end



        %% =====================================================
        % PARSE DISCRETE-TIME VECTOR
        % =====================================================
        function vector = parseVector( ...
                app, ...
                textValue, ...
                signalName)


            textValue = ...
                strtrim(textValue);


            if isempty(textValue)

                error( ...
                    '%s cannot be empty.', ...
                    signalName);

            end


            cleaned = ...
                regexprep( ...
                    textValue, ...
                    '[\[\]\(\),;]', ...
                    ' ');


            cleaned = ...
                strtrim(cleaned);


            if isempty(cleaned)

                error( ...
                    '%s is invalid.', ...
                    signalName);

            end


            tokens = ...
                regexp( ...
                    cleaned, ...
                    '\s+', ...
                    'split');


            vector = ...
                str2double(tokens);


            if isempty(vector) || ...
                    any(isnan(vector)) || ...
                    any(~isfinite(vector))

                error( ...
                    [signalName, ...
                    ' must contain numeric values only. ', ...
                    'Example: [1 2 1 0]']);

            end


            vector = ...
                vector(:).';

        end



        %% =====================================================
        % VALIDATE CONTINUOUS-TIME SIGNAL
        % =====================================================
        function validateContinuousSignal( ...
                app, ...
                signalType, ...
                startTime, ...
                endTime, ...
                amplitude, ...
                signalName)


            if ~isfinite(startTime)

                error( ...
                    '%s start time must be finite.', ...
                    signalName);

            end


            if ~isfinite(amplitude)

                error( ...
                    '%s amplitude must be finite.', ...
                    signalName);

            end


            if strcmp(signalType, 'Impulse')

                return;

            end


            if ~isfinite(endTime)

                error( ...
                    '%s end time must be finite.', ...
                    signalName);

            end


            if endTime <= startTime

                error( ...
                    ['%s end time must be greater ', ...
                    'than its start time.'], ...
                    signalName);

            end

        end



        %% =====================================================
        % GET CONTINUOUS-TIME SIGNAL SUPPORT
        % =====================================================
        function [supportStart, supportEnd] = ...
                getContinuousSupport( ...
                    app, ...
                    signalType, ...
                    startTime, ...
                    endTime)


            if strcmp(signalType, 'Impulse')

                supportStart = ...
                    startTime;

                supportEnd = ...
                    startTime;

            else

                supportStart = ...
                    startTime;

                supportEnd = ...
                    endTime;

            end

        end



        %% =====================================================
        % GENERATE CONTINUOUS-TIME SIGNAL
        % =====================================================
        function signal = generateContinuousSignal( ...
                app, ...
                signalType, ...
                timeVector, ...
                startTime, ...
                endTime, ...
                amplitude, ...
                dt)


            signal = ...
                zeros(size(timeVector));


            switch signalType


                %% =============================================
                % IMPULSE
                % =============================================

                case 'Impulse'


                    if startTime >= min(timeVector)-dt/2 && ...
                            startTime <= max(timeVector)+dt/2


                        [~, index] = ...
                            min(abs(timeVector-startTime));


                        signal(index) = ...
                            amplitude / dt;

                    end



                %% =============================================
                % STEP
                % =============================================

                case 'Step'


                    signal = ...
                        amplitude .* ...
                        double( ...
                            timeVector >= startTime & ...
                            timeVector <= endTime);



                %% =============================================
                % RECTANGULAR PULSE
                % =============================================

                case 'Rectangular Pulse'


                    signal = ...
                        amplitude .* ...
                        double( ...
                            timeVector >= startTime & ...
                            timeVector <= endTime);



                %% =============================================
                % TRIANGULAR PULSE
                % =============================================

                case 'Triangular Pulse'


                    center = ...
                        (startTime + endTime) / 2;


                    halfWidth = ...
                        (endTime-startTime) / 2;


                    signal = ...
                        amplitude .* ...
                        max( ...
                            1 - ...
                            abs( ...
                                (timeVector-center) ./ ...
                                halfWidth), ...
                            0);


                    signal( ...
                        timeVector < startTime | ...
                        timeVector > endTime) = 0;



                %% =============================================
                % SAWTOOTH PULSE
                % =============================================

                case 'Sawtooth Pulse'


                    inside = ...
                        timeVector >= startTime & ...
                        timeVector <= endTime;


                    signal(inside) = ...
                        amplitude .* ...
                        ( ...
                            timeVector(inside)-startTime) ./ ...
                        (endTime-startTime);



                otherwise

                    error( ...
                        'Unknown continuous-time signal type.');

            end

        end



        %% =====================================================
        % AUTOMATIC Y LIMITS
        % =====================================================
        function limits = getYLimits(app, data)


            minimum = ...
                min([0 data(:).']);


            maximum = ...
                max([0 data(:).']);


            signalRange = ...
                maximum - minimum;


            if signalRange < 1e-12

                signalRange = 1;

            end


            margin = ...
                0.15 * signalRange;


            limits = [ ...
                minimum-margin, ...
                maximum+margin];

        end



        %% =====================================================
        % ANIMATION SPEED
        % =====================================================
        function delay = getFrameDelay( ...
                app, ...
                numberOfFrames)


            speed = ...
                app.AnimationSpeedSlider.Value;


            slowDuration = 12;

            fastDuration = 1.5;


            fraction = ...
                (speed-1) / 99;


            totalDuration = ...
                slowDuration - ...
                fraction * ...
                (slowDuration-fastDuration);


            delay = ...
                totalDuration / ...
                max(numberOfFrames, 1);

        end



        %% =====================================================
        % UPDATE DT / CT INTERFACE
        % =====================================================
        function updateModeUI(app)


            if app.DiscreteTimeButton.Value


                app.InputDTPanel.Visible = 'on';

                app.InputCTPanel.Visible = 'off';


                app.ImpulseDTPanel.Visible = 'on';

                app.ImpulseCTPanel.Visible = 'off';


                title( ...
                    app.UIAxes, ...
                    'Input Signal x[k]');


                xlabel(app.UIAxes, 'k');

                ylabel(app.UIAxes, 'x[k]');


                title( ...
                    app.UIAxes2, ...
                    'Shifted Impulse Response h[n-k]');


                xlabel(app.UIAxes2, 'k');

                ylabel(app.UIAxes2, 'h[n-k]');


                title( ...
                    app.UIAxes3, ...
                    'Convolution y[n]');


                xlabel(app.UIAxes3, 'n');

                ylabel(app.UIAxes3, 'y[n]');


            else


                app.InputDTPanel.Visible = 'off';

                app.InputCTPanel.Visible = 'on';


                app.ImpulseDTPanel.Visible = 'off';

                app.ImpulseCTPanel.Visible = 'on';


                title( ...
                    app.UIAxes, ...
                    'Input Signal x(\tau)');


                xlabel(app.UIAxes, '\tau');

                ylabel(app.UIAxes, 'x(\tau)');


                title( ...
                    app.UIAxes2, ...
                    'Shifted Impulse Response h(t-\tau)');


                xlabel(app.UIAxes2, '\tau');

                ylabel(app.UIAxes2, 'h(t-\tau)');


                title( ...
                    app.UIAxes3, ...
                    'Convolution y(t)');


                xlabel(app.UIAxes3, 't');

                ylabel(app.UIAxes3, 'y(t)');

            end

        end



        %% =====================================================
        % CLEAR PLOTS
        % =====================================================
        function clearPlots(app)


            cla(app.UIAxes);

            cla(app.UIAxes2);

            cla(app.UIAxes3);


            grid(app.UIAxes, 'on');

            grid(app.UIAxes2, 'on');

            grid(app.UIAxes3, 'on');


            updateModeUI(app);

        end

    end



    % =========================================================
    % CREATE GUI
    % =========================================================
    methods (Access = private)


        function createComponents(app)


            %% =================================================
            % MAIN WINDOW
            % =================================================

            app.UIFigure = ...
                uifigure('Visible', 'off');


            app.UIFigure.Position = ...
                [30 30 1450 920];


            app.UIFigure.Name = ...
                'Convolution & Correlation Visualizer';



            %% =================================================
            % MAIN GRID
            % =================================================

            mainGrid = ...
                uigridlayout( ...
                    app.UIFigure, ...
                    [2 2]);


            mainGrid.RowHeight = ...
                {55, '1x'};


            mainGrid.ColumnWidth = ...
                {445, '1x'};


            mainGrid.Padding = ...
                [10 10 10 10];


            mainGrid.RowSpacing = 8;

            mainGrid.ColumnSpacing = 12;



            %% =================================================
            % TITLE
            % =================================================

            app.TitleLabel = ...
                uilabel(mainGrid);


            app.TitleLabel.Text = ...
                'Convolution & Correlation Visualizer';


            app.TitleLabel.FontSize = 26;

            app.TitleLabel.FontWeight = 'bold';

            app.TitleLabel.HorizontalAlignment = ...
                'center';


            app.TitleLabel.Layout.Row = 1;

            app.TitleLabel.Layout.Column = [1 2];



            %% =================================================
            % LEFT CONTROL PANEL
            % =================================================

            controlPanel = ...
                uipanel(mainGrid);


            controlPanel.Title = ...
                'Signal and Animation Controls';


            controlPanel.Layout.Row = 2;

            controlPanel.Layout.Column = 1;


            controlPanel.Scrollable = 'on';



            controlGrid = ...
                uigridlayout( ...
                    controlPanel, ...
                    [6 1]);


            % Increased Animation Speed row from 65 to 100
            controlGrid.RowHeight = ...
                {70, 240, 240, 100, 55, 35};


            controlGrid.Padding = ...
                [7 7 7 7];


            controlGrid.RowSpacing = 6;



            %% =================================================
            % MODE SELECTION
            % =================================================

            app.ModeButtonGroup = ...
                uibuttongroup(controlGrid);


            app.ModeButtonGroup.Title = ...
                'Signal Domain';


            app.ModeButtonGroup.Layout.Row = 1;


            app.ModeButtonGroup.SelectionChangedFcn = ...
                createCallbackFcn( ...
                    app, ...
                    @ModeSelectionChanged, ...
                    true);


            app.DiscreteTimeButton = ...
                uiradiobutton( ...
                    app.ModeButtonGroup);


            app.DiscreteTimeButton.Text = ...
                'Discrete-Time';


            app.DiscreteTimeButton.Position = ...
                [18 16 130 25];


            app.DiscreteTimeButton.Value = true;


            app.ContinuousTimeButton = ...
                uiradiobutton( ...
                    app.ModeButtonGroup);


            app.ContinuousTimeButton.Text = ...
                'Continuous-Time';


            app.ContinuousTimeButton.Position = ...
                [205 16 150 25];



            %% =================================================
            % INPUT SIGNAL OUTER PANEL
            % =================================================

            inputPanel = ...
                uipanel(controlGrid);


            inputPanel.Title = ...
                'Input Signal x';


            inputPanel.Layout.Row = 2;



            inputOverlay = ...
                uigridlayout( ...
                    inputPanel, ...
                    [1 1]);


            inputOverlay.Padding = ...
                [4 4 4 4];


            inputOverlay.RowHeight = ...
                {'1x'};


            inputOverlay.ColumnWidth = ...
                {'1x'};



            %% =================================================
            % DISCRETE-TIME INPUT
            % =================================================

            app.InputDTPanel = ...
                uipanel(inputOverlay);


            app.InputDTPanel.Title = ...
                'Discrete-Time Input';


            app.InputDTPanel.Layout.Row = 1;

            app.InputDTPanel.Layout.Column = 1;



            inputDTGrid = ...
                uigridlayout( ...
                    app.InputDTPanel, ...
                    [2 2]);


            inputDTGrid.RowHeight = ...
                {38, 38};


            inputDTGrid.ColumnWidth = ...
                {125, '1x'};


            inputDTGrid.Padding = ...
                [10 10 10 10];


            inputDTGrid.RowSpacing = 8;

            inputDTGrid.ColumnSpacing = 10;



            label = uilabel(inputDTGrid);

            label.Text = 'Vector x[n]:';

            label.Layout.Row = 1;

            label.Layout.Column = 1;



            app.InputVectorEditField = ...
                uieditfield( ...
                    inputDTGrid, ...
                    'text');


            app.InputVectorEditField.Value = ...
                '[1 2 1 0]';


            app.InputVectorEditField.Layout.Row = 1;

            app.InputVectorEditField.Layout.Column = 2;



            label = uilabel(inputDTGrid);

            label.Text = 'Start Index:';

            label.Layout.Row = 2;

            label.Layout.Column = 1;



            app.InputStartIndexEditField = ...
                uieditfield( ...
                    inputDTGrid, ...
                    'numeric');


            app.InputStartIndexEditField.Value = -1;


            app.InputStartIndexEditField.Layout.Row = 2;

            app.InputStartIndexEditField.Layout.Column = 2;



            %% =================================================
            % CONTINUOUS-TIME INPUT
            % =================================================

            app.InputCTPanel = ...
                uipanel(inputOverlay);


            app.InputCTPanel.Title = ...
                'Continuous-Time Input';


            app.InputCTPanel.Layout.Row = 1;

            app.InputCTPanel.Layout.Column = 1;



            inputCTGrid = ...
                uigridlayout( ...
                    app.InputCTPanel, ...
                    [4 2]);


            inputCTGrid.RowHeight = ...
                {36, 36, 36, 36};


            inputCTGrid.ColumnWidth = ...
                {125, '1x'};


            inputCTGrid.Padding = ...
                [9 9 9 9];


            inputCTGrid.RowSpacing = 5;

            inputCTGrid.ColumnSpacing = 10;



            % Signal Type

            label = uilabel(inputCTGrid);

            label.Text = 'Signal Type:';

            label.Layout.Row = 1;

            label.Layout.Column = 1;



            app.InputSignalTypeDropDown = ...
                uidropdown(inputCTGrid);


            app.InputSignalTypeDropDown.Items = ...
                { ...
                'Impulse', ...
                'Step', ...
                'Triangular Pulse', ...
                'Rectangular Pulse', ...
                'Sawtooth Pulse'};


            app.InputSignalTypeDropDown.Value = ...
                'Rectangular Pulse';


            app.InputSignalTypeDropDown.Layout.Row = 1;

            app.InputSignalTypeDropDown.Layout.Column = 2;


            app.InputSignalTypeDropDown.ValueChangedFcn = ...
                createCallbackFcn( ...
                    app, ...
                    @InputSignalTypeChanged, ...
                    true);



            % Start Time

            label = uilabel(inputCTGrid);

            label.Text = 'Start Time:';

            label.Layout.Row = 2;

            label.Layout.Column = 1;



            app.InputStartTimeEditField = ...
                uieditfield( ...
                    inputCTGrid, ...
                    'numeric');


            app.InputStartTimeEditField.Value = -1;


            app.InputStartTimeEditField.Layout.Row = 2;

            app.InputStartTimeEditField.Layout.Column = 2;



            % End Time

            label = uilabel(inputCTGrid);

            label.Text = 'End Time:';

            label.Layout.Row = 3;

            label.Layout.Column = 1;



            app.InputEndTimeEditField = ...
                uieditfield( ...
                    inputCTGrid, ...
                    'numeric');


            app.InputEndTimeEditField.Value = 1;


            app.InputEndTimeEditField.Layout.Row = 3;

            app.InputEndTimeEditField.Layout.Column = 2;



            % Amplitude

            label = uilabel(inputCTGrid);

            label.Text = 'Amplitude:';

            label.Layout.Row = 4;

            label.Layout.Column = 1;



            app.InputAmplitudeEditField = ...
                uieditfield( ...
                    inputCTGrid, ...
                    'numeric');


            app.InputAmplitudeEditField.Value = 1;


            app.InputAmplitudeEditField.Layout.Row = 4;

            app.InputAmplitudeEditField.Layout.Column = 2;



            %% =================================================
            % IMPULSE RESPONSE OUTER PANEL
            % =================================================

            impulsePanel = ...
                uipanel(controlGrid);


            impulsePanel.Title = ...
                'Second Signal / Impulse Response h';


            impulsePanel.Layout.Row = 3;



            impulseOverlay = ...
                uigridlayout( ...
                    impulsePanel, ...
                    [1 1]);


            impulseOverlay.Padding = ...
                [4 4 4 4];


            impulseOverlay.RowHeight = ...
                {'1x'};


            impulseOverlay.ColumnWidth = ...
                {'1x'};



            %% =================================================
            % DISCRETE-TIME IMPULSE RESPONSE
            % =================================================

            app.ImpulseDTPanel = ...
                uipanel(impulseOverlay);


            app.ImpulseDTPanel.Title = ...
                'Discrete-Time Impulse Response';


            app.ImpulseDTPanel.Layout.Row = 1;

            app.ImpulseDTPanel.Layout.Column = 1;



            impulseDTGrid = ...
                uigridlayout( ...
                    app.ImpulseDTPanel, ...
                    [2 2]);


            impulseDTGrid.RowHeight = ...
                {38, 38};


            impulseDTGrid.ColumnWidth = ...
                {125, '1x'};


            impulseDTGrid.Padding = ...
                [10 10 10 10];


            impulseDTGrid.RowSpacing = 8;

            impulseDTGrid.ColumnSpacing = 10;



            label = uilabel(impulseDTGrid);

            label.Text = 'Vector h[n]:';

            label.Layout.Row = 1;

            label.Layout.Column = 1;



            app.ImpulseVectorEditField = ...
                uieditfield( ...
                    impulseDTGrid, ...
                    'text');


            app.ImpulseVectorEditField.Value = ...
                '[1 1 1]';


            app.ImpulseVectorEditField.Layout.Row = 1;

            app.ImpulseVectorEditField.Layout.Column = 2;



            label = uilabel(impulseDTGrid);

            label.Text = 'Start Index:';

            label.Layout.Row = 2;

            label.Layout.Column = 1;



            app.ImpulseStartIndexEditField = ...
                uieditfield( ...
                    impulseDTGrid, ...
                    'numeric');


            app.ImpulseStartIndexEditField.Value = 0;


            app.ImpulseStartIndexEditField.Layout.Row = 2;

            app.ImpulseStartIndexEditField.Layout.Column = 2;



            %% =================================================
            % CONTINUOUS-TIME IMPULSE RESPONSE
            % =================================================

            app.ImpulseCTPanel = ...
                uipanel(impulseOverlay);


            app.ImpulseCTPanel.Title = ...
                'Continuous-Time Impulse Response';


            app.ImpulseCTPanel.Layout.Row = 1;

            app.ImpulseCTPanel.Layout.Column = 1;



            impulseCTGrid = ...
                uigridlayout( ...
                    app.ImpulseCTPanel, ...
                    [4 2]);


            impulseCTGrid.RowHeight = ...
                {36, 36, 36, 36};


            impulseCTGrid.ColumnWidth = ...
                {125, '1x'};


            impulseCTGrid.Padding = ...
                [9 9 9 9];


            impulseCTGrid.RowSpacing = 5;

            impulseCTGrid.ColumnSpacing = 10;



            % Signal Type

            label = uilabel(impulseCTGrid);

            label.Text = 'Signal Type:';

            label.Layout.Row = 1;

            label.Layout.Column = 1;



            app.ImpulseSignalTypeDropDown = ...
                uidropdown(impulseCTGrid);


            app.ImpulseSignalTypeDropDown.Items = ...
                { ...
                'Impulse', ...
                'Step', ...
                'Triangular Pulse', ...
                'Rectangular Pulse', ...
                'Sawtooth Pulse'};


            app.ImpulseSignalTypeDropDown.Value = ...
                'Triangular Pulse';


            app.ImpulseSignalTypeDropDown.Layout.Row = 1;

            app.ImpulseSignalTypeDropDown.Layout.Column = 2;


            app.ImpulseSignalTypeDropDown.ValueChangedFcn = ...
                createCallbackFcn( ...
                    app, ...
                    @ImpulseSignalTypeChanged, ...
                    true);



            % Start Time

            label = uilabel(impulseCTGrid);

            label.Text = 'Start Time:';

            label.Layout.Row = 2;

            label.Layout.Column = 1;



            app.ImpulseStartTimeEditField = ...
                uieditfield( ...
                    impulseCTGrid, ...
                    'numeric');


            app.ImpulseStartTimeEditField.Value = 0;


            app.ImpulseStartTimeEditField.Layout.Row = 2;

            app.ImpulseStartTimeEditField.Layout.Column = 2;



            % End Time

            label = uilabel(impulseCTGrid);

            label.Text = 'End Time:';

            label.Layout.Row = 3;

            label.Layout.Column = 1;



            app.ImpulseEndTimeEditField = ...
                uieditfield( ...
                    impulseCTGrid, ...
                    'numeric');


            app.ImpulseEndTimeEditField.Value = 2;


            app.ImpulseEndTimeEditField.Layout.Row = 3;

            app.ImpulseEndTimeEditField.Layout.Column = 2;



            % Amplitude

            label = uilabel(impulseCTGrid);

            label.Text = 'Amplitude:';

            label.Layout.Row = 4;

            label.Layout.Column = 1;



            app.ImpulseAmplitudeEditField = ...
                uieditfield( ...
                    impulseCTGrid, ...
                    'numeric');


            app.ImpulseAmplitudeEditField.Value = 1;


            app.ImpulseAmplitudeEditField.Layout.Row = 4;

            app.ImpulseAmplitudeEditField.Layout.Column = 2;



            %% =================================================
            % ANIMATION SPEED PANEL
            % =================================================

            speedPanel = ...
                uipanel(controlGrid);


            speedPanel.Title = ...
                'Animation Speed';


            speedPanel.Layout.Row = 4;



            % Two rows:
            % Row 1 = actual slider
            % Row 2 = custom labels
            speedGrid = ...
                uigridlayout( ...
                    speedPanel, ...
                    [2 1]);


            speedGrid.RowHeight = ...
                {45, 24};


            speedGrid.ColumnWidth = ...
                {'1x'};


            speedGrid.Padding = ...
                [25 6 25 6];


            speedGrid.RowSpacing = 0;



            %% -------------------------------------------------
            % SPEED SLIDER
            % -------------------------------------------------

            app.AnimationSpeedSlider = ...
                uislider(speedGrid);


            app.AnimationSpeedSlider.Layout.Row = 1;


            app.AnimationSpeedSlider.Limits = ...
                [1 100];


            app.AnimationSpeedSlider.Value = 70;


            app.AnimationSpeedSlider.MajorTicks = ...
                [1 25 50 75 100];


            % Built-in labels intentionally removed.
            % Custom labels are added below.
            app.AnimationSpeedSlider.MajorTickLabels = ...
                {'', '', '', '', ''};



            %% -------------------------------------------------
            % CUSTOM SPEED LABELS
            % -------------------------------------------------

            speedLabelGrid = ...
                uigridlayout( ...
                    speedGrid, ...
                    [1 5]);


            speedLabelGrid.Layout.Row = 2;


            speedLabelGrid.ColumnWidth = ...
                {'1x', '1x', '1x', '1x', '1x'};


            speedLabelGrid.Padding = ...
                [0 0 0 0];


            speedLabelGrid.ColumnSpacing = 0;



            % Slow

            speedLabel = ...
                uilabel(speedLabelGrid);


            speedLabel.Text = ...
                'Slow';


            speedLabel.HorizontalAlignment = ...
                'left';


            speedLabel.Layout.Column = 1;



            % 25

            speedLabel = ...
                uilabel(speedLabelGrid);


            speedLabel.Text = ...
                '25';


            speedLabel.HorizontalAlignment = ...
                'center';


            speedLabel.Layout.Column = 2;



            % 50

            speedLabel = ...
                uilabel(speedLabelGrid);


            speedLabel.Text = ...
                '50';


            speedLabel.HorizontalAlignment = ...
                'center';


            speedLabel.Layout.Column = 3;



            % 75

            speedLabel = ...
                uilabel(speedLabelGrid);


            speedLabel.Text = ...
                '75';


            speedLabel.HorizontalAlignment = ...
                'center';


            speedLabel.Layout.Column = 4;



            % Fast

            speedLabel = ...
                uilabel(speedLabelGrid);


            speedLabel.Text = ...
                'Fast';


            speedLabel.HorizontalAlignment = ...
                'right';


            speedLabel.Layout.Column = 5;



            %% =================================================
            % BUTTONS
            % =================================================

            buttonGrid = ...
                uigridlayout( ...
                    controlGrid, ...
                    [1 3]);


            buttonGrid.Layout.Row = 5;


            buttonGrid.ColumnWidth = ...
                {'1x', '1x', 80};


            buttonGrid.Padding = ...
                [0 0 0 0];


            buttonGrid.ColumnSpacing = 8;



            app.ComputeConvolutionButton = ...
                uibutton( ...
                    buttonGrid, ...
                    'push');


            app.ComputeConvolutionButton.Text = ...
                'Convolution';


            app.ComputeConvolutionButton.FontWeight = ...
                'bold';


            app.ComputeConvolutionButton.ButtonPushedFcn = ...
                createCallbackFcn( ...
                    app, ...
                    @ComputeConvolutionButtonPushed, ...
                    true);



            app.ComputeCorrelationButton = ...
                uibutton( ...
                    buttonGrid, ...
                    'push');


            app.ComputeCorrelationButton.Text = ...
                'Correlation';


            app.ComputeCorrelationButton.FontWeight = ...
                'bold';


            app.ComputeCorrelationButton.ButtonPushedFcn = ...
                createCallbackFcn( ...
                    app, ...
                    @ComputeCorrelationButtonPushed, ...
                    true);



            app.ResetButton = ...
                uibutton( ...
                    buttonGrid, ...
                    'push');


            app.ResetButton.Text = ...
                'Reset';


            app.ResetButton.ButtonPushedFcn = ...
                createCallbackFcn( ...
                    app, ...
                    @ResetButtonPushed, ...
                    true);



            %% =================================================
            % STATUS LABEL
            % =================================================

            app.StatusLabel = ...
                uilabel(controlGrid);


            app.StatusLabel.Layout.Row = 6;


            app.StatusLabel.Text = ...
                'Ready';


            app.StatusLabel.HorizontalAlignment = ...
                'center';


            app.StatusLabel.FontWeight = ...
                'bold';



            %% =================================================
            % RIGHT PLOT PANEL
            % =================================================

            plotPanel = ...
                uipanel(mainGrid);


            plotPanel.Title = ...
                'Signal Operation Visualization';


            plotPanel.Layout.Row = 2;

            plotPanel.Layout.Column = 2;



            plotGrid = ...
                uigridlayout( ...
                    plotPanel, ...
                    [3 1]);


            plotGrid.RowHeight = ...
                {'1x', '1x', '1x'};


            plotGrid.Padding = ...
                [8 8 8 8];


            plotGrid.RowSpacing = 8;



            %% =================================================
            % AXIS 1
            % =================================================

            app.UIAxes = ...
                uiaxes(plotGrid);


            app.UIAxes.Layout.Row = 1;


            title( ...
                app.UIAxes, ...
                'Input Signal x[k]');


            xlabel(app.UIAxes, 'k');

            ylabel(app.UIAxes, 'x[k]');

            grid(app.UIAxes, 'on');

            app.UIAxes.Box = 'on';



            %% =================================================
            % AXIS 2
            % =================================================

            app.UIAxes2 = ...
                uiaxes(plotGrid);


            app.UIAxes2.Layout.Row = 2;


            title( ...
                app.UIAxes2, ...
                'Shifted Impulse Response h[n-k]');


            xlabel(app.UIAxes2, 'k');

            ylabel(app.UIAxes2, 'h[n-k]');

            grid(app.UIAxes2, 'on');

            app.UIAxes2.Box = 'on';



            %% =================================================
            % AXIS 3
            % =================================================

            app.UIAxes3 = ...
                uiaxes(plotGrid);


            app.UIAxes3.Layout.Row = 3;


            title( ...
                app.UIAxes3, ...
                'Convolution y[n]');


            xlabel(app.UIAxes3, 'n');

            ylabel(app.UIAxes3, 'y[n]');

            grid(app.UIAxes3, 'on');

            app.UIAxes3.Box = 'on';



            %% =================================================
            % INITIAL STATE
            % =================================================

            app.DiscreteTimeButton.Value = true;


            updateModeUI(app);


            InputSignalTypeChanged(app, []);

            ImpulseSignalTypeChanged(app, []);


            app.StatusLabel.Text = ...
                'Ready';


            app.UIFigure.Visible = ...
                'on';

        end

    end



    % =========================================================
    % APP CONSTRUCTOR / DELETE
    % =========================================================
    methods (Access = public)


        %% Constructor

        function app = ConvolutionAnimationApp


            createComponents(app);


            registerApp( ...
                app, ...
                app.UIFigure);


            if nargout == 0

                clear app

            end

        end


        %% Delete

        function delete(app)


            if ~isempty(app.UIFigure) && ...
                    isvalid(app.UIFigure)

                delete(app.UIFigure);

            end

        end

    end

end