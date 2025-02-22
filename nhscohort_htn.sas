/* ***PPP, add documentation on top of each program.
Project:            Empirical Dietary Index for Eu-Uricemia and Risk of Gout                                                                             
Outcome:            Hypertension                                  
Exposure:           Build dietary index: &FIq_                                                                                                                                                                                        
Programmer:         Xiaowen Wang   

Program Name:       /udd/n2xwa/urate_Wang/cohort/nhscohort_htn.sas
Last updated:       01/2025
Study design:

Prospective cohort study 
NHS: 1984-2018.6

covariates: 
Analyses were stratified by age (in month), calendar year, and cohort. 
Multivariable models were adjusted for race (White, Asian, African American or other): &race_ 
physical activity (<3, 3 to < 9, 9 to < 18, 18 to < 27, ≥27 mets/wk):  &actc_ 
smoking status (never, former, or current [1-14, 15-24, or ≥25 cigarettes/d]): &smkc_
menopausal status (premenopausal or postmenopausal [never, or postmenopausal hormone use], NHS only): pmh_ever 
baseline hypertension (yes or no): hbpbase
baseline high cholesterol (yes or no): cholbase
aspirin use (yes or no): aspirin
multivitamin use (yes or no): mvit
famaily history of MI: mifh
total energy intake (quintiles): &qtei_
baseline BMI (<21, 21-24.9, 25-29.9, 30-34.9, or>=35): &bmib_
history of kidney failure (HPFS only): ckdcase
diuretic use: diuret

Missing value: carry forward one cycle 

EXCLUSIONS/SKIPS at BASELINE and during FOLLOW-UP:
- exclude if history/baseline of hypertension
- exluded those whose last returned questionnaire was at baseline
- who had unusual total energy intake at baseline (<600 or >3500 kcal/d for NHS, <800 or >4200 kcal/d for HPFS)
- records with missing values for diet index (FI84)
- censor incident hypertension, death

/*****************************************************************************************************************************************
* NHS cohort data (hypertension)   
******************************************************************************************************************************************/
 
                                                                                                                        
options linesize=130 pagesize=78;
filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/';
filename local '/usr/local/channing/sasautos/';
filename PHSmacro '/proj/phdats/phdat01/phstools/sasautos/';
filename mumacro '/udd/nhlmu/macro';
libname library '/proj/nhsass/nhsas00/formats/';
libname htnfile '/udd/hpeha/htn/';
options mautosource sasautos=(mumacro local nhstools PHSmacro);
options fmtsearch=(readfmt);



/********* READ IN CONFIRMED GOUT FILES *********/
/************************************* CVD data *****************************************/
/*** read CVD data ***/

data mi;
%include '/proj/nhdats/nh_dat_cdx/endpoints/mi/mi7620.073120.cases.input';

mi=1;
dtdxmi=dxmonth;

keep id dtdxmi mi; 
run;


/*********************** STROKE files*******************************************

****************************************************************************/
data stroke;
%include '/proj/nhdats/nh_dat_cdx/endpoints/stroke/str7620.031621.cases.input';

*total stroke;
tots=1;
dtdxstr=dxmonth;

*hemorrhagic stroke;
   hems=0;
   if dxmonth>0 and 1<=str_type<=2 then do;
     hems=1;
     dtdxhemstr=dxmonth;
   end;

*subarachnoid hemorrhage;
   sah=0;
   if dxmonth>0 and str_type=1 then do;
     sah=1;
     dtdxsah=dxmonth;
   end;

*intraparenchymal hemorrhage;
   iph=0;
   if dxmonth>0 and str_type=2 then do;
     iph=1;
     dtdxiph=dxmonth;
   end;

*ischemic stroke;
   iscs=0;
   if dxmonth>0 and 3<=str_type<=5 then do;
     iscs=1;
     dtdxiscstr=dxmonth;
   end;

*thrombotic stroke;
   trbs=0;
   if dxmonth>0 and str_type=3 then do;
     trbs=1;
     dtdxtrbstr=dxmonth;
   end;

*embolic stroke;
   embs=0;
   if dxmonth>0 and str_type=4 then do;
     embs=1;
     dtdxembstr=dxmonth;
   end;


keep id dtdx: tots hems sah iph iscs trbs embs;


/***Read CABG***/
data cabg;
    %include '/proj/nhdats/nh_dat_cdx/endpoints/cabg/cabg7612.060816.nodups.input'; 

cabg=0;
if dxmonth>0 then do;
  cabg=1;
  dtdxcabg=dxmonth;
end;

keep id dtdxcabg cabg;
run;

*Read reproted cabg from %nurXX;
%nur14(keep=cabg14 cabgd14);
run;

%nur16(keep=cabg16 cabgd16);
run;


data update_cabg;
  merge cabg nur14 nur16;
  by id;

if dtdxcabg=. then do;
                            

                              if cabg16=1 then do;
                                                 if cabgd16=1 then dtdxcabg=1374;
                                            else if cabgd16=2 then dtdxcabg=1386;
                                            else if cabgd16=3 then dtdxcabg=1398;
                                            else                   dtdxcabg=1386;
                        end;

                              if cabg14=1 then do;
                                                 if cabgd14=1 then dtdxcabg=1350;
                                            else if cabgd14=2 then dtdxcabg=1362;
                                            else if cabgd14=3 then dtdxcabg=1374;
                                            else                   dtdxcabg=1362;
                                              end;
end;

if dtdxcabg>0 ;
cabg=1;

run;


data disease_1;
    merge mi stroke update_cabg;
    by id;

*CHD: MI (includes fatal and non-fatal cases);
if dtdxmi>0 then dtdxchd=dtdxmi;

*CHD: MI + CABG; 
if dtdxmi>0 then dtdxchdcabg=dtdxmi;
else if dtdxcabg>0 then dtdxchdcabg=dtdxcabg;

totchdcabg=0;
if dtdxchdcabg>0 then totchdcabg=1;


*Total CVD: MI + STROKE;
if dtdxmi>0       then dtdxcvd=dtdxmi; 
else if dtdxstr>0  then dtdxcvd=dtdxstr; 

*Total CVD + CABG;
dtdxcvdcabg=min(dtdxchdcabg,dtdxstr);
if dtdxcvdcabg=dtdxchdcabg then dtdxcvd_chdcabg=dtdxcvdcabg;
else dtdxcvd_str=dtdxcvdcabg;

/*** DIABETES**/                


data diabetes;
    infile '/proj/nhdats/nh_dat_cdx/endpoints/diabetes/db7624.110123.cases' lrecl=183 recfm=d;
  
    input
    @1    id        6.
    @7    cd    $   1.
    @10   cohort        1.
    @13   icda        5.1
    @20   qyr       2.
    @26   mdx1        2.
    @28   ydx1        2.
    @32   confdb       $ 2.
    @36   nhsicda       5.
    @43   mdx       2.
    @45   ydx       2.
    @49   dxmonthdb       4.
    @55   rc_record_id      6.
    @63   recur       1.
    @66   type        1.
    @67   prob      1.
        ;
    label
        id              = 'id number'
        icda            = 'icda code'
        mdx1            = 'reported month of dx'
        ydx1            = 'reported year of dx'
        confdb          = 'confirmation code'
        mdx             = 'confirmed month of dx'
        ydx             = 'confirmed year of dx'
        nhsicda         = 'nhs icda code'
        dxmonthdb       = 'diagnose date of diabetes by month'
        ;

    type2db=0;
    if type=2 and prob=1 then type2db=1; *type 2 diabees;

    dtdxdb=9999;
    if dxmonthdb > 0 then dtdxdb=dxmonthdb;

    dtdxdb2=9999;
    if dxmonthdb > 0 and type2db=1 then dtdxdb2=dxmonthdb;

    drop icda confdb nhsicda;
run;
    proc sort; by id; run;



 /** Read DEATH files **/

data dead;
    infile '/proj/nhdats/nh_dat_cdx/deaths/deadff.041122' lrecl=91 recfm=d; 
    input
      @1        id         6.
      @8        icda  $    5.
      @15       mod        2.
      @17       yod        2.
      @21       icda10 $   5.
      @28       qyr        2.
      @32       state  $   2.
      @34       source     1.
      @46       confdth    2.
      @49       modx       2.
      @51       yodx       2.
      @54       nhsicda $  4.
      @88       dxmonthdd  4.
      ;
    label
      id              = 'id number'
      icda            = 'icda code for death'
      mod             = 'reported month of death'
      yod             = 'reported year of death'
      confdth         = 'confirmation code'
      nhsicda         = 'nhs icda code'
      dxmonthdd       = 'Date of death'
      ;

    dtdth=9999;
    if dxmonthdd > 0 then dtdth=dxmonthdd;

    newicda=compress(nhsicda, 'E');
    keep id /*confdth*/ dtdth newicda;

run;

    proc sort; by id; run;

 /** Read Hypertension files **/

    data htncasef;  set htnfile.nhs1_htn; *file created by hpeha;
    htnyr=int(htndtdx/12);
    proc sort; by id; run;



               /* Call in food variables */
    **************************************************
    *             Dietary food groups          *
    **************************************************;
%serv84 (keep = id 
                blueb_s84 cotch_s84 crmch_s84 otch_s84 lccaf_s84 lcnoc_s84 lcoth_s84  
                hamb_s84 bmix_s84  bmain_s84 rais_s84 liq_s84 skim_s84 
                liv_s84 mixv_s84 oilv_s84 tom_s84 toj_s84 tosau_s84
                rwine_s84  wwine_s84)

data serv84_cat;
set serv84;

/* Blueberries */           blueb84     = sum(blueb_s84);
/* Tomato products */       tomprod84   = sum(tom_s84, toj_s84, tosau_s84);
/* Diet beverage */         dietbev84   = sum(lccaf_s84, lcnoc_s84, lcoth_s84);
/* Soft and hard cheese */  shchee84    = sum(cotch_s84, crmch_s84, otch_s84);
/* Fresh red meat */        frmeat84    = sum(hamb_s84, bmix_s84, bmain_s84); 
/* Grapes */                grape84     = sum(rais_s84); 
/* Liquor */                liq84       = sum(liq_s84);
/* Low-fat milk */          lfmilk84    = sum(skim_s84);
/* Organ meats */           organ84     = sum(liv_s84);
/* Mixed vegetables */      mixveg84    = sum(mixv_s84);
/* Oil-based dress */       oildres84   = sum(oilv_s84);
/* Wine */                  wine84      = sum(rwine_s84, wwine_s84);
FI84= - (blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

run;


/******************** 1986 ********************/
%serv86 (keep = id
                tom_s86     toj_s86     tosau_s86   sbean_s86   peas_s86    
                brocc_s86   cauli_s86   slaw_s86    ccabb_s86   bruss_s86 
                rcar_s86    ccar_s86    corn_s86    mixv_s86    yam_s86 
                ysqua_s86   eggpl_s86   kale_s86    rspin_s86   cspin_s86 
                ilett_s86   rlett_s86   cel_s86     grpep_s86   cuke_s86 
                mush_s86    alfsp_s86   kraut_s86   rais_s86    prune_s86 
                ban_s86     cant_s86    avo_s86     appl_s86    pear_s86 
                aj_s86      apsau_s86   oran_s86    oj_s86      grfr_s86 
                grj_s86     straw_s86   blueb_s86   peach_s86   h2om_s86 
                cpeac_s86   cpear_s86   fcock_s86   othj_s86    tea_s86         
                dcaf_s86    coff_s86    soda_s86    local_s86   punch_s86 
                h2o_s86     beer_s86    rwine_s86   wwine_s86   liq_s86 
                tofu_s86    bean_s86    pbut_s86    pnut_s86    onut_s86 
                egg_s86     dog_s86     chwi_s86    chwo_s86    bacon_s86 
                procm_s86   hamb_s86    bmix_s86    bmain_s86   ctuna_s86 
                shrim_s86   dkfsh_s86   ofish_s86   livb_s86    livc_s86        
                skim_s86    whole_s86   cream_s86   cofwh_s86   sherb_s86       
                icecr_s86   but_s86     marg_s86    yog_s86     sour_s86        
                cotch_s86   crmch_s86   otch_s86    cer_s86     oat_s86         
                ckcer_s86   whbr_s86    dkbr_s86    crack_s86   engl_s86        
                muff_s86    pcake_s86   brice_s86   wrice_s86   pasta_s86       
                otgrn_s86   fries_s86   pot_s86     pchip_s86   pizza_s86       
                choco_s86   cdyw_s86    cdywo_s86   cokr_s86    cokh_s86        
                brwn_s86    donut_s86   cakh_s86    cakr_s86    pieh_s86        
                pier_s86    sroll_s86   jam_s86     popc_s86    bran_s86        
                wgerm_s86   chowd_s86   soupb_s86   souph_s86   soupr_s86       
                soysa_s86   chsau_s86   mayo_s86    peppr_s86   must_s86        
                oilv_s86        
                );


/*************************************************************************/
/************************ Constructing categories ************************/

data serv86_cat;
set serv86;

/* Avocados */              avocado86   = sum(avo_s86); 
/* Bananas */               banana86    = sum(ban_s86);
/* Beer */                  beer86      = sum(beer_s86);
/* Blueberries */           blueb86     = sum(blueb_s86);
/* Broccoli */              brocc86     = sum(brocc_s86);
/* Brussels sprouts */      bruss86     = sum(bruss_s86);
/* Candy */                 candy86     = sum(choco_s86, cdyw_s86, cdywo_s86);
/* Carrots */               carrot86    = sum(rcar_s86, ccar_s86);
/* Celery */                celery86    = sum(cel_s86);
/* Chowder or cream soup */ chowder86   = sum(chowd_s86);
/* Citrus fruits */         citrus86    = sum(oran_s86, grfr_s86, oj_s86, grj_s86);
/* Coffee */                coffee86    = sum(coff_s86, dcaf_s86);
/* Cold breakfast cereal */ 
/* Condiments */            condi86     = sum(jam_s86, chsau_s86, must_s86, peppr_s86, soysa_s86); /* in 1986 have mustard, soy sauce, pepper shake */
/* Corn */                  corn86      = sum(corn_s86);
/* Crackers */              cracker86   = sum(crack_s86);
/* Dark orange squash */    dksqa86     = sum(ysqua_s86); /* Called Winter squash, yellow or orange in 1986 */
/* Desserts */              dess86      = sum(cokr_s86, cokh_s86, brwn_s86, donut_s86, cakh_s86, cakr_s86, 
                                              pieh_s86, pier_s86, sroll_s86);
/* Diet beverage */         dietbev86   = sum(local_s86); /* just have one item to cover all 3 later ones? */
/* Eggs */                  eggs86      = sum(egg_s86);
/* Fish and seafood */      fish86      = sum(ctuna_s86, shrim_s86, dkfsh_s86, ofish_s86);
/* French fries */          fries86     = sum(fries_s86);
/* Fresh red meat */        frmeat86    = sum(hamb_s86, bmix_s86, bmain_s86); /* Only 3 items in 1986? */
/* Grapes */                grape86     = sum(rais_s86);
/* High-fat dairy */        hfdairy86   = sum(sour_s86, but_s86, cream_s86);
/* Liquor */                liq86       = sum(liq_s86);
/* Low-fat milk */          lfmilk86    = sum(skim_s86);
/* Margarine */             marg86      = sum(marg_s86);
/* Mayo or creamy dress */  mayo86      = sum(mayo_s86);
/* Melons */                melon86     = sum(cant_s86, h2om_s86);
/* Milk-based frzn dess */  milkdes86   = sum(sherb_s86, icecr_s86);
/* MISCELLANEOUS */         misc86      = sum(soupb_s86, souph_s86, soupr_s86, mush_s86, fcock_s86, cuke_s86); *Other soups, mushrooms, other canned fruit, cucumber;
/* Mixed vegetables */      mixveg86    = sum(mixv_s86);
/* Non-dairy cof whit */    nondai86    = sum(cofwh_s86);
/* Nuts */                  othnut86    = sum(onut_s86);
/* Oil-based dress */       oildres86   = sum(oilv_s86); /* Only 1 items in 1986? */
/* Onions */                *Not collected in 1986;
/* Organ meats */           organ86     = sum(livb_s86, livc_s86);
/* Other cruciferous veg */ othveg86    = sum(cauli_s86, ccabb_s86, kale_s86, slaw_s86, kraut_s86); /* Cooked cabbage is another variable in 1986. Sauerkraut only in 1986 */
/* Other fruit juices */    othfrj86    = sum(othj_s86);
/* Other leafy veg */       othleaf86   = sum(ilett_s86, rlett_s86);
/* Other legumes */         othleg86    = sum(peas_s86, sbean_s86, bean_s86, alfsp_s86); /* I think alfalfa is only collected in 1986 */
/* Other nightshades */     othnite86   = sum(eggpl_s86, grpep_s86);
/* Packaged savory snacks */pksavsn86   = sum(pchip_s86);
/* Peanuts */               pnut86      = sum(pbut_s86, pnut_s86);
/* Pizza */                 pizza86     = sum(pizza_s86);
/* Pome fruits */           pome86      = sum(appl_s86, pear_s86, aj_s86, apsau_s86, cpear_s86);    /* Pear is its own category in 1986. Also has canned pears */
/* Potatoes */              potato86    = sum(pot_s86);
/* Poultry */               poultry86   = sum(chwi_s86, chwo_s86);
/* Processed red meat */    prmeat86    = sum(dog_s86, bacon_s86, procm_s86);
/* Prune family */          prune86     = sum(prune_s86, peach_s86, cpeac_s86); /* 1986 has canned peaches */
/* Refined grain prod */    rgrain86    = sum(engl_s86, muff_s86, pcake_s86, wrice_s86, pasta_s86, whbr_s86);
/* Soft and hard cheese */  shchee86    = sum(cotch_s86, crmch_s86, otch_s86);
/* Soy products */          soy86       = sum(tofu_s86);
/* Spinach */               spinach86   = sum(rspin_s86, cspin_s86);
/* Strawberries */          strawb86    = sum(straw_s86);
/* SSBs */                  ssb86       = sum(soda_s86, punch_s86); /* soda = carbonated beverage with sugar */
/* Tea */                   tea86       = sum(tea_s86);
/* Tomato products */       tomprod86   = sum(tom_s86, toj_s86, tosau_s86);
/* Whole grains */          wgrain86    = sum(oat_s86, dkbr_s86, bran_s86, wgerm_s86, brice_s86, popc_s86, ckcer_s86, otgrn_s86); /* Oat bran ? */
/* Whole milk */            whlmilk86   = sum(whole_s86);
/* Wine */                  wine86      = sum(rwine_s86, wwine_s86);
/* Yam or sweet potato */   yamswt86    = sum(yam_s86);
/* Yogurt */                yogurt86    = sum(yog_s86);
FI86 = -(blueb86 * -0.022359623 + shchee86 * -0.000357103 + dietbev86 * 0.037505123 + frmeat86 * 0.041039490 
     + grape86 * -0.005362665 + liq86 * 0.042291654 + lfmilk86 * -0.037611764 + organ86 * 0.039207711 
     + mixveg86 * 0.091345174 + oildres86 * 0.016648388 + tomprod86 * 0.022265025 + wine86 * 0.016825528);

run;

data serv86_cat;
set serv86_cat;

drop            tom_s86     toj_s86     tosau_s86   sbean_s86   peas_s86    
                brocc_s86   cauli_s86   slaw_s86    ccabb_s86   bruss_s86 
                rcar_s86    ccar_s86    corn_s86    mixv_s86    yam_s86 
                ysqua_s86   eggpl_s86   kale_s86    rspin_s86   cspin_s86 
                ilett_s86   rlett_s86   cel_s86     grpep_s86   cuke_s86 
                mush_s86    alfsp_s86   kraut_s86   rais_s86    prune_s86 
                ban_s86     cant_s86    avo_s86     appl_s86    pear_s86 
                aj_s86      apsau_s86   oran_s86    oj_s86      grfr_s86 
                grj_s86     straw_s86   blueb_s86   peach_s86   h2om_s86 
                cpeac_s86   cpear_s86   fcock_s86   othj_s86    tea_s86         
                dcaf_s86    coff_s86    soda_s86    local_s86   punch_s86 
                h2o_s86     beer_s86    rwine_s86   wwine_s86   liq_s86 
                tofu_s86    bean_s86    pbut_s86    pnut_s86    onut_s86 
                egg_s86     dog_s86     chwi_s86    chwo_s86    bacon_s86 
                procm_s86   hamb_s86    bmix_s86    bmain_s86   ctuna_s86 
                shrim_s86   dkfsh_s86   ofish_s86   livb_s86    livc_s86        
                skim_s86    whole_s86   cream_s86   cofwh_s86   sherb_s86       
                icecr_s86   but_s86     marg_s86    yog_s86     sour_s86        
                cotch_s86   crmch_s86   otch_s86    cer_s86     oat_s86         
                ckcer_s86   whbr_s86    dkbr_s86    crack_s86   engl_s86        
                muff_s86    pcake_s86   brice_s86   wrice_s86   pasta_s86       
                otgrn_s86   fries_s86   pot_s86     pchip_s86   pizza_s86       
                choco_s86   cdyw_s86    cdywo_s86   cokr_s86    cokh_s86        
                brwn_s86    donut_s86   cakh_s86    cakr_s86    pieh_s86        
                pier_s86    sroll_s86   jam_s86     popc_s86    bran_s86        
                wgerm_s86   chowd_s86   soupb_s86   souph_s86   soupr_s86       
                soysa_s86   chsau_s86   mayo_s86    peppr_s86   must_s86        
                oilv_s86    ;
run;


/**********************************************/
/******************** 1990 ********************/

%serv90 (keep = id 
                tom_s90     toj_s90     tosau_s90   sbean_s90   peas_s90        
                brocc_s90   cauli_s90   cabb_s90    bruss_s90   rcar_s90        
                ccar_s90    corn_s90    mixv_s90    yam_s90     osqua_s90       
                eggpl_s90   kale_s90    rspin_s90   cspin_s90   ilett_s90       
                rlett_s90   cel_s90     oniog_s90   oniov_s90   beet_s90        
                rais_s90    prune_s90   ban_s90     cant_s90    appl_s90        
                aj_s90      apsau_s90   oran_s90    oj_s90      grfr_s90        
                grj_s90     straw_s90   blueb_s90   peach_s90   h2om_s90        
                othj_s90    tea_s90     dcaf_s90    coff_s90    cola_s90        
                cnoc_s90    otsug_s90   lccaf_s90   lcnoc_s90   lcoth_s90       
                punch_s90   h2o_s90     beer_s90    rwine_s90   wwine_s90       
                liq_s90     tofu_s90    bean_s90    pbut_s90    pnut_s90        
                onut_s90    egg_s90     dog_s90     chwi_s90    chwo_s90        
                bacon_s90   procm_s90   hamb_s90    bmix_s90    pmain_s90       
                bmain_s90   ctuna_s90   shrim_s90   dkfsh_s90   ofish_s90       
                livb_s90    livc_s90    skim_s90    whole_s90   cream_s90       
                cofwh_s90   sherb_s90   icecr_s90   but_s90     marg_s90        
                yog_s90     sour_s90    cotch_s90   crmch_s90   otch_s90        
                cer_s90     oat_s90     ckcer_s90   whbr_s90    dkbr_s90        
                crack_s90   engl_s90    muff_s90    pcake_s90   brice_s90       
                wrice_s90   pasta_s90   otgrn_s90   fries_s90   pot_s90         
                pchip_s90   pizza_s90   choco_s90   cdyw_s90    cdywo_s90       
                cokr_s90    cokh_s90    brwn_s90    donut_s90   cakh_s90        
                cakr_s90    pieh_s90    pier_s90    srolh_s90   srolr_s90       
                jam_s90     popc_s90    oatbr_s90   bran_s90    wgerm_s90       
                chowd_s90   chsau_s90   mayo_s90    salt_s90    ooil_s90        
                oilv_s90 );




/*************************************************************************/
/************************ Constructing categories ************************/

data serv90_cat;
set serv90;

/* Avocados */              *Not collected in 1990;
/* Bananas */               banana90    = sum(ban_s90);
/* Beer */                  beer90      = sum(beer_s90);
/* Blueberries */           blueb90     = sum(blueb_s90);
/* Broccoli */              brocc90     = sum(brocc_s90);
/* Brussels sprouts */      bruss90     = sum(bruss_s90);
/* Candy */                 candy90     = sum(choco_s90, cdyw_s90, cdywo_s90);
/* Carrots */               carrot90    = sum(rcar_s90, ccar_s90);
/* Celery */                celery90    = sum(cel_s90);
/* Chowder or cream soup */ chowder90   = sum(chowd_s90);
/* Citrus fruits */         citrus90    = sum(oran_s90, grfr_s90, oj_s90, grj_s90);
/* Coffee */                coffee90    = sum(coff_s90, dcaf_s90);
/* Cold breakfast cereal */
/* Condiments */            condi90     = sum(jam_s90, chsau_s90);
/* Corn */                  corn90      = sum(corn_s90);
/* Crackers */              cracker90   = sum(crack_s90);
/* Dark orange squash */    dksqa90     = sum(osqua_s90);
/* Desserts */              dess90      = sum(cokr_s90, cokh_s90, brwn_s90, donut_s90, cakh_s90, cakr_s90, 
                                              pieh_s90, pier_s90, srolh_s90, srolr_s90);
/* Diet beverage */         dietbev90   = sum(lccaf_s90, lcnoc_s90, lcoth_s90);
/* Eggs */                  eggs90      = sum(egg_s90);
/* Fish and seafood */      fish90      = sum(ctuna_s90, shrim_s90, dkfsh_s90, ofish_s90);
/* French fries */          fries90     = sum(fries_s90);
/* Fresh red meat */        frmeat90    = sum(hamb_s90, bmix_s90, pmain_s90, bmain_s90); 
/* Grapes */                grape90     = sum(rais_s90); 
/* High-fat dairy */        hfdairy90   = sum(sour_s90, but_s90, cream_s90);
/* Liquor */                liq90       = sum(liq_s90);
/* Low-fat milk */          lfmilk90    = sum(skim_s90);
/* Margarine */             marg90      = sum(marg_s90);
/* Mayo or creamy dress */  mayo90      = sum(mayo_s90);
/* Melons */                melon90     = sum(cant_s90, h2om_s90); 
/* Milk-based frzn dess */  milkdes90   = sum(sherb_s90, icecr_s90);
/* MISCELLANEOUS */         *Mushrooms and other soup not collected in 1990;
/* Mixed vegetables */      mixveg90    = sum(mixv_s90);
/* Non-dairy cof whit */    nondai90    = sum(cofwh_s90); 
/* Nuts */                  othnut90    = sum(onut_s90);
/* Oil-based dress */       oildres90   = sum(ooil_s90, oilv_s90);
/* Onions */                onion90     = sum(oniog_s90, oniov_s90);
/* Organ meats */           organ90     = sum(livb_s90, livc_s90);
/* Other cruciferous veg */ othveg90    = sum(cauli_s90, cabb_s90, kale_s90);
/* Other fruit juices */    othfrj90    = sum(othj_s90);
/* Other leafy veg */       othleaf90   = sum(ilett_s90, rlett_s90);
/* Other legumes */         othleg90    = sum(peas_s90, sbean_s90, bean_s90);
/* Other nightshades */     othnite90   = sum(eggpl_s90);
/* Packaged savory snacks */pksavsn90   = sum(pchip_s90);
/* Peanuts */               pnut90      = sum(pbut_s90, pnut_s90);
/* Pizza */                 pizza90     = sum(pizza_s90);
/* Pome fruits */           pome90      = sum(appl_s90, apsau_s90, aj_s90); 
/* Potatoes */              potato90    = sum(pot_s90);
/* Poultry */               poultry90   = sum(chwi_s90, chwo_s90);
/* Processed red meat */    prmeat90    = sum(bacon_s90, dog_s90, procm_s90);
/* Prune family */          prune90     = sum(prune_s90, peach_s90);
/* Refined grain prod */    rgrain90    = sum(engl_s90, muff_s90, pcake_s90, wrice_s90, pasta_s90, whbr_s90);
/* Soft and hard cheese */  shchee90    = sum(cotch_s90, crmch_s90, otch_s90);
/* Soy products */          soy90       = sum(tofu_s90);
/* Spinach */               spinach90   = sum(rspin_s90, cspin_s90);
/* Strawberries */          strawb90    = sum(straw_s90);
/* SSBs */                  ssb90       = sum(cola_s90, cnoc_s90, otsug_s90, punch_s90);
/* Tea */                   tea90       = sum(tea_s90);
/* Tomato products */       tomprod90   = sum(tom_s90, toj_s90, tosau_s90);
/* Whole grains */          wgrain90    = sum(oat_s90, dkbr_s90, oatbr_s90, bran_s90, wgerm_s90, 
                                              brice_s90, popc_s90, ckcer_s90, otgrn_s90);
/* Whole milk */            whlmilk90   = sum(whole_s90);
/* Wine */                  wine90      = sum(rwine_s90, wwine_s90);
/* Yam or sweet potato */   yamswt90    = sum(yam_s90);
/* Yogurt */                yogurt90    = sum(yog_s90);
FI90 = -(blueb90 * -0.022359623 + shchee90 * -0.000357103 + dietbev90 * 0.037505123 + frmeat90 * 0.041039490 
     + grape90 * -0.005362665 + liq90 * 0.042291654 + lfmilk90 * -0.037611764 + organ90 * 0.039207711 
     + mixveg90 * 0.091345174 + oildres90 * 0.016648388 + tomprod90 * 0.022265025 + wine90 * 0.016825528);


run;

data serv90_cat;
set serv90_cat;
drop            tom_s90     toj_s90     tosau_s90   sbean_s90   peas_s90        
                brocc_s90   cauli_s90   cabb_s90    bruss_s90   rcar_s90        
                ccar_s90    corn_s90    mixv_s90    yam_s90     osqua_s90       
                eggpl_s90   kale_s90    rspin_s90   cspin_s90   ilett_s90       
                rlett_s90   cel_s90     oniog_s90   oniov_s90   beet_s90        
                rais_s90    prune_s90   ban_s90     cant_s90    appl_s90        
                aj_s90      apsau_s90   oran_s90    oj_s90      grfr_s90        
                grj_s90     straw_s90   blueb_s90   peach_s90   h2om_s90        
                othj_s90    tea_s90     dcaf_s90    coff_s90    cola_s90        
                cnoc_s90    otsug_s90   lccaf_s90   lcnoc_s90   lcoth_s90       
                punch_s90   h2o_s90     beer_s90    rwine_s90   wwine_s90       
                liq_s90     tofu_s90    bean_s90    pbut_s90    pnut_s90        
                onut_s90    egg_s90     dog_s90     chwi_s90    chwo_s90        
                bacon_s90   procm_s90   hamb_s90    bmix_s90    pmain_s90       
                bmain_s90   ctuna_s90   shrim_s90   dkfsh_s90   ofish_s90       
                livb_s90    livc_s90    skim_s90    whole_s90   cream_s90       
                cofwh_s90   sherb_s90   icecr_s90   but_s90     marg_s90        
                yog_s90     sour_s90    cotch_s90   crmch_s90   otch_s90        
                cer_s90     oat_s90     ckcer_s90   whbr_s90    dkbr_s90        
                crack_s90   engl_s90    muff_s90    pcake_s90   brice_s90       
                wrice_s90   pasta_s90   otgrn_s90   fries_s90   pot_s90         
                pchip_s90   pizza_s90   choco_s90   cdyw_s90    cdywo_s90       
                cokr_s90    cokh_s90    brwn_s90    donut_s90   cakh_s90        
                cakr_s90    pieh_s90    pier_s90    srolh_s90   srolr_s90       
                jam_s90     popc_s90    oatbr_s90   bran_s90    wgerm_s90       
                chowd_s90   chsau_s90   mayo_s90    salt_s90    ooil_s90        
                oilv_s90    ;
run;
  
%serv94 (keep = id 
                blueb_s94 cotch_s94 crmch_s94 otch_s94 lccaf_s94 lcnoc_s94 lcoth_s94  
                hamb_s94 bmix_s94 pmain_s94 bmain_s94 rais_s94 liq_s94 skim_s94 
                livb_s94 livc_s94 mixv_s94 ooil_s94 tom_s94 toj_s94 tosau_s94
                rwine_s94  wwine_s94)

data serv94_cat;
set serv94;

/* Blueberries */           blueb94     = sum(blueb_s94);
/* Tomato products */       tomprod94   = sum(tom_s94, toj_s94, tosau_s94);
/* Diet beverage */         dietbev94   = sum(lccaf_s94, lcnoc_s94, lcoth_s94);
/* Soft and hard cheese */  shchee94    = sum(cotch_s94, crmch_s94, otch_s94);
/* Fresh red meat */        frmeat94    = sum(hamb_s94, bmix_s94, pmain_s94, bmain_s94); 
/* Grapes */                grape94     = sum(rais_s94); 
/* Liquor */                liq94       = sum(liq_s94);
/* Low-fat milk */          lfmilk94    = sum(skim_s94);
/* Organ meats */           organ94     = sum(livb_s94, livc_s94);
/* Mixed vegetables */      mixveg94    = sum(mixv_s94);
/* Oil-based dress */       oildres94   = sum(ooil_s94);
/* Wine */                  wine94      = sum(rwine_s94, wwine_s94);
FI94 = -(blueb94 * -0.022359623 + shchee94 * -0.000357103 + dietbev94 * 0.037505123 + frmeat94 * 0.041039490 
     + grape94 * -0.005362665 + liq94 * 0.042291654 + lfmilk94 * -0.037611764 + organ94 * 0.039207711 
     + mixveg94 * 0.091345174 + oildres94 * 0.016648388 + tomprod94 * 0.022265025 + wine94 * 0.016825528);

run;


%serv98 (keep = id 
                blueb_s98 cotch_s98 crmch_s98 otch_s98 lccaf_s98 lcnoc_s98 lcoth_s98  
                hamb_s98 bmix_s98 pmain_s98 bmain_s98 rais_s98 liq_s98 skim_s98 
                livb_s98 livc_s98 mixv_s98 ooil_s98 tom_s98 toj_s98 tosau_s98
                rwine_s98  wwine_s98)

data serv98_cat;
set serv98;

/* Blueberries */           blueb98     = sum(blueb_s98);
/* Tomato products */       tomprod98   = sum(tom_s98, toj_s98, tosau_s98);
/* Diet beverage */         dietbev98   = sum(lccaf_s98, lcnoc_s98, lcoth_s98);
/* Soft and hard cheese */  shchee98    = sum(cotch_s98, crmch_s98, otch_s98);
/* Fresh red meat */        frmeat98    = sum(hamb_s98, bmix_s98, pmain_s98, bmain_s98); 
/* Grapes */                grape98     = sum(rais_s98); 
/* Liquor */                liq98       = sum(liq_s98);
/* Low-fat milk */          lfmilk98    = sum(skim_s98);
/* Organ meats */           organ98     = sum(livb_s98, livc_s98);
/* Mixed vegetables */      mixveg98    = sum(mixv_s98);
/* Oil-based dress */       oildres98   = sum(ooil_s98);
/* Wine */                  wine98      = sum(rwine_s98, wwine_s98);
FI98 = -(blueb98 * -0.022359623 + shchee98 * -0.000357103 + dietbev98 * 0.037505123 + frmeat98 * 0.041039490 
     + grape98 * -0.005362665 + liq98 * 0.042291654 + lfmilk98 * -0.037611764 + organ98 * 0.039207711 
     + mixveg98 * 0.091345174 + oildres98 * 0.016648388 + tomprod98 * 0.022265025 + wine98 * 0.016825528);

run;


%serv02 (keep = id 
                blueb_s02 cotch_s02 crmch_s02 otch_s02 lccaf_s02 lcnoc_s02   
                hamb_s02 bmix_s02 pmain_s02 bmain_s02 rais_s02 liq_s02 skim_s02 
                livb_s02 livc_s02 mixv_s02 ooil_s02 tom_s02 toj_s02 tosau_s02
                rwine_s02  wwine_s02)

data serv02_cat;
set serv02;

/* Blueberries */           blueb02     = sum(blueb_s02);
/* Tomato products */       tomprod02   = sum(tom_s02, toj_s02, tosau_s02);
/* Diet beverage */         dietbev02   = sum(lccaf_s02, lcnoc_s02);
/* Soft and hard cheese */  shchee02    = sum(cotch_s02, crmch_s02, otch_s02);
/* Fresh red meat */        frmeat02    = sum(hamb_s02, bmix_s02, pmain_s02, bmain_s02); 
/* Grapes */                grape02     = sum(rais_s02); 
/* Liquor */                liq02       = sum(liq_s02);
/* Low-fat milk */          lfmilk02    = sum(skim_s02);
/* Organ meats */           organ02     = sum(livb_s02, livc_s02);
/* Mixed vegetables */      mixveg02    = sum(mixv_s02);
/* Oil-based dress */       oildres02   = sum(ooil_s02);
/* Wine */                  wine02      = sum(rwine_s02, wwine_s02);
FI02 = -(blueb02 * -0.022359623 + shchee02 * -0.000357103 + dietbev02 * 0.037505123 + frmeat02 * 0.041039490 
     + grape02 * -0.005362665 + liq02 * 0.042291654 + lfmilk02 * -0.037611764 + organ02 * 0.039207711 
     + mixveg02 * 0.091345174 + oildres02 * 0.016648388 + tomprod02 * 0.022265025 + wine02 * 0.016825528);

run;

%serv06 (keep = id 
                blueb_s06 cotch_s06 crmch_s06 otch_s06 lccaf_s06 lcnoc_s06   
                hamb_s06 bmix_s06 pmain_s06 bmain_s06 rais_s06 liq_s06 skim_s06 
                livb_s06 livc_s06 mixv_s06 ooil_s06 tom_s06 toj_s06 tosau_s06
                rwine_s06  wwine_s06)

data serv06_cat;
set serv06;

/* Blueberries */           blueb06     = sum(blueb_s06);
/* Tomato products */       tomprod06   = sum(tom_s06, toj_s06, tosau_s06);
/* Diet beverage */         dietbev06   = sum(lccaf_s06, lcnoc_s06);
/* Soft and hard cheese */  shchee06    = sum(cotch_s06, crmch_s06, otch_s06);
/* Fresh red meat */        frmeat06    = sum(hamb_s06, bmix_s06, pmain_s06, bmain_s06); 
/* Grapes */                grape06     = sum(rais_s06); 
/* Liquor */                liq06       = sum(liq_s06);
/* Low-fat milk */          lfmilk06    = sum(skim_s06);
/* Organ meats */           organ06     = sum(livb_s06, livc_s06);
/* Mixed vegetables */      mixveg06    = sum(mixv_s06);
/* Oil-based dress */       oildres06   = sum(ooil_s06);
/* Wine */                  wine06      = sum(rwine_s06, wwine_s06);
FI06 = -(blueb06 * -0.022359623 + shchee06 * -0.000357103 + dietbev06 * 0.037505123 + frmeat06 * 0.041039490 
     + grape06 * -0.005362665 + liq06 * 0.042291654 + lfmilk06 * -0.037611764 + organ06 * 0.039207711 
     + mixveg06 * 0.091345174 + oildres06 * 0.016648388 + tomprod06 * 0.022265025 + wine06 * 0.016825528);

run;

%serv10 (keep = id 
                blueb_s10 cotch_s10 crmch_s10 otch_s10 lccaf_s10 lcnoc_s10   
                hamb_s10 bmix_s10 pmain_s10 bmain_s10 rais_s10 liq_s10 skim_s10 
                livb_s10 livc_s10 mixv_s10 ooil_s10 tom_s10 toj_s10 tosau_s10
                rwine_s10  wwine_s10)

data serv10_cat;
set serv10;

/* Blueberries */           blueb10     = sum(blueb_s10);
/* Tomato products */       tomprod10   = sum(tom_s10, toj_s10, tosau_s10);
/* Diet beverage */         dietbev10   = sum(lccaf_s10, lcnoc_s10);
/* Soft and hard cheese */  shchee10    = sum(cotch_s10, crmch_s10, otch_s10);
/* Fresh red meat */        frmeat10    = sum(hamb_s10, bmix_s10, pmain_s10, bmain_s10); 
/* Grapes */                grape10     = sum(rais_s10); 
/* Liquor */                liq10       = sum(liq_s10);
/* Low-fat milk */          lfmilk10    = sum(skim_s10);
/* Organ meats */           organ10     = sum(livb_s10, livc_s10);
/* Mixed vegetables */      mixveg10    = sum(mixv_s10);
/* Oil-based dress */       oildres10   = sum(ooil_s10);
/* Wine */                  wine10      = sum(rwine_s10, wwine_s10);
FI10 = -(blueb10 * -0.022359623 + shchee10 * -0.000357103 + dietbev10 * 0.037505123 + frmeat10 * 0.041039490 
     + grape10 * -0.005362665 + liq10 * 0.042291654 + lfmilk10 * -0.037611764 + organ10 * 0.039207711 
     + mixveg10 * 0.091345174 + oildres10 * 0.016648388 + tomprod10 * 0.022265025 + wine10 * 0.016825528);

run;


/***PPP, use %ahei2010_8420 instead*/

%ahei2010_8420;

   
    **************************************************
    *         database of BMI   & covariables        *
    **************************************************;

%der7620 (keep =  mobf                                      /*month of birth*/
                  yobf                                      /*year of birth*/

    irt76  irt78  irt80  irt82  irt84  irt86  irt88  irt90  irt92  irt94  
    irt96  irt98  irt00  irt02  irt04  irt06  irt08  irt10  irt12  irt14  irt16 

    bmi76   bmi78   bmi80   bmi82   bmi84   bmi86   bmi88   bmi90   bmi92   bmi94  
    bmi96   bmi98   bmi00   bmi02   bmi04   bmi06   bmi08   bmi10   bmi12   bmi14  bmi16 

    race9204/* 1.White; 2.Black; 3.American Indian; 4.Asian; 5.Hawaiian */  race  white

    smkdr76  smkdr78  smkdr80  smkdr82  smkdr84  smkdr86  smkdr88  smkdr90  smkdr92  smkdr94  
    smkdr96  smkdr98  smkdr00  smkdr02  smkdr04  smkdr06  smkdr08  smkdr10  smkdr12  smkdr14  smkdr16   
    
    dmnp76  dmnp78  dmnp80  dmnp82  dmnp84  dmnp86  dmnp88  dmnp90  dmnp92  dmnp94  
    dmnp96  dmnp98  dmnp00  dmnp02  dmnp04 


    nhor76  nhor78  nhor80  nhor82  nhor84  nhor86  nhor88  nhor90  nhor92  nhor94  
    nhor96  nhor98  nhor00  nhor02  nhor04  nhor06  nhor08  nhor10  nhor12  nhor14  nhor16 
  
    can76  can78  can80  can82  can84  can86  can88  can90  can92  can94  
    can96  can98  can00  can02  can04  can06  can08  can10  can12   can14  can16 

    hrt76  hrt78  hrt80  hrt82  hrt84  hrt86  hrt88  hrt90  hrt92  hrt94  
    hrt96  hrt98  hrt00  hrt02  hrt04  hrt06  hrt08  hrt10  hrt12  hrt14  hrt16 
    ocu76   ocu78   ocu80   ocu82   ocu84                                                                                                                                /*ORAL CONTRACEPTIVE USE*/
    pkyr76  pkyr78  pkyr80  pkyr82  pkyr84  pkyr86  pkyr88  pkyr90  pkyr92  pkyr94  
    pkyr96  pkyr98  pkyr00  pkyr02  pkyr04  pkyr06  pkyr08  pkyr10  pkyr12  pkyr14   pkyr16    /*pack years smoked*/
    );


  /***Race***/
    
    if race9204=1 then white=1; else white=0; 
    race=race9204; 
    proc sort; by id; run;  


      %supp8016(keep=id
                      mvitu84
                      mvitu86
                      mvitu88
                      mvitu90
                      mvitu92
                      mvitu94
                      mvitu96
                      mvitu98
                      mvitu00
                      mvitu02
                      mvitu04
                      mvitu06
                      mvitu08
                      mvitu10
                      mvitu12
                      mvitu14
                      mvitu16);

    data vitamin; /* Setting up data on multivatimin use */
    set supp8016;
    run;
    proc sort; by id; run;
    proc datasets; delete supp8016; run;


    /**********READING IN  DATA ON ASPIRIN USE AND USE OF NON-STEROIDAL-INFLAMMATORY DRUGS (NSAID)**********/
    %meds8016(keep=id
    aspu80 aspu82 aspu84 aspu86 aspu88 aspu90 aspu92 aspu94 aspu96 aspu98 aspu00 aspu02 aspu04 aspu06 aspu08 aspu10 aspu12 aspu14 aspu16
    nsaiu90 nsaiu92 nsaiu94 nsaiu96 nsaiu98 nsaiu00 nsaiu02 nsaiu04 nsaiu06 nsaiu08 nsaiu10 nsaiu12 nsaiu14 nsaiu16
    );
    data meds; /* Data set 6, setting up data on aspirin use and NSAID use */
    set meds8016;
    run;
    proc sort; by id; run;
    proc datasets; delete meds8016; run;

    %n80_nts(keep=calor80n alco80n  sat80n    mon80n   poly80n );  proc sort; by id; run;  
    %n84_nts(keep=calor84n alco84n  tfat84n sat84n  mon84n  poly84n prot84n carbo84n  afat84n vfat84n);  proc sort; by id; run; 
    %n86_nts(keep=calor86n alco86n  tfat86n sat86n  mon86n  poly86n prot86n carbo86n  afat86n vfat86n);  proc sort; by id; run;
    %n90_nts(keep=calor90n alco90n  tfat90n sat90n  mon90n  poly90n prot90n carbo90n  afat90n vfat90n);  proc sort; by id; run;
    %n94_nts(keep=calor94n alco94n  tfat94n sat94n  mon94n  poly94n prot94n carbo94n  afat94n vfat94n);  proc sort; by id; run;
    %n98_nts(keep=calor98n alco98n  tfat98n sat98n  mon98n  poly98n prot98n carbo98n  afat98n vfat98n);  proc sort; by id; run;
    %n02_nts(keep=calor02n alco02n  tfat02n sat02n  mon02n  poly02n prot02n carbo02n  afat02n vfat02n);  proc sort; by id; run;
    %n06_nts(keep=calor06n alco06n  tfat06n sat06n  mon06n  poly06n prot06n carbo06n  afat06n vfat06n);  proc sort; by id; run;
    %n10_nts(keep=calor10n alco10n  tfat10n sat10n  mon10n  poly10n prot10n carbo10n  afat10n vfat10n);  proc sort; by id; run;


/********************************************************************************************************************************************************************************/
%n767880(keep= q80  wt18   ht76  wt76  wt78  wt80 
        str76    str78    str80  hbp76 hbp78 hbp80   
        chol76   chol78   chol80 db76  db78  db80 
        mmi76    ammi76   fmi76  afmi76 
        cabg76   cabg78   cabg80 menarche
        mi76  mi78  mi80 ang76 ang78 ang80);
        str76 =0; str78 =0; str80=0; * no this info assum as 0 for now;    
        cabg76=0; cabg78=0; cabg80=0; * no this info assum as 0 for now;    
proc sort; by id; run;
/********************************************************************************************************************************************************************************/
%nur82(keep= db82 mi82 ang82 str82 chol82 hbp82 fdb82 mdb82 sdb82 bdb82 wt82 bowel82 lax82 cabg82 thiaz82);
cabg82=0;
proc sort; by id; run;

/********************************************************************************************************************************************************************************/
%nur84(keep=  db84 mi84 ang84 cabg84 str84 chol84 hbp84 wt84 gout84 );
    array correct db84 mi84 ang84 cabg84 str84 chol84 hbp84 gout84;
    do over correct;
        correct=correct-1;end;
run;

/********************************************************************************************************************************************************************************/        
%nur86(keep=db86 mi86 ang86 cabg86 str86 chol86 hbp86 wt86 );

/********************************************************************************************************************************************************************************/
%nur88(keep=db88 mi88 ang88 cabg88 str88 chol88 hbp88 fdb88 sdb88 mdb88 bdb88  wt88 men1888 thiaz88);

/********************************************************************************************************************************************************************************/
%nur90(keep=db90 mi90 ang90 cabg90 str90 chol90 hbp90 wt90);

/********************************************************************************************************************************************************************************/
%nur92(keep=db92 mi92 ang92 cabg92 str92 fdb92 sdb92 mdb92 chol92 hbp92 wt92);

/********************************************************************************************************************************************************************************/
%nur94(keep=db94 mi94 ang94 cabg94 str94 wt94 thiaz94 lasix94);

/********************************************************************************************************************************************************************************/
%nur96(keep=db96 mi96 ang96 cabg96 str96 chol96 hbp96 wt96 thiaz96 );

/********************************************************************************************************************************************************************************/
%nur98(keep=db98 mi98 ang98 cabg98 str98 chol98 hbp98 wt98 thiaz98 lasix98);

/********************************************************************************************************************************************************************************/
%nur00(keep=db00 mi00 ang00 cabg00 str00 chol00 hbp00 wt00 thiaz00 lasix00);     

/********************************************************************************************************************************************************************************/
%nur02(keep=db02 mi02 ang02 cabg02 str02 chol02 hbp02 wt02 thiaz02 lasix02 );

/********************************************************************************************************************************************************************************/
%nur04(keep=db04 mi04 ang04 cabg04 str04 chol04 hbp04 wt04 thiaz04 lasix04);

/********************************************************************************************************************************************************************************/
%nur06(keep=db06 mi06 ang06 cabg06 str06 chol06 hbp06 wt06 thiaz06 lasix06);

/********************************************************************************************************************************************************************************/
%nur08(keep=db08 mi08 ang08 cabg08 str08 chol08 hbp08 wt08 thiaz08 );

/*****************xs**************************************************************************************************************************************************************/
%nur10(keep=db10 mi10 ang10 cabg10 str10 chol10 hbp10 wt10);

/********************************************************************************************************************************************************************************/
%nur12(keep=db12 mi12 ang12 cabg12 str12 chol12 hbp12 wt12);

/********************************************************************************************************************************************************************************/
%nur14(keep=db14 mi14 ang14 cabg14 str14 chol14 hbp14 wt14);

/********************************************************************************************************************************************************************************/
%nur16(keep=db16 mi16 ang16 cabg16 str16 chol16 hbp16 wt16);

/********************************************************************************************************************************************************************************/
/********************************************************************************************************************************************************************************/


/** Physical activity measurement --- METs/week **/
 %act8614(keep= act86m  act88m  act92m  act94m  act96m
                act98m  act00m  act04m  act08m  act10m
                actc86  actc88  actc92  actc94  actc96  actc98
                actc00m actc00  actc04m actc04  actc08m actc08
                walk10m  rujog10m  biksw10m actc10 act10m);

             if walk10m  ge 998 then walk10m=.;
        else if rujog10m ge 998 then rujog10m=.;
        else if biksw10m ge 998 then biksw10m=.;

act10m=sum(walk10m,rujog10m,biksw10m);

  if act10m lt 3 then actc10=1;
  else if 3  le act10m lt 9  then actc10=2;
  else if 9  le act10m lt 18 then actc10=3;
  else if 18 le act10m lt 27 then actc10=4;
  else if 27 le act10m       then actc10=5;
  else if act10m=.           then actc10=6;

    actc00=actc00m;
    actc04=actc04m;
    actc08=actc08m;

array act{10}  actc86 actc88 actc92 actc94 actc96
               actc98 actc00 actc04 actc08 actc10;

array actm{10} act86m act88m act92m act94m act96m
               act98m act00m act04m act08m act10m;

    do i=1 to 10;
        if act{i}>=6 then act{i}=6;
        if actm{i} >997 then actm{i}=.;
    end;
 /* carry forward missing */
    do i=2 to 10;
        if act{i}=.  then act{i}=act{i-1};
        if actm{i}=. then actm{i}=actm{i-1};
    end;
    run;

**************************************************
    *           Family hostory of diseases           *
    **************************************************;
    /*** read family history of diabetes ***/
    %nur82(keep=id fdb82 sdb82 mdb82 bdb82 dbfh82);
       if fdb82=1 or mdb82=1 or sdb82=1 or bdb82=1 then dbfh82=1;
       else dbfh82=0;
       run;
       

    /*** read family history of diabetes ***/
    %nur88(keep= id fdb88 sdb88 mdb88 bdb88 dbfh88);
       if fdb88=1 or mdb88=1 or sdb88=1 or bdb88=1 then dbfh88=1;
       else dbfh88=0;
       run;
         
    /*** read family history of diabetes * hypertension ***/ 
    %nur92(keep= id fdb92 sdb92 mdb92 dbfh92 fhbp92 shbp92 mhbp92 hbpfh92);
       if fdb92=1 or mdb92=1 or sdb92=1 then dbfh92=1; 
       else dbfh92=0; 
       if fhbp92=1 or mhbp92=1 or shbp92=1 then hbpfh92=1;
       else hbpfh92=0;

    /*** read family history of MI (parents)***/

    %n767880(keep=  id mmi76 fmi76 ammi76 afmi76
          mothmi76 fathmi76 mifh76);      
      if mmi76=1 and ammi76<=60 then mothmi76=1;
      if fmi76=1 and afmi76<=60 then fathmi76=1;     
      if mothmi76=1 or fathmi76=1 then mifh76=1; else mifh76=0;

   %nur84(keep= id mmi84 ammi84 fmi84 afmi84  mothmi84 fathmi84 mifh84);
      if mmi84=2 and  1<=ammi84<=2 then mothmi84=1;
      if fmi84=2 and  1<=afmi84<=2 then fathmi84=1;     
      if mothmi84=1 or fathmi84=1 then mifh84=1; else mifh84=0;

    /*** read family history of MI & stroke (brother/sister)***/
   %nur96(keep= id brmi96 brmid96 smi96 smid96 mifh96 bstr96 bstrd96 sstr96 sstrd96 strfh96);
      if (brmi96=1 and brmid96 in (1,2)) or (smi96=1 and smid96 in (1,2)) then mifh96=1; else mifh96=0;
      if (bstr96=1 and bstrd96 in (1,2)) or (sstr96=1 and sstrd96 in (1,2)) then strfh96=1; else strfh96=0;

    /*** read family history of MI & stroke (brother/sister/offspring-MI///parents/sibling for stroke)***/
   %nur08(keep= id brmi08 brmid08 smi08 smid08 omi08 omid08 mifh08 mstr08 mstrd08 fstr08 fstrd08 sstr08 sstrd08 strfh08);
      if (brmi08=1 and brmid08 in (1,2)) or (smi08=1 and smid08 in (1,2)) or (omi08=1 and omid08 in (1,2)) then mifh08=1; else mifh08=0;
      if (mstr08=1 and mstrd08 in (1,2)) or (fstr08=1 and fstrd08 in (1,2)) or (sstr08=1 and sstrd08 in (1,2)) then strfh08=1; else strfh08=0;

   data familyhis;
      merge  n767880 nur82 nur84 nur88 nur92 nur96 nur08;
      by id;
      dbfh=0; if dbfh82=1 or dbfh88=1 or dbfh92=1 then dbfh=1; 
      mifh=0; if mifh76=1 or mifh84=1 or mifh96 or mifh08=1   then mifh=1; 
      strfh=0; if strfh96=1 or strfh08=1          then strfh=1; 
      keep id dbfh mifh strfh dbfh82 mifh76;

      proc sort; by id; run;



                              ********************
                              *      database    *
                              ********************;

    data xwang;
    merge diabetes disease_1 dead ahei2010_8420 familyhis htncasef
          der7620(in=a)  n80_nts n84_nts n86_nts n90_nts n94_nts  n98_nts  n02_nts  n06_nts n10_nts          
          serv84_cat serv86_cat serv90_cat serv94_cat serv98_cat serv02_cat serv06_cat serv10_cat
          n767880 nur82 nur84 nur86 nur88  nur90 nur92 nur94 nur96 nur98 nur00 nur02 nur04 nur06 nur08 nur10
          vitamin meds
          act8614;  
     by id;
     if a;
run;

/* assign score based on rank */

%macro rank(var);

proc sql;
   select distinct(&var) into :&var._0 - 
   from xwang;
quit;

data xwang;
set xwang;

if &&&var._1=0 then do; 
/* Positive score*/
  &var.i=&var+1;

/* Reverse score*/
  if &var=0 then &var.ir=5;
  else if &var=1 then &var.ir=4;
  else if &var=2 then &var.ir=3;
  else if &var=3 then &var.ir=2;
  else if &var=4 then &var.ir=1;

end;

else if &&&var._1=1 then do;
/* Positive score*/
  if &var=1 then &var.i=1;
  else &var.i=&var+1;

/* Reverse score*/
  if &var=1 then &var.ir=5;
  else if &var=2 then &var.ir=3;
  else if &var=3 then &var.ir=2;
  else if &var=4 then &var.ir=1;
end;

proc freq;table &var.i;run;
proc freq;table &var.ir;run;
%mend;


proc rank data=xwang groups=5 out=xwang;
var    
blueb84 shchee84 dietbev84 frmeat84 grape84 liq84 lfmilk84 organ84 mixveg84 oildres84 tomprod84 wine84
blueb86 shchee86 dietbev86 frmeat86 grape86 liq86 lfmilk86 organ86 mixveg86 oildres86 tomprod86 wine86
blueb90 shchee90 dietbev90 frmeat90 grape90 liq90 lfmilk90 organ90 mixveg90 oildres90 tomprod90 wine90
blueb94 shchee94 dietbev94 frmeat94 grape94 liq94 lfmilk94 organ94 mixveg94 oildres94 tomprod94 wine94
blueb98 shchee98 dietbev98 frmeat98 grape98 liq98 lfmilk98 organ98 mixveg98 oildres98 tomprod98 wine98
blueb02 shchee02 dietbev02 frmeat02 grape02 liq02 lfmilk02 organ02 mixveg02 oildres02 tomprod02 wine02
blueb06 shchee06 dietbev06 frmeat06 grape06 liq06 lfmilk06 organ06 mixveg06 oildres06 tomprod06 wine06
blueb10 shchee10 dietbev10 frmeat10 grape10 liq10 lfmilk10 organ10 mixveg10 oildres10 tomprod10 wine10
;
ranks  
blueb84q shchee84q dietbev84q frmeat84q grape84q liq84q lfmilk84q organ84q mixveg84q oildres84q tomprod84q wine84q
blueb86q shchee86q dietbev86q frmeat86q grape86q liq86q lfmilk86q organ86q mixveg86q oildres86q tomprod86q wine86q
blueb90q shchee90q dietbev90q frmeat90q grape90q liq90q lfmilk90q organ90q mixveg90q oildres90q tomprod90q wine90q
blueb94q shchee94q dietbev94q frmeat94q grape94q liq94q lfmilk94q organ94q mixveg94q oildres94q tomprod94q wine94q
blueb98q shchee98q dietbev98q frmeat98q grape98q liq98q lfmilk98q organ98q mixveg98q oildres98q tomprod98q wine98q
blueb02q shchee02q dietbev02q frmeat02q grape02q liq02q lfmilk02q organ02q mixveg02q oildres02q tomprod02q wine02q
blueb06q shchee06q dietbev06q frmeat06q grape06q liq06q lfmilk06q organ06q mixveg06q oildres06q tomprod06q wine06q
blueb10q shchee10q dietbev10q frmeat10q grape10q liq10q lfmilk10q organ10q mixveg10q oildres10q tomprod10q wine10q;
run;


%rank(blueb84q);
%rank(shchee84q);
%rank(dietbev84q);
%rank(frmeat84q);
%rank(grape84q);
%rank(liq84q);
%rank(lfmilk84q);
%rank(organ84q);
%rank(mixveg84q);
%rank(oildres84q);
%rank(tomprod84q);
%rank(wine84q);

%rank(blueb86q);
%rank(shchee86q);
%rank(dietbev86q);
%rank(frmeat86q);
%rank(grape86q);
%rank(liq86q);
%rank(lfmilk86q);
%rank(organ86q);
%rank(mixveg86q);
%rank(oildres86q);
%rank(tomprod86q);
%rank(wine86q);

%rank(blueb90q);
%rank(shchee90q);
%rank(dietbev90q);
%rank(frmeat90q);
%rank(grape90q);
%rank(liq90q);
%rank(lfmilk90q);
%rank(organ90q);
%rank(mixveg90q);
%rank(oildres90q);
%rank(tomprod90q);
%rank(wine90q);

%rank(blueb94q);
%rank(shchee94q);
%rank(dietbev94q);
%rank(frmeat94q);
%rank(grape94q);
%rank(liq94q);
%rank(lfmilk94q);
%rank(organ94q);
%rank(mixveg94q);
%rank(oildres94q);
%rank(tomprod94q);
%rank(wine94q);

%rank(blueb98q);
%rank(shchee98q);
%rank(dietbev98q);
%rank(frmeat98q);
%rank(grape98q);
%rank(liq98q);
%rank(lfmilk98q);
%rank(organ98q);
%rank(mixveg98q);
%rank(oildres98q);
%rank(tomprod98q);
%rank(wine98q);

%rank(blueb02q);
%rank(shchee02q);
%rank(dietbev02q);
%rank(frmeat02q);
%rank(grape02q);
%rank(liq02q);
%rank(lfmilk02q);
%rank(organ02q);
%rank(mixveg02q);
%rank(oildres02q);
%rank(tomprod02q);
%rank(wine02q);

%rank(blueb06q);
%rank(shchee06q);
%rank(dietbev06q);
%rank(frmeat06q);
%rank(grape06q);
%rank(liq06q);
%rank(lfmilk06q);
%rank(organ06q);
%rank(mixveg06q);
%rank(oildres06q);
%rank(tomprod06q);
%rank(wine06q);

%rank(blueb10q);
%rank(shchee10q);
%rank(dietbev10q);
%rank(frmeat10q);
%rank(grape10q);
%rank(liq10q);
%rank(lfmilk10q);
%rank(organ10q);
%rank(mixveg10q);
%rank(oildres10q);
%rank(tomprod10q);
%rank(wine10q);

data xwang;
    set xwang;
FI84r = blueb84qi + shchee84qi + dietbev84qir + frmeat84qir + grape84qi + liq84qir 
      + lfmilk84qi + organ84qir + mixveg84qir + oildres84qir + tomprod84qir + wine84qir;

FI86r = blueb86qi + shchee86qi + dietbev86qir + frmeat86qir + grape86qi + liq86qir 
      + lfmilk86qi + organ86qir + mixveg86qir + oildres86qir + tomprod86qir + wine86qir;

FI90r = blueb90qi + shchee90qi + dietbev90qir + frmeat90qir + grape90qi + liq90qir 
      + lfmilk90qi + organ90qir + mixveg90qir + oildres90qir + tomprod90qir + wine90qir;

FI94r = blueb94qi + shchee94qi + dietbev94qir + frmeat94qir + grape94qi + liq94qir 
      + lfmilk94qi + organ94qir + mixveg94qir + oildres94qir + tomprod94qir + wine94qir;

FI98r = blueb98qi + shchee98qi + dietbev98qir + frmeat98qir + grape98qi + liq98qir 
      + lfmilk98qi + organ98qir + mixveg98qir + oildres98qir + tomprod98qir + wine98qir;

FI02r = blueb02qi + shchee02qi + dietbev02qir + frmeat02qir + grape02qi + liq02qir 
      + lfmilk02qi + organ02qir + mixveg02qir + oildres02qir + tomprod02qir + wine02qir;

FI06r = blueb06qi + shchee06qi + dietbev06qir + frmeat06qir + grape06qi + liq06qir 
      + lfmilk06qi + organ06qir + mixveg06qir + oildres06qir + tomprod06qir + wine06qir;

FI10r = blueb10qi + shchee10qi + dietbev10qir + frmeat10qir + grape10qi + liq10qir 
      + lfmilk10qi + organ10qir + mixveg10qir + oildres10qir + tomprod10qir + wine10qir;
    run;


   data xwang;
   set xwang end=_end_; 

     *make intermediate outcomes cumulative varibles: i.e. once cancer, always cancer;
    array cance {21} can76  can78  can80  can82  can84
                   can86  can88  can90  can92  can94
                   can96  can98  can00  can02  can04
                   can06  can08  can10  can12  can14 can16;
    array hrt   {21} hrt76  hrt78  hrt80  hrt82  hrt84
                   hrt86  hrt88  hrt90  hrt92  hrt94
                   hrt96  hrt98  hrt00  hrt02  hrt04
                   hrt06  hrt08  hrt10  hrt12  hrt14 hrt16;
    array ang   {21} ang76  ang78  ang80  ang82  ang84
                   ang86  ang88  ang90  ang92  ang94
                   ang96  ang98  ang00  ang02  ang04
                   ang06  ang08  ang10  ang12  ang14 ang16;
    array minf  {21} mi76  mi78  mi80  mi82  mi84
                   mi86  mi88  mi90  mi92  mi94
                   mi96  mi98  mi00  mi02  mi04
                   mi06  mi08  mi10  mi12  mi14  mi16;
    array hbp   {21} hbp76 hbp78 hbp80 hbp82 hbp84
                   hbp86 hbp88 hbp90 hbp92 hbp94
                   hbp96 hbp98 hbp00 hbp02 hbp04
                   hbp06 hbp08 hbp10 hbp12 hbp14 hbp16;
    array chol  {21} chol76  chol78  chol80  chol82  chol84
                   chol86  chol88  chol90  chol92  chol94
                   chol96  chol98  chol00  chol02  chol04
                   chol06  chol08  chol10  chol12  chol14  chol16;
    array diab  {21} db76  db78  db80  db82  db84
                   db86  db88  db90  db92  db94
                   db96  db98  db00  db02  db04
                   db06  db08  db10  db12  db14  db16;

    array strok {21} str76 str78  str80 str82 str84
                   str86 str88 str90 str92 str94
                   str96 str98 str00 str02 str04
                   str06 str08 str10 str12 str14 str16;
    array cabgf {21}  cabg76 cabg78 cabg80 cabg82 cabg84
                   cabg86 cabg88 cabg90 cabg92 cabg94
                   cabg96 cabg98 cabg00 cabg02 cabg04
                   cabg06 cabg08 cabg10 cabg12 cabg14 cabg16;
        do i=1 to 21;
        if hrt{i} in (1,3) then minf{i} = 1;
        if hrt{i} in (2,3) then ang {i} = 1;
    end;

    do i=2 to 21;
        if cance {i-1} = 1   then cance {i} = 1;
        if hrt {i-1} = 1   then hrt {i} = 1;
        if ang {i-1} = 1   then ang {i} = 1;
        if hbp {i-1} = 1   then hbp {i} = 1;
        if cabgf  {i-1} = 1 then cabgf  {i} = 1;
        if minf  {i-1} = 1   then minf  {i} = 1;
        if strok{i-1} = 1 then strok{i} = 1;
        if chol{i-1} = 1   then chol{i} = 1;
        if diab  {i-1} = 1   then diab  {i} = 1; 

    end;

    do i=1 to 21;
        if cance {i} ne 1   then cance {i} = 0;
        if ang {i} ne 1   then ang {i} = 0;
        if hbp {i} ne 1   then hbp {i} = 0;
        if strok{i} ne 1 then strok{i} = 0;
        if cabgf  {i} ne 1 then cabgf  {i} = 0;
        if minf  {i} ne 1   then minf  {i} = 0;
        if chol{i} ne 1   then chol{i} = 0;
        if diab  {i} ne 1   then diab  {i} = 0; 
    end;

    do i=2 to 21;
        if strok{i} ne 1 then strok{i} = 0;
    end;

     /*updated and stop updated components of UPFPDI*/
array   energy  {8} calor84n calor86n calor90n calor94n calor98n calor02n calor06n calor10n;
array   ahei    {8} ahei2010_84 ahei2010_86 ahei2010_90 ahei2010_94 ahei2010_98 ahei2010_02 ahei2010_06 ahei2010_10;
array   FIm     {8} FI84    FI86    FI90   FI94   FI98    FI02   FI06   FI10  ;
array   FImr    {8} FI84r    FI86r    FI90r   FI94r   FI98r    FI02r   FI06r   FI10r  ;
array   cancee  {8} can84   can86   can90   can94   can98  can02   can06   can10;
array   hrtt    {8} hrt84   hrt86   hrt90   hrt94   hrt98  hrt02   hrt06   hrt10;
array   diabb   {8} db84    db86    db90    db94    db98   db02    db06    db10;
array   strokk  {8} str84   str86   str90   str94   str98  str02   str06   str10;
array   cabgff  {8} cabg84  cabg86  cabg90  cabg94  cabg98 cabg02  cabg06  cabg10;
  
do i=2 to DIM(energy);
       

if energy{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1  then energy{i}=energy{i-1};
if ahei{i}=. or  cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1  then ahei{i}=ahei{i-1};
if FIm{i}=.  or  cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1  then FIm{i}=FIm{i-1};
if FImr{i}=.  or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1  then FImr{i}=FImr{i-1};
end;                                                                                    


/*calculate cumulative average**/
%macro cumavg (cycle=, cyclevar=, varin=, varout=);
*options symbolgen mprint mlogic;
%put CUMAVG MACRO  maintained by Lisa Li;
  array in{&cycle, &cyclevar} &varin;; 
  array out{&cycle,&cyclevar} &varout;;
   do j=1 to &cyclevar;
      out{1,j}=in{1,j};      
      do i=2 to &cycle;
   sumvar=0;
   n=0;
         do k=1 to i;
            if (in{k,j} ne .)  then do;
      n=n+1; sumvar=sumvar+in{k,j};
      end;
     end;
  if n=0 then out{i,j}=in{1,j}; 
  else out{i,j}=sumvar/n;
  end;
   end;
   drop i j k sumvar n;
%mend cumavg;

%cumavg(cycle=8, cyclevar=2,  
  varin=           
    FI84 FI84r
    FI86 FI86r
    FI90 FI90r
    FI94 FI94r
    FI98 FI98r
    FI02 FI02r
    FI06 FI06r
    FI10 FI10r, 

  varout=      
    FI84v FI84vr
    FI86v FI86vr
    FI90v FI90vr
    FI94v FI94vr
    FI98v FI98vr
    FI02v FI02vr
    FI06v FI06vr
    FI10v FI10vr);
run;



data xwang;
set xwang;
%cumavg(cycle=8, cyclevar=3,
  varin= 
          calor84n  alco84n ahei2010_84
          calor86n  alco86n ahei2010_86
          calor90n  alco90n ahei2010_90
          calor94n  alco94n ahei2010_94
          calor98n  alco98n ahei2010_98
          calor02n  alco02n ahei2010_02
          calor06n  alco06n ahei2010_06
          calor10n  alco10n ahei2010_10,
        
  varout=
          calor84nv alco84v ahei84_av
          calor86nv alco86v ahei86_av
          calor90nv alco90v ahei90_av
          calor94nv alco94v ahei94_av
          calor98nv alco98v ahei98_av
          calor02nv alco02v ahei02_av
          calor06nv alco06v ahei06_av
          calor10nv alco10v ahei10_av);

run;

  proc rank data=xwang out=quintile group=5;
            var  calor84nv  calor86nv   calor90nv   calor94nv   calor98nv   calor02nv   calor06nv   calor10nv
                 FI84v   FI86v   FI90v   FI94v   FI98v   FI02v   FI06v   FI10v
                 FI84vr   FI86vr  FI90vr   FI94vr   FI98vr   FI02vr   FI06vr   FI10vr
                 ahei84_av ahei86_av ahei90_av ahei94_av ahei98_av ahei02_av ahei06_av ahei10_av;
            ranks calor84q calor86q  calor90q   calor94q   calor98q   calor02q   calor06q   calor10q
              FI84q  FI86q   FI90q   FI94q   FI98q   FI02q   FI06q   FI10q
               FI84qr  FI86qr   FI90qr   FI94qr   FI98qr   FI02qr   FI06qr   FI10qr
              ahei84q ahei86q ahei90q ahei94q ahei98q ahei02q ahei06q ahei10q;

run;

    data quintile;
    set  quintile end=_end_;

    /*** Set up bsaeline variables ***/

    if can76=1 or can78=1 or can80=1 or can82=1 or can84=1 then canbase=1; else canbase=0;
    label canbase='baseline cancer'; 
    if can76=1 or can78=1 or can80=1 or can82=1 or can84=1 then can84=1; else can84=0;

    if db76=1 or db78=1 or db80=1 or db82=1 or db84=1 then dbbase=1; else dbbase=0;
    label dbbase='baseline diabetes'; 
    if db76=1 or db78=1 or db80=1 or db82=1 or db84=1 then db84=1; else db84=0;

    if mi76=1 or mi78=1 or mi80=1 or mi82=1 or mi84=1 then mibase=1; else mibase=0;
    label mibase='baseline MI'; 
    if mi76=1 or mi78=1 or mi80=1 or mi82=1 or mi84=1 then mi84=1; else mi84=0;

    if ang76=1 or ang78=1 or ang80=1 or ang82=1 or ang84=1 then angbase=1; else angbase=0;
    label angbase='baseline ANGINA'; 
    if ang76=1 or ang78=1 or ang80=1 or ang82=1 or ang84=1 then ang84=1; else ang84=0;

    if 1<=hrt76<=3 or 1<=hrt78<=3 or 1<=hrt80<=3 or 1<=hrt82<=3 or 1<=hrt84<=3 then hrtbase=1; else hrtbase=0;   
    label hrtbase='baseline heart disease';  /* 1.mi; 2.angina; 3.both mi and angina */
    if 1<=hrt76<=3 or 1<=hrt78<=3 or 1<=hrt80<=3 or 1<=hrt82<=3 or 1<=hrt84<=3 then hrt84=1; else hrt84=0;   

    if str82=1 or str84=1 then strbase=1; else strbase=0;
    label strbase='baseline stroke'; 
    if str82=1 or str84=1 then str84=1; else str84=0;

    if cabg84=1 then cabgbase=1; else cabgbase=0;
    label cabgbase='baseline cabg'; 

    if hbp76=1 or hbp78=1 or hbp80=1 or hbp82=1 or hbp84=1 then hbp84=1; else hbp84=0;         /* set hbp84*/
    if chol76=1 or chol78=1 or chol80=1 or chol82=1 or chol84=1 then chol84=1; else chol84=0;  /* set chol84*/

run;


PROC DATASETS;
delete    diabetes disease_1 dead ahei2010_8420 serv84_cat serv86_cat serv90_cat serv94_cat serv98_cat serv02_cat serv06_cat serv10_cat
          n80_nts n84_nts n86_nts n90_nts n94_nts  n98_nts  n02_nts  n06_nts n10_nts familyhis
          der7620 n767880 nur82 nur84 nur86 nur88 nur90 nur92 nur94 nur96 nur98 nur00 nur02 nur04 nur06 nur08 nur10 nur12 nur14 nur16 
          meds vitamin act8614;
      RUN;



  data nhs1hei;
  set quintile end=_end_; 
*include lasix use with thiaz use;

  * if lasix94=1 then thiaz94=1;
  * if lasix96=1 then thiaz96=1;
  * if lasix98=1 then thiaz98=1;
  * if lasix00=1 then thiaz00=1;
  * if lasix02=1 then thiaz02=1;
  * if lasix04=1 then thiaz04=1;
  * if lasix06=1 then thiaz06=1;
  * if lasix08=1 then thiaz08=1;

array   irt     {18}    irt84   irt86   irt88   irt90   irt92   irt94   irt96   irt98   irt00   irt02   irt04   irt06   irt08    irt10   irt12 irt14 irt16   cutoff;
array   tvar    {17}    t84     t86     t88     t90     t92     t94     t96     t98     t00     t02     t04     t06     t08     t10     t12  t14 t16  ;
array   period  {17}    period1 period2 period3 period4 period5 period6 period7 period8 period9 period10 period11 period12 period13 period14 period15  period16 period17;
array   bmiv    {17}    bmi84   bmi86   bmi88   bmi90   bmi92   bmi94   bmi96   bmi98   bmi00   bmi02   bmi04   bmi06   bmi08   bmi10   bmi12 bmi14 bmi16  ;
array   age     {17}    age84   age86   age88   age90   age92   age94   age96   age98   age00   age02   age04   age06   age08   age10   age12 age14 age16 ;

array   nsmk    {17}    smkdr84 smkdr86 smkdr88 smkdr90 smkdr92 smkdr94 smkdr96 smkdr98 smkdr00 smkdr02 smkdr04 smkdr06 smkdr08 smkdr10 smkdr12  smkdr14 smkdr16;
array   pkyr    {17}    pkyr84   pkyr86   pkyr88   pkyr90   pkyr92   pkyr94   pkyr96    pkyr98    pkyr00    pkyr02    pkyr04    pkyr06    pkyr08   pkyr10   pkyr12 pkyr14 pkyr16 ;

array   calornv {17}    calor84nv calor86nv calor86nv calor90nv calor90nv calor94nv calor94nv calor98nv calor98nv calor02nv calor02nv calor06nv calor06nv calor10nv calor10nv  calor10nv calor10nv;
array   calor   {17}    calor84n calor86n calor86n calor90n calor90n calor94n calor94n calor98n calor98n calor02n calor02n calor06n calor06n calor10n calor10n calor10n calor10n ;
array   qtei    {17}    calor84q calor86q calor86q calor90q calor90q calor94q calor94q calor98q calor98q calor02q calor02q calor06q calor06q  calor10q calor10q  calor10q calor10q ;

/* array   aheinv {13}    ahei84_av ahei86_av ahei86_av ahei90_av ahei90_av ahei94_av ahei94_av ahei98_av ahei98_av ahei02_av ahei02_av ahei06_av ahei06_av ahei10_av ahei10_av ahei10_av ahei10_av;
array   qahei  {13}    ahei84q   ahei86q   ahei86q   ahei90q   ahei90q   ahei94q   ahei94q   ahei98q   ahei98q   ahei02q   ahei02q   ahei06q   ahei06q ;

 */
array   alco    {17}    alco84n alco86n alco86n alco90n alco90n alco94n alco94n alco98n alco98n alco02n alco02n alco06n alco06n alco10n alco10n alco10n alco10n;
array   alcocum {17}    alco84v alco86v alco86v alco90v alco90v alco94v alco94v alco98v alco98v alco02v alco02v alco06v alco06v alco10v alco10v  alco10v alco10v  ;

array   actc    {17}    actc86  actc86  actc88  actc88  actc92  actc94  actc96  actc98 actc98 actc00  actc00  actc04 actc04  actc08 actc08 actc10 actc10;
array   actm    {17}    act86m  act86m  act88m  act88m  act92m  act94m  act96m  act98m act98m act00m  act00m  act04m  act04m act08m  act08m act10m  act10m;

array   dmnp    {17}    dmnp84   dmnp86  dmnp88   dmnp90   dmnp92   dmnp94   dmnp96  dmnp98  dmnp00  dmnp02  dmnp04  dmnp04  dmnp04  dmnp04  dmnp04 dmnp04  dmnp04 ;
array   ocu     {17}    ocu84    ocu86   ocu88    ocu90    ocu92    ocu94    ocu96   ocu98   ocu00   ocu02   ocu04   ocu06   ocu08   ocu10   ocu12  ocu12 ocu12 ;
array   hor     {17}    nhor84   nhor86  nhor88   nhor90   nhor92   nhor94   nhor96  nhor98  nhor00  nhor02  nhor04  nhor06  nhor08   nhor10  nhor12 nhor12 nhor12 ;

array   mvyn    {17}    mvitu84  mvitu86  mvitu88  mvitu90  mvitu92  mvitu94  mvitu96   mvitu98   mvitu00   mvitu02   mvitu04   mvitu06   mvitu08  mvitu10  mvitu12 mvitu14 mvitu16 ;
array   asparr  {17}    aspu84   aspu86   aspu88   aspu90   aspu92   aspu94   aspu96    aspu98    aspu00    aspu02    aspu04    aspu06    aspu08    aspu10   aspu12  aspu14   aspu16  ;

array    FIm   {17}    FI84v   FI86v   FI86v   FI90v   FI90v   FI94v   FI94v   FI98v   FI98v   FI02v   FI02v   FI06v   FI06v   FI10v  FI10v FI10v  FI10v;
array    FIs   {17}    FI84q   FI86q   FI86q   FI90q   FI90q   FI94q   FI94q   FI98q   FI98q   FI02q   FI02q   FI06q   FI06q   FI10q  FI10q  FI10q  FI10q;

array FImr {17} FI84vr FI86vr FI86vr FI90vr FI90vr FI94vr FI94vr FI98vr FI98vr FI02vr FI02vr FI06vr FI06vr FI10vr FI10vr FI10vr FI10vr;
array FIsr {17} FI84qr FI86qr FI86qr FI90qr FI90qr FI94qr FI94qr FI98qr FI98qr FI02qr FI02qr FI06qr FI06qr FI10qr FI10qr FI10qr FI10qr;


/*****************************************************************/
    if mobf<=0 or mobf>12 then mobf=6;  ** birthday in months;
    bdt=12*yobf+mobf;
  **************************************************************************
***** If an irt date is before June of that qq year or after or equal ****
***** to the next qq year it is incorrect and should be defaulted to  ****
***** June of that qq year.    Make time period indicator tvar=0.       ****
**************************************************************************;

    cutoff=1422; /* nmw - cutoff 2018.6 */

  do i=1 to DIM(irt)-1;
        if irt{i}>0 then ltf=irt{i};
    end;
    if ltf=irt{dim(irt)-1} then ltf=.;
    
   do i=1 to DIM(irt)-1;
  if (irt{i}<(990+24*i) | irt{i}>=(1014+24*i)) then irt{i}=990+24*i;
      age{i}=int((irt{i}-bdt)/12);
   end;
    

  /*Carry forward one cycle*/

    do i=DIM(irt)-1 to 2 by -1;  
        if bmiv{i}<=0     then bmiv{i}=bmiv{i-1};
        if pkyr{i}<0     then pkyr{i}=pkyr{i-1};
        if dmnp{i}<0     then dmnp{i}=dmnp{i-1};
        if hor{i}<0      then hor{i}=hor{i-1};
        if mvyn{i}=.   then mvyn{i}=mvyn{i-1};
    end;

    do i=1 to DIM(irt)-1;
        ocu{i}=ocu84;                        /* only investigated from 76-84 */
    end;
 


%beginex();
/*************************************************************/
/*                DO-LOOP OVER TIME PERIODS                  */
    do i=1 to DIM(irt)-1;
        interval=i;
        do j=1 to DIM(tvar);
            tvar{j}=0;
            period{j}=0;
        end;
        tvar{i}=1;
        period{i}=1;

/*** outcomes ***/

******* Define the death case in the ith time period ******;
 
     alldead=0;  talld=irt{i+1}-irt{i};
     if (irt{i}<dtdth<=irt{i+1}) then do;
     alldead=1; talld=dtdth-irt{i};
     end;

  /* death from cancer */
     dead_can=0;
     if alldead=1 and (1400<=newicda<=2070) then dead_can=1;

  /* death from CVD */
     dead_cvd=0;
     if alldead=1 and (3900<=newicda<=4580) then dead_cvd=1;


******* Define the type 2 diabetes case in the ith time period ******;
     dbcase=0;
     tdb=irt{i+1}-irt{i};
     if irt{i}<dtdxdb<=irt{i+1} then do;
     dbcase=1;
     tdb=dtdxdb-irt{i};
end;
if irt{i}<=dtdth<irt{i+1} then tdb=min(tdb, dtdth-irt{i});

db2case=0;                                           
  tdb2=irt{i+1}-irt{i};                             
        if irt{i}<dtdxdb2<=irt{i+1} then do;       
    db2case=1; 
  tdb2=dtdxdb2-irt{i}; 
  end;       
    if irt{i} le dtdth lt irt{i+1} then tdb2=min(tdb2, dtdth-irt{i}); 




******* Define CVD case in the ith time period ******;
     CVDcase=0;
     tcvd=irt{i+1}-irt{i};
     if irt{i}<dtdxcvd<=irt{i+1} then do;
     CVDcase=1;
     tcvd=dtdxcvd-irt{i};
     end;
     if irt{i}<=dtdth<irt{i+1} then tcvd=min(tcvd, dtdth-irt{i});


******* Define CVD case + CABG in the ith time period ******;
     CVDcaseca=0;
     tcvdca=irt{i+1}-irt{i};
     if irt{i}<dtdxcvdcabg<=irt{i+1} then do;
     CVDcaseca=1;
     tcvdca=dtdxcvdcabg-irt{i};
     end;
     if irt{i}<=dtdth<irt{i+1} then tcvdca=min(tcvdca, dtdth-irt{i});

******* Define CHD case in the ith time period ******;
     CHDcase=0; 
     tchd=irt{i+1}-irt{i};
     if irt{i}<dtdxchd<=irt{i+1} then do;
     CHDcase=1; 
     tchd=dtdxchd-irt{i};
     end;
     if irt{i} le dtdth lt irt{i+1} then tchd=min(tchd, dtdth-irt{i});

******* Define CHD+CABG case in the ith time period ******;
     CHDCA=0; 
     tchdca=irt{i+1}-irt{i};
     if irt{i}<dtdxchdcabg<=irt{i+1} then do;
     CHDCA=1; 
     tchd=dtdxchdcabg-irt{i};
     end;
     if irt{i} le dtdth lt irt{i+1} then tchdca=min(tchdca, dtdth-irt{i});
******* Define CABG case in the ith time period ******;
     CABGcase=0; 
     tcabg=irt{i+1}-irt{i};
     if irt{i}<dtdxcabg<=irt{i+1} then do;
     CABGcase=1; 
     tcabg=dtdxcabg-irt{i};
     end;
     if irt{i} le dtdth lt irt{i+1} then tcabg=min(tcabg, dtdth-irt{i});
******* Define the STROKE case in the ith time period ******;
     STRcase=0; 
     tstr=irt{i+1}-irt{i};
     if irt{i}<dtdxstr<=irt{i+1} and CHDcase=0 then do;
     STRcase=1; 
     tstr=dtdxstr-irt{i};
     end;
     if irt{i} le dtdth lt irt{i+1} then tstr=min(tstr, dtdth-irt{i});


** Define the htn case in the ith time period **;
  htncase=0;  if (irt[i]< htndtdx <= irt[i+1]) then htncase=1;

** Define time-to-failure htn variable;
  htntime=irt[i+1]-irt[i];
  if htncase=1 then htntime=min(htntime, htndtdx-irt[i]);
  if (irt[i]<= dtdth <irt[i+1]) then htntime=min(htntime, dtdth-irt[i]);

******* Age ******;
     agemo=irt{i}-bdt; 
     age{i}=int((irt{i}-bdt)/12);      
     if age{i} =< 0 then age{i}=.;

            agecon=age{i};
            agegp=int((age{i}-30)/5);     **** Define the agegp in the i-th period;
            if agegp<=0 then agegp=1;
            if agegp>8 then agegp=8;
            %indic3(vbl=agegp, prefix=agegp, reflev=1, min=2, max=8, 
                      usemiss=0,
                     label1='age<40',
                     label2='age40-44',
                     label3='age45-49',
                     label4='age50-54',
                     label5='age55-59',
                     label6='age60-64',
                     label7='age65-69',
                     label8='age >= 70');
     if agecon>60 then agesub=1; else agesub=0;


        /* Postmenopausal hormone use */
        if dmnp{i}=1 or  hor{i}=1 then pmh_mn=1;
        if dmnp{i}=2 and hor{i}=2 then pmh_mn=2;
        if dmnp{i}=2 and hor{i}=3 then pmh_mn=3;
        if dmnp{i}=2 and hor{i}=4 then pmh_mn=4;
        if dmnp{i}=3                then pmh_mn=5;
        if dmnp{i}=4 or (hor{i}=0 or hor{i}=6 or hor{i}=5) then pmh_mn=9;

        select(pmh_mn);
          when (1,5)   phmsstatus=1;
          when (2)     phmsstatus=2;
          when (3)     phmsstatus=3;
          when (4)     phmsstatus=4;
          otherwise    phmsstatus=.;
        end;
     
        %indic3(vbl=phmsstatus, prefix=phmsstatus, min=2, max=4, reflev=1,missing=., usemiss=1,         
                  label1='premenopause',
                  label2='pmh neveruse',
                  label3='pmh curr use',
                  label4='pmh past use');  

        select(phmsstatus);
          when (3,4)   pmh_ever=1; /* current or past use */
          otherwise    pmh_ever=0;
        end;


     /***  OC use  ***********/

        oc=ocu{i};
            
        if oc in (1,2) then oc_ever=1; *ever use;
        else oc_ever=0;

     /***smoking status***/
    
        if nsmk{i}=1 then smkever=1;  *never;
        else if nsmk{i} in(2,3,4,5,6,7,8) then smkever=2; *past smoker;
        else if nsmk{i} in (9,10) then smkever=3; *current, 1-14 cigs ;
        else if nsmk{i}=11 then smkever=4; *current, 15-24 cigs ;
        else if nsmk{i} in(12,13,14) then smkever=5; *current, 25+ cigs ; 
        else smkever=1; *missing;
 

        %indic3(vbl=smkever, prefix=smkc, min=2, max=5, reflev=1, missing=., usemiss=1,
          label1='Never smoke',
          label2='Past smoker',
          label3='Current smoker 1-14 cigs',
          label4='Current smoker 15-24 cigs',
          label5='Current smoker 25+ cigs');

    
        if nsmk{1}=1 then bsmkever=1;  *never;
        else if nsmk{1} in(2,3,4,5,6,7,8) then bsmkever=2; *past smoker;
        else if nsmk{1} in (9,10) then bsmkever=3; *current, 1-14 cigs ;
        else if nsmk{1}= 11 then bsmkever=4; *current, 15-24 cigs ;
        else if nsmk{1} in (12,13,14) then bsmkever=5; *current, 25+ cigs ; 
        else bsmkever=.; *missing;
 

        %indic3(vbl=bsmkever, prefix=bsmkever, min=2, max=5, reflev=1, missing=., usemiss=0,
          label1='Never smoke',
          label2='Past smoker',
          label3='Current smoker 1-14 cigs',
          label4='Current smoker 15-24 cigs',
          label5='Current smoker 25+ cigs');


/*** Alcohol ***/

          alco_cum=alcocum{i};
          
          if           alcocum{i}=0  then alco_cumc=1;
          else if 0 <  alcocum{i}<5  then alco_cumc=2;
          else if 5=<  alcocum{i}<10 then alco_cumc=3;
          else if 10<= alcocum{i}<15 then alco_cumc=4;
          else if 15=< alcocum{i}<30 then alco_cumc=5;
          else if 30<= alcocum{i}    then alco_cumc=6;
          else                            alco_cumc=9;
          label alco_cumc='Cumulative average dailay alcohol intake, g/d, categorical';

        if alco_cumc in (2,3,4,5,6) then neverdrinker=0;
        else neverdrinker=1;


          
          %indic3(vbl=alco_cumc, prefix=alco_cumc, min=2, max=6, reflev=1, missing=9,usemiss=0,
                  label1='none',
                  label2='1-4 gm',
                  label3='5-9 gm',
                  label4='10-14 gm',
                  label5='15-29 gm',
                  label6='30+ gm');  

/* race classfication;*/

        racec=.;
             if race=1        then racec=1;
        else if race in (3,5) then racec=2;
        else if race=4        then racec=3;
        else if race=2        then racec=4;

        race=racec;
        %indic3(vbl=race,prefix=race,min=2,max=4,reflev=1,usemiss=0,
                label1='white',
                label2='other',
                label3='asian',
                label4='african american');

  if racec=2 then white=1; else white=0; 


 /*** TEI ***/
             calorm=calornv{i};
             teicon=calor{i};
             teiq=qtei{i};
             %indic3(vbl=teiq, prefix=qtei, reflev=0, missing=., usemiss=0, min=1, max=4); 

 /*** AHEI ***/
/* 
             aheim=aheinv{i}; 
             aheiq=qahei{i};
             %indic3(vbl=aheiq, prefix=qahei, reflev=0, missing=., usemiss=0, min=1, max=4); 
 */

 /***category of exercise***/
       actcc=actc{i};
       if  actcc=6 or  actcc=. then  actcc=3;
       %indic3(vbl=actcc, prefix=actc, min=2, max=5, reflev=1, missing=6, usemiss=0);

       actcb=actc{1};
       if  actcb=6 or  actcb=. then  actcb=3;
       %indic3(vbl=actcb, prefix=actcb, min=2, max=5, reflev=1, missing=6, usemiss=0);


actmcon=actm {i};

if actmcon>7.5 then active=1; else active=0;

/*** Indicator for BMI ***/ 
                
         bmicon=bmiv{i};

         if      0<   bmicon <23 then bmic=1;
         else if 23=< bmicon <25 then bmic=2;
         else if 25=< bmicon <30 then bmic=3;
         else if 30=< bmicon <35 then bmic=4;
         else if 35=< bmicon     then bmic=5;
         else if bmicon=. or bmicon=0 then bmic=3;
         %indic3(vbl=bmic, prefix=bmic, reflev=1, min=2, max=5, missing=., usemiss=0,
                    label1='bmi<23', 
                    label2='bmi 23-24.9',
                    label3='bmi 25-29.9', 
                    label4='bmi 30.0-35', 
                    label5='bmi 35.0+');
         

         if bmicon>=25 then bmic25=1;  else  bmic25=0;
         if bmicon>=30 then bmic30=1;  else  bmic30=0;

  bmibase=bmiv{1};
    if          0 < bmibase< 23.00 then bmib=1;
        else if 23.00<= bmibase< 25.00 then bmib=2;
        else if 25.00<= bmibase< 30.00 then bmib=3;
        else if 30.00<= bmibase< 35.00 then bmib=4;
        else if 35.00<= bmibase        then bmib=5;
        else if bmibase=. or bmibase=0 then bmib=3;

        %indic3(vbl=bmib, prefix=bmib, min=2, max=5, reflev=1,
                missing=., usemiss=0,
                label1='bmi base  <23.0',
                label2='bmi base=>23.0 & <25.0',
                label3='bmi base=>25.0 & <30.0',
                label4='bmi base=>30.0 & <35.0',
                label5='bmi base=>35.0');
        
              if      0< bmibase <25 then bmib25=0;
         else if bmibase>=25 then bmib25=1;
     if      0< bmibase <30 then bmib30=0;
         else if bmibase>=30 then bmib30=1;
       

     /*** aspirin ***/
            select(asparr{i});
                when (1)     aspirin=1;
                 otherwise    aspirin=0;
            end;



      /*** multiple vitamin ***/
             select(mvyn{i});
                when (1) mvit=1;
              otherwise  mvit=0;
            end;  

    /************** Indicator for baseline of High Blood Pressure *********************/
    
         hbpbase=hbp84;

/************** Indicator for baseline of High Blood Pressure *********************/
 
         cholbase=chol84;
     
/*For subgroup analysis*/
     if smkever=1 then smknever=1;         /***Never smker***/
     else smknever=0;
     if smkever=2 then smk_ps=1;         /***past smker***/
     else smk_ps=0;
     if smkever=3 or smkever=4 or smkever=5 then smk_ct=1;             /**current smker**/
     else smk_ct=0; 
     if phmsstatus=1 then prepau=1; else prepau=0; 
     if phmsstatus=1 then postpau=0; else postpau=1; 


       /*** dietary pattern***/
        /*** Cumulative***/
       
         FIcon= FIm{i};
         FIq= FIs{i}+1;
         %indic3(vbl= FIq, prefix= FIq, min=2, max=5, reflev=1, missing=., usemiss=0);

         FIconr= FImr{i};
         FIqr= FIsr{i}+1;
         %indic3(vbl= FIqr, prefix= FIqr, min=2, max=5, reflev=1, missing=., usemiss=0);


      /****************  BASELINE EXCLUSIONS ********************************************/
          if i=1 then do;
   %exclude(yobf<=20)
 

  %exclude(0 lt dtdth lt irt84);
  %exclude(0 lt htndtdx le irt84);

   %exclude(hbpbase eq 1);
   %exclude(age84 eq .); 
   %exclude(FI84 eq .);

   %exclude(teicon < 600); 
   %exclude(teicon > 3500);
   
   %exclude(ltf eq irt{i});

   %output();
   end; 
 
/* EXCLUSIONS DURING FOLLOW-UP */
         if i>1 then do;
           %exclude(irt[i-1] le dtdth lt irt[i]);
           %exclude(irt[i-1] lt htndtdx le irt[i]);

             %output();
   end;
   end;        /* END OF DO-LOOP OVER TIME PERIODs */

%endex(); /* must do AFTER all exclusions */




data nhs1;
set nhs1hei end=_end_; 
keep id agemo  agecon agegp &agegp_ interval agesub 
     irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12  irt14 irt16 cutoff
     t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14 t16 
   dtdxcvdcabg dtdxchdcabg dtdxchd dtdxstr tcvdca tchdca tchd tstr CVDcaseca CVDcase CHDCA CHDcase STRcase CABGcase 
   dtdth alldead dead_can dead_cvd talld  dbfh  mifh  strfh 
   FIq FIqr
   &FIq_  &FIqr_
   FIcon FIconr  
   htncase  htntime htndtdx
white race &race_  mvit aspirin pmh_ever &phmsstatus_  teiq  &qtei_ alco_cumc &alco_cumc_  smkever &smkc_  actcc &actc_  bmib &bmib_ &bmic_ bmic30 bmib30 bmic25 bmib25
smknever  prepau active bmicon oc_ever  /* aheiq &qahei_ aheim */
age84 aspu84 phmsstatus age84  hbpbase cholbase  
alco84n calor84n   act86m  neverdrinker calorm; 

proc means;
run;

proc sort data=nhs1;
  by id;
  run;

