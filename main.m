clc;clear;

% Load the actual measured CYA, 'section1 - Realangle1_S1.mat' and so on
load('Realangle_S4.mat')

% Initialize the list of CYA identification values
pred_angel = [];

% Load the coordinates of the pin center returned by the object detection model
load('RightCenterCoord_S4.mat');

% Based on the derivation process provided in the paper, 
% K = 0.7 is obtained through measurement and calculation

% Based on the calibration process shown in Fig.11 of the paper, it can be
% obtained that N1 = 650, N2 = 1130.

% CYA calculation formula based on the calibration results

for i = 1:9001 % must be consistent with the length of RightCenterCoord

    temp_angel = atan((detect_coord(i, 1) - 650) / (1130 - detect_coord(i, 2)*0.7));
    
    temp_angel = temp_angel * 180 / pi;

    pred_angel = [pred_angel, temp_angel];
end

pred_angel = pred_angel';   

% The first column of angle is the identified value, and the second column is the true value.
angle = [pred_angel, realangle];

% Smoothing process
angle(:, 1) = smooth(angle(:, 1), 'lowess');
angle(:, 1) = smooth(angle(:, 1), 50);
% For aesthetic reasons, we apply a smoothing treatment of 100 in the 
% sections 1 and 2 where CYA is smaller, and a smoothing treatment of 50 
% in the sections 3 and 4 where CYA is larger. Actual measured CYA is
% already smoothed.

% Calculate the error for each frame
angle(:, 3) = abs(angle(:, 2) - angle(:, 1));

% Generate the corresponding time array
time = 0:0.04:360;
time = time';

% Calculate the RMSE metric
squaredErrors = (angle(:,1)-angle(:,2)).^2;

rmse = sum(angle(:, 3)) / size(angle,1);

mae = sqrt(mean(squaredErrors));

% Calculate the R-squared metric
y = angle(:, 2); 

y_pred = angle(:, 1); 

RSS = sum((y - y_pred).^2);

SST = sum((y - mean(y)).^2);

R_squared = 1 - (RSS/SST);

% Plot the result image
plot(time, angle(:, 1), 'LineWidth',2);
hold on 
plot(time, angle(:, 2), 'LineWidth',2);




