%% Test drive for arduino dynamomter
%{
The goal of this file is to prove that Matlab can prompt the hand
dynamometer sensor to read force level for a given amount of duration and
receives the signal back. The sensor will read the force output every
second and sends it back.
When I ask the sensor to scan for 6 sec with a sampling_rate of 100 Hz, it
would only return around 510 sampling points in the 6 sec. The
actual sampling_rate is 85 Hz
%}

%% Connect to the sensor
sensor = serialport('/dev/cu.usbmodem142401', 9600);

if exist('sensor', 'var') == 1
    fprintf('Arduino Uno sensor connected on %s \n', sensor.Port);
else
    error('Error: Arduino sensor not connected \n');
end

flush(sensor);
sensor.UserData = struct("data",[],"count", 1);
configureTerminator(sensor,"LF");
configureCallback(sensor, "terminator", @readData);

%% Prompt the sensor once and read from it
sensor.UserData = struct("data",[],"count", 1);
out = zeros(1, 3);
out(1) = 1; % start flag for Arduino
out(2) = 3000; % length of sampling in millisec
out(3) = 100; % sampling_freq

write(sensor, out, "uint16");

%% plot
plot(sensor.UserData.data);