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
    FIconr  FIqr:

    /**Covariates***/
    agemo agesub agecon agegp   agegp:
    /*race: */  
    race    race:  white
    /******************************************************************************/ 
    qtei:   teiq  calorm 
    qahei:  aheiq  aheim
    qdash:  dashqq  dashm

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
    hbpbase cholbase ckdcase prs_urate
    ;
run;


data pooltable1;
set pool;
        /*Generating Table 1 for participants*/
        proc format;
        value race   1='White' 2='Others' 3='Asian' 4='African-american';
        value bmib   1='Underweight' 2='healthy weight' 3='Overweight' 4='Obesity' 5='Obesity';
        /*       value actcc  1='<3 total mets/wk' 2='3 to < 9 mets/wk' 3='9 to < 18 mets/wk' 4='18 to < 27 mets/wk' 5='27+ mets/wk';*/
        
        run;
        
proc sort data=pooltable1;by newid interval;run;

data pooltable1;
set pooltable1;
by newid interval;
if first.newid;

        label  
           race='Race'
           bmib= 'Body mass index (BMI, kg m2)'
           mvit='Multivitamin use'
           aspirin='Aspirin use'
           smknever='Never smoker'
           active='High Level Physical activity(MET-h/wk)'
           calorm='Total energy intake (Kcal/d)'  
           aheim='AHEI '  
           dashm= 'DASH'
           diuret='Diuretic drug use';
 
        format race race. bmib bmib. ;
        run;

proc sort data=pooltable1;by newid interval;run;

/*Distributions of characteristics might be different between baseline and whole folllow-up, need to rank separately*/
proc rank data=pooltable1 groups=5 out=pooltable1;
var FIcon;
ranks FIq_base ;
run;

data pooltable1;
set pooltable1;
FIq_base=FIq_base+1;
run;


%table1(data= pooltable1,
        agegroup =  agegp,
        exposure =  FIq_base,
        varlist  =  agecon race  mvit  smknever active bmib calorm aheim  dashm
        hbpbase cholbase diuret FIconr,                                                  
        noadj    =  agecon,     
        cat      =  mvit  smknever  hbpbase cholbase active diuret,  
        rtftitle =  Baseline characteristics of cohort, 
        landscape=  F,                               
        file     =  pool.table1, 
        uselbl   =  F,
        dec      =  2,
        poly=race bmib );
run;


proc corr data=pooltable1;
    var aheim FIcon;
run;

proc corr data=pooltable1;
    var dashm FIcon;
run;