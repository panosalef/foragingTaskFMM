function positionScheduleAlign = getScheduleAlignedPosition(position,schedules)
[~,sortIdx] = sort(schedules);
trialId = str2double(strcat(num2str(sortIdx(1)),num2str(sortIdx(2)),num2str(sortIdx(3))));

%% Rotation Matrices
theta = 120;
Rccw = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
Rcw = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];


%% Cases
if trialId == 123
    positionScheduleAlign = position;
    
elseif trialId == 132
    positionScheduleAlign = position;
    positionScheduleAlign(1,:) = - positionScheduleAlign(1,:);
    
elseif trialId == 213
    positionScheduleAlign = position;
    positionScheduleAlign(1,:) = - positionScheduleAlign(1,:);
    positionScheduleAlign = Rccw*positionScheduleAlign;
    
elseif trialId == 231
    positionScheduleAlign = Rccw*position;
    
elseif trialId == 312
    positionScheduleAlign = Rcw*position;
    
elseif trialId == 321
    positionScheduleAlign = position;
    positionScheduleAlign(1,:) = - positionScheduleAlign(1,:);
    positionScheduleAlign = Rcw*positionScheduleAlign;
    
end

end

