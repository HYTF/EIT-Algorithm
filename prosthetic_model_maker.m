%msh sets max size of mesh pieces
msh=1;
%let's do a quick calculation for electrode position
%the format we're giving to netgen is a matrix of [angle, z; angle2, z2]
%all distances in cm
angles = linspace(0,360,6);
angles = angles(1:end-1);
contactnumber=10;
elecpositions = [];
bottom = 5;
for z=[bottom+3, bottom + 6]
    for angle=angles
        if z ==bottom+3
            elecpositions = [elecpositions;angle+(180/5),z];
        else
            elecpositions = [elecpositions;angle,z];
        end
    end

end
%let's set the other variables
%elec_ are electrode variables, elec_msh is max size of mesh elems in
%electrode
height = 13.5;
radius = 35/(2*pi);
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
prosimg.fwd_model.stimulation = stim_meas_list(allmeas,contactnumber); %Set the measurements in EIDORS
Jsub=calc_jacobian(prosimg); %Calculate the mesh sensitivity vectors for the measurement slice
JGsub=Jsub*proszersins; %Map to polynomial model space
JGQ=[JGQ;JGsub];



 