%msh sets max size of mesh pieces
msh=3;
%let's do a quick calculation for electrode position
%the format we're giving to netgen is a matrix of [angle, z; angle2, z2]
%all distances in cm
%nelec is the number of electrodes per row
nelec = 19;
angles = linspace(0,360,19+1);
angles = angles(1:end-1);
contactnumber=38;
elecpositions = [];
bottom = 0;
%REPLACE DIST1 WITH DISTANCE BTWN BOTTOM OF TANK AND BOTTOM ROW OF
%ELECTRODES, DIST2 IS DISTANCE BETWEEN BOTTOM OF TANK AND SECOND TO BOTTOM
%ROW OF ELECTRODES
dist1 = 3;
dist2 = 6;
for z=[dist1, dist2]
    for angle=angles
        elecpositions = [elecpositions;angle,z];
    end

end
%let's set the other variables
%elec_ are electrode variables, elec_msh is max size of mesh elems in
%electrode
height = 30;
radius = 14;
% elec_shape = [width,height, maxsz]  % Rectangular elecs
%      OR
% elec_shape = [radius, 0, maxsz ]    % Circular elecs
elec_shape = [.5,.5,.1];
%optional for fun stuff, last arg
%extra = []
fmdl= ng_mk_cyl_models([height,[radius,msh]],elecpositions,elec_shape);
%fmdl= ng_mk_cyl_models([height,[radius,msh]],elecpositions, elec_shape); 
prosimg = mk_image(fmdl,1); %calculated S/m
%Generate an eidors image object for solving
proszersins = ZernSinPolinpPar2(fmdl, height, radius, contactnumber, 3, 2);
JGQ=[];
allmeas = allmeasgetter(contactnumber);
%TODO: write code to take a random quarter of the measurements (every fourth row
%of allmeas), and olug that into allmeas in the line below
prosimg.fwd_model.stimulation = stim_meas_list(allmeas,contactnumber); %Set the measurements in EIDORS
Jsub=calc_jacobian(prosimg); %Calculate the mesh sensitivity vectors for the measurement slice
JGsub=Jsub*proszersins; %Map to polynomial model space
JGQ=[JGQ;JGsub];



 