**************************************************
*  Table S6 S7: the code is same as table2_gout, only exposure is different.      

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
options mautosource sasautos=(mymacr channing nhstools hpstools ehmac PHSmacro); *path to macro;
options fmtsearch=(formats);
options nocenter ls=130 ps=78 replace;



/************************ Call in Cleaned Datasets*******************************************************/
%include '/udd/n2xwa/urate_Wang/cohort/nhscohort_pls.sas';
%include '/udd/n2xwa/urate_Wang/cohort/hpfscohort_pls.sas';

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
    
    FIcon   FIq:
    FIMcon  FIMq:
    FIconr  FIqr: 

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
    ;
run;

proc sort data=pool;by interval;run;

proc freq data=pool;tables case;run;

proc means data=pool mean median n nmiss;
class FIqr;
var FIconr;
output out=FIr(drop=_type_ _freq_) mean= median=/ autoname;
run;
data FIr;set FIr;where FIqr ne .;run;



/*********************************************************************************************************************************
PURPOSE: Generate COX models
----------------------------------------------------------------------------------------------------------------------------------

/********************************************************************************************************/


%let cov = hbpbase cholbase ckdcase pmh_ever oc_ever diuret  &race_  &actc_   &smkc_  &qtei_  &bmib_;


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
if  index(parameter, 'FIqr');
run;
%mend;


%model_phreg1(dsn=pool,event=case, time=tgt, exp=&FIqr_,  cov1=,     label=age,food=rank,cat=);
%model_phreg1(dsn=pool,event=case, time=tgt, exp=&FIqr_,  cov1=&cov, label=mvt,food=rank,cat=);

data main;
length cat $100 model $100. food $100. outcome $100. parameter $100. cohort $100.;
retain outcome model food cohort parameter Estimate Stderr hazardratio HRlowerCL HRupperCL ProbChiSq;
set 

pool_case_age_rank_        pool_case_mvt_rank_
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

     if food="rank" then exporder=1;
run;

proc sort data=table_main_HR;
    by outcome exporder model;
run;

    
/**************************************************************************/
options orientation=landscape;
ODS RTF FILE='./output/table2_pool_pls.rtf' startpage=no; 
title '/*********************************Main**************************************/';
proc print data=table_main_HR;run;
ODS RTF CLOSE;

