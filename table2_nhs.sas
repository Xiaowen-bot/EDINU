
**************************************************
* project: Empirical Dietary Index for Eu-Uricemia and Risk of Gout in U.S. Men and Women 
* Exposure: FI (FIq:  & FIr: )
* outcome: gout
* Follow-up period: NHS: 1984-2010  

**************************************************;


/*/**********************************************************************************************************************************/

/*****************General options*******************/;
filename hpstools '/proj/hpsass/hpsas00/hpstools/sasautos';
filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/';
filename PHSmacro '/proj/phdats/phdat01/phstools/sasautos/'; 
filename channing '/usr/local/channing/sasautos';
filename ehmac    '/udd/stleh/ehmac';
libname  formats  '/proj/hpsass/hpsas00/formats';
libname  library  '/proj/nhsass/nhsas00/formats/';

options mautosource sasautos=(channing nhstools hpstools ehmac PHSmacro); *path to macro;       
options fmtsearch=(formats);           
options nocenter minoperator ls=130 ps=78 replace;



/************************ Call in Cleaned Datasets*******************************************************/
%include '/udd/n2xwa/urate/cohort/nhscohort_gout.sas';


data nhs1;
    set nhs1;
    gtcase=case;
run;
/*********************************************************************************************************************************
PURPOSE: Calculate Person-Year
----------------------------------------------------------------------------------------------------------------------------------

/*********** Define macro to output Case Person-Year ***********/
%macro casepy(cohort,exp,case);
proc sql;
create table temp1 as
select *, 
sum(_ppm) as sumppm,sum(&case) as &cohort._sum_&case
from two
group by &exp;
;
quit;
data &cohort._&exp._&case;
set temp1;where &exp ne .;
by &exp;
if first.&exp;
sumpy=round(sumppm/12,1);
cohort="&cohort";
casepy_&case._&cohort=(put(&cohort._sum_&case,comma32.) || '/' || put(sumpy,comma32. -L));
casepy_&case=&cohort._sum_&case ;
keep cohort &exp casepy_&case._&cohort casepy_&case sumpy;
run;
proc transpose data=&cohort._&exp._&case out=&cohort._&exp._&case.print prefix=&exp;
by cohort;
var casepy_&case._&cohort casepy_&case sumpy;
run;
title"**************************&cohort. for &case. Case/PY**************************";
proc print data=&cohort._&exp._&case.print;run;
title"";
data &cohort._&exp._&case;
set &cohort._&exp._&case;
food="&exp";
run;
%mend;

%macro cpy(exp,case);
data casepy;
set 
nhs1_&exp._&case.
;
run;
proc sql;
create table temp1 as
select *, 
sum(casepy_&case.) as sumcase_all,sum(sumpy) as sumpy_all 
from casepy
group by &exp;
;
quit;
proc sort data=temp1;by &exp cohort ;run;
data cp_&exp._&case.;
set temp1 ;
by &exp;
if first.&exp;
casepy_&case._all=(put(sumcase_all,comma32.) || '/' || put(sumpy_all,comma32. -L));
run;
proc transpose data=cp_&exp._&case. out=cp_&exp._&case.;
id &exp;
var casepy_&case._all;
run;
data cp_&exp._&case.;
retain cohort food ;
set  cp_&exp._&case.;
food="&exp";
cohort="nhs1";
run;
proc print data=cp_&exp._&case.;run;
%mend;



%pre_pm(data=nhs1, out=TWO, timevar=interval,
        irt= irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 , 
        cutoff=cutoff, dtdx=goutdtdx, dtdth=dtdth, case=gtcase, var=FIq);
   
%pm(data=TWO, case=gtcase, exposure=FIq);
%casepy(cohort=nhs1,exp=FIq , case=gtcase);
%cpy(FIq, gtcase);


 data casepy_gtcase;
 set cp_FIq_gtcase;
run;


options orientation=landscape;
ODS RTF FILE='./output/casepy_nhs1.rtf' startpage=no; 
proc print data=casepy_gtcase; run;
ODS RTF CLOSE;

/**************************************PURPOSE: Generate COX models************************/


data nhs1; 
    set nhs1;           

    sex=0;
    cohort=1;
    newid=(id+10000000);                        /*IDs for pooling- NHS begins with 1*/

run;



data nhs1;
set  nhs1 ;

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
    hbpbase cholbase 
    ;
run;

proc sort data=nhs1;by interval;run;


proc means data=nhs1 mean median n nmiss;
class FIq;
var FIcon;
output out=FI(drop=_type_ _freq_) mean= median=/ autoname;
run;
data FI;set FI;where FIq ne .;run;


proc standard data=nhs1 mean=0 std=1 out=scaled_pp;
    by interval;
    var FIcon;
run;

data nhs1;
    merge nhs1 scaled_pp(rename=(FIcon=FI_SD));
run;

/*********************************************************************************************************************************
PURPOSE: Generate COX models
----------------------------------------------------------------------------------------------------------------------------------

/********************************************************************************************************/


%let cov = hbpbase cholbase diuret  pmh_ever oc_ever  &race_  &actc_  &smkc_  &qtei_  &bmib_;


/**************************************************************************************/
/********************** Exposure 1: post-dx cum avg ******************/
/**************************************************************************************/

/*************************** Define macro for main analysis ***************************/

%macro model_phreg1(dsn, event, time, exp, cov1, label, food, cat);
title "For &exp.: &label.";
proc phreg data=&dsn nosummary;
model &time*&event(0)=&exp &cov1/ties=BRESLOW rl;
strata interval agemo /* cohort sex */;
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
if index(parameter, 'FIq') ;
run;
%mend;


/*  All-cause mortality  */
%model_phreg1(dsn=nhs1,event=case, time=tgt, exp=&FIq_,  cov1=,     label=age,food=total,cat=);
%model_phreg1(dsn=nhs1,event=case, time=tgt, exp=&FIq_,  cov1=&cov, label=mvt,food=total,cat=);

%model_phreg1(dsn=nhs1,event=case, time=tgt, exp=FI_SD,  cov1=,     label=age,food=total,cat=sd);
%model_phreg1(dsn=nhs1,event=case, time=tgt, exp=FI_SD,  cov1=&cov, label=mvt,food=total,cat=sd);


data main;
length cat $100 model $100. food $100. outcome $100. parameter $100. cohort $100.;
retain outcome model food cohort parameter Estimate Stderr hazardratio HRlowerCL HRupperCL ProbChiSq;
set 
nhs1_case_age_total_       nhs1_case_mvt_total_
nhs1_case_age_total_sd     nhs1_case_mvt_total_sd 
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
run;

proc sort data=table_main_HR;
    by outcome exporder model;
run;

    
/**************************************************************************/
options orientation=landscape;
ODS RTF FILE='./output/table2_nhs.rtf' startpage=no; 
title '/*********************************Main**************************************/';
proc print data=table_main_HR;run;
ODS RTF CLOSE;


