/*/**********************************************************************************************************************************/


filename hpstools '/proj/hpsass/hpsas00/hpstools/sasautos';
filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/';
filename PHSmacro '/proj/phdats/phdat01/phstools/sasautos/';
filename channing '/usr/local/channing/sasautos';
filename ehmac    '/udd/stleh/ehmac';
filename mymacr '/udd/n2bli/macro'; 
libname  formats  '/proj/hpsass/hpsas00/formats';
libname  library  '/proj/nhsass/nhsas00/formats/';
options mautosource sasautos=(mymacr channing nhstools hpstools ehmac PHSmacro); *path to macro;
options fmtsearch=(formats);
options nocenter ls=130 ps=78 replace;



/************************ Call in Cleaned Datasets*******************************************************/
%include '/udd/n2xwa/urate_Wang/cohort/nhscohort_gout.sas';
%include '/udd/n2xwa/urate_Wang/cohort/hpfscohort_gout.sas';


data nhs1; 
    set nhs1;           

    sex=0;
    cohort=1;
    newid=(id+10000000);                        /*IDs for pooling- NHS begins with 1*/
    ckdcase=0;
run;

data hpfs; 
    set hpfs; 

    pmhr=0;
    pmh2=0;
    pmh3=0;
    pmh4=0;
    pmhm=0;

    pmh_ever=0;
    oc_ever=0;

    sex=1;
    cohort=3;
   newid2=(id+30000000);        /*IDs for pooling- HPFS begins with 3*/
   newid=newid2*100;            /* for overlapped IDs*/
run;


data pool;
set hpfs nhs1 ;

 keep 

    newid sex cohort interval

    /**Outcome******/
    goutdtdx case tgt

    /**Exposure*****/
    
    FIcon  FIq:

    /**Covariates***/
    agemo agesub agecon agegp   agegp:
    /*race: */  
    race    race:  white
    /******************************************************************************/ 
    qtei:   teiq  calorm
    qahei:  aheiq 

    /******************************************************************************/ 

    bmib:   bmib bmib25 bmib30
    
    /******************************************************************************/ 

    mvit aspirin diuret
    /******************************************************************************/            
    /*smk:*/  
    smkc:  smkever smknever
    
    /******************************************************************************/ 
    alco_cumc: alco_cumc neverdrinker
    /******************************************************************************/     
    actc:  actcc active
   
    /******************************************************************************/        

    pmh_ever oc_ever

    /******************************************************************************/
    hbpbase cholbase ckdcase

    prs_urate

    ;
run;

proc sort data=pool;by interval;run;

    proc standard data=pool mean=0 std=1 out=scaled_pp;
    by interval;
    var FIcon;
    run;

    data pool;
    merge pool scaled_pp(rename=(FIcon=FI_SD));
    run;

   data pool;
    set pool;
    where bmib25 ne .; 
   run;


proc rank data=pool  groups=2  out=pool;
 by interval;
 var prs_urate  ;
 ranks prs_group ;
run;

proc means data=pool;
    class prs_group;
    var FI_SD;
run;
proc sort data=pool; by newid; run;



/*********************************************************************************************************************************
PURPOSE: Generate COX models for subgroup analysis
----------------------------------------------------------------------------------------------------------------------------------

/********************************************************************************************************/
%let cov_sub1 = /* hbpbase */ cholbase ckdcase  diuret pmh_ever oc_ever  &race_  &actc_   &smkc_  &qtei_    &bmib_;
* %let cov_sub2 = hbpbase /* cholbase */ ckdcase  diuret pmh_ever oc_ever  &race_  &actc_  &smkc_  &qtei_    &bmib_;
%let cov_sub3 = hbpbase cholbase ckdcase  diuret  pmh_ever oc_ever  &race_  /* &actc_ */  &smkc_  &qtei_   &bmib_;

%let cov_sub5 = hbpbase cholbase ckdcase  diuret  pmh_ever oc_ever  &race_  &actc_  /* &smkc_ */  &qtei_    &bmib_;
%let cov_sub6 = hbpbase cholbase ckdcase  diuret  pmh_ever oc_ever  &race_  &actc_  &smkc_   &qtei_   /* &bmib_ */;
%let cov_sub7 = hbpbase cholbase ckdcase  /* diuret */ pmh_ever oc_ever  &race_  &actc_   &smkc_   &qtei_    &bmib_ ;
%let cov_sub8 = hbpbase cholbase ckdcase  diuret  pmh_ever oc_ever  &race_  &actc_  &smkc_   &qtei_    &bmib_ ;


/*************************** Define macro for main analysis ***************************/

%macro model_phreg1(dsn, event, time, exp, by, cov1, label, food, cat);
title "For &exp.: &label.";
proc sort data=&dsn; by &by; run;
proc phreg data=&dsn nosummary;
  by &by;
model &time*&event(0)=&exp &cov1/ties=BRESLOW rl;
strata interval agemo cohort;
ods output ParameterEstimates=&dsn._&event._&by._&food._&cat. ;
run;
data &dsn._&event._&by._&food._&cat.;
length model $100. parameter $100. food $100. cohort $100.;
outcome="&event.";
food   ="&food." ;
byvar   ="&by." ;
model  ="&label.";
cat    ="&cat."  ;
cohort ="&dsn."  ;
set &dsn._&event._&by._&food._&cat. ;
if index(parameter, 'FI_SD') ;
run;
%mend;


%model_phreg1(dsn=pool,event=case, time=tgt, exp=FI_SD,  by=hbpbase  , cov1=&cov_sub1, label=mvt,food=total,cat=);
* %model_phreg1(dsn=pool,event=case, time=tgt, exp=FI_SD,  by=cholbase , cov1=&cov_sub2, label=mvt,food=total,cat=);
%model_phreg1(dsn=pool,event=case, time=tgt, exp=FI_SD,  by=active   , cov1=&cov_sub3, label=mvt,food=total,cat=);

%model_phreg1(dsn=pool,event=case, time=tgt, exp=FI_SD,  by=smknever  ,    cov1=&cov_sub5, label=mvt,food=total,cat=);
%model_phreg1(dsn=pool,event=case, time=tgt, exp=FI_SD,  by=bmib25  ,      cov1=&cov_sub6, label=mvt,food=total,cat=);
%model_phreg1(dsn=pool,event=case, time=tgt, exp=FI_SD,  by=diuret  ,      cov1=&cov_sub7, label=mvt,food=total,cat=);
%model_phreg1(dsn=pool,event=case, time=tgt, exp=FI_SD,  by=prs_group  ,   cov1=&cov_sub8, label=mvt,food=total,cat=);


data main;
length cat $100 model $100. food $100. outcome $100. parameter $100. cohort $100.;
retain outcome model food cohort parameter Estimate Stderr hazardratio HRlowerCL HRupperCL ProbChiSq;
set 
pool_case_hbpbase_total_
/* pool_case_cholbase_total_   */  
pool_case_active_total_ 

pool_case_smknever_total_ 
pool_case_bmib25_total_ 
pool_case_diuret_total_ 
pool_case_prs_group_total_ 
;
parameter=substr(parameter,1,4);

run;

data round_main_HR;
   set main;
   hzrcl = (put(round(hazardratio,0.01),4.2) || ' (' || put(round(HRlowerCL,0.01),4.2)|| ', ' ||
   put(round(HRupperCL,0.01),4.2) || ') ' );
   keep cohort cat outcome byvar model parameter Estimate Stderr hzrcl ProbChiSq food;
   run;

/*******************************HR(95%CI)*******************************************/
proc sort data=round_main_HR;by outcome byvar food model  ;run; 
proc transpose data=round_main_HR
                out=table_main_HR
        prefix=cat;
        by outcome byvar food model   ;
        var hzrcl  ProbChiSq ; 
        run;

data table_main_HR;set table_main_HR;
rename  
    cat1=perSD_0
    cat2=perSD_1

    ;
Measure='HR';
drop _name_;
run;


data table_main_HR; 
    set table_main_HR;
    exporder=.;
     if food="total" then exporder=1;
  
    byorder=.;
     if byvar="hbpbase"  then byorder=1;
    /*  if byvar="cholbase" then byorder=2; */
     if byvar="active"   then byorder=2;
     if byvar="smknever"     then byorder=3;
     if byvar="bmib325" then byorder=4;
     if byvar="diuret" then byorder=5;
     if byvar="prs_group" then byorder=6;

run;

proc sort data=table_main_HR;
    by byorder exporder model;
run;

    
/**************************************************************************/
options orientation=landscape;
ODS RTF FILE='./output/table_stra_gout.rtf' startpage=no; 
title '/*********************************Main**************************************/';

proc print data=table_main_HR (where=(byvar="hbpbase")); var outcome byvar food perSD_0 ; run;
proc print data=table_main_HR (where=(byvar="hbpbase")); var outcome byvar food perSD_1 ; run;

/* proc print data=table_main_HR (where=(byvar="cholbase")); var outcome byvar food perSD_0 ; run;
proc print data=table_main_HR (where=(byvar="cholbase")); var outcome byvar food perSD_1 ; run; */

proc print data=table_main_HR (where=(byvar="active")); var outcome byvar food perSD_0; run;
proc print data=table_main_HR (where=(byvar="active")); var outcome byvar food perSD_1; run;

proc print data=table_main_HR (where=(byvar="smknever")); var outcome byvar food perSD_0; run;
proc print data=table_main_HR (where=(byvar="smknever")); var outcome byvar food perSD_1; run;

proc print data=table_main_HR (where=(byvar="bmib25")); var outcome byvar food perSD_0 ; run;
proc print data=table_main_HR (where=(byvar="bmib25")); var outcome byvar food perSD_1; run;

proc print data=table_main_HR (where=(byvar="diuret")); var outcome byvar food perSD_0 ; run;
proc print data=table_main_HR (where=(byvar="diuret")); var outcome byvar food perSD_1; run;

proc print data=table_main_HR (where=(byvar="prs_group")); var outcome byvar food perSD_0 ; run;
proc print data=table_main_HR (where=(byvar="prs_group")); var outcome byvar food perSD_1; run;

ODS RTF CLOSE;