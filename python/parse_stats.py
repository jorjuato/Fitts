#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys

def get_results_string(filepath):
	fid=open(filepath,'r')
	line=fid.readline()
	return line.split('=')[1][1:-2]

did=1
R_PATH="/home/jorge/Dropbox/dev/Bimanual-Fitts/R"
R_SAVE_PATH="/home/jorge/KINARM/out"

RES_STR=get_results_string(os.path.join(R_PATH,"get_Rname.R"))
RES_PATH=os.path.join(R_SAVE_PATH,RES_STR)
R_RES_DIR=os.path.join(RES_PATH,"stats")
R_OUT_DIR=os.path.join(RES_PATH,"dataframes")


if did:
    factors=['S','DID','grp','grp:S','grp:DID','S:DID','grp:S:DID']
    oneway=('grp','S','DID')
    twoway=('grp:S','grp:DID','S:DID')
    threeway=('grp:S:DID',)
else:
    factors=['grp','S','IDR', 'IDL','grp:S','IDR:IDL','grp:IDR','grp:IDL', 'S:IDR','S:IDL','grp:IDR:IDL','S:IDR:IDL','grp:S:IDR','grp:S:IDL','grp:S:IDR:IDL']
    oneway=('grp','S','IDR','IDL','ID')
    twoway=('grp:S','grp:IDR','grp:IDL','grp:ID','S:IDR','S:IDL','S:ID','IDR:IDL')
    threeway=('grp:S:IDR', 'grp:S:IDL','grp:S:ID', 'S:IDR:IDL')
    fourway=('grp:S:IDR:IDL',)
 
header=['DFn','DFd','F','p','ges','W','p[Mal]','GGe','p[GG]','HFe','p[HF]']
idx={vname:i for i,vname in enumerate(header)}
line_length=160



def print_results(res,pvar='p',pval=0.05,sig=1):
    varsorted=sorted(res.keys())
    print_res(oneway,"ONE WAY EFFECTS",res,pvar,pval,sig)
    print_res(twoway,"TWO WAY EFFECTS",res,pvar,pval,sig)
    print_res(threeway,"THREE WAY EFFECTS",res,pvar,pval,sig)
    if not did:
        print_res(fourway,"FOUR WAY EFFECTS",res,pvar,pval,sig)


def print_res(xway,msg,res,pvar,pval,sig):
    xwaydict=dict()
    varsorted=sorted(res.keys())
    for factor in xway:
        varnames=[]
        for var in varsorted:
            tests=res[var]
            try:
                if sig:
                    if tests[factor][idx[pvar]]<pval:
                        varnames.append(var)
                else:
                    if tests[factor][idx[pvar]]>pval:
                        varnames.append(var)
            except:
                continue
        xwaydict[factor]=varnames
    fmtstr="|{:<18}"*len(xway)+'|'
    print "="*40
    print "\t\t{0}".format(msg)
    print "="*40
    print "-"*line_length
    print fmtstr.format(*xway)
    print "-"*line_length
    rowno=1
    flag=1
    while flag:
        flag=0
        row=[]  
        for factor in xway:
            if len(xwaydict[factor])<rowno:
                row.append('')
            else:
                row.append(xwaydict[factor][rowno-1])
                flag=1
        print fmtstr.format(*row)
        rowno=rowno+1
    print "-"*line_length
    print
    
def get_sig_byfact(res,fact,pval):
    pass
    
def parse_results(res_path=R_RES_DIR):
    return { var:parse_var(res_path,var) for var in os.listdir(res_path)}   
        
def parse_var(res_path,v):
    var_res=dict();
    vlist=['DID6_MT','DID6_accQ','DID6_peakVel','DID6_IPerfEf','DID6_Harmonicity','DID6_maxangle','DID6_vfCircularity','DID3_rho','DID3_phDiffStd','DID3_flsPC','DID3_KLD','DID3_minPeakDelay','DID3_minPeakDelayNorm','DID3_d4D']
    vpath=os.path.join(res_path,v)
    if v not in vlist:
		return dict()
    
    ######################################################
    #Process anova.out file
    anovaF=open(os.path.join(vpath,'anova.out'))
    
    #Load first block of anova results
    skip_lines(anovaF,2)
    for line in anovaF:
        line = line.replace("*", "")
        fields=line.split() 
        if len(fields)==0 or not fields[0].isdigit():
            break
        var_res[fields[1]]=map(float,fields[2:])
    
    #Load second block of anova results
    skip_lines(anovaF,1)
    for line in anovaF:
        line = line.replace("*", "")
        fields=line.split()
        if len(fields)==0 or not fields[0].isdigit():
            break
        var_res[fields[1]].extend( map(float,fields[2:]) )
        
    #Load third block of anova results
    skip_lines(anovaF,1)
    for line in anovaF:
        line = line.replace("*", "")
        fields=line.split()     
        if len(fields)==0 or not fields[0].isdigit():
            break
        var_res[fields[1]].extend( map(float,fields[2:]) )
        
    anovaF.close()

    ######################################################  
    #Process lmer_tukey.out
    #postF=open(os.path.join(vpath,'lmer_tukey.out'))
    
    #while 1:
        #factor=skip_to_factor(postF)
        #if factor==0:
            #break
        #skip_to_estimate(postF)
        #postDict=dict()
        #for line in postF:
            #if line.startswith('---') or line.startswith('(Adjusted'):
                #break
            #line = line.replace("*", "")
            #line = line.replace(".", "")
            #line = line.replace("<", "")
            #fields=line.split('==')
            #postDict[fields[0].strip()]=map(float,fields[1].split())
        #var_res[factor].append(postDict)
    return var_res      
        
        
def skip_lines(fileObj,lineno):
    for i,line in enumerate(fileObj):
        if i==lineno:
            break
            
def skip_to_factor(fileObj):
    for line in fileObj:
        if line.startswith('[1]'):
            line = line.replace("\"", "")
            return line.split()[1]
    return 0

def skip_to_estimate(fileObj):  
    for line in fileObj:
        if line.strip().startswith('Estimate'):
            return
            
def print_var(results,vname,postp='p[HF]'):
    s=[' ','*']
    res=results[vname]
    print "ANOVA Results for variable %s" % vname
    print"-"*90
    print "Factor\t\tpVal\tSGN\tSpher\tSGN\tp[GG]\tSGN\tp[HF]\tSGN"
    print"-"*90
    for i,factor in enumerate(factors):
        if i%5==0 and not i==0:
            print"-"*90
        try:
            r=res[factor]
        except:
            print("Unimanual variable")
            return
        pv=r[3]<0.05        
        if len(r)==11:
            sphv=r[6]<0.05
            ggv=r[8]<0.05
            hfv=r[10]<0.05            
            if len(factor)>7:
                print "%s\t%.3f\t%s\t%.3f\t%s\t%.3f\t%s\t%.3f\t%s" % (factor,r[3],s[pv],r[6],s[sphv],r[8],s[ggv],r[10],s[hfv])
            else:
                print "%s\t\t%.3f\t%s\t%.3f\t%s\t%.3f\t%s\t%.3f\t%s" % (factor,r[3],s[pv],r[6],s[sphv],r[8],s[ggv],r[10],s[hfv])
        else:
            print "%s\t\t%.3f\t%s" % (factor,r[3],s[pv])
    print"-"*90

def get_factors(vname):
    if vname.startswith('UniL') or vname.startswith('UniR'):
        return ['S','ID','grp','grp:S','grp:ID','S:ID','grp:S:ID']
    elif vname.startswith('DID3_') or vname.startswith('DID6_'):
        return ['S','DID','grp','grp:S','grp:DID','S:DID','grp:S:DID']
    else:
        return ['grp','S','IDR', 'IDL','grp:S','IDR:IDL','grp:IDR','grp:IDL', 'S:IDR','S:IDL','grp:IDR:IDL','S:IDR:IDL','grp:S:IDR','grp:S:IDL','grp:S:IDR:IDL']
    
def save_results(results,fname=os.path.join(R_OUT_DIR,'anova.out')):
    sep=' '
    f=open(fname,'w+')
    for key,value in results.iteritems():
        f.write(key)        
        for factor in get_factors(key):
            try:
                r=value[factor]
            except:
                break
            pv=r[3]<0.05        
            if len(r)==11:
                sphv=r[6]<0.05
                ggv=r[8]<0.05
                hfv=r[10]<0.05
                if (pv and not sphv) or (pv and hfv):
                    f.write(sep+factor)
            elif pv:
                    f.write(sep+factor)
        f.write('\n')
    f.close()   
    
def write_table(results,fname=os.path.join(R_OUT_DIR,'table.csv')):
    sep=','
    f=open(fname,'w+')    
    vlist=['DID6_MT','DID6_accQ','DID6_peakVel','DID6_Harmonicity','DID6_maxangle','DID6_vfCircularity','DID3_rho','DID3_flsPC','DID3_phDiffStd','DID3_KLD']
    flist=['grp','S','DID','grp:S','grp:DID','S:DID','grp:S:DID']    
    keys=results.keys()
    for vname in vlist:
		if vname in keys:
			vres=results[vname]
			if len(vres)==0:
				continue
			else:
				f.write(vname)
				for factor in flist:
					r=vres[factor]
					Fstat=r[2]
					pval=r[3]
					ges=r[4]
					rstring='%s%2.2f%s%2.2f%s%2.2f' % (sep,Fstat,sep,pval,sep,ges)
					f.write(rstring)
				f.write('\n')		 
    f.close()   
    
        
if __name__ == '__main__':    
    res=parse_results()
    #print_results(res,'p[Mal]',0.05,1)
    save_results(res)
    write_table(res)
    sys.exit()
