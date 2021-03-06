classdef Config < handle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        %Global properties
        root_path 
        rout_path
        data_path
        save_path
        plot_path
        anal_path
        scripts_path = '/home/jorge/Dropbox/dev/Bimanual-Fitts'
        branch_path  = '20130904' % Unique name to identify this specific config
        name=''         %Participant directory name
        number=1        %Session number
        blockpath=''    %Block path
        unimanual=0
        hand=''
        inmemory=0
        parallelMode=0  % 0=no paralellization 
                        % 1=parallelize on participants
                        % 2=parallelize on sessions
        workers=5
        
        %Plotting
        ext='png'
        interactive=0
        relative_plots_mode=1   % 1=
                                % 2=
        replication_ts=4
        plot_onload=1
        
        %Data fetch configuration
        fs = 1E3
        skip_osc=5
        filter_stds=3
        cutoff=12
        store_vf=1
        store_idx=1
        store_ls=1
        compress_pc=0
        compress_ts=0
        split_analysis=1
        promediate=1
        peak_size=0.005
        
        %Canonical histograms properties
        hist_peaks = 'x'
        hist_bins = 100
        
        %LockingStrength properties
        peak_delta=2;
        peak_env=25;
        KLD_bins=20;
        
        %VectorField properties
        neighbourhood = [3,3]
        binnumber = 31
        bins = 31
        step = 1
        minValsToComputeCondProb = 11
        use_norm=1
        maxAngle_localenv=0
        fitorder=0
        samplerate=250
        
    end % properties
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Dependent = true, GetAccess = public)
        plot_participant_path
        plot_learning_path
        plot_session_path
        plot_block_path        
        participants   
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
    
        function participants = get.participants(obj)
            participants = length(dir2(obj.data_path));
        end
        
        function set.participants(obj,val)
            %pass
        end
        
        function plot_participant_path = get.plot_participant_path(obj)
            if ischar(obj.name)
                name=obj.name;
            else
                name=num2str(obj.name,'%03d');
            end
            plot_participant_path = joinpath(obj.plot_path,name);
            %plot_participant_path=obj.plot_path;
        end

        function plot_learning_path = get.plot_learning_path(obj)
            plot_learning_path = joinpath(obj.plot_participant_path,'Learning');
        end
        
        function plot_session_path = get.plot_session_path(obj)
            session_name=strcat('Session',num2str(obj.number));
            plot_session_path = joinpath(obj.plot_participant_path,session_name);
        end
        
        function plot_block_path = get.plot_block_path(obj)
            plot_block_path = joinpath(obj.plot_session_path,obj.blockpath);
        end
        
        
        function obj = Config(root_path)
            if nargin == 0
                obj.root_path = joinpath(getuserdir(),'KINARM');
            else
                obj.root_path = root_path;
            end
            
            
            obj.data_path = joinpath(obj.root_path,'rawdata');
            
            if ~isempty(obj.branch_path)
                obj.rout_path = joinpath(joinpath(obj.root_path,'out'),obj.branch_path);
                obj.save_path = joinpath(obj.rout_path,'data');
                obj.plot_path = joinpath(obj.rout_path,'plot');
            else
                obj.rout_path = joinpath(obj.root_path,'out');
                obj.save_path = joinpath(obj.rout_path,'data');
                obj.plot_path = joinpath(obj.rout_path,'plot');
                %obj.anal_path = joinpath(obj.rout_path,'anal');
            end

            if ~exist(obj.save_path,'dir'), mkdir(obj.save_path); end     
            if ~exist(obj.plot_path,'dir'), mkdir(obj.plot_path); end
            %if ~exist(obj.anal_path,'dir'), mkdir(obj.anal_path); end
            obj.participants = size(dir2(obj.data_path),1);
            if obj.participants==0
               fprintf('No participant data found in %s\n',obj.data_path)
            end
        end
        
        function new = copy(obj)
            new = deepcopy(obj,obj.name);
        end
        
        function dump_tofile(obj,filename,force)
            if nargin==2 && filename==1 
                force=1;
                filename=[obj.save_path '.conf'];            
            end
            if nargin<2, 
                filename=[obj.save_path '.conf']; 
                force=0;
            end
            
            if exist(filename,'file') && force==0
                error('File already exists, use force=1 to override');
            end                
                
            fd=fopen(filename,'wt');
            props = properties(obj);
            for i=1:length(props)
                fprintf(fd,'%25s\t%-20s\n',props{i},num2str(obj.(props{i})));
            end
            fclose(fd);
        end
        
    end
end
