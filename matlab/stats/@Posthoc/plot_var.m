function plot_var(phoc)
  
    vstr=phoc.vstr;
    
    %Create directory to store plots if needed
    if  ~exist(phoc.savepath,'dir')
        mkdir(phoc.savepath);
    end
    
    %Iterate over interactions
    for f=1:length(phoc.flists)
       %Hard coded custom sorting of groups
       res=phoc.results{f};
       factors=res.factors;
       vdata = res.data;
       phgrps=res.phgrps;
       phgrplabels=res.phgrplabels;
       f1mat=res.f1mat;
       f2mat=res.f2mat;
       yrange=get_yrange(vdata);
       
       %Print some nice header
       if phoc.verbose
           fprintf(phoc.fid,'\n');
           fprintf(phoc.fid,[repmat('=',1,80),'\n']);
           fprintf(phoc.fid,'Post-hoc analysis using Holm-Sidak pairwise comparisons on factors\n');
           fprintf(phoc.fid,factors{:});
       end

       %Rearrange data matrix to match that of factors
       
       %yrange=[min(vdata(:)),max(vdata(:))];
       if ~all(isfinite(vdata(:))) || ~all(isnumeric(vdata(:)))
            fprintf(phoc.fid,'Warning: all X values must be numeric and finite. vname=%s\n ',phoc.vname);
            continue
       end

       
       %Choose plotting according to number and type of factors
       switch length(factors)
           case 1               
               create_fig(phoc,factors);
               ax=subplot(1,1,1);
               plot_bw(vdata,factors{1},vstr,ax);
               ylim(yrange);
               save_fig(phoc,factors);
                    
           case 2
               create_fig(phoc,factors);
               ax=subplot(1,1,1);
               [bar_data,gp]=plot_interaction(vdata,factors,vstr,ax);
               add_anotations(bar_data,gp,f1mat,f2mat,yrange);
               ylim(yrange);
               save_fig(phoc,factors);
           case 3
               create_fig(phoc,factors);
               if strcmp('grp',factors{1})
                   for g=1:2
                       if g==1
                           do_ylabel=1;
                           do_legend=1;
                       else
                           do_ylabel=0;
                           do_legend=0;
                       end
                       ax=subplot(1,2,g);
                       [bar_data,gp]=plot_interaction(squeeze(vdata(g,:,:,:)),factors(2:end),vstr,ax,do_legend,do_ylabel);
                       title(sprintf('%s Coupling',phoc.ds.cnames{g}));
                       add_anotations(bar_data,gp,squeeze(f1mat(g,:,:)),squeeze(f2mat(g,:,:)),yrange);
                   end
                   ylim(yrange);
                   save_fig(phoc,factors);
               elseif strcmp('idl',factors{1})
                   for l=1:2
                       if l==1
                           do_ylabel=1;
                           do_legend=1;
                       else
                           do_ylabel=0;
                           do_legend=0;
                       end
                       ax=subplot(1,2,l);
                       [bar_data,gp]=plot_interaction(squeeze(vdata(l,:,:,:)),factors(2:end),vstr,ax,do_legend,do_ylabel);
                       title(['IDL ',phoc.ds.lnames{l}]);
                       add_anotations(bar_data,gp,squeeze(f1mat(l,:,:)),squeeze(f2mat(l,:,:)),yrange);
                       ylim(yrange);
                   end                      
                   save_fig(phoc,factors);
                elseif strcmp('idr',factors{1})
                   for r=1:3
                       if r==1
                           do_ylabel=1;
                           do_legend=1;
                       else
                           do_ylabel=0;
                           do_legend=0;
                       end
                       ax=subplot(1,3,r);
                       [bar_data,gp]=plot_interaction(squeeze(vdata(r,:,:,:)),factors(2:end),vstr,ax,do_legend,do_ylabel);
                       title(['IDR ',phoc.ds.rnames{r}]);
                       add_anotations(bar_data,gp,squeeze(f1mat(r,:,:)),squeeze(f2mat(r,:,:)),yrange);
                       ylim(yrange);
                   end                   
                   save_fig(phoc,factors);
               end
           case 4
               create_fig(phoc,factors);
               for g=1:2
                   if phoc.rfirst
                       for r=1:3                           
                           if r==1
                               do_ylabel=1;
                               do_legend=1;
                           else
                               do_ylabel=0;
                               do_legend=0;
                           end
                           ax=subplot(2,3,r+(g-1)*3);
                           [bar_data,gp]=plot_interaction(squeeze(vdata(g,r,:,:,:)),factors(3:end),vstr,ax,do_legend,do_ylabel);
                           title(sprintf('%s Coupling - IDR %s',phoc.ds.cnames{g},phoc.ds.rnames{r}));                           
                           add_anotations(bar_data,gp,squeeze(f1mat(g,r,:,:)),squeeze(f2mat(g,r,:,:)),yrange);
                           ylim(yrange);
                           %resize_fonts(5);
                       end
                   else
                       for l=1:2
                           if l==1
                               do_ylabel=1;
                               do_legend=1;
                           else
                               do_ylabel=0;
                               do_legend=0;
                           end
                           ax=subplot(2,2,l+(g-1)*2);
                           [bar_data,gp]=plot_interaction(squeeze(vdata(g,l,:,:,:)),factors(3:end),vstr,ax,0,do_ylabel);
                           title(sprintf('%s Coupling - IDL %s',phoc.ds.cnames{g},phoc.ds.lnames{l}));                           
                           add_anotations(bar_data,gp,squeeze(f1mat(g,l,:,:)),squeeze(f2mat(g,l,:,:)),yrange);
                           ylim(yrange);
                           %resize_fonts(5);
                       end  
                   end
               end      
               save_fig(phoc,factors);
       end

    end
end

function resize_fonts(fontsize)
    textobj = findobj('type', 'text');
    set(textobj, 'fontunits', 'points');
    set(textobj, 'fontsize', fontsize);
    set(textobj, 'fontweight', 'normal');
end

function plot_bw(data,factor,vname,ax)
    %Box and whiskers plot for 1D tests
    if nargin<4, figure;ax=subplot(1,1,1); end
    gp=get_props({'',factor});
    boxplot(ax,data')
    title(factor)
    ylabel(vname);  
    format_ticks(ax,gp.x,[],gp.xticklabels,[]);
    %set(ax,'XTick',gp.x,'XTicklabel',gp.xticklabels);    
end


function [bar_data,gp]=plot_interaction(data,factors,vname,ax,do_legend,do_ylabel)
    %Interaction plot for 2D tests
    if nargin<6, do_ylabel=1; end
    if nargin<5, do_legend=1; end
    if nargin<4, figure;ax=subplot(1,1,1); end

    %Get bar groups for plotting
    [f1,f2,kk]=size(data);
    bar_data=zeros(f1,f2,2);
    for i=1:f1
        for j=1:f2
            bar_data(i,j,1)=mean(data(i,j,:));
            bar_data(i,j,2)=std(data(i,j,:));
        end
    end

    %Get graphic properties of factors
    gp=get_props(factors);
    h=cell(f1,1);
    hold on
    for i=1:f1
        %h{i}=errorbar(ax,gp.x,bar_data(i,:,1),bar_data(i,:,2),'Color',gp.colors{i});   
        
        %h{i}=errorbar(ax,gp.x,bar_data(i,:,1),bar_data(i,:,2),'LineSpec',gp.linespec{i});        
        plot(ax, gp.x, bar_data(i,:,1), gp.linespec{i} );
        h{i}=errorbar(ax,gp.x,bar_data(i,:,1),bar_data(i,:,2),'LineSpec','none');     
    end
    %hold off
    
    %set(ax,'XTick',gp.x,'XTicklabel',gp.xticklabels);  
    format_ticks(ax,gp.x,[],gp.xticklabels,[]);
    
    if do_ylabel
        ylabel(vname,'interpreter','latex', 'FontName', 'Arial');
    end
    if do_legend
        legend(gp.labels','interpreter','latex', 'FontName', 'Arial')%,'Location','BestOutside')
    end
    title(sprintf('%s vs %s',factors{1},factors{2}),'interpreter','latex', 'FontName', 'Arial');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%AUXILIAR FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function add_anotations(bardata,gp,f1mat,f2mat,ylimits)
    [f1,f1i]=size(f1mat);
    [f2,f2i]=size(f2mat);
    %ymin=min(min(bardata(:,:,1)-bardata(:,:,2)));
    %ymax=max(max(bardata(:,:,1)+bardata(:,:,2)));
    ymax=ylimits(2);
    ymin=ylimits(1);
    yrange=abs(ymax-ymin);
    %single out homogeneous cases
    do_f1=1;
    do_f2=1;
    if f2==2
        xmsg=0.9;
    else
        xmsg=0.55;
    end
    if ~any(f1mat(:)~=1)
        msg=sprintf('All significant for %s',gp.f2name);
        text(xmsg,ymax-yrange/12,msg)
        do_f1=0;
    elseif ~any(f1mat(:)~=0)
        msg=sprintf('All non significant for %s',gp.f2name);
        text(xmsg,ymax-yrange/12,msg)
        do_f1=0;
    end
    if ~any(f2mat(:)~=1)
        msg=sprintf('All significant for %s',gp.f1name);
        text(xmsg,ymax-yrange/6,msg)
        do_f2=0;
    elseif ~any(f2mat(:)~=0)
        msg=sprintf('All non significant for %s',gp.f1name);
        text(xmsg,ymax-yrange/6,msg)
        do_f2=0;
    end
    
    %Plot interaction of factor 1 across levels of factor 2
    if do_f1
        for i=1:f1            
            for j=1:f1i
                if f1mat(i,j)==0, continue; end
                [g1,g2]=get_groups(j,f2);
                if g1==1 && g2==3
                    x=g1-g1/3;
                    y=bardata(i,g1,1);
                    msg=sprintf('%s-%s',gp.f2{g1},gp.f2{g2});
                    text(x,y,msg,'BackgroundColor',[.3 .9 .3]);
                else
                    y=(bardata(i,g1,1)+bardata(i,g2,1))/2;
                    x=(g1+g2)/2-0.1;
                    msg=sprintf('%s-%s',gp.f2{g1},gp.f2{g2});
                    text(x,y,msg,'BackgroundColor',[.3 .9 .3]);
                end
            end
        end
    end
    
    %Plot interaction of factor 2 across levels of factor 1
    if do_f2
        for i=1:f2
            for j=1:f2i
                if f2mat(i,j)==0, continue; end
                [g1,g2]=get_groups(j,f1);
                if g1==1 && g2==3
                    if bardata(g1,i,1)<bardata(g2,i,1)
                        y=bardata(g1,i,1)-yrange/10;
                    else
                        y=bardata(g2,i,1)-yrange/10;
                    end
                    x=i-0.1;
                    msg=sprintf('%s|%s',gp.f1{g1},gp.f1{g2});
                    text(x,y,msg,'BackgroundColor',[.7 .9 .7]);
                else
                    y=(bardata(g1,i,1)+bardata(g2,i,1))/2;
                    x=i-0.1;
                    msg=sprintf('%s|%s',gp.f1{g1},gp.f1{g2});
                    text(x,y,msg,'BackgroundColor',[.7 .9 .7]);
                end
            end
        end
    end
end

function [g1,g2]=get_groups(j,flen)
    if flen==2
        g1=1;
        g2=2;
    elseif j==1
        g1=1;
        g2=2;
    elseif j==2
        g1=2;
        g2=3;
    elseif j==3
        g1=1;
        g2=3;
    else
        error('Something went wrong with posthoc matrices')
    end
end


function save_fig(phoc,factors) 
    if ~isempty(phoc.savepath)
        figname = joinpath(phoc.savepath,[factors{:}]);
        if strcmp(phoc.ds.ext,'fig')
            hgsave(gcf,figname,'all');
        else
            set(gcf, 'PaperUnits', 'inches', 'PaperPosition', get_fig_position(phoc,factors)./phoc.ds.dpi);
            mlf2pdf(gcf,figname)
            %print(gcf,['-d',phoc.ds.ext],sprintf('-r%d',phoc.ds.dpi),figname);        
            close gcf
        end
    end
end

function create_fig(phoc,factors)
    if ~isempty(phoc.savepath)
        figure('name',[factors{:}],'numbertitle','off','PaperUnits', 'inches', 'PaperPosition', get_fig_position(phoc,factors)./phoc.ds.dpi,'Visible','off');
    else
        figure('name',[factors{:}],'numbertitle','off');
    end
end

function rect=get_fig_position(phoc,factors)
   rect=phoc.ds.figsize;
   return
   switch length(factors)
       case 1
           rect=[0,0,1200,1400];
       case 2
           rect=[0,0,1800,2200];
       case 3
           if strcmp('idr',factors{1})
               rect=[0,0,7200,3600];
           else
               rect=[0,0,4800,3600];
           end
       case 4
           if strcmp('idr',factors{2})
               rect=[0,0,7200,3600];
           else
               rect=[0,0,4800,3600];
           end
   end
end
    
function gp = get_props(factors)
    gp=struct();
    %Fill factor 1 related graphic properties
    if strcmp('grp',factors{1}) 
        gp.colors={[1,0.2,0.2],[0.2,0.2,1]};
        gp.linespec={'-ok','-.xk'};
        gp.labels={'Strong Coupling','Weak Coupling'};
        gp.f1={'S','W'};
        gp.f1name='group';
    elseif strcmp('ss',factors{1})
        gp.colors={[1,0.2,0.2],[0.2,0.2,1],[0.2,1,0.2]};
        gp.linespec={'-ok','-.xk',':dk'};
        gp.labels={'S1','S2','S3'};
        gp.f1=gp.labels;
        gp.f1name='session';
    elseif strcmp('idl',factors{1})
        gp.colors={[1,0.2,0.2],[0.2,0.2,1]};
        gp.linespec={'-ok','-.xk'};
        gp.labels={'IDL Easy','IDL Difficult'};
        gp.f1={'LE','LD'};
        gp.f1name='left id';
    else
        gp.colors={[1,0.2,0.2],[0.2,0.2,1],[0.2,1,0.2]};
        gp.linespec={'-ok','-.xk',':dk'};
        gp.labels={'IDR Easy','IDR Medium','IDR Difficult'};
        gp.f1={'RE','RM','RD'};
        gp.f1name='rigth id';
    end
    %Fill factor 2 related graphic properties
    if strcmp('grp',factors{2}) 
        gp.x=[1,2];       
        gp.xticklabels={'Strong Coupling','Weak Coupling'};
        gp.f2={'S','W'};
        gp.f2name='grp';
    elseif strcmp('ss',factors{2})
        gp.x=[1,2,3];
        gp.xticklabels={'S1','S2','S3'};
        gp.f2=gp.xticklabels;
        gp.f2name='session';
    elseif strcmp('idl',factors{2})
        gp.x=[1,2];        
        gp.xticklabels={'IDL Easy','IDL Difficult'};
        gp.f2={'LE','LD'};
        gp.f2name='left id';
    else
        gp.x=[1,2,3];        
        gp.xticklabels={'IDR Easy','IDR Medium','IDR Difficult'};
        gp.f2={'RE','RM','RD'};
        gp.f2name='right id';
    end
end

function yrange=get_yrange(vdata)
    vsize=size(vdata);
    yrange=[0,0];
    switch length(vsize)
       case 2    
            for i=1:vsize(1)
                d=squeeze(vdata(i,:));
                yrange=compare_range(d,yrange);
            end
        case 3
            for i=1:vsize(1)
                for j=1:vsize(2)
                    d=squeeze(vdata(i,j,:));
                    yrange=compare_range(d,yrange);
                end
            end
            
        case 4
            for i=1:vsize(1)
                for j=1:vsize(2)
                    for k=1:vsize(3)
                        d=squeeze(vdata(i,j,k,:));
                        yrange=compare_range(d,yrange);
                    end
                end
            end            
        case 5
            for i=1:vsize(1)
                for j=1:vsize(2)
                    for k=1:vsize(3)
                        for l=1:vsize(4) 
                            d=squeeze(vdata(i,j,k,l,:));
                            yrange=compare_range(d,yrange);
                        end
                    end
                end
            end       
    end
end

function yrange = compare_range(data,yrange)

    ymin=mean(data(:));%-std(data(:));    
    ymax=mean(data(:));%+std(data(:));    
    if isempty(yrange)
        yrange=[ymin,ymax];
    else
        if yrange(1)>ymin
            yrange(1)=ymin;
        end
        if yrange(2)<ymax
            yrange(2)=ymax;
        end
    end
end
