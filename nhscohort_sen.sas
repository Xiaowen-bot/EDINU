
/*****************************************************************************************************************************************
Figure S5: the code is same as nhscohort_gout, only exposure is bulit differently.                                                                                     
 
******************************************************************************************************************************************/
 
                                                                                                                        
* options linesize=130 pagesize=78;
* filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/';
* filename local '/usr/local/channing/sasautos/';
* filename PHSmacro '/proj/phdats/phdat01/phstools/sasautos/';
* filename mumacro '/udd/nhlmu/macro';
* libname library '/proj/nhsass/nhsas00/formats/';
* options mautosource sasautos=(mumacro local nhstools PHSmacro);
* options fmtsearch=(readfmt);



/********* READ IN CONFIRMED GOUT FILES *********/

/*------------------------------------------------------------
This case file was obtained from Hyon Choi's group.
Source: /udd/nhleo/NHSgout/gout8211.sas
------------------------------------------------------------*/

data gout;
   infile '/udd/hphyo/Leo/Pattern/Final/gout8211.dtdx.dat';
   input id gtcase goutdtdx gout82e gout84e gout86e gout88e gout02e gout04e gout06e gout08e gout10e gout12e;
   label gtcase='1=confirmed by supplemental Q'  
         goutdtdx='diagonosis date of gout'  
         gout82e='self report from 82 main Q'  
         gout84e='self report from 84 main Q'  
         gout86e='self report from 86 main Q'  
         gout88e='self report from 88 main Q'  
         gout02e='self report from 02 main Q'  
         gout04e='self report from 04 main Q'  
         gout06e='self report from 06 main Q'
         gout08e='self report from 08 main Q'
         gout10e='self report from 10 main Q'
         gout12e='self report from 12 main Q';
            
year=int(goutdtdx/12);
if gtcase=1 or gtcase=0 then suppfiles=1; *confirmed by supplemental questionnaires;
selfrpt=1;
run;


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


               /* Call in food variables */
    **************************************************
    *             Dietary food groups          *
    **************************************************;



%serv84 (keep = id 
                blueb_s84 cotch_s84 crmch_s84 otch_s84 lccaf_s84 lcnoc_s84 lcoth_s84  
                hamb_s84 bmix_s84  bmain_s84 rais_s84 liq_s84 skim_s84 
                liv_s84 mixv_s84 oilv_s84 tom_s84 toj_s84 tosau_s84
                yam_s84 ysqua_s84 nut_s84 yog_s84 tea_s84 
                beer_s84 sour_s84 but_s84 cream_s84 egg_s84 
                jam_s84 chsau_s84 dog_s84 bacon_s84 procm_s84 
                pot_s84 whbr_s84 wrice_s84 crack_s84 engl_s84 
                muff_s84 pcake_s84 pasta_s84  ckcer_s84 oat_s84 dkbr_s84 brice_s84 otgrn_s84 bran_s84 wgerm_s84 popc_s84
aj_s84 othj_s84 appl_s84 tofu_s84 cauli_s84 kale_s84 jam_s84 chsau_s84 oran_s84 grfr_s84 grj_s84 pizza_s84
                ban_s84 cant_s84  oj_s84 car_s84  cel_s84
                chwi_s84 chwo_s84 mayo_s84 cer_s84
                rwine_s84  wwine_s84 corn_s84 peas_s84 sbean_s84 bean_s84)

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

/* Yellow vegetables */      yelveg84    = sum(yam_s84, ysqua_s84);
/* Nuts */                   othnut84    = sum(nut_s84);
/* Yogurt */                 yogurt84    = sum(yog_s84);
/* Tea */                    tea84       = sum(tea_s84);
/* Beer */                   beer84      = sum(beer_s84);
/* High-fat dairy */         hfdairy84   = sum(sour_s84, but_s84, cream_s84); 
/* Eggs */                   eggs84      = sum(egg_s84);
/* Processed red meat */     prmeat84    = sum(dog_s84, bacon_s84, procm_s84);
/* Potatoes */               potato84    = sum(pot_s84);
/* Refined grain products */ rgrain84    = sum(whbr_s84, wrice_s84, crack_s84, engl_s84, muff_s84, pcake_s84, pasta_s84);

/* cold breakfast cereal */  cereal84    = sum(cer_s84);
/* Mayo or creamy dress */   mayo84      = sum(mayo_s84);
/* onion */                  onion84     = .   ;          /* *Not collected in 1984 */
/* Poultry */                poultry84   = sum(chwi_s84, chwo_s84);
/* umb*/                     umb84       = sum(car_s84, cel_s84);
/* carrots*/                 carrot84    = sum(car_s84);
/* Orange juice*/            oj84        = sum(oj_s84);
/* Avocado  */               avo84       = .  ;    *Not collected in 1984;
/* Other fruits  */          othfru84    = sum(ban_s84, cant_s84);

/* Whole grains */          wgrain84    = sum(cer_s84, ckcer_s84, oat_s84, dkbr_s84, brice_s84, otgrn_s84, bran_s84, wgerm_s84, popc_s84);
/* Juice */                 juice84     = sum(aj_s84, othj_s84);
/* Apple */                 apple84     = sum(appl_s84);
/* Soy products */          soy84       = sum(tofu_s84);
/* Cruciferous veg */       crucveg84   = sum(cauli_s84, kale_s84);
/* Condiments */            condi84     = sum(jam_s84, chsau_s84);
/* Citrus fruits */         citrus84    = sum(oran_s84, grfr_s84, grj_s84);

/* Pizza */                 pizza84     = sum(pizza_s84);

/* corn */                  corn84     = sum(corn_s84);
/* beans*/                  beans84    = sum(peas_s84,sbean_s84, bean_s84);
  



FI84= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84a= -(shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84b= -(blueb84*-0.022359623 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84c= -(blueb84*-0.022359623+shchee84*-0.000357103  +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84d= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84e = -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84f= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84g= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84h= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84i= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+oildres84*0.016648388 
+tomprod84*0.022265025+wine84*0.016825528);

FI84j= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174
+tomprod84*0.022265025+wine84*0.016825528);

FI84k= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+wine84*0.016825528);

FI84l= -(blueb84*-0.022359623+shchee84*-0.000357103 +dietbev84*0.037505123 +frmeat84*0.041039490+grape84*-0.005362665 
+liq84*0.042291654+lfmilk84*-0.037611764+organ84*0.039207711+mixveg84*0.091345174+oildres84*0.016648388 
+tomprod84*0.022265025);



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

/* Pome fruits */           pome86      = sum(appl_s86, pear_s86, aj_s86, apsau_s86, cpear_s86);    /* Pear is its own category in 1986. Also has canned pears */
/* Potatoes */              potato86    = sum(pot_s86);

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

/* Whole milk */            whlmilk86   = sum(whole_s86);
/* Wine */                  wine86      = sum(rwine_s86, wwine_s86);
/* Yam or sweet potato */   yamswt86    = sum(yam_s86);
/* Yogurt */                yogurt86    = sum(yog_s86);
/* Yellow vegetables */     yelveg86    = sum(yam_s86, ysqua_s86);

/* cold breakfast cereal */  cereal86    = sum(cer_s86);
/* Mayo or creamy dress */   mayo86      = sum(mayo_s86);
/* onion */                  onion86     = .  ; *Not collected in 1986;
/* Poultry */                poultry86   = sum(chwi_s86, chwo_s86);
/* umb*/                     umb86       = sum(rcar_s86, ccar_s86, cel_s86);
/* carrot*/                  carrot86    = sum(rcar_s86, ccar_s86);
/* Orange juice*/            oj86        = sum(oj_s86);
/* Avocado  */               avo86       = sum(avo_s86);
/* Other fruits  */          othfru86    = sum(ban_s86,cant_s86);

/* Whole grains */          wgrain86    = sum(oat_s86, dkbr_s86, bran_s86, wgerm_s86, brice_s86, popc_s86, ckcer_s86, otgrn_s86); 
/* Juice */                 juice86     = sum(aj_s86, othj_s86);
/* Apple */                 apple86     = sum(appl_s86);
/* Soy products */          soy86       = sum(tofu_s86);
/* Cruciferous veg */       crucveg86   = sum(cauli_s86, slaw_s86, kale_s86);

/* Citrus fruits */         citrus86    = sum(oran_s86, grfr_s86, grj_s86);

/* Pizza */                  pizza86     = sum(pizza_s86);

/* beans */                  beans86     = sum(peas_s86,sbean_s86, bean_s86);

FI86 = -(blueb86 * -0.022359623 + shchee86 * -0.000357103 + dietbev86 * 0.037505123 + frmeat86 * 0.041039490 
     + grape86 * -0.005362665 + liq86 * 0.042291654 + lfmilk86 * -0.037611764 + organ86 * 0.039207711 
     + mixveg86 * 0.091345174 + oildres86 * 0.016648388 + tomprod86 * 0.022265025 + wine86 * 0.016825528);

FI86a= -(shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86b= -(blueb86*-0.022359623 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86c= -(blueb86*-0.022359623+shchee86*-0.000357103  +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86d= -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86e = -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86f= -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86g= -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86h= -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86i= -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+oildres86*0.016648388 
+tomprod86*0.022265025+wine86*0.016825528);

FI86j= -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174
+tomprod86*0.022265025+wine86*0.016825528);

FI86k= -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+wine86*0.016825528);

FI86l= -(blueb86*-0.022359623+shchee86*-0.000357103 +dietbev86*0.037505123 +frmeat86*0.041039490+grape86*-0.005362665 
+liq86*0.042291654+lfmilk86*-0.037611764+organ86*0.039207711+mixveg86*0.091345174+oildres86*0.016648388 
+tomprod86*0.022265025);

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

/* Whole milk */            whlmilk90   = sum(whole_s90);
/* Wine */                  wine90      = sum(rwine_s90, wwine_s90);
/* Yam or sweet potato */   yamswt90    = sum(yam_s90);
/* Yogurt */                yogurt90    = sum(yog_s90);
/* Yellow vegetables */     yelveg90    = sum(yam_s90, osqua_s90);

/* cold breakfast cereal */  cereal90    = sum(cer_s90);
/* Mayo or creamy dress */   mayo90      = sum(mayo_s90);
/* Onions */                 onion90     = sum(oniog_s90, oniov_s90);
/* Poultry */                poultry90   = sum(chwi_s90, chwo_s90);
/* umb*/                     umb90       = sum(rcar_s90, ccar_s90, cel_s90);
/* umb*/                     carrot90    = sum(rcar_s90, ccar_s90);
/* Orange juice*/            oj90        = sum(oj_s90);
/* Avocado  */               avo90       = . ;  *Not collected in 1990;
/* Other fruits  */          othfru90    = sum(ban_s90, cant_s90);

/* Whole grains */          wgrain90    = sum(oat_s90, dkbr_s90, oatbr_s90, bran_s90, wgerm_s90, 
                                              brice_s90, popc_s90, ckcer_s90, otgrn_s90);
/* Juice */                 juice90     = sum(aj_s90, othj_s90);
/* Apple */                 apple90     = sum(appl_s90);
/* Soy products */          soy90       = sum(tofu_s90);
/* Cruciferous veg */       crucveg90   = sum(cauli_s90,kale_s90);

/* Citrus fruits */         citrus90    = sum(oran_s90, grfr_s90, grj_s90);

/* Pizza */                 pizza90     = sum(pizza_s90);
/* beans*/                  beans90    = sum(peas_s90,sbean_s90, bean_s90);

FI90 = - (blueb90 * -0.022359623 + shchee90 * -0.000357103 + dietbev90 * 0.037505123 + frmeat90 * 0.041039490 
     + grape90 * -0.005362665 + liq90 * 0.042291654 + lfmilk90 * -0.037611764 + organ90 * 0.039207711 
     + mixveg90 * 0.091345174 + oildres90 * 0.016648388 + tomprod90 * 0.022265025 + wine90 * 0.016825528);

FI90a= -(shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90b= -(blueb90*-0.022359623 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90c= -(blueb90*-0.022359623+shchee90*-0.000357103  +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90d= -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90e = -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90f= -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90g= -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90h= -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90i= -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+oildres90*0.016648388 
+tomprod90*0.022265025+wine90*0.016825528);

FI90j= -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174
+tomprod90*0.022265025+wine90*0.016825528);

FI90k= -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+wine90*0.016825528);

FI90l= -(blueb90*-0.022359623+shchee90*-0.000357103 +dietbev90*0.037505123 +frmeat90*0.041039490+grape90*-0.005362665 
+liq90*0.042291654+lfmilk90*-0.037611764+organ90*0.039207711+mixveg90*0.091345174+oildres90*0.016648388 
+tomprod90*0.022265025);

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
                yam_s94 osqua_s94 onut_s94 plyog_s94 flyog_s94 
                tea_s94 beer_s94 lbeer_s94 but_s94 cream_s94 
                egg_s94 jam_s94 bfdog_s94 bacon_s94 procm_s94 
                pot_s94 whbr_s94 wrice_s94 crack_s94 engl_s94 
                muff_s94 pcake_s94 pasta_s94  ckcer_s94 oat_s94 dkbr_s94 brice_s94 otgrn_s94 bran_s94 oatbr_s94 wgerm_s94 popc_s94 tort_s94
aj_s94 othj_s94 appl_s94 tofu_s94 cauli_s94 kale_s94 jam_s94 oran_s94 grfr_s94 grj_s94 pizza_s94
                ban_s94 cant_s94 avo_s94 oj_s94 rcar_s94 ccar_s94 cel_s94
                chwi_s94 chwo_s94 oniog_s94 oniov_s94 mayo_s94 cer_s94
                rwine_s94  wwine_s94 corn_s94 peas_s94 sbean_s94 bean_s94)

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

/* Yellow vegetables */      yelveg94    = sum(yam_s94, osqua_s94);
/* Nuts */                   othnut94    = sum(onut_s94);
/* Yogurt */                 yogurt94    = sum(plyog_s94,flyog_s94);
/* Tea */                    tea94       = sum(tea_s94);
/* Beer */                   beer94      = sum(beer_s94,lbeer_s94);
/* High-fat dairy */         hfdairy94   = sum(but_s94, cream_s94); 
/* Eggs */                   eggs94      = sum(egg_s94);
/* Condiments */             condi94     = sum(jam_s94); 
/* Processed red meat */     prmeat94    = sum(bfdog_s94, bacon_s94, procm_s94);
/* Potatoes */               potato94    = sum(pot_s94);
/* Refined grain products */ rgrain94    = sum(whbr_s94, wrice_s94, crack_s94, engl_s94, muff_s94, pcake_s94, pasta_s94, tort_s94);

/* cold breakfast cereal */  cereal94    = sum(cer_s94);
/* Mayo or creamy dress */   mayo94      = sum(mayo_s94);
/* onion */                  onion94     = sum(oniog_s94, oniov_s94);
/* Poultry */                poultry94   = sum(chwi_s94, chwo_s94);
/* umb*/                     umb94       = sum(rcar_s94, ccar_s94, cel_s94);
/* carrot*/                  carrot94    = sum(rcar_s94, ccar_s94);
/* Orange juice*/            oj94        = sum(oj_s94);
/* Avocado  */               avo94       = sum(avo_s94);
/* Other fruits  */          othfru94    = sum(ban_s94, cant_s94);

/* Whole grains */          wgrain94    = sum(cer_s94, ckcer_s94, oat_s94, dkbr_s94, brice_s94, otgrn_s94, bran_s94 ,oatbr_s94, wgerm_s94, popc_s94, tort_s94 );
/* Juice */                 juice94     = sum(aj_s94, othj_s94);
/* Apple */                 apple94     = sum(appl_s94);
/* Soy products */          soy94       = sum(tofu_s94);
/* Cruciferous veg */       crucveg94   = sum(cauli_s94, kale_s94);

/* Citrus fruits */         citrus94    = sum(oran_s94, grfr_s94, grj_s94);

/* Pizza */                 pizza94     = sum(pizza_s94);

/* corn */                  corn94     = sum(corn_s94);
/* beans*/                  beans94    = sum(peas_s94,sbean_s94, bean_s94);
  

FI94 = -(blueb94 * -0.022359623 + shchee94 * -0.000357103 + dietbev94 * 0.037505123 + frmeat94 * 0.041039490 
     + grape94 * -0.005362665 + liq94 * 0.042291654 + lfmilk94 * -0.037611764 + organ94 * 0.039207711 
     + mixveg94 * 0.091345174 + oildres94 * 0.016648388 + tomprod94 * 0.022265025 + wine94 * 0.016825528);

FI94a= -(shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94b= -(blueb94*-0.022359623 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94c= -(blueb94*-0.022359623+shchee94*-0.000357103  +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94d= -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94e = -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94f= -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94g= -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94h= -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94i= -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+oildres94*0.016648388 
+tomprod94*0.022265025+wine94*0.016825528);

FI94j= -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174
+tomprod94*0.022265025+wine94*0.016825528);

FI94k= -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+wine94*0.016825528);

FI94l= -(blueb94*-0.022359623+shchee94*-0.000357103 +dietbev94*0.037505123 +frmeat94*0.041039490+grape94*-0.005362665 
+liq94*0.042291654+lfmilk94*-0.037611764+organ94*0.039207711+mixveg94*0.091345174+oildres94*0.016648388 
+tomprod94*0.022265025);

run;


%serv98 (keep = id 
                blueb_s98 cotch_s98 crmch_s98 otch_s98 lccaf_s98 lcnoc_s98 lcoth_s98  
                hamb_s98 bmix_s98 pmain_s98 bmain_s98 rais_s98 liq_s98 skim_s98 
                livb_s98 livc_s98 mixv_s98 ooil_s98 tom_s98 toj_s98 tosau_s98
                yam_s98 osqua_s98 onut_s98 plyog_s98 flyog_s98 
                tea_s98 dtea_s98 beer_s98 lbeer_s98 but_s98 
                cream_s98 egg_s98 jam_s98 bfdog_s98 bacon_s98 
                procm_s98 pot_s98 whbr_s98 wrice_s98 crack_s98 
                engl_s98 muff_s98 pcake_s98 pasta_s98 pretz_s98 
                ckcer_s98 oat_s98 dkbr_s98 brice_s98 otgrn_s98 bran_s98 oatbr_s98 wgerm_s98 popc_s98 tort_s98
aj_s98 othj_s98 appl_s98 tofu_s98 cauli_s98 kale_s98 jam_s98 oran_s98 grfr_s98 grj_s98 pizza_s98
                ban_s98 cant_s98 avo_s98 oj_s98 rcar_s98 ccar_s98 cel_s98
                chwi_s98 chwo_s98 oniog_s98 oniov_s98 mayo_s98 cer_s98
                rwine_s98  wwine_s98 corn_s98 peas_s98 sbean_s98 bean_s98)

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

/* Yellow vegetables */      yelveg98    = sum(yam_s98, osqua_s98);
/* Nuts */                   othnut98    = sum(onut_s98);
/* Yogurt */                 yogurt98    = sum(plyog_s98,flyog_s98);
/* Tea */                    tea98       = sum(tea_s98, dtea_s98);
/* Beer */                   beer98      = sum(beer_s98, lbeer_s98);
/* High-fat dairy */         hfdairy98   = sum(but_s98, cream_s98); 
/* Eggs */                   eggs98      = sum(egg_s98);

/* Processed red meat */     prmeat98    = sum(bfdog_s98, bacon_s98, procm_s98);
/* Potatoes */               potato98    = sum(pot_s98);
/* Refined grain products */ rgrain98    = sum(whbr_s98, wrice_s98, crack_s98, engl_s98, muff_s98, pcake_s98, pasta_s98, pretz_s98, tort_s98);

/* cold breakfast cereal */  cereal98    = sum(cer_s98);
/* Mayo or creamy dress */   mayo98      = sum(mayo_s98);
/* onion */                  onion98     = sum(oniog_s98, oniov_s98);
/* Poultry */                poultry98   = sum(chwi_s98, chwo_s98);
/* umb*/                     umb98       = sum(rcar_s98, ccar_s98, cel_s98);
/* carrot*/                  carrot98    = sum(rcar_s98, ccar_s98);
/* Orange juice*/            oj98        = sum(oj_s98);
/* Avocado  */               avo98       = sum(avo_s98);
/* Other fruits  */          othfru98    = sum(ban_s98, cant_s98);

/* Whole grains */          wgrain98    = sum(cer_s98, ckcer_s98, oat_s98, dkbr_s98, brice_s98, otgrn_s98 ,bran_s98, oatbr_s98, wgerm_s98, popc_s98, tort_s98 );
/* Juice */                 juice98     = sum(aj_s98, othj_s98);
/* Apple */                 apple98     = sum(appl_s98);
/* Soy products */          soy98       = sum(tofu_s98);
/* Cruciferous veg */       crucveg98   = sum(cauli_s98,  kale_s98);
/* Condiments */            condi98     = sum(jam_s98);
/* Citrus fruits */         citrus98    = sum(oran_s98, grfr_s98, grj_s98);

/* Pizza */                 pizza98    = sum(pizza_s98);
/* corn */                  corn98     = sum(corn_s98);
/* beans*/                  beans98    = sum(peas_s98,sbean_s98, bean_s98);
  

FI98 = - (blueb98 * -0.022359623 + shchee98 * -0.000357103 + dietbev98 * 0.037505123 + frmeat98 * 0.041039490 
     + grape98 * -0.005362665 + liq98 * 0.042291654 + lfmilk98 * -0.037611764 + organ98 * 0.039207711 
     + mixveg98 * 0.091345174 + oildres98 * 0.016648388 + tomprod98 * 0.022265025 + wine98 * 0.016825528);

FI98a= -(shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98b= -(blueb98*-0.022359623 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98c= -(blueb98*-0.022359623+shchee98*-0.000357103  +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98d= -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98e = -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98f= -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98g= -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98h= -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98i= -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+oildres98*0.016648388 
+tomprod98*0.022265025+wine98*0.016825528);

FI98j= -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174
+tomprod98*0.022265025+wine98*0.016825528);

FI98k= -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+wine98*0.016825528);

FI98l= -(blueb98*-0.022359623+shchee98*-0.000357103 +dietbev98*0.037505123 +frmeat98*0.041039490+grape98*-0.005362665 
+liq98*0.042291654+lfmilk98*-0.037611764+organ98*0.039207711+mixveg98*0.091345174+oildres98*0.016648388 
+tomprod98*0.022265025);

run;


%serv02 (keep = id 
                blueb_s02 cotch_s02 crmch_s02 otch_s02 lccaf_s02 lcnoc_s02   
                hamb_s02 bmix_s02 pmain_s02 bmain_s02 rais_s02 liq_s02 skim_s02 
                livb_s02 livc_s02 mixv_s02 ooil_s02 tom_s02 toj_s02 tosau_s02
                yam_s02 osqua_s02 onut_s02 plyog_s02 flyog_s02 
                tea_s02 dtea_s02 beer_s02 lbeer_s02 but_s02 
                cream_s02 egg_s02 jam_s02 bfdog_s02 bacon_s02 
                procm_s02 pot_s02 whbr_s02 wrice_s02 crack_s02 
                engl_s02 muff_s02 pcake_s02 pasta_s02 pretz_s02 
                crlit_s02 tort_s02  ckcer_s02 oat_s02 dkbr_s02 ryebr_s02 brice_s02 oatbr_s02 bran_s02 wgerm_s02 popc_s02 ffpop_s02 tort_s02
aj_s02 othj_s02 prunj_s02 appl_s02 tofu_s02 cauli_s02 kale_s02 jam_s02 oran_s02 grfr_s02 pizza_s02
                ban_s02 cant_s02 oj_s02 rcar_s02 ccar_s02 cel_s02
                chwi_s02 chwo_s02 oniog_s02 oniov_s02 mayo_s02 cer_s02
                rwine_s02  wwine_s02 corn_s02 peas_s02 sbean_s02 bean_s02)

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

/* Yellow vegetables */      yelveg02    = sum(yam_s02, osqua_s02);
/* Nuts */                   othnut02    = sum(onut_s02);
/* Yogurt */                 yogurt02    = sum(plyog_s02,flyog_s02);
/* Tea */                    tea02       = sum(tea_s02,dtea_s02);
/* Beer */                   beer02      = sum(beer_s02,lbeer_s02);
/* High-fat dairy */         hfdairy02   = sum(but_s02, cream_s02); 
/* Eggs */                   eggs02      = sum(egg_s02);

/* Processed red meat */     prmeat02    = sum(bfdog_s02, bacon_s02, procm_s02);
/* Potatoes */               potato02    = sum(pot_s02);
/* Refined grain products */ rgrain02    = sum(whbr_s02, wrice_s02, crack_s02, engl_s02, muff_s02, pcake_s02, pasta_s02, pretz_s02, crlit_s02, tort_s02);

/* cold breakfast cereal */  cereal02    = sum(cer_s02);
/* Mayo or creamy dress */   mayo02      = sum(mayo_s02);
/* onion */                  onion02     = sum(oniog_s02, oniov_s02);
/* Poultry */                poultry02   = sum(chwi_s02, chwo_s02);
/* umb*/                     umb02       = sum(rcar_s02, ccar_s02, cel_s02);
/* carrot*/                  carrot02    = sum(rcar_s02, ccar_s02);
/* Orange juice*/            oj02        = sum(oj_s02);
/* Avocado  */               avo02       = . ;  *Not collected in 1990;
/* Other fruits  */          othfru02    = sum(ban_s02, cant_s02);

/* Whole grains */          wgrain02    = sum(cer_s02, ckcer_s02, oat_s02, dkbr_s02, ryebr_s02, brice_s02 ,oatbr_s02 ,bran_s02 ,wgerm_s02 ,popc_s02, ffpop_s02, tort_s02 );
/* Juice */                 juice02     = sum(aj_s02, othj_s02,prunj_s02);
/* Apple */                 apple02     = sum(appl_s02);
/* Soy products */          soy02       = sum(tofu_s02);
/* Cruciferous veg */       crucveg02   = sum(cauli_s02, kale_s02);
/* Condiments */            condi02     = sum(jam_s02);
/* Citrus fruits */         citrus02    = sum(oran_s02, grfr_s02);

/* Pizza */                 pizza02     = sum(pizza_s02);
/* corn */                  corn02     = sum(corn_s02);
/* beans*/                  beans02    = sum(peas_s02,sbean_s02, bean_s02);
  

FI02 = -(blueb02 * -0.022359623 + shchee02 * -0.000357103 + dietbev02 * 0.037505123 + frmeat02 * 0.041039490 
     + grape02 * -0.005362665 + liq02 * 0.042291654 + lfmilk02 * -0.037611764 + organ02 * 0.039207711 
     + mixveg02 * 0.091345174 + oildres02 * 0.016648388 + tomprod02 * 0.022265025 + wine02 * 0.016825528);

FI02a= -(shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02b= -(blueb02*-0.022359623 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02c= -(blueb02*-0.022359623+shchee02*-0.000357103  +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02d= -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02e = -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02f= -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02g= -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02h= -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02i= -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+oildres02*0.016648388 
+tomprod02*0.022265025+wine02*0.016825528);

FI02j= -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174
+tomprod02*0.022265025+wine02*0.016825528);

FI02k= -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+wine02*0.016825528);

FI02l= -(blueb02*-0.022359623+shchee02*-0.000357103 +dietbev02*0.037505123 +frmeat02*0.041039490+grape02*-0.005362665 
+liq02*0.042291654+lfmilk02*-0.037611764+organ02*0.039207711+mixveg02*0.091345174+oildres02*0.016648388 
+tomprod02*0.022265025);

run;

%serv06 (keep = id 
                blueb_s06 cotch_s06 crmch_s06 otch_s06 lccaf_s06 lcnoc_s06   
                hamb_s06 bmix_s06 pmain_s06 bmain_s06 rais_s06 liq_s06 skim_s06 
                livb_s06 livc_s06 mixv_s06 ooil_s06 tom_s06 toj_s06 tosau_s06
                yam_s06 osqua_s06 onut_s06 plyog_s06 flyog_s06 
                tea_s06 dtea_s06 beer_s06 lbeer_s06 but_s06 
                cream_s06 egg_s06 jam_s06 bfdog_s06 bacon_s06 
                procm_s06 pot_s06 whbr_s06 wrice_s06 crack_s06 
                engl_s06 muff_s06 pcake_s06 pasta_s06 pretz_s06 
                tort_s06 crsbr_s06 cer_s06 ckcer_s06 oat_s06 dkbr_s06 brice_s06 ryebr_s06 bran_s06 oatbr_s06 popc_s06 ffpop_s06 tort_s06 crsbr_s06
aj_s06 othj_s06 prunj_s06 appl_s06 tofu_s06 cauli_s06 kale_s06 jam_s06 oran_s06 grfr_s06 pizza_s06
                ban_s06 cant_s06 avo_s06 oj_s06 rcar_s06 ccar_s06 cel_s06
                chwi_s06 chwo_s06 oniog_s06 oniov_s06 mayo_s06 
                rwine_s06  wwine_s06 corn_s06 peas_s06 sbean_s06 bean_s06)

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

/* Yellow vegetables */      yelveg06    = sum(yam_s06, osqua_s06);
/* Nuts */                   othnut06    = sum(onut_s06);
/* Yogurt */                 yogurt06    = sum(plyog_s06,flyog_s06);
/* Tea */                    tea06       = sum(tea_s06,dtea_s06);
/* Beer */                   beer06      = sum(beer_s06,lbeer_s06);
/* High-fat dairy */         hfdairy06   = sum(but_s06, cream_s06); 
/* Eggs */                   eggs06      = sum(egg_s06);

/* Processed red meat */     prmeat06    = sum(bfdog_s06, bacon_s06, procm_s06);
/* Potatoes */               potato06    = sum(pot_s06);
/* Refined grain products */ rgrain06    = sum(whbr_s06, wrice_s06, crack_s06, engl_s06, muff_s06, pcake_s06, pasta_s06, pretz_s06, tort_s06, crsbr_s06);

/* cold breakfast cereal */  cereal06    = sum(cer_s06);
/* Mayo or creamy dress */   mayo06      = sum(mayo_s06);
/* onion */                  onion06     = sum(oniog_s06, oniov_s06);
/* Poultry */                poultry06   = sum(chwi_s06, chwo_s06);
/* umb*/                     umb06       = sum(rcar_s06, ccar_s06, cel_s06);
/* carrot*/                  carrot06    = sum(rcar_s06, ccar_s06);
/* Orange juice*/            oj06        = sum(oj_s06);
/* Avocado  */               avo06       = sum(avo_s06);
/* Other fruits  */          othfru06    = sum(ban_s06, cant_s06);

/* Whole grains */          wgrain06    = sum(cer_s06, ckcer_s06, oat_s06, dkbr_s06, brice_s06, ryebr_s06, bran_s06, oatbr_s06, popc_s06, ffpop_s06, tort_s06, crsbr_s06);
/* Juice */                 juice06     = sum(aj_s06, othj_s06, prunj_s06);
/* Apple */                 apple06     = sum(appl_s06);
/* Soy products */          soy06       = sum(tofu_s06);
/* Cruciferous veg */       crucveg06   = sum(cauli_s06, kale_s06);
/* Condiments */            condi06     = sum(jam_s06);
/* Citrus fruits */         citrus06    = sum(oran_s06, grfr_s06);

/* Pizza */                 pizza06     = sum(pizza_s06);

/* corn */                  corn06    = sum(corn_s06);
/* beans*/                  beans06    = sum(peas_s06,sbean_s06, bean_s06);
  
FI06 = -(blueb06 * -0.022359623 + shchee06 * -0.000357103 + dietbev06 * 0.037505123 + frmeat06 * 0.041039490 
     + grape06 * -0.005362665 + liq06 * 0.042291654 + lfmilk06 * -0.037611764 + organ06 * 0.039207711 
     + mixveg06 * 0.091345174 + oildres06 * 0.016648388 + tomprod06 * 0.022265025 + wine06 * 0.016825528);

FI06a= -(shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06b= -(blueb06*-0.022359623 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06c= -(blueb06*-0.022359623+shchee06*-0.000357103  +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06d= -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06e = -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06f= -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06g= -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06h= -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06i= -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+oildres06*0.016648388 
+tomprod06*0.022265025+wine06*0.016825528);

FI06j= -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174
+tomprod06*0.022265025+wine06*0.016825528);

FI06k= -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+wine06*0.016825528);

FI06l= -(blueb06*-0.022359623+shchee06*-0.000357103 +dietbev06*0.037505123 +frmeat06*0.041039490+grape06*-0.005362665 
+liq06*0.042291654+lfmilk06*-0.037611764+organ06*0.039207711+mixveg06*0.091345174+oildres06*0.016648388 
+tomprod06*0.022265025);

run;

%serv10 (keep = id 
                blueb_s10 cotch_s10 crmch_s10 otch_s10 lccaf_s10 lcnoc_s10   
                hamb_s10 bmix_s10 pmain_s10 bmain_s10 rais_s10 liq_s10 skim_s10 
                livb_s10 livc_s10 mixv_s10 ooil_s10 tom_s10 toj_s10 tosau_s10
                yam_s10 osqua_s10 onut_s10 plyog_s10 flyog_s10 
                tea_s10 beer_s10 lbeer_s10 but_s10 
                cream_s10 egg_s10 jam_s10 bfdog_s10 bacon_s10 
                procm_s10 pot_s10 whbr_s10 wrice_s10 
                engl_s10 muff_s10 pcake_s10 pasta_s10 pretz_s10 
                crackot_s10 cer_s10 ckcer_s10 oat_s10 dkbr_s10  brice_s10 ryebr_s10 oatbr_s10 wgerm_s10 popc_s10 ffpop_s10 tort_s10 crackww_s10
                aj_s10   othj_s10 prunj_s10 appl_s10 tofu_s10 cauli_s10 kale_s10 jam_s10 oran_s10 grfr_s10 pizza_s10
                ban_s10  cant_s10 avo_s10 oj_s10 rcar_s10 ccar_s10 cel_s10
                chwi_s10 chwo_s10  oniog_s10 oniov_s10 mayo_s10 
                rwine_s10  wwine_s10 corn_s10 peas_s10 sbean_s10 bean_s10)

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

/* Yellow vegetables */      yelveg10    = sum(yam_s10, osqua_s10);
/* Nuts */                   othnut10    = sum(onut_s10);
/* Yogurt */                 yogurt10    = sum(plyog_s10,flyog_s10);
/* Tea */                    tea10       = sum(tea_s10);
/* Beer */                   beer10      = sum(beer_s10,lbeer_s10);
/* High-fat dairy */         hfdairy10   = sum(but_s10, cream_s10); 
/* Eggs */                   eggs10      = sum(egg_s10);
/* Condiments */             condi10     = sum(jam_s10); 
/* Processed red meat */     prmeat10    = sum(bfdog_s10, bacon_s10, procm_s10);
/* Potatoes */               potato10    = sum(pot_s10);
/* Refined grain products */ rgrain10    = sum(whbr_s10, wrice_s10, engl_s10,   muff_s10, pcake_s10, pasta_s10, pretz_s10, crackot_s10);

/* cold breakfast cereal */  cereal10    = sum(cer_s10);
/* Mayo or creamy dress */   mayo10      = sum(mayo_s10);
/* onion */                  onion10     = sum(oniog_s10, oniov_s10);
/* Poultry */                poultry10   = sum(chwi_s10, chwo_s10);
/* umb*/                     umb10       = sum(rcar_s10, ccar_s10, cel_s10);
/* carrot*/                  carrot10    = sum(rcar_s10, ccar_s10);
/* Orange juice*/            oj10        = sum(oj_s10);
/* Avocado  */               avo10       = sum(avo_s10);
/* Other fruits  */          othfru10    = sum(ban_s10, cant_s10);

/* Whole grains */          wgrain10    = sum(cer_s10 ,ckcer_s10 ,oat_s10, dkbr_s10, brice_s10, ryebr_s10, oatbr_s10 ,wgerm_s10, popc_s10, ffpop_s10, tort_s10, crackww_s10);
/* Juice */                 juice10     = sum(aj_s10, othj_s10, prunj_s10);
/* Apple */                 apple10     = sum(appl_s10);
/* Soy products */          soy10       = sum(tofu_s10);
/* Cruciferous veg */       crucveg10   = sum(cauli_s10, kale_s10);

/* Citrus fruits */         citrus10    = sum(oran_s10, grfr_s10);

/* Pizza */                 pizza10     = sum(pizza_s10);
/* corn */                  corn10    = sum(corn_s10);
/* beans*/                  beans10    = sum(peas_s10,sbean_s10, bean_s10);
  


FI10 = -(blueb10 * -0.022359623 + shchee10 * -0.000357103 + dietbev10 * 0.037505123 + frmeat10 * 0.041039490 
     + grape10 * -0.005362665 + liq10 * 0.042291654 + lfmilk10 * -0.037611764 + organ10 * 0.039207711 
     + mixveg10 * 0.091345174 + oildres10 * 0.016648388 + tomprod10 * 0.022265025 + wine10 * 0.016825528);

FI10a= -(shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10b= -(blueb10*-0.022359623 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10c= -(blueb10*-0.022359623+shchee10*-0.000357103  +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10d= -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10e = -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10f= -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10g= -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10h= -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10i= -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+oildres10*0.016648388 
+tomprod10*0.022265025+wine10*0.016825528);

FI10j= -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174
+tomprod10*0.022265025+wine10*0.016825528);

FI10k= -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+wine10*0.016825528);

FI10l= -(blueb10*-0.022359623+shchee10*-0.000357103 +dietbev10*0.037505123 +frmeat10*0.041039490+grape10*-0.005362665 
+liq10*0.042291654+lfmilk10*-0.037611764+organ10*0.039207711+mixveg10*0.091345174+oildres10*0.016648388 
+tomprod10*0.022265025);

run;


libname NHAHEI '/proj/hpalcs/hpalc0b/DIETSCORES/NHS/'; *** path to AHEI2010 of Stephanie Chiuve***;

data ahei84; 
  set NHAHEI.diet84l; 
  ahei84_na=nAHEI84_noal; 
  ahei84_a=nAHEI84a; 
  ahei84_nowgr =  sum (meataI84, nutI84, ssbI84, tvegI84, frtI84a, ppolyI84, tranI84, nETOHI84c, omegI84, /*wgI84,*/ na84s);
  ahei84_noveg =  sum (meataI84, nutI84, ssbI84, /* tvegI84, */ frtI84a, ppolyI84, tranI84, nETOHI84c, omegI84, wgI84, na84s);
  ahei84_nofrt =  sum (meataI84, nutI84, ssbI84, tvegI84,  /* frtI84a, */ ppolyI84, tranI84, nETOHI84c, omegI84, wgI84, na84s);
  ahei84_noleg =  sum (meataI84, /* nutI84, */ ssbI84, tvegI84,  frtI84a, ppolyI84, tranI84, nETOHI84c, omegI84, wgI84, na84s);
  keep id ahei84_a ahei84_na ahei84_nowgr ahei84_noveg ahei84_nofrt ahei84_noleg; 
  proc sort; by id;
run;

data ahei86; 
  set NHAHEI.diet86l; 
  ahei86_na=nAHEI86_noal; 
  ahei86_a=nAHEI86a; 
  ahei86_nowgr =  sum (meataI86, nutI86, ssbI86, tvegI86, frtI86a, ppolyI86, tranI86, nETOHI86c, omegI86, /*wgI86,*/ na86s);
  ahei86_noveg =  sum (meataI86, nutI86, ssbI86, /* tvegI86, */ frtI86a, ppolyI86, tranI86, nETOHI86c, omegI86, wgI86, na86s);
  ahei86_nofrt =  sum (meataI86, nutI86, ssbI86, tvegI86,  /* frtI86a, */ ppolyI86, tranI86, nETOHI86c, omegI86, wgI86, na86s);
  ahei86_noleg =  sum (meataI86, /* nutI86, */ ssbI86, tvegI86,  frtI86a, ppolyI86, tranI86, nETOHI86c, omegI86, wgI86, na86s);
  keep id ahei86_a ahei86_na ahei86_nowgr ahei86_noveg ahei86_nofrt ahei86_noleg; 
  proc sort; by id;
run;

data ahei90; 
  set NHAHEI.diet90l; 
  ahei90_na=nAHEI90_noal; 
  ahei90_a=nAHEI90a; 
  ahei90_nowgr =  sum (meataI90, nutI90, ssbI90, tvegI90, frtI90a, ppolyI90, tranI90, nETOHI90c, omegI90, /*wgI90,*/ na90s);
  ahei90_noveg =  sum (meataI90, nutI90, ssbI90, /* tvegI90, */ frtI90a, ppolyI90, tranI90, nETOHI90c, omegI90, wgI90, na90s);
  ahei90_nofrt =  sum (meataI90, nutI90, ssbI90, tvegI90,  /* frtI90a, */ ppolyI90, tranI90, nETOHI90c, omegI90, wgI90, na90s);
  ahei90_noleg =  sum (meataI90, /* nutI90, */ ssbI90, tvegI90,  frtI90a, ppolyI90, tranI90, nETOHI90c, omegI90, wgI90, na90s);
  keep id ahei90_a ahei90_na ahei90_nowgr ahei90_noveg ahei90_nofrt ahei90_noleg;
  proc sort; by id;
run;

data ahei94; 
  set NHAHEI.diet94l; 
  ahei94_na=nAHEI94_noal; 
  ahei94_a=nAHEI94a; 
  ahei94_nowgr =  sum (meataI94, nutI94, ssbI94, tvegI94, frtI94a, ppolyI94, tranI94, nETOHI94c, omegI94, /*wgI94,*/ na94s);
  ahei94_noveg =  sum (meataI94, nutI94, ssbI94, /* tvegI94, */ frtI94a, ppolyI94, tranI94, nETOHI94c, omegI94, wgI94, na94s);
  ahei94_nofrt =  sum (meataI94, nutI94, ssbI94, tvegI94,  /* frtI94a, */ ppolyI94, tranI94, nETOHI94c, omegI94, wgI94, na94s);
  ahei94_noleg =  sum (meataI94, /* nutI94, */ ssbI94, tvegI94,  frtI94a, ppolyI94, tranI94, nETOHI94c, omegI94, wgI94, na94s);
  keep id ahei94_a ahei94_na ahei94_nowgr ahei94_noveg ahei94_nofrt ahei94_noleg; 
  proc sort; by id;
run;

data ahei98; 
  set NHAHEI.diet98l; 
  ahei98_na=nAHEI98_noal; 
  ahei98_a=nAHEI98a; 
  ahei98_nowgr =  sum (meataI98, nutI98, ssbI98, tvegI98, frtI98a, ppolyI98, tranI98, nETOHI98c, omegI98, /*wgI98,*/ na98s);
  ahei98_noveg =  sum (meataI98, nutI98, ssbI98, /* tvegI98, */ frtI98a, ppolyI98, tranI98, nETOHI98c, omegI98, wgI98, na98s);
  ahei98_nofrt =  sum (meataI98, nutI98, ssbI98, tvegI98,  /* frtI98a, */ ppolyI98, tranI98, nETOHI98c, omegI98, wgI98, na98s);
  ahei98_noleg =  sum (meataI98, /* nutI98, */ ssbI98, tvegI98,  frtI98a, ppolyI98, tranI98, nETOHI98c, omegI98, wgI98, na98s);
  keep id ahei98_a ahei98_na ahei98_nowgr ahei98_noveg ahei98_nofrt ahei98_noleg; 
  proc sort; by id;
run;

data ahei02; 
  set NHAHEI.diet02l; 
  ahei02_na=nAHEI02_noal; 
  ahei02_a=nAHEI02a; 
  ahei02_nowgr =  sum (meataI02, nutI02, ssbI02, tvegI02, frtI02a, ppolyI02, tranI02, nETOHI02c, omegI02, /*wgI02,*/ na02s);
  ahei02_noveg =  sum (meataI02, nutI02, ssbI02, /* tvegI02, */ frtI02a, ppolyI02, tranI02, nETOHI02c, omegI02, wgI02, na02s);
  ahei02_nofrt =  sum (meataI02, nutI02, ssbI02, tvegI02,  /* frtI02a, */ ppolyI02, tranI02, nETOHI02c, omegI02, wgI02, na02s);
  ahei02_noleg =  sum (meataI02, /* nutI02, */ ssbI02, tvegI02,  frtI02a, ppolyI02, tranI02, nETOHI02c, omegI02, wgI02, na02s);
  keep id ahei02_a ahei02_na ahei02_nowgr ahei02_noveg ahei02_nofrt ahei02_noleg; 
  proc sort; by id;
run;

data ahei06; 
  set NHAHEI.diet06l; 
  ahei06_na=nAHEI06_noal; 
  ahei06_a=nAHEI06a;
  ahei06_nowgr =  sum (meataI06, nutI06, ssbI06, tvegI06, frtI06a, ppolyI06, tranI06, nETOHI06c, omegI06, /*wgI06,*/ na06s);
  ahei06_noveg =  sum (meataI06, nutI06, ssbI06, /* tvegI06, */ frtI06a, ppolyI06, tranI06, nETOHI06c, omegI06, wgI06, na06s);
  ahei06_nofrt =  sum (meataI06, nutI06, ssbI06, tvegI06,  /* frtI06a, */ ppolyI06, tranI06, nETOHI06c, omegI06, wgI06, na06s);
  ahei06_noleg =  sum (meataI06, /* nutI06, */ ssbI06, tvegI06,  frtI06a, ppolyI06, tranI06, nETOHI06c, omegI06, wgI06, na06s);
  keep id ahei06_a ahei06_na ahei06_nowgr ahei06_noveg ahei06_nofrt ahei06_noleg; 
  proc sort; by id;
run;

data ahei10; 
  set NHAHEI.diet10l; 
  ahei10_na=nAHEI10_noal; 
  ahei10_a=nAHEI10a;
  ahei10_nowgr =  sum (meataI10, nutI10, ssbI10, tvegI10, frtI10a, ppolyI10, tranI10, nETOHI10c, omegI10, /*wgI10,*/ na10s);
  ahei10_noveg =  sum (meataI10, nutI10, ssbI10, /* tvegI10, */ frtI10a, ppolyI10, tranI10, nETOHI10c, omegI10, wgI10, na10s);
  ahei10_nofrt =  sum (meataI10, nutI10, ssbI10, tvegI10,  /* frtI10a, */ ppolyI10, tranI10, nETOHI10c, omegI10, wgI10, na10s);
  ahei10_noleg =  sum (meataI10, /* nutI10, */ ssbI10, tvegI10,  frtI10a, ppolyI10, tranI10, nETOHI10c, omegI10, wgI10, na10s);
rmea10w = meataI10;
nut10 = nutI10;
ssb10 = ssbI10;
tveg10 = tvegI10;
fruit10 = frtI10a;
ppoly10 = ppolyI10;
ptran10 = tranI10;
drinks10 = nETOHI10c;
mgomg10 = omegI10;
whgrn10a = wgI10;
  keep id ahei10_a ahei10_na ahei10_nowgr ahei10_noveg ahei10_nofrt ahei10_noleg; 
  proc sort; by id;
run;


data ahei; 
    merge ahei84 ahei86  ahei90  ahei94  ahei98  ahei02  ahei06  ahei10; 
    by id; 

    ahei88_a =.; ahei92_a =.; ahei96_a =.; ahei00_a =.; ahei04_a =.; ahei08_a =.;   
    ahei88_na=.; ahei92_na=.; ahei96_na=.; ahei00_na=.; ahei04_na=.; ahei08_na=.;
    ahei88_nowgr =.; ahei92_nowgr =.; ahei96_nowgr =.; ahei00_nowgr =.; ahei04_nowgr =.; ahei08_nowgr =.; 
    ahei88_noveg =.; ahei92_noveg =.; ahei96_noveg =.; ahei00_noveg =.; ahei04_noveg =.; ahei08_noveg =.; 
    ahei88_nofrt =.; ahei92_nofrt =.; ahei96_nofrt =.; ahei00_nofrt =.; ahei04_nofrt =.; ahei08_nofrt =.;
    ahei88_noleg =.; ahei92_noleg =.; ahei96_noleg =.; ahei00_noleg =.; ahei04_noleg =.; ahei08_noleg =.;

    array aheial {14} ahei84_a ahei86_a  ahei88_a  ahei90_a  ahei92_a  ahei94_a  ahei96_a  ahei98_a  ahei00_a  ahei02_a  ahei04_a  ahei06_a  ahei08_a  ahei10_a ;
    array aheino {14} ahei84_na ahei86_na ahei88_na ahei90_na ahei92_na ahei94_na ahei96_na ahei98_na ahei00_na ahei02_na ahei04_na ahei06_na ahei08_na ahei10_na;
    array aheinowgr {14} ahei84_nowgr ahei86_nowgr ahei88_nowgr ahei90_nowgr ahei92_nowgr ahei94_nowgr ahei96_nowgr ahei98_nowgr ahei00_nowgr ahei02_nowgr ahei04_nowgr ahei06_nowgr ahei08_nowgr ahei10_nowgr;
    array aheinoveg {14} ahei84_noveg  ahei86_noveg ahei88_noveg ahei90_noveg ahei92_noveg ahei94_noveg ahei96_noveg ahei98_noveg ahei00_noveg ahei02_noveg ahei04_noveg ahei06_noveg ahei08_noveg ahei10_noveg;
    array aheinofrt {14} ahei84_nofrt ahei86_nofrt ahei88_nofrt ahei90_nofrt ahei92_nofrt ahei94_nofrt ahei96_nofrt ahei98_nofrt ahei00_nofrt ahei02_nofrt ahei04_nofrt ahei06_nofrt ahei08_nofrt ahei10_nofrt;
    array aheinoleg {14} ahei84_noleg ahei86_noleg ahei88_noleg ahei90_noleg ahei92_noleg ahei94_noleg ahei96_noleg ahei98_noleg ahei00_noleg ahei02_noleg ahei04_noleg ahei06_noleg ahei08_noleg ahei10_noleg;
    
    do i=1 to 14;
        if aheial{i}<0 or aheial{i}>110 then aheial{i}=.;
        if aheino{i}<0 or aheino{i}>110 then aheino{i}=.;
        if aheinowgr{i}<0 or aheinowgr{i}>110 then aheinowgr{i}=.;
        if aheinoveg{i}<0 or aheinoveg{i}>110 then aheinoveg{i}=.;
        if aheinofrt{i}<0 or aheinofrt{i}>110 then aheinofrt{i}=.;
        if aheinoleg{i}<0 or aheinoleg{i}>110 then aheinoleg{i}=.;

    end;

    do i=2 to 14;
        if aheial{i}=. then aheial{i}=aheial{i-1};
        if aheino{i}=. then aheino{i}=aheino{i-1};
        if aheinowgr{i}=. then aheinowgr{i}=aheinowgr{i-1};
        if aheinoveg{i}=. then aheinoveg{i}=aheinoveg{i-1};
        if aheinofrt{i}=. then aheinofrt{i}=aheinofrt{i-1};
        if aheinoleg{i}=. then aheinoleg{i}=aheinoleg{i-1};
    end;
run;

proc sort; by id; run;
      
   
    **************************************************
    *         database of BMI   & covariables        *
    **************************************************;

%der7620 (keep =  mobf                                      /*month of birth*/
                  yobf                                      /*year of birth*/

    irt76  irt78  irt80  irt82  irt84  irt86  irt88  irt90  irt92  irt94  
    irt96  irt98  irt00  irt02  irt04  irt06  irt08  irt10  irt12  /* irt14  irt16 */

    bmi76   bmi78   bmi80   bmi82   bmi84   bmi86   bmi88   bmi90   bmi92   bmi94  
    bmi96   bmi98   bmi00   bmi02   bmi04   bmi06   bmi08   bmi10   bmi12   /* bmi14  bmi16 */

    race9204/* 1.White; 2.Black; 3.American Indian; 4.Asian; 5.Hawaiian */  race  white

    smkdr76  smkdr78  smkdr80  smkdr82  smkdr84  smkdr86  smkdr88  smkdr90  smkdr92  smkdr94  
    smkdr96  smkdr98  smkdr00  smkdr02  smkdr04  smkdr06  smkdr08  smkdr10  smkdr12  /* smkdr14  smkdr16   */ 
    
    dmnp76  dmnp78  dmnp80  dmnp82  dmnp84  dmnp86  dmnp88  dmnp90  dmnp92  dmnp94  
    dmnp96  dmnp98  dmnp00  dmnp02  dmnp04 


    nhor76  nhor78  nhor80  nhor82  nhor84  nhor86  nhor88  nhor90  nhor92  nhor94  
    nhor96  nhor98  nhor00  nhor02  nhor04  nhor06  nhor08  nhor10  nhor12  /* nhor14  nhor16 */
  
    can76  can78  can80  can82  can84  can86  can88  can90  can92  can94  
    can96  can98  can00  can02  can04  can06  can08  can10  can12  /* can14  can16 */

    hrt76  hrt78  hrt80  hrt82  hrt84  hrt86  hrt88  hrt90  hrt92  hrt94  
    hrt96  hrt98  hrt00  hrt02  hrt04  hrt06  hrt08  hrt10  hrt12  /* hrt14  hrt16 */
    ocu76   ocu78   ocu80   ocu82   ocu84                                                                                                                                /*ORAL CONTRACEPTIVE USE*/
    pkyr76  pkyr78  pkyr80  pkyr82  pkyr84  pkyr86  pkyr88  pkyr90  pkyr92  pkyr94  
    pkyr96  pkyr98  pkyr00  pkyr02  pkyr04  pkyr06  pkyr08  pkyr10  pkyr12  /* pkyr14   pkyr16 */     /*pack years smoked*/
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
%nur96(keep=db96 mi96 ang96 cabg96 str96 chol96 hbp96 wt96 thiaz96 lasix96);

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
%nur08(keep=db08 mi08 ang08 cabg08 str08 chol08 hbp08 wt08 thiaz08 lasix08);

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


                              ********************
                              *     PRS gout    *
                              ********************;

proc import datafile="/udd/nhadj/GoutSNPs/urate.grs.and.risk.alleles.dat"
    out=GOUTPRS
    dbms=dlm
    replace;
    delimiter='09'x; 
    getnames=yes; 
run;

    data GOUTPRS;
    set  GOUTPRS; 
    id = studyID;      
    run; 

data GOUTPRS;set GOUTPRS(keep=id prs_urate);run;

proc sort data=GOUTPRS; by id; run;



                              ********************
                              *      database    *
                              ********************;

    data xwang;
    merge gout dead ahei GOUTPRS
          der7620(in=a)  n80_nts n84_nts n86_nts n90_nts n94_nts  n98_nts  n02_nts  n06_nts n10_nts          
          serv84_cat serv86_cat serv90_cat serv94_cat serv98_cat serv02_cat serv06_cat serv10_cat
          n767880 nur82 nur84 nur86 nur88  nur90 nur92 nur94 nur96 nur98 nur00 nur02 nur04 nur06 nur08 nur10
          vitamin meds
          act8614;  
     by id;
     if a;
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
array   ahei    {8} ahei84_a ahei86_a ahei90_a ahei94_a ahei98_a ahei02_a ahei06_a ahei10_a;
array   FI      {8} FI84   FI86     FI90    FI94    FI98     FI02    FI06    FI10  ;
array   FIa     {8} FI84a  FI86a    FI90a   FI94a   FI98a    FI02a   FI06a   FI10a  ;
array   FIb     {8} FI84b  FI86b    FI90b   FI94b   FI98b    FI02b   FI06b   FI10b  ;
array   FIc     {8} FI84c  FI86c    FI90c   FI94c   FI98c    FI02c   FI06c   FI10c  ;
array   FId     {8} FI84d  FI86d    FI90d   FI94d   FI98d    FI02d   FI06d   FI10d  ;
array   FIe     {8} FI84e  FI86e    FI90e   FI94e   FI98e    FI02e   FI06e   FI10e  ;
array   FIf     {8} FI84f  FI86f    FI90f   FI94f   FI98f    FI02f   FI06f   FI10f  ;
array   FIg     {8} FI84g  FI86g    FI90g   FI94g   FI98g    FI02g   FI06g   FI10g  ;
array   FIh     {8} FI84h  FI86h    FI90h   FI94h   FI98h    FI02h   FI06h   FI10h  ;
array   FIi     {8} FI84i  FI86i    FI90i   FI94i   FI98i    FI02i   FI06i   FI10i  ;
array   FIj     {8} FI84j  FI86j    FI90j   FI94j   FI98j    FI02j   FI06j   FI10j  ;
array   FIk     {8} FI84k  FI86k    FI90k   FI94k   FI98k    FI02k   FI06k   FI10k  ;
array   FIl     {8} FI84l  FI86l    FI90l   FI94l   FI98l    FI02l   FI06l   FI10l  ;
array   cancee  {8} can84   can86   can90   can94   can98  can02   can06   can10;
array   hrtt    {8} hrt84   hrt86   hrt90   hrt94   hrt98  hrt02   hrt06   hrt10;
array   diabb   {8} db84    db86    db90    db94    db98   db02    db06    db10;
array   strokk  {8} str84   str86   str90   str94   str98  str02   str06   str10;
array   cabgff  {8} cabg84  cabg86  cabg90  cabg94  cabg98 cabg02  cabg06  cabg10;
  
do i=2 to DIM(energy);
       

if energy{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1  then energy{i}=energy{i-1};
if ahei{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1  then ahei{i}=ahei{i-1};
if FI{i}=.  or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1  then FI{i}=FI{i-1};
if FIa{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIa{i}=FIa{i-1};
if FIb{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIb{i}=FIb{i-1};
if FIc{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIc{i}=FIc{i-1};
if FId{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FId{i}=FId{i-1};
if FIe{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIe{i}=FIe{i-1};
if FIf{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIf{i}=FIf{i-1};
if FIg{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIg{i}=FIg{i-1};
if FIh{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIh{i}=FIh{i-1};
if FIi{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIi{i}=FIi{i-1};
if FIj{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIj{i}=FIj{i-1};
if FIk{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIk{i}=FIk{i-1};
if FIl{i}=. or cancee{i}=1 or hrtt{i}=1 or diabb{i}=1 or strokk{i}=1 then FIl{i}=FIl{i-1};

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

%cumavg(cycle=8, cyclevar=13,  
  varin=           
FI84 FI84a FI84b FI84c FI84d FI84e FI84f FI84g FI84h FI84i FI84j FI84k FI84l 
FI86 FI86a FI86b FI86c FI86d FI86e FI86f FI86g FI86h FI86i FI86j FI86k FI86l
FI90 FI90a FI90b FI90c FI90d FI90e FI90f FI90g FI90h FI90i FI90j FI90k FI90l  
FI94 FI94a FI94b FI94c FI94d FI94e FI94f FI94g FI94h FI94i FI94j FI94k FI94l  
FI98 FI98a FI98b FI98c FI98d FI98e FI98f FI98g FI98h FI98i FI98j FI98k FI98l  
FI02 FI02a FI02b FI02c FI02d FI02e FI02f FI02g FI02h FI02i FI02j FI02k FI02l  
FI06 FI06a FI06b FI06c FI06d FI06e FI06f FI06g FI06h FI06i FI06j FI06k FI06l  
FI10 FI10a FI10b FI10c FI10d FI10e FI10f FI10g FI10h FI10i FI10j FI10k FI10l  , 

  varout=      
FI84v FI84av FI84bv FI84cv FI84dv FI84ev FI84fv FI84gv FI84hv FI84iv FI84jv FI84kv FI84lv  
FI86v FI86av FI86bv FI86cv FI86dv FI86ev FI86fv FI86gv FI86hv FI86iv FI86jv FI86kv FI86lv  
FI90v FI90av FI90bv FI90cv FI90dv FI90ev FI90fv FI90gv FI90hv FI90iv FI90jv FI90kv FI90lv  
FI94v FI94av FI94bv FI94cv FI94dv FI94ev FI94fv FI94gv FI94hv FI94iv FI94jv FI94kv FI94lv  
FI98v FI98av FI98bv FI98cv FI98dv FI98ev FI98fv FI98gv FI98hv FI98iv FI98jv FI98kv FI98lv  
FI02v FI02av FI02bv FI02cv FI02dv FI02ev FI02fv FI02gv FI02hv FI02iv FI02jv FI02kv FI02lv  
FI06v FI06av FI06bv FI06cv FI06dv FI06ev FI06fv FI06gv FI06hv FI06iv FI06jv FI06kv FI06lv  
FI10v FI10av FI10bv FI10cv FI10dv FI10ev FI10fv FI10gv FI10hv FI10iv FI10jv FI10kv FI10lv  
);

run;


data xwang;
set xwang;
%cumavg(cycle=8, cyclevar=3,
  varin= 
          calor84n  alco84n ahei84_a
          calor86n  alco86n ahei86_a
          calor90n  alco90n ahei90_a
          calor94n  alco94n ahei94_a
          calor98n  alco98n ahei98_a
          calor02n  alco02n ahei02_a
          calor06n  alco06n ahei06_a
          calor10n  alco10n ahei10_a,
        
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
                 FI84v      FI86v       FI90v       FI94v       FI98v       FI02v       FI06v       FI10v
     FI84av     FI86av      FI90av      FI94av      FI98av      FI02av      FI06av      FI10av  
FI84bv     FI86bv      FI90bv      FI94bv      FI98bv      FI02bv      FI06bv      FI10bv  
FI84cv     FI86cv      FI90cv      FI94cv      FI98cv      FI02cv      FI06cv      FI10cv  
FI84dv     FI86dv      FI90dv      FI94dv      FI98dv      FI02dv      FI06dv      FI10dv  
FI84ev     FI86ev      FI90ev      FI94ev      FI98ev      FI02ev      FI06ev      FI10ev  
FI84fv     FI86fv      FI90fv      FI94fv      FI98fv      FI02fv      FI06fv      FI10fv  
FI84gv     FI86gv      FI90gv      FI94gv      FI98gv      FI02gv      FI06gv      FI10gv  
FI84hv     FI86hv      FI90hv      FI94hv      FI98hv      FI02hv      FI06hv      FI10hv  
FI84iv     FI86iv      FI90iv      FI94iv      FI98iv      FI02iv      FI06iv      FI10iv  
FI84jv     FI86jv      FI90jv      FI94jv      FI98jv      FI02jv      FI06jv      FI10jv  
FI84kv     FI86kv      FI90kv      FI94kv      FI98kv      FI02kv      FI06kv      FI10kv  
FI84lv     FI86lv      FI90lv      FI94lv      FI98lv      FI02lv      FI06lv      FI10lv  
 ahei84_av ahei86_av ahei90_av ahei94_av ahei98_av ahei02_av ahei06_av ahei10_av
               ;
       ranks     calor84q calor86q  calor90q   calor94q   calor98q   calor02q   calor06q   calor10q
               FI84q     FI86q      FI90q      FI94q      FI98q      FI02q      FI06q      FI10q  
FI84aq    FI86aq     FI90aq     FI94aq     FI98aq     FI02aq     FI06aq     FI10aq  
FI84bq    FI86bq     FI90bq     FI94bq     FI98bq     FI02bq     FI06bq     FI10bq  
FI84cq    FI86cq     FI90cq     FI94cq     FI98cq     FI02cq     FI06cq     FI10cq  
FI84dq    FI86dq     FI90dq     FI94dq     FI98dq     FI02dq     FI06dq     FI10dq  
FI84eq    FI86eq     FI90eq     FI94eq     FI98eq     FI02eq     FI06eq     FI10eq  
FI84fq    FI86fq     FI90fq     FI94fq     FI98fq     FI02fq     FI06fq     FI10fq  
FI84gq    FI86gq     FI90gq     FI94gq     FI98gq     FI02gq     FI06gq     FI10gq  
FI84hq    FI86hq     FI90hq     FI94hq     FI98hq     FI02hq     FI06hq     FI10hq  
FI84iq    FI86iq     FI90iq     FI94iq     FI98iq     FI02iq     FI06iq     FI10iq  
FI84jq    FI86jq     FI90jq     FI94jq     FI98jq     FI02jq     FI06jq     FI10jq  
FI84kq    FI86kq     FI90kq     FI94kq     FI98kq     FI02kq     FI06kq     FI10kq  
FI84lq    FI86lq     FI90lq     FI94lq     FI98lq     FI02lq     FI06lq     FI10lq

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
delete    gout dead ahei serv84_cat serv86_cat serv90_cat serv94_cat serv98_cat serv02_cat serv06_cat serv10_cat
          n80_nts n84_nts n86_nts n90_nts n94_nts  n98_nts  n02_nts  n06_nts n10_nts
          der7620 n767880 nur82 nur84 nur86 nur88 nur90 nur92 nur94 nur96 nur98 nur00 nur02 nur04 nur06 nur08 nur10 nur12 nur14 nur16 
          meds vitamin act8614;
      RUN;



  data nhs1hei;
  set quintile end=_end_; 
*include lasix use with thiaz use;

  if lasix94=1 then thiaz94=1;
  if lasix96=1 then thiaz96=1;
  if lasix98=1 then thiaz98=1;
  if lasix00=1 then thiaz00=1;
  if lasix02=1 then thiaz02=1;
  if lasix04=1 then thiaz04=1;
  if lasix06=1 then thiaz06=1;
  if lasix08=1 then thiaz08=1;

array   irt     {14}    irt84   irt86   irt88   irt90   irt92   irt94   irt96   irt98   irt00   irt02   irt04   irt06   irt08   /* irt10   irt12  */   cutoff;
array   tvar    {13}    t84     t86     t88     t90     t92     t94     t96     t98     t00     t02     t04     t06     t08     /* t10     t12  */  ;
array   period  {13}    period1 period2 period3 period4 period5 period6 period7 period8 period9 period10 period11 period12 period13 /* period14 period15 */ ;
array   bmiv    {13}    bmi84   bmi86   bmi88   bmi90   bmi92   bmi94   bmi96   bmi98   bmi00   bmi02   bmi04   bmi06   bmi08   /* bmi10   bmi12 */   ;
array   age     {13}    age84   age86   age88   age90   age92   age94   age96   age98   age00   age02   age04   age06   age08   /* age10   age12 */  ;

array   nsmk    {13}    smkdr84 smkdr86 smkdr88 smkdr90 smkdr92 smkdr94 smkdr96 smkdr98 smkdr00 smkdr02 smkdr04 smkdr06 smkdr08 /* smkdr10 smkdr12 */ ;
array   pkyr    {13}    pkyr84   pkyr86   pkyr88   pkyr90   pkyr92   pkyr94   pkyr96    pkyr98    pkyr00    pkyr02    pkyr04    pkyr06    pkyr08   /* pkyr10   pkyr12  */  ;

array  diur     {13}    thiaz82  thiaz82 thiaz88 thiaz88 thiaz88 thiaz94 thiaz96 thiaz98 thiaz00 thiaz02  thiaz04 thiaz06 thiaz08;

array   calornv {13}    calor84nv calor86nv calor86nv calor90nv calor90nv calor94nv calor94nv calor98nv calor98nv calor02nv calor02nv calor06nv calor06nv /* calor10nv calor10nv */ ;
array   calor   {13}    calor84n calor86n calor86n calor90n calor90n calor94n calor94n calor98n calor98n calor02n calor02n calor06n calor06n /* calor10n calor10n  */;
array   qtei    {13}    calor84q calor86q calor86q calor90q calor90q calor94q calor94q calor98q calor98q calor02q calor02q calor06q calor06q /* calor10q calor10q  */;

array   aheinv {13}    ahei84_av ahei86_av ahei86_av ahei90_av ahei90_av ahei94_av ahei94_av ahei98_av ahei98_av ahei02_av ahei02_av ahei06_av ahei06_av ;
array   qahei  {13}    ahei84q   ahei86q   ahei86q   ahei90q   ahei90q   ahei94q   ahei94q   ahei98q   ahei98q   ahei02q   ahei02q   ahei06q   ahei06q ;


array   alco    {13}    alco84n alco86n alco86n alco90n alco90n alco94n alco94n alco98n alco98n alco02n alco02n alco06n alco06n /* alco10n alco10n  */;
array   alcocum {13}    alco84v alco86v alco86v alco90v alco90v alco94v alco94v alco98v alco98v alco02v alco02v alco06v alco06v /* alco10v alco10v  */  ;

array   actc    {13}    actc86  actc86  actc88  actc88  actc92  actc94  actc96  actc98 actc98 actc00  actc00  actc04   actc08  ;
array   actm    {13}    act86m  act86m  act88m  act88m  act92m  act94m  act96m  act98m act98m act00m  act00m  act04m  act08m  ;

array   dmnp    {13}    dmnp84   dmnp86  dmnp88   dmnp90   dmnp92   dmnp94   dmnp96  dmnp98  dmnp00  dmnp02  dmnp04  dmnp04  dmnp04  /* dmnp04  dmnp04  */;
array   ocu     {13}    ocu84    ocu86   ocu88    ocu90    ocu92    ocu94    ocu96   ocu98   ocu00   ocu02   ocu04   ocu06   ocu08   /* ocu10   ocu12 */  ;
array   hor     {13}    nhor84   nhor86  nhor88   nhor90   nhor92   nhor94   nhor96  nhor98  nhor00  nhor02  nhor04  nhor06  nhor08  /* nhor10  nhor12  */;

array   mvyn    {13}    mvitu84  mvitu86  mvitu88  mvitu90  mvitu92  mvitu94  mvitu96   mvitu98   mvitu00   mvitu02   mvitu04   mvitu06   mvitu08  /* mvitu10  mvitu12  */ ;
array   asparr  {13}    aspu84   aspu86   aspu88   aspu90   aspu92   aspu94   aspu96    aspu98    aspu00    aspu02    aspu04    aspu06    aspu08   /* aspu10   aspu12 */   ;

array    FIm   {13}    FI84v   FI86v   FI86v   FI90v   FI90v   FI94v   FI94v   FI98v   FI98v   FI02v   FI02v   FI06v   FI06v  /*  FI10v  FI10v */ ;
array    FIs   {13}    FI84q   FI86q   FI86q   FI90q   FI90q   FI94q   FI94q   FI98q   FI98q   FI02q   FI02q   FI06q   FI06q   /* FI10q  FI10q */ ;


array    FIam   {13}    FI84av   FI86av   FI86av   FI90av   FI90av   FI94av   FI94av   FI98av   FI98av   FI02av   FI02av   FI06av   FI06av  /*  FI10av  FI10av */ ;
array    FIas   {13}    FI84aq   FI86aq   FI86aq   FI90aq   FI90aq   FI94aq   FI94aq   FI98aq   FI98aq   FI02aq   FI02aq   FI06aq   FI06aq   /* FI10aq  FI10aq */ ;

array    FIbm   {13}    FI84bv   FI86bv   FI86bv   FI90bv   FI90bv   FI94bv   FI94bv   FI98bv   FI98bv   FI02bv   FI02bv   FI06bv   FI06bv  /*  FI10bv  FI10bv */ ;
array    FIbs   {13}    FI84bq   FI86bq   FI86bq   FI90bq   FI90bq   FI94bq   FI94bq   FI98bq   FI98bq   FI02bq   FI02bq   FI06bq   FI06bq   /* FI10bq  FI10bq */ ;

array    FIcm   {13}    FI84cv   FI86cv   FI86cv   FI90cv   FI90cv   FI94cv   FI94cv   FI98cv   FI98cv   FI02cv   FI02cv   FI06cv   FI06cv  /*  FI10cv  FI10cv */ ;
array    FIcs   {13}    FI84cq   FI86cq   FI86cq   FI90cq   FI90cq   FI94cq   FI94cq   FI98cq   FI98cq   FI02cq   FI02cq   FI06cq   FI06cq   /* FI10cq  FI10cq */ ;

array    FIdm   {13}    FI84dv   FI86dv   FI86dv   FI90dv   FI90dv   FI94dv   FI94dv   FI98dv   FI98dv   FI02dv   FI02dv   FI06dv   FI06dv  /*  FI10dv  FI10dv */ ;
array    FIds   {13}    FI84dq   FI86dq   FI86dq   FI90dq   FI90dq   FI94dq   FI94dq   FI98dq   FI98dq   FI02dq   FI02dq   FI06dq   FI06dq   /* FI10dq  FI10dq */ ;

array    FIem   {13}    FI84ev   FI86ev   FI86ev   FI90ev   FI90ev   FI94ev   FI94ev   FI98ev   FI98ev   FI02ev   FI02ev   FI06ev   FI06ev  /*  FI10ev  FI10ev */ ;
array    FIes   {13}    FI84eq   FI86eq   FI86eq   FI90eq   FI90eq   FI94eq   FI94eq   FI98eq   FI98eq   FI02eq   FI02eq   FI06eq   FI06eq   /* FI10eq  FI10eq */ ;

array    FIfm   {13}    FI84fv   FI86fv   FI86fv   FI90fv   FI90fv   FI94fv   FI94fv   FI98fv   FI98fv   FI02fv   FI02fv   FI06fv   FI06fv  /*  FI10fv  FI10fv */ ;
array    FIfs   {13}    FI84fq   FI86fq   FI86fq   FI90fq   FI90fq   FI94fq   FI94fq   FI98fq   FI98fq   FI02fq   FI02fq   FI06fq   FI06fq   /* FI10fq  FI10fq */ ;

array    FIgm   {13}    FI84gv   FI86gv   FI86gv   FI90gv   FI90gv   FI94gv   FI94gv   FI98gv   FI98gv   FI02gv   FI02gv   FI06gv   FI06gv  /*  FI10gv  FI10gv */ ;
array    FIgs   {13}    FI84gq   FI86gq   FI86gq   FI90gq   FI90gq   FI94gq   FI94gq   FI98gq   FI98gq   FI02gq   FI02gq   FI06gq   FI06gq   /* FI10gq  FI10gq */ ;

array    FIhm   {13}    FI84hv   FI86hv   FI86hv   FI90hv   FI90hv   FI94hv   FI94hv   FI98hv   FI98hv   FI02hv   FI02hv   FI06hv   FI06hv  /*  FI10hv  FI10hv */ ;
array    FIhs   {13}    FI84hq   FI86hq   FI86hq   FI90hq   FI90hq   FI94hq   FI94hq   FI98hq   FI98hq   FI02hq   FI02hq   FI06hq   FI06hq   /* FI10hq  FI10hq */ ;

array    FIim   {13}    FI84iv   FI86iv   FI86iv   FI90iv   FI90iv   FI94iv   FI94iv   FI98iv   FI98iv   FI02iv   FI02iv   FI06iv   FI06iv  /*  FI10iv  FI10iv */ ;
array    FIis   {13}    FI84iq   FI86iq   FI86iq   FI90iq   FI90iq   FI94iq   FI94iq   FI98iq   FI98iq   FI02iq   FI02iq   FI06iq   FI06iq   /* FI10iq  FI10iq */ ;

array    FIjm   {13}    FI84jv   FI86jv   FI86jv   FI90jv   FI90jv   FI94jv   FI94jv   FI98jv   FI98jv   FI02jv   FI02jv   FI06jv   FI06jv  /*  FI10jv  FI10jv */ ;
array    FIjs   {13}    FI84jq   FI86jq   FI86jq   FI90jq   FI90jq   FI94jq   FI94jq   FI98jq   FI98jq   FI02jq   FI02jq   FI06jq   FI06jq   /* FI10jq  FI10jq */ ;

array    FIkm   {13}    FI84kv   FI86kv   FI86kv   FI90kv   FI90kv   FI94kv   FI94kv   FI98kv   FI98kv   FI02kv   FI02kv   FI06kv   FI06kv  /*  FI10kv  FI10kv */ ;
array    FIks   {13}    FI84kq   FI86kq   FI86kq   FI90kq   FI90kq   FI94kq   FI94kq   FI98kq   FI98kq   FI02kq   FI02kq   FI06kq   FI06kq   /* FI10kq  FI10kq */ ;

array    FIlm   {13}    FI84lv   FI86lv   FI86lv   FI90lv   FI90lv   FI94lv   FI94lv   FI98lv   FI98lv   FI02lv   FI02lv   FI06lv   FI06lv  /*  FI10lv  FI10lv */ ;
array    FIls   {13}    FI84lq   FI86lq   FI86lq   FI90lq   FI90lq   FI94lq   FI94lq   FI98lq   FI98lq   FI02lq   FI02lq   FI06lq   FI06lq   /* FI10lq  FI10lq */ ;


/*****************************************************************/
    if mobf<=0 or mobf>12 then mobf=6;  ** birthday in months;
    bdt=12*yobf+mobf;
  **************************************************************************
***** If an irt date is before June of that qq year or after or equal ****
***** to the next qq year it is incorrect and should be defaulted to  ****
***** June of that qq year.    Make time period indicator tvar=0.       ****
**************************************************************************;

    cutoff=1326; /* nmw - cutoff 2010.6 */

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
 
    do i=1 to 13;
  if diur{i}=.     then diur{i}=0;
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


******* Define gout case in the ith time period ******;
case=0;
tgt=irt{i+1}-irt{i};
if (irt{i}<goutdtdx<=irt{i+1}) and gtcase=1 then do;
  case=1;
  tgt=goutdtdx-irt{i};
end;
    
if irt{i} le dtdth lt irt{i+1} then tgt=min(tgt, dtdth-irt{i});



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

             aheim=aheinv{i}; 
             aheiq=qahei{i};
             %indic3(vbl=aheiq, prefix=qahei, reflev=0, missing=., usemiss=0, min=1, max=4); 


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

/*** diur ***/
     diuret=diur{i};


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


          FIacon = FIam{i};
FIaq = FIas{i} + 1;
%indic3(vbl= FIaq, prefix= FIaq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIbcon = FIbm{i};
FIbq = FIbs{i} + 1;
%indic3(vbl= FIbq, prefix= FIbq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIccon = FIcm{i};
FIcq = FIcs{i} + 1;
%indic3(vbl= FIcq, prefix= FIcq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIdcon = FIdm{i};
FIdq = FIds{i} + 1;
%indic3(vbl= FIdq, prefix= FIdq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIecon = FIem{i};
FIeq = FIes{i} + 1;
%indic3(vbl= FIeq, prefix= FIeq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIfcon = FIfm{i};
FIfq = FIfs{i} + 1;
%indic3(vbl= FIfq, prefix= FIfq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIgcon = FIgm{i};
FIgq = FIgs{i} + 1;
%indic3(vbl= FIgq, prefix= FIgq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIhcon = FIhm{i};
FIhq = FIhs{i} + 1;
%indic3(vbl= FIhq, prefix= FIhq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIicon = FIim{i};
FIiq = FIis{i} + 1;
%indic3(vbl= FIiq, prefix= FIiq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIjcon = FIjm{i};
FIjq = FIjs{i} + 1;
%indic3(vbl= FIjq, prefix= FIjq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIkcon = FIkm{i};
FIkq = FIks{i} + 1;
%indic3(vbl= FIkq, prefix= FIkq, min=2, max=5, reflev=1, missing=., usemiss=0);

FIlcon = FIlm{i};
FIlq = FIls{i} + 1;
%indic3(vbl= FIlq, prefix= FIlq, min=2, max=5, reflev=1, missing=., usemiss=0);



      /****************  BASELINE EXCLUSIONS ********************************************/
      if i=1 then do;
   %exclude(yobf<=20)
   %exclude(0 lt dtdth le irt{i}); 
    /***Cleaned up exclusions (adapted from /udd/nhsra/thesis_final/chapter_1)***/
    
    %exclude(gout84 eq 1);
    %exclude(0 lt goutdtdx le irt{i});
    %exclude(gtcase eq 0);          *rejected gout cases; 
    %exclude(gtcase eq 1 and goutdtdx le 0);    *patients returned supplemental questionnaires but with gout dtdx missing;

   
   %exclude(age84 eq .); 


   %exclude(FI84  eq .);
   %exclude(FI84a  eq .);
   %exclude(FI84b  eq .);
   %exclude(FI84c  eq .);
   %exclude(FI84d  eq .);
   %exclude(FI84e  eq .);
   %exclude(FI84f  eq .);
   %exclude(FI84g  eq .);
   %exclude(FI84h  eq .);
   %exclude(FI84i  eq .);
   %exclude(FI84j  eq .);
   %exclude(FI84k  eq .);
   %exclude(FI84l  eq .);


   %exclude(teicon < 600); 
   %exclude(teicon > 3500);
   
   %exclude(ltf eq irt{i});
   %output();
   end; 
 
/* EXCLUSIONS DURING FOLLOW-UP */
         if i>1 then do;
  %exclude(irt{i-1} le dtdth    lt irt{i});                       
  %exclude(irt{i-1} lt goutdtdx le irt{i});  
  %exclude(0        lt ltf      le irt{i});  /*Censor lost to follow up*/   

/*No need to censor lost to follow up as we also included fatal CVD, which has been consistent in 3 cohorts */
             %output();
   end;
   end;        /* END OF DO-LOOP OVER TIME PERIODs */

%endex();      /* must do AFTER all exclusions */



data nhs1;
set nhs1hei end=_end_; 
keep id agemo  agecon agegp &agegp_ interval agesub 
     irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 /* irt10 irt12 */ /* irt14 irt16 */ cutoff
     t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 /* t10 t12 */ /* t14 t16 */
   goutdtdx case tgt
   dtdth alldead dead_can dead_cvd talld prs_urate

    FIq &FIq_ FIcon
    FIaq &FIaq_ FIacon
    FIbq &FIbq_ FIbcon
    FIcq &FIcq_ FIccon
    FIdq &FIdq_ FIdcon
    FIeq  &FIeq_  FIecon
    FIfq  &FIfq_  FIfcon
    FIgq  &FIgq_  FIgcon
    FIhq  &FIhq_  FIhcon
    FIiq  &FIiq_  FIicon
    FIjq  &FIjq_  FIjcon
    FIkq  &FIkq_  FIkcon
    FIlq  &FIlq_  FIlcon


white race &race_  mvit aspirin pmh_ever &phmsstatus_  teiq  &qtei_ alco_cumc &alco_cumc_  smkever &smkc_  actcc &actc_  bmib &bmib_ &bmic_ bmic30 bmib30 bmic25 bmib25
smknever  prepau active bmicon oc_ever  aheiq &qahei_ aheim
age84 aspu84 phmsstatus age84  hbpbase cholbase  diuret
alco84n calor84n   act86m  neverdrinker calorm; 

proc means;
run;

proc sort data=nhs1;
  by id;
  run;

