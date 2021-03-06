require(lattice)
require(HH)

plot_interactions <- function(mdata,vname,vpath){
    #Plot grp vs S    
    png(file=paste(vpath,"INT_grp_vs_S.png",sep="/"), bg="transparent", width=1400, height=1000)
    print(interaction2wt(get(vname)~grp+S,responselab=vname,main.in=paste(vname," Group vs Session"),mdata))
    dev.off()
    
    #Plot group vs IDR IDL
    form<-as.formula(paste(vname,"~ grp + IDR + IDL"))
    png(file=paste(vpath,"INT_grp_vs_IDL-IDR.png",sep="/"), bg="transparent", width=1400, height=1000)
    print(interaction2wt(form,responselab=vname,main.in=paste(vname," Group vs IDL-IDR"),mdata))
    dev.off()    
    #Plot group vs IDR IDL, 1 per session    
    ip1<-interaction2wt(form,responselab=vname,subset=mdata$S==1,main.in=paste(vname," Group vs IDL-IDR, S1"),mdata)
    ip2<-interaction2wt(form,responselab=vname,subset=mdata$S==2,main.in=paste(vname," Group vs IDL-IDR, S4"),mdata)
    ip3<-interaction2wt(form,responselab=vname,subset=mdata$S==3,main.in=paste(vname," Group vs IDL-IDR, S7"),mdata)
    png(file=paste(vpath,"INT_grp_vs_IDL-IDR_by-S.png",sep="/"), bg="transparent", width=2500, height=1500)
    print(ip1,split=c(1,1,3,1))
    print(ip2,split=c(2,1,3,1),newpage=FALSE)
    print(ip3,split=c(3,1,3,1),newpage=FALSE)
    dev.off()
    
    #Plot Session vs IDR IDL
    form=as.formula(paste(vname,"~ S + IDR + IDL"))
    png(file=paste(vpath,"INT_S_vs_IDL-IDR.png",sep="/"), bg="transparent", width=1400, height=1000)
    print(interaction2wt(form,responselab=vname,main.in=paste(vname," Session vs IDL-IDR"),mdata))
    dev.off()
    #Plot Session vs IDR IDL, 1 per group    
    ip1<-interaction2wt(form,responselab=vname,subset=mdata$grp=='U',main.in=paste(vname," S vs IDL-IDR, Uncoupled"),mdata)
    ip2<-interaction2wt(form,responselab=vname,subset=mdata$grp=='C',main.in=paste(vname," S vs IDL-IDR, Coupled"),mdata)
    png(file=paste(vpath,"S_vs_IDL-IDR_by-grp.png",sep="/"), bg="transparent", width=1400, height=1000)
    plot(ip1,split=c(1,1,1,2))
    plot(ip2,split=c(1,2,1,2),newpage=FALSE)
    dev.off()
    
    #Plot participant vs IDR IDL
    form=as.formula(paste(vname,"~ pp + IDR + IDL"))
    png(file=paste(vpath,"INT_PP_vs_IDR-IDL.png",sep="/"), bg="transparent", width=1400, height=1000)    
    print(interaction2wt(form,responselab=vname,main.in=paste(vname,"  PP vs IDL-IDR"),mdata))
    dev.off()
    #Plot participant vs IDR IDL, 1 per session    
    ip1<-interaction2wt(form,responselab=vname,subset=mdata$S==1,main.in=paste(vname,"  PP vs IDL-IDR, S1"),mdata)
    ip2<-interaction2wt(form,responselab=vname,subset=mdata$S==2,main.in=paste(vname,"  PP vs IDL-IDR, S4"),mdata)
    ip3<-interaction2wt(form,responselab=vname,subset=mdata$S==3,main.in=paste(vname,"  PP vs IDL-IDR, S7"),mdata)
    png(file=paste(vpath,"PP_vs_IDR-IDL_by-S.png",sep="/"), bg="transparent", width=2500, height=1500)
    plot(ip1,split=c(1,1,1,3))
    plot(ip2,split=c(1,2,1,3),newpage=FALSE)
    plot(ip3,split=c(1,3,1,3),newpage=FALSE)
    dev.off()
}
plot_boxplots <- function(mdata,vname,vpath){
    ylim_var<-eval(parse(text=paste(paste('c(0,max(mdata$',vname,sep=''),'))',sep='')))
    #Plot grp vs S    
    png(file=paste(vpath,"grp_vs_S.png",sep="/"), bg="transparent", width=700, height=500)
    form=as.formula(paste(vname,"~ grp | S"))
    plot(bwplot(form,mdata,main = "Group vs Session"))
    dev.off()    
    
    #Plot group vs IDR IDL
    png(file=paste(vpath,"grp_vs_IDL-IDR.png",sep="/"), bg="transparent", width=700, height=500)
    form=as.formula(paste(vname,"~ grp | IDR + IDL"))
    plot(bwplot(form,mdata,main = "Group vs IDL-IDR"))
    dev.off()
    
    #Plot group vs IDR IDL, 1 per session    
    form<-as.formula(paste(vname,"~ grp | IDR + IDL"))  
    bw1<-bwplot(form,mdata,main = "Group vs IDL-IDR Session 1",subset=mdata$S==1,ylim=ylim_var)
    bw2<-bwplot(form,mdata,main = "Group vs IDL-IDR Session 4",subset=mdata$S==2,ylim=ylim_var)
    bw3<-bwplot(form,mdata,main = "Group vs IDL-IDR Session 7",subset=mdata$S==3,ylim=ylim_var)
    png(file=paste(vpath,"grp_vs_IDL-IDR_S.png",sep="/"), bg="transparent", width=1400, height=1000)
    plot(bw1,split=c(1,1,3,1))
    plot(bw2,split=c(2,1,3,1),newpage=FALSE)
    plot(bw3,split=c(3,1,3,1),newpage=FALSE)
    dev.off()
    
    #Plot Session vs IDR IDL
    png(file=paste(vpath,"S_vs_IDL-IDR.png",sep="/"), bg="transparent", width=700, height=500)
    form=as.formula(paste(vname,"~ S | IDR + IDL"))
    plot(bwplot(form,mdata))
    dev.off()

    #Plot Session vs IDR IDL, 1 per group    
    form=as.formula(paste(vname,"~ S | IDR + IDL"))
    bw1<-bwplot(form,mdata,main = "Session vs IDR-IDL Coupled",subset=mdata$grp=='U',ylim=ylim_var)
    bw2<-bwplot(form,mdata,main = "Session vs IDR-IDL Uncoupled",subset=mdata$grp=='C',ylim=ylim_var)
    png(file=paste(vpath,"S_vs_IDL-IDR_grp.png",sep="/"), bg="transparent", width=1400, height=1000)
    plot(bw1,split=c(1,1,1,2))
    plot(bw2,split=c(1,2,1,2),newpage=FALSE)
    dev.off()
    
    #Plot participant vs IDR IDL
    png(file=paste(vpath,"PP_vs_IDR-IDL.png",sep="/"), bg="transparent", width=700, height=500)
    form=as.formula(paste(vname,"~ pp | IDR + IDL"))
    print(bwplot(form,mdata))
    dev.off()

    #Plot participant vs IDR IDL, 1 per session    
    form=as.formula(paste(vname,"~ pp | IDR + IDL"))
    bw1<-bwplot(form,mdata,main = "Participant vs IDR-IDL Session 1",subset=mdata$S==1,ylim=ylim_var)
    bw2<-bwplot(form,mdata,main = "Participant vs IDR-IDL  Session 4",subset=mdata$S==2,ylim=ylim_var)
    bw3<-bwplot(form,mdata,main = "Participant vs IDR-IDL  Session 7",subset=mdata$S==3,ylim=ylim_var)
    png(file=paste(vpath,"PP_vs_IDR-IDL_S.png",sep="/"), bg="transparent", width=1400, height=1000)
    plot(bw1,split=c(1,1,1,3))
    plot(bw2,split=c(1,2,1,3),newpage=FALSE)
    plot(bw3,split=c(1,3,1,3),newpage=FALSE)
    dev.off()
    
    #Plot participant vs grp S
    png(file=paste(vpath,"PP_vs_grp-S.png",sep="/"), bg="transparent", width=700, height=500)
    form=as.formula(paste(vname,"~ pp | grp + S"))
    print(bwplot(form,mdata))
    dev.off()
}

plot_densityplot <- function(mdata,vname,vpath){
    hist_density<-function(x, ...){
        panel.histogram(x, ...)
        panel.mathdensity(dmath=dnorm, col="black", args=list(mean=mean(x), sd=sd(x)))
    }
    form<-as.formula(paste("~",paste(vname,"|IDL:IDR")))
    dens_g1_s1<-histogram(form,mdata,main = "Coupled Session 1",type="density",subset=(mdata$S==1 & mdata$grp=="U"),panel=hist_density)
    dens_g1_s4<-histogram(form,mdata,main = "Coupled Session 4",type="density",subset=(mdata$S==2 & mdata$grp=="U"),panel=hist_density)
    dens_g1_s7<-histogram(form,mdata,main = "Coupled Session 7",type="density",subset=(mdata$S==3 & mdata$grp=="U"),panel=hist_density)
    dens_g2_s1<-histogram(form,mdata,main = "Uncoupled Session 1",type="density",subset=(mdata$S==1 & mdata$grp=="C"),panel=hist_density)
    dens_g2_s4<-histogram(form,mdata,main = "Uncoupled Session 4",type="density",subset=(mdata$S==2 & mdata$grp=="C"),panel=hist_density)
    dens_g2_s7<-histogram(form,mdata,main = "Uncoupled Session 7",type="density",subset=(mdata$S==3 & mdata$grp=="C"),panel=hist_density)
    
    png(file=paste(vpath,"density_plot.png",sep="/"), bg="transparent", width=1400, height=1000)
    plot(dens_g1_s1,split=c(1,1,3,2))
    plot(dens_g1_s4,split=c(2,1,3,2),newpage=FALSE)
    plot(dens_g1_s7,split=c(3,1,3,2),newpage=FALSE)
    plot(dens_g2_s1,split=c(1,2,3,2),newpage=FALSE)
    plot(dens_g2_s4,split=c(2,2,3,2),newpage=FALSE)
    plot(dens_g2_s7,split=c(3,2,3,2),newpage=FALSE)
    dev.off()
}

plot_barcharts <- function(mdata,vname,vpath){
    form<-as.formula(paste("~",paste(vname,"|IDL:IDR")))
    chart_g1_s1<-barchart(form,mdata,main = "Coupled Session 1",subset=(mdata$S==1 & mdata$grp=="U"),origin=0)
    chart_g1_s4<-barchart(form,mdata,main = "Coupled Session 4",subset=(mdata$S==2 & mdata$grp=="U"),origin=0)
    chart_g1_s7<-barchart(form,mdata,main = "Coupled Session 7",subset=(mdata$S==3 & mdata$grp=="U"),origin=0)
    chart_g2_s1<-barchart(form,mdata,main = "Uncoupled Session 1",subset=(mdata$S==1 & mdata$grp=="C"),origin=0)
    chart_g2_s4<-barchart(form,mdata,main = "Uncoupled Session 4",subset=(mdata$S==2 & mdata$grp=="C"),origin=0)
    chart_g2_s7<-barchart(form,mdata,main = "Uncoupled Session 7",subset=(mdata$S==3 & mdata$grp=="C"),origin=0)
    
    png(file=paste(vpath,"barchart.png",sep="/"), bg="transparent", width=1400, height=1000)
    plot(chart_g1_s1,split=c(1,1,3,2))
    plot(chart_g1_s4,split=c(2,1,3,2),newpage=FALSE)
    plot(chart_g1_s7,split=c(3,1,3,2),newpage=FALSE)
    plot(chart_g2_s1,split=c(1,2,3,2),newpage=FALSE)
    plot(chart_g2_s4,split=c(2,2,3,2),newpage=FALSE)
    plot(chart_g2_s7,split=c(3,2,3,2),newpage=FALSE)
    dev.off()    
}
