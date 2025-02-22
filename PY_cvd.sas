


*********************************************************************************************************************************/
**********************************************************************************************************
The program is to derive person-years (Total CVD outcomes)    
cutoff:
NHS1 June of 2018 1422
HPFS June of 2016 1398

**********************************************************************************************************;


                                                     ***
                                                ***      ***
                                            ***              ***
                                        ***         POOL         ***
                                            ***              ***
                                                ***      ***
                                                     ***;


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
%include '/udd/n2xwa/urate_Wang/cohort/nhscohort_cvd.sas';
%include '/udd/n2xwa/urate_Wang/cohort/hpfscohort_cvd.sas';


/********************************************************************************************************************************************/
/****************************************************** CASE-PERSON YEARS********************************************************************/
/********************************************************************************************************************************************/
data hpfs;
set hpfs;
CVDcaseca=CVDCABGcase;
dtdxcvdcabg=dtdxcvdca;
run;


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
set temp1;
where &exp ne .;
by &exp;
if first.&exp;
sumpy=round(sumppm/12,1);
cohort="&cohort";
casepy_&case._&cohort=(put(&cohort._sum_&case,comma20.) || '/' || put(sumpy,comma20. -L));
casepy_&case=&cohort._sum_&case ;
keep cohort &exp casepy_&case._&cohort casepy_&case sumpy;
run;
proc transpose data=&cohort._&exp._&case out=&cohort._&exp._&case.print prefix=&exp;
by cohort;
var casepy_&case._&cohort casepy_&case sumpy;
run;
title"**************************&cohort. for &case. Case/PY**************************";
proc print data=&cohort._&exp._&case.print;
run;
title"";
data &cohort._&exp._&case;
set &cohort._&exp._&case;
index="&exp";
run;
%mend;

*===================================*
*==== NHS1 ====*
====================================*;

%pre_pm(data=nhs1,out=TWO,case=CVDcaseca,timevar=interval,irt=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14 irt16,cutoff=1422,
dtdx=dtdxcvdcabg, dtdth=dtdth,var=agegp FIq); 
%pm(data=TWO, case=CVDcaseca, exposure=FIq, strata=agegp);
%casepy(cohort=nhs1,exp=FIq, case=CVDcaseca);

%pre_pm(data=nhs1,out=TWO,case=CHDcase,timevar=interval,irt=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14 irt16,cutoff=1422,
dtdx=dtdxchd, dtdth=dtdth,var=agegp FIq); 
%pm(data=TWO, case=CHDcase, exposure=FIq, strata=agegp);
%casepy(cohort=nhs1,exp=FIq, case=CHDcase);

%pre_pm(data=nhs1,out=TWO,case=STRcase,timevar=interval,irt=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14 irt16,cutoff=1422,
dtdx=dtdxstr, dtdth=dtdth,var=agegp FIq); 
%pm(data=TWO, case=STRcase, exposure=FIq, strata=agegp);
%casepy(cohort=nhs1,exp=FIq, case=STRcase);

*===================================*
*==== HPFS ====*
====================================*;


%pre_pm(data=hpfs,out=TWO,timevar=interval,irt=rtmnyr86 rtmnyr88 rtmnyr90 rtmnyr92 rtmnyr94 rtmnyr96 rtmnyr98 rtmnyr00 rtmnyr02 rtmnyr04 rtmnyr06 rtmnyr08 rtmnyr10 rtmnyr12 rtmnyr14 ,cutoff=1398,dtdx=dtdxcvdcabg, dtdth=dtdth,
case=CVDcaseca, var=agegp FIq); 
%pm(data=TWO, case=CVDcaseca, exposure=FIq, strata=agegp);
%casepy(cohort=hpfs,exp=FIq, case=CVDcaseca);

%pre_pm(data=hpfs,out=TWO,timevar=interval,irt=rtmnyr86 rtmnyr88 rtmnyr90 rtmnyr92 rtmnyr94 rtmnyr96 rtmnyr98 rtmnyr00 rtmnyr02 rtmnyr04 rtmnyr06 rtmnyr08 rtmnyr10 rtmnyr12 rtmnyr14  ,cutoff=1398,dtdx=dtdxchd, dtdth=dtdth,
case=CHDcase, var=agegp FIq); 
%pm(data=TWO, case=CHDcase, exposure=FIq, strata=agegp);
%casepy(cohort=hpfs,exp=FIq, case=CHDcase);

%pre_pm(data=hpfs,out=TWO,timevar=interval,irt=rtmnyr86 rtmnyr88 rtmnyr90 rtmnyr92 rtmnyr94 rtmnyr96 rtmnyr98 rtmnyr00 rtmnyr02 rtmnyr04 rtmnyr06 rtmnyr08 rtmnyr10 rtmnyr12 rtmnyr14  ,cutoff=1398,dtdx=dtdxstr, dtdth=dtdth,
case=STRcase, var=agegp FIq); 
%pm(data=TWO, case=STRcase, exposure=FIq, strata=agegp);
%casepy(cohort=hpfs,exp=FIq, case=STRcase);

*===================================*
*==== POOL ====*
====================================*;

/****************************************************************************************************************************************************************************************************************/
/****************************************************************************************************************************************************************************************************************/
/****************************************************************************************************************************************************************************************************************/
/****************************************************************************************************************************************************************************************************************/

%macro cpy(exp,case);
data casepy;
    set 
    hpfs_&exp._&case.
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

proc sort data=temp1;
by &exp cohort ;
run;
data cp_&exp._&case.;
set temp1 ;
by &exp;
if first.&exp;
casepy_&case._all=(put(sumcase_all,comma20.) || '/' || put(sumpy_all,comma20. -L));
run;

proc transpose data=cp_&exp._&case. out=cp_&exp._&case.;
id &exp;
var casepy_&case._all;
run;

data cp_&exp._&case.;
retain cohort index ;
set  cp_&exp._&case.;
index="&exp";
cohort="Pool";
run;
proc print data=cp_&exp._&case.;
run;
%mend;

%cpy(FIq,CVDcaseca);
%cpy(FIq,CHDcase);
%cpy(FIq,STRcase);

data casepy_CVDcaseca;
    set  
    cp_FIq_CVDcaseca
    cp_FIq_CHDcase
    cp_FIq_STRcase
    ;
run;

options orientation=landscape;
ODS RTF FILE='/udd/n2xwa/urate_Wang/cohort/casePY_pool_CVD.rtf' startpage=no; 
proc print data=casepy_CVDcaseca;
run;
ODS RTF CLOSE;

