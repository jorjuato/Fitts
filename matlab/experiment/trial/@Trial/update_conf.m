function update_conf(obj,src,evnt)
    if nargin==2
        obj.conf=src;
    elseif nargin==1
        src=deepcopy(obj.conf,obj.conf.name);
    end
    %elseif strcmp(evnt.EventName,'PostSet')
        %display('updated Trial configuration')
        
        if obj.conf.unimanual==1
            obj.ts.update_conf(copy(src));
            obj.osc.update_conf(copy(src));
            obj.vf.update_conf(copy(src));
        else
            obj.ts.update_conf(copy(src));
            obj.oscL.update_conf(copy(src));
            obj.oscR.update_conf(copy(src));
            obj.vfL.update_conf(copy(src));
            obj.vfR.update_conf(copy(src));
            obj.ls.update_conf(copy(src));
        end
end
