% Code to generate tail angles from 3D coordinates of birds in Takeoff, landing and competition
% Created summer 2025, updated 12.2.25 to allow for negative angles (when tail flare is narrower than rump width) 
% Rosalee Elting
% December 2, 2025

%% IMPORTING DATA AND DEFINING MARGINS 
%import xyz points as c. 
d=c;

%Set X-axis time scale in seconds for univariate plots and derivatives
time = (1 :length(c))'*0.0005;

%remove outliers due to DLC errors and replace with shape-preserving cubic
%spline interpolation.  SPECIAL NOTE: presently only optimized for tail
%points; figure out setttings for other points
%first fill missing values (nan) with interpolation 
c = fillmissing(d, 'linear'); 
%can use 'makima', modified Akima method designed to reduce overshooting if
%large gaps are being interpolated. In some cases linear seems best if the
%bird is not changing much,but there are digitization errors. 

%second replace outliers with a moving median 
c = filloutliers(c,"pchip","movmedian",50);

%invert x; this is needed if 
%EasyWand delivers coefficients with Z+ = upward
c(:,1:3:size(c,2))=c(:,1:3:size(c,2))*-1;
% currently don't need for many of the field videos! 

%Define Unit Vectors of X Y Z Axes
x=[1 0 0]';
y=[0 1 0]';
z=[0 0 1]';
origin = [0 0 0];

%% PLOT TAIL ANGLE SPREAD
%Compute angle of tail spread
tail_a =  [c(:,25)-c(:,13) c(:,26)-c(:,14) c(:,27)-c(:,15)];
tail_b =  [c(:,28)-c(:,16) c(:,29)-c(:,17) c(:,30)-c(:,18)];
rump_width = ((c(:,13)-c(:,16)).^2 + (c(:,14)- c(:,17)).^2 + (c(:,15)-c(:,18)).^2).^0.5; %linear distance between two points
tail_width = ((c(:,25)-c(:,28)).^2 + (c(:,26)- c(:,29)).^2 + (c(:,27)- c(:,30)).^2).^0.5; 

tail_angle=(1:length(c))';
for j=1:length(c)
    tail_angle(j)= acos((dot(tail_a(j,:),tail_b(j,:)))/(norm(tail_a(j,:))*norm(tail_b(j,:))));
    if rump_width(j,:) < tail_width(j,:)
        tail_angle(j) = tail_angle(j); %keep same if tail is wider than rump
    else 
        tail_angle(j) = tail_angle(j) *-1 ; %netagive tail angle is the tail is very folded (narrower than rump)
    end
end

figure
plot(rump_width, 'r')
hold on 
plot(tail_width, 'b')


tail_angle_deg=tail_angle*180/pi;
% figure
% plot(time(:,1), tail_angle_deg);
figure
plot(tail_angle_deg, 'k*');
hold on 
title("Tail Flare Angle (deg)")

%% LOLLIPOP OF TAIL POSITION VECTORS tail_a AND  tail_b 
figure
plot3(tail_a(:,1),tail_a(:,2),tail_a(:,3),'b')
hold on
box on
grid on
plot3(origin(1,1),origin(1,2),origin(1,3),'go','MarkerFaceColor', 'g')
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Linear Shifted Body Axis Rooted at Rump');
for j=1:length(tail_a)
plot3([tail_a(j,1),origin(1,1)],[tail_a(j,2),origin(1,2)],[tail_a(j,3),origin(1,3)],'b-')
plot3([tail_b(j,1),origin(1,1)],[tail_b(j,2),origin(1,2)],[tail_b(j,3),origin(1,3)],'r-')
end

%% LOLLIPOP PLOTS IN 3D WITH TAIL POLYGON 
%calculate middle of spine and middle of rump between shoulders and 
%bases of tail
spine = [(c(:,7) + c(:,10))/2 (c(:,8)+c(:,11))/2 (c(:,9)+c(:,12))/2] ;
rump = [(c(:,13)+c(:,16))/2 (c(:,14)+c(:,17))/2  (c(:,15)+c(:,18))/2 ] ;


%create lollipop plot using every "skip" set of points
%skip save every nth row
skip = 10;
spine_sub=spine(1:skip:end,:);
rump_sub=rump(1:skip:end,:);
L_base_tail_sub=c(1:skip:end,13:15);
R_base_tail_sub=c(1:skip:end,16:18);
L_tailtip_sub=c(1:skip:end,25:27);
R_tailtip_sub=c(1:skip:end,28:30);
beakbase_sub=c(1:skip:end,4:6);
beaktip_sub=c(1:skip:end,1:3);

%plot lines between anatomical points
figure
hold on
for j=1:length(spine_sub)
plot3([spine_sub(j,1),rump_sub(j,1)],[spine_sub(j,2),rump_sub(j,2)],[spine_sub(j,3),rump_sub(j,3)],'r')
plot3([spine_sub(j,1),beakbase_sub(j,1)],[spine_sub(j,2),beakbase_sub(j,2)],[spine_sub(j,3),beakbase_sub(j,3)],'k')
plot3([beaktip_sub(j,1),beakbase_sub(j,1)],[beaktip_sub(j,2),beakbase_sub(j,2)],[beaktip_sub(j,3),beakbase_sub(j,3)],'k')
plot3([L_base_tail_sub(j,1),R_base_tail_sub(j,1)],[L_base_tail_sub(j,2),R_base_tail_sub(j,2)],[L_base_tail_sub(j,3),R_base_tail_sub(j,3)],'k')
plot3([L_base_tail_sub(j,1),L_tailtip_sub(j,1)],[L_base_tail_sub(j,2),L_tailtip_sub(j,2)],[L_base_tail_sub(j,3),L_tailtip_sub(j,3)],'k')
plot3([R_base_tail_sub(j,1),R_tailtip_sub(j,1)],[R_base_tail_sub(j,2),R_tailtip_sub(j,2)],[R_base_tail_sub(j,3),R_tailtip_sub(j,3)],'k')
plot3([L_tailtip_sub(j,1),R_tailtip_sub(j,1)],[L_tailtip_sub(j,2),R_tailtip_sub(j,2)],[L_tailtip_sub(j,3),R_tailtip_sub(j,3)],'k')
fill3([L_tailtip_sub(j,1),L_base_tail_sub(j,1), R_base_tail_sub(j,1), R_tailtip_sub(j,1)],[L_tailtip_sub(j,2),L_base_tail_sub(j,2), R_base_tail_sub(j,2), R_tailtip_sub(j,2)], [L_tailtip_sub(j,3),L_base_tail_sub(j,3), R_base_tail_sub(j,3), R_tailtip_sub(j,3)],[1 0 0],'LineStyle','none', FaceAlpha=0.5)
end
plot3(beakbase_sub(:,1),beakbase_sub(:,2),beakbase_sub(:,3),'ko', 'MarkerFaceColor','0.7 0.7 0.7')
plot3(spine_sub(:,1),spine_sub(:,2),spine_sub(:,3),'r*')
% plot3(rump_sub(:,1),rump_sub(:,2),rump_sub(:,3),'go', 'MarkerFaceColor','0.7 0.7 0.7')
box on
grid on
% Create labels for axes
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
set(gca,'color', [1 0.949019607843137 0.749019607843137]);%make background of graph light yellow
% hold offbill
% alpha(0.5)


%% EXPORT TAIL ANGLES FOR BIRD 
writematrix(tail_angle_deg,'ch54_ch56_z01_ch56_w_tail_angles.csv')

