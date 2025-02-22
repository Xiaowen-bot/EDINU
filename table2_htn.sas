**************************************************
* project: Empirical Dietary Index for Eu-Uricemia and Risk of Gout in U.S. Men and Women 
* Exposure: FI (FIq:  & FIr: )
* outcome: Hypertension
* Follow-up period: NHS: 1984-2018  HPFS:1986-2016

**************************************************;

/*/**********************************************************************************************************************************/


filename hpstools '/proj/hpsass/hpsas00/hpstools/sasautos';
filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/';
filename PHSmacro '/proj/phdats/phdat01/phstools/sasautos/';
filename channing '/usr/local/channing/sasautos';
filename ehmac    '/udd/stleh/ehmac';
filename mymacr '/udd/n2bli/macro'; 
libname  formats  '/proj/hpsass/hpsas00/formats';
libname  library  '/proj/nhsass/nhsas00/formats/';
libname  htnfile '/udd/hpeha/htn/';
options mautosource sasautos=(mymacr channing nhstools hpstools ehmac PHSmacro); *path to macro;
options fmtsearch=(formats);
options nocenter ls=130 ps=78 replace;



/************************ Call in Cleaned Datasets*******************************************************/
%include '/udd/n2xwa/urate_Wang/cohort/nhscohort_htn.sas';
%include '/udd/n2xwa/urate_Wang/cohort/hpfscohort_htn.sas';

data nhs1; 
    set nhs1;           

    sex=0;
    cohort=1;
    newid=(id+10000000);                        /*IDs for pooling- NHS begins with 1*/

   
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

     mifh=famhxmi;
    dbfh=famhxdb;

run;


data pool;
set hpfs nhs1 ;

 keep 

    newid sex cohort interval

    /**Outcome******/
    htncase  htntime htndtdx

    /**Exposure*****/
    
    FIcon  FIq:
    FIconr  FIqr:
    /**Covariates***/
    agemo agesub agecon agegp   agegp:
    /*race: */  
    race    race:  white
    /******************************************************************************/ 
    qtei:   teiq  calorm
    /* qahei:  aheiq 
 */
    /******************************************************************************/ 

    bmib:   bmib bmib25 bmib30
    
    /******************************************************************************/ 

    mvit aspirin 
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
    hbpbase cholbase  mifh dbfh
    ;
run;

proc sort data=pool;by interval;run;

proc freq data=pool;tables htncase;run;

proc means data=pool mean median n nmiss;
class FIq;
var FIcon;
output out=FI(drop=_type_ _freq_) mean= median=/ autoname;
run;
data FI;set FI;where FIq ne .;run;

proc means data=pool mean median n nmiss;
class FIqr;
var FIconr;
output out=FIr(drop=_type_ _freq_) mean= median=/ autoname;
run;
data FIr;set FIr;where FIqr ne .;run;



proc standard data=pool mean=0 std=1 out=scaled_pp;
    by interval;
    var FIcon;
run;

data pool;
    merge pool scaled_pp(rename=(FIcon=FI_SD));
run;

/*********************************************************************************************************************************
PURPOSE: Generate COX models
----------------------------------------------------------------------------------------------------------------------------------

/********************************************************************************************************/


%let cov =  cholbase  pmh_ever oc_ever mvit aspirin mifh  &race_  &actc_   &smkc_  &qtei_  &bmib_;


/**************************************************************************************/
/********************** Exposure 1: post-dx cum avg ******************/
/**************************************************************************************/

/*************************** Define macro for main analysis ***************************/

%macro model_phreg1(dsn, event, time, exp, cov1, label, food, cat);
title "For &exp.: &label.";
proc phreg data=&dsn nosummary;
model &time*&event(0)=&exp &cov1/ties=BRESLOW rl;
strata interval agemo cohort;
ods output ParameterEstimates=&dsn._&event._&label._&food._&cat. ;
run;
data &dsn._&event._&label._&food._&cat.;
length model $100. parameter $100. food $100. cohort $100.;
outcome="&event.";
food   ="&food." ;
model  ="&label.";
cat    ="&cat."  ;
cohort ="&dsn."  ;
set &dsn._&event._&label._&food._&cat. ;
if index(parameter, 'FIq') or index(parameter, 'FIqr') ;
run;
%mend;


%model_phreg1(dsn=pool,event=htncase, time=htntime, exp=&FIq_,  cov1=,     label=age,food=total,cat=);
%model_phreg1(dsn=pool,event=htncase, time=htntime, exp=&FIq_,  cov1=&cov, label=mvt,food=total,cat=);

%model_phreg1(dsn=pool,event=htncase, time=htntime, exp=FI_SD,  cov1=,     label=age,food=total,cat=sd);
%model_phreg1(dsn=pool,event=htncase, time=htntime, exp=FI_SD,  cov1=&cov, label=mvt,food=total,cat=sd);

%model_phreg1(dsn=pool,event=htncase, time=htntime, exp=&FIqr_,  cov1=,     label=age,food=rank,cat=);
%model_phreg1(dsn=pool,event=htncase, time=htntime, exp=&FIqr_,  cov1=&cov, label=mvt,food=rank,cat=);

data main;
length cat $100 model $100. food $100. outcome $100. parameter $100. cohort $100.;
retain outcome model food cohort parameter Estimate Stderr hazardratio HRlowerCL HRupperCL ProbChiSq;
set 
pool_htncase_age_total_       pool_htncase_mvt_total_
pool_htncase_age_total_sd     pool_htncase_mvt_total_sd 
pool_htncase_age_rank_        pool_htncase_mvt_rank_
;
parameter=substr(parameter,1,4);

run;

data round_main_HR;
   set main;
   hzrcl = (put(round(hazardratio,0.01),4.2) || ' (' || put(round(HRlowerCL,0.01),4.2)|| ', ' ||
   put(round(HRupperCL,0.01),4.2) || ') ' );
   keep cohort cat outcome model parameter Estimate Stderr hzrcl ProbChiSq food;
   run;
/*******************************HR(95%CI)*******************************************/
proc sort data=round_main_HR;by outcome food model  ;run; 
proc transpose data=round_main_HR
                out=table_main_HR
        prefix=cat;
        by outcome food model   ;
        var hzrcl  ProbChiSq ; /* add another var here */
        run;

data table_main_HR;set table_main_HR;
rename  
    cat1=Q2
    cat2=Q3
    cat3=Q4
    cat4=Q5
    ;
Measure='HR';
Q1='1.00';
drop _name_;
run;

data table_main_HR; 
    set table_main_HR;
    exporder=.;
     if food="total" then exporder=1;
     if food="rank" then exporder=2;
run;

proc sort data=table_main_HR;
    by outcome exporder model;
run;

    
/**************************************************************************/
options orientation=landscape;
ODS RTF FILE='./output/table2_pool_htn.rtf' startpage=no; 
title '/*********************************Main**************************************/';
proc print data=table_main_HR;run;
ODS RTF CLOSE;


%LGTPHCURV9(    data    = pool, 
        exposure= FI_SD, 
        case    = htncase, 
        model   = cox, 
        time    = htntime,
        strata  = agemo interval,
        adj =  &cov, 
        refval  = min,  
        lpct    = 1, 
        hpct    = 99,  
        nk  = 4,    
        SELECT   = 3,         
        pwhich  = spline,  
        footer  = NONE,
        GRAPHTIT= NONE,
        plot    = 4,
        e   = T,     
        ci  = 2,     
        displayx= T,  
        klines  = T,   
        plotdec = T,
        PLOTDATA = FI_htn.txt);  