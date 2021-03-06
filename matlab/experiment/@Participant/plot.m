% Plots kinematic properties of data from a bimanual Fitts experiment withvariation of 
% either the phase (in-phase/anti-phase) or the viscosity.
% All plotting functionare included in the file. It should work
% with DS structures generated with getMultiResults_fb because it doesn't  
% depend on any parameter of DS structure, only its dimensions.

function  plot(obj)
    oscillations_dir   =joinpath(obj.conf.plot_learning_path,'oscillations');
    relative_dir       =joinpath(obj.conf.plot_learning_path,'relative');
    lockingStrength_dir=joinpath(obj.conf.plot_learning_path,'lockingStrength');
    vf_dir             =joinpath(obj.conf.plot_learning_path,'vectorFields');
    
    if ~exist(obj.conf.plot_participant_path,'dir') & obj.conf.interactive==0
        mkdir(obj.conf.plot_participant_path);
    end
    if ~exist(obj.conf.plot_learning_path,'dir') & obj.conf.interactive==0
        mkdir(obj.conf.plot_learning_path);
    end
    
    %obj.plot_learning_oscillations(oscillations_dir);
    %obj.plot_learning_relative(relative_dir);    
    %obj.plot_learning_lockingStrength(lockingStrength_dir);
    %obj.plot_learning_vf(vf_dir,ext);
	%obj.plot_vf(vf_dir);
    obj.plot_va(vf_dir);
    obj.plot_angphsp()
    obj.plot_angvar('ph');
    obj.plot_angvar('omega');
    obj.plot_angvar('alpha');
    obj.plot_angvar('xnorm');
    obj.plot_angvar('vnorm');
    obj.plot_angvar('anorm');
    obj,plot_angvar('jerknorm');
	
    %for s=1:obj.size
        %if obj.sessions(s).train == 0
            %obj.sessions(s).plot();
        %end
    %end
end
