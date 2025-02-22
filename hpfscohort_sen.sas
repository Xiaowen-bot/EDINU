**************************************************
* Figure S5: the code is same as hpfscohort_gout, only exposure is bulit differently.                 *
**************************************************;

/******* General options *************************************/

* filename hpstools '/proj/hpsass/hpsas00/hpstools/sasautos';
* filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/';
* filename PHSmacro '/proj/phdats/phdat01/phstools/sasautos/'; 
* filename channing '/usr/local/channing/sasautos';
* filename ehmac    '/udd/stleh/ehmac';
* libname  formats  '/proj/hpsass/hpsas00/formats';
* libname  library  '/proj/nhsass/nhsas00/formats/';

* options mautosource sasautos=(channing nhstools hpstools ehmac PHSmacro); *path to macro;       
* options fmtsearch=(formats);           
* options nocenter minoperator ls=130 ps=78 replace;

**************************************************
*                    Outcome                     *
**************************************************;
/* copy from '/udd/nhsra/thesis_final/case_files/hpfs.gout.case.file.sas' */
%include '/udd/n2xwa/gout/hpfs.gout.case.file.sas';

************** Death Files **************;
data dead;
    infile '/proj/hpdats/hpdat02/dead/dead'  lrecl=353 recfm=d;   
    input 
    id 1-6
    mod 13-14
    yod 17-18
    icda $ 21-24;

    if 0<=yod<50 then yod=yod+100;
    if mod<=0 and yod>0 then mod=6;

    dtdth=9999;
    if yod ne . and mod ne . then dtdth=(yod*12)+mod;

    newicda=compress(icda, 'E');
    if newicda='V812' then newicda=812;

    
run;      
**************************************************
    *             Dietary food groups        *
**************************************************;
/******************** 1986 ********************/
%h86_dt (keep=id blueb86d cotch86d crmch86d otch86d lccaf86d lcnoc86d lcoth86d 
                 hamb86d bmix86d bmain86d rais86d liq86d skim86d 
                 cerbr86d cer86d yam86d ysqua86d onut86d yog86d tea86d beer86d but86d cream86d egg86d jam86d bacon86d dog86d procm86d 
                 pot86d  whbr86d wrice86d crack86d engl86d muff86d pcake86d pasta86d
                 chwi86d chwo86d  car86d cel86d oj86d
                 ban86d cant86d mayo86d  ckcer86d oat86d dkbr86d brice86d otgrn86d bran86d wgerm86d popc86d
aj86d othj86d appl86d tofu86d cauli86d slaw86d kale86d jam86d chsau86d oran86d grfr86d grj86d pizza86d
                 livb86d livc86d mixv86d oilv86d tom86d toj86d tosau86d corn86d  peas86d bean86d sbean86d
                 rwine86d  wwine86d, noformat=T);



data h86; set h86_dt;
array food {*}
        blueb86d cotch86d crmch86d otch86d lccaf86d lcnoc86d lcoth86d 
                 hamb86d bmix86d bmain86d rais86d liq86d skim86d cerbr86d
                 livb86d livc86d mixv86d oilv86d tom86d toj86d tosau86d
                 chwi86d chwo86d car86d  cel86d oj86d
                 ban86d cant86d mayo86d   ckcer86d oat86d dkbr86d brice86d otgrn86d bran86d wgerm86d popc86d
aj86d othj86d appl86d tofu86d cauli86d slaw86d kale86d jam86d chsau86d oran86d grfr86d grj86d pizza86d
                 rwine86d  wwine86d  yam86d ysqua86d onut86d yog86d tea86d beer86d but86d cream86d egg86d jam86d bacon86d dog86d procm86d 
                 pot86d cer86d whbr86d wrice86d crack86d engl86d muff86d pcake86d pasta86d corn86d  peas86d bean86d sbean86d;

   do i=1 to DIM(food);
             if food{i}=8  then food{i}=6;
        else if food{i}=7  then food{i}=4.5;
        else if food{i}=6  then food{i}=2.5;
        else if food{i}=5  then food{i}=1;
        else if food{i}=4  then food{i}=0.79;
        else if food{i}=3  then food{i}=0.43;
        else if food{i}=2  then food{i}=0.14;
        else if food{i}=1  then food{i}=0.07;
        else if food{i}=0  then food{i}=0;
        else if food{i}=9  then food{i}=0;
        else if food{i}=.  then food{i}=0;
   end;


/** coding for livers **/
array liv86{2} livb86d livc86d;
   do i=1 to 2;
             if liv86{i} in (.,1,6)  then liv86{i}=0;
        else if liv86{i} in (2)               then liv86{i}=0.015;
        else if liv86{i} in (3)               then liv86{i}=0.03;
        else if liv86{i} in (4)               then liv86{i}=0.08;
        else if liv86{i} in (5)               then liv86{i}=0.14;
   end;

/* copied from PDI calculation: /udd/hpbme/PDIs/HPFS/PLANTINDEX86HPFSMB.dat */
if cerbr86d in (., 0, 004, 008, 010, 011, 012, 013, 015, 016, 017, 
                019, 020, 021, 022, 023, 025, 028, 029, 030, 031, 
                033, 035, 037, 042, 043, 044, 045, 046, 047, 051, 
                052, 053, 059, 060, 061, 062, 063, 064, 065, 066, 
                068, 073, 074, 075, 076, 079, 080, 081, 082, 083, 
                084, 085, 086, 088, 096, 097, 098, 101, 109, 111, 
                112, 113, 114, 115, 116, 119, 122, 123, 130, 145, 
                146, 147, 148, 149, 150, 151, 152, 153, 155, 157, 
                158, 164, 165, 166, 167, 168, 169, 170, 173, 176, 
                181, 182, 184, 185, 186, 187, 189, 191, 192, 195, 
                197, 198, 204, 205, 207, 210, 211, 212, 218, 221, 
                228, 229, 231, 232, 234, 258, 260, 262, 263, 264, 
                265, 278, 280, 290, 291, 292, 293, 301, 306, 309, 
                312, 313, 314, 322) 
then rcer86d = cer86d;
else wcer86d = cer86d;

if rcer86d = . then rcer86d = .;
if wcer86d = . then wcer86d = .;
run;


data h86_cat;
set  h86;

/* Blueberries */       blueb86     = sum(blueb86d);
/* Soft and hard cheese */  shchee86    = sum(cotch86d, crmch86d, otch86d);
/* Diet beverage */     dietbev86   = sum(lccaf86d, lcnoc86d, lcoth86d);
/* Fresh red meat */        frmeat86    = sum(hamb86d, bmix86d, bmain86d);  
/* Grapes */            grape86     = sum(rais86d);
/* Liquor */            liq86       = sum(liq86d);
/* Low-fat milk */      lfmilk86    = sum(skim86d);
/* Mixed vegetables */      mixveg86    = sum(mixv86d);
/* Oil-based dress */       oildres86   = sum(oilv86d);
/* Organ meats */       organ86     = sum(livb86d, livc86d);
/* Tomato products */       tomprod86   = sum(tom86d, toj86d, tosau86d);
/* Wine */          wine86      = sum(rwine86d, wwine86d);

/* Yellow vegetables */      yelveg86    = sum(yam86d, ysqua86d);
/* Nuts */                   othnut86    = sum(onut86d);
/* Yogurt */                 yogurt86    = sum(yog86d);
/* Tea */                    tea86       = sum(tea86d);
/* Beer */                   beer86      = sum(beer86d);
/* High-fat dairy */         hfdairy86   = sum(but86d, cream86d); 
/* Eggs */                   eggs86      = sum(egg86d);

/* Processed red meat */     prmeat86    = sum(bacon86d, dog86d, procm86d);
/* Potatoes */               potato86    = sum(pot86d);
/* Refined grain products */ rgrain86    = sum(rcer86d, whbr86d, wrice86d, crack86d, engl86d, muff86d, pcake86d, pasta86d);

/* cold breakfast cereal */  cereal86    = sum(cer86d);
/* mayonnaise */             mayo86      = sum(mayo86d);
* /* onion */                  onion86     = . ;  *Not collected in 1986;
/* Poultry */                poultry86   = sum(chwi86d, chwo86d); 
/* umb*/                     umb86       = sum(car86d, cel86d);
/* Orange juice*/            oj86        = sum(oj86d);
/* Avocado  */     
/* Other fruits  */          othfru86    = sum(ban86d,cant86d);

/* Whole grains */          wgrain86    = sum(wcer86d, ckcer86d ,oat86d, dkbr86d ,brice86d ,otgrn86d ,bran86d ,wgerm86d, popc86d);
/* Juice */                 juice86     = sum(aj86d, othj86d);
/* Apple */                 apple86     = sum(appl86d);
/* Soy products */          soy86       = sum(tofu86d);
/* Cruciferous veg */       crucveg86   = sum(cauli86d, slaw86d, kale86d);
/* Condiments */            condi86     = sum(jam86d, chsau86d);
/* Citrus fruits */         citrus86    = sum(oran86d, grfr86d, grj86d);

/* Pizza */                  pizza86     = sum(pizza86d);

/* carrot*/                  carrot86    = sum(car86d);
/* corn*/                    corn86    = sum(corn86d);
/* beans */                  beans86     = sum(peas86d,sbean86d, bean86d);

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

/**********************************************/
/******************** 1990 ********************/
%h90_dt (keep=
        cerbr90d    
        procm90d    bacon90d    dog90d      hamb90d     bmix90d     bmain90d    PMAIN90D    livb90d     livc90d     ctuna90d    
        dkfsh90d    ofsh90d     shrim90d    chwi90d     chwo90d     egg90d      but90d      marg90d     skim90d     sherb90d    
        yog90d      whole90d    cream90d    sour90d     icecr90d    crmch90d    otch90d     liq90d      rwine90d    wwine90d    
        beer90d     tea90d      cof90d      decaf90d    h2o90d      rais90d     ban90d      cant90d     h2om90d     appl90d     
        ASAU90D     PRUNE90D    oran90d     oj90d       grfr90d     straw90d    blueb90d    peach90d    aj90d       grj90d      
        othj90d     brocc90d    slaw90d     cauli90d    bruss90d    kale90d     rcar90d     ccar90d     osqua90d    yam90d      
        tom90d      toj90d      tosau90d    cspin90d    rspin90d    ilett90d    rlett90d    sbean90d    peas90d     bean90d     
        tofu90d     corn90d     mixv90d     cel90d      eggpl90d    BEET90D     ONIOG90D    ONIOV90D    potb90d     fries90d    
        oat90d      ckcer90d    drbr90d     brice90d    otgrn90d    OATBR90D    bran90d     wgerm90d    cer90d      whbr90d     
        engl90d     muff90d     wrice90d    pasta90d    pcake90d    pizza90d    pchip90d    crack90d    popc90d     pnut90d     
        onut90d     pbut90d     cola90d     cnoc90d     otsug90d    punch90d    lccaf90d    lcnoc90d    lcoth90d    OOIL90D     
        oilv90d     mayo90d     chowd90d    choco90d    cdyw90d     cdywo90d    cokh90d     cokr90d     brwn90d     donut90d    
        cakh90d     cakr90d     pieh90d     pier90d     srolh90d    srolr90d    chsau90d    jam90d      cotch90d    cofw90d     
        salt90d,    
        noformat=T);
run;

data h90; set h90_dt;
array food {*}
                procm90d    bacon90d    dog90d      hamb90d     bmix90d     bmain90d    PMAIN90D                            ctuna90d    
        dkfsh90d    ofsh90d     shrim90d    chwi90d     chwo90d     egg90d      but90d      marg90d     skim90d     sherb90d 
        yog90d      whole90d    cream90d    sour90d     icecr90d    crmch90d    otch90d     liq90d      rwine90d    wwine90d
        beer90d     tea90d      cof90d      decaf90d    h2o90d      rais90d     ban90d      cant90d     h2om90d     appl90d 
        ASAU90D     PRUNE90D    oran90d     oj90d       grfr90d     straw90d    blueb90d    peach90d    aj90d       grj90d 
        othj90d     brocc90d    slaw90d     cauli90d    bruss90d    kale90d     rcar90d     ccar90d     osqua90d    yam90d 
        tom90d      toj90d      tosau90d    cspin90d    rspin90d    ilett90d    rlett90d    sbean90d    peas90d     bean90d 
        tofu90d     corn90d     mixv90d     cel90d      eggpl90d    BEET90D     ONIOG90D    ONIOV90D    potb90d     fries90d 
        oat90d      ckcer90d    drbr90d     brice90d    otgrn90d    OATBR90D    bran90d     wgerm90d    cer90d      whbr90d 
        engl90d     muff90d     wrice90d    pasta90d    pcake90d    pizza90d    pchip90d    crack90d    popc90d     pnut90d 
        onut90d     pbut90d     cola90d     cnoc90d     otsug90d    punch90d    lccaf90d    lcnoc90d    lcoth90d    OOIL90D
        oilv90d     mayo90d     chowd90d    choco90d    cdyw90d     cdywo90d    cokh90d     cokr90d     brwn90d     donut90d 
        cakh90d     cakr90d     pieh90d     pier90d     srolh90d    srolr90d    chsau90d    jam90d      cotch90d    cofw90d 
        salt90d     ;

   do i=1 to DIM(food);
             if food{i}=8  then food{i}=6;
        else if food{i}=7  then food{i}=4.5;
        else if food{i}=6  then food{i}=2.5;
        else if food{i}=5  then food{i}=1;
        else if food{i}=4  then food{i}=0.79;
        else if food{i}=3  then food{i}=0.43;
        else if food{i}=2  then food{i}=0.14;
        else if food{i}=1  then food{i}=0.07;
        else if food{i}=0  then food{i}=0;
        else if food{i}=9  then food{i}=0;
        else if food{i}=.  then food{i}=0;
   end;

/** coding for livers **/
array liv90{2} livc90d livb90d;
   do i=1 to 2;
             if liv90{i} in (.,1,6)  then liv90{i}=0;
        else if liv90{i} in (2)               then liv90{i}=0.015;
        else if liv90{i} in (3)               then liv90{i}=0.03;
        else if liv90{i} in (4)               then liv90{i}=0.08;
        else if liv90{i} in (5)               then liv90{i}=0.14;
   end;

/** Distinguish between whole grain and refined grain breakfast cereals **/
if cerbr90d IN (., 0, 004, 008, 010, 011, 012, 013, 015, 016, 017, 
                019, 020, 021, 022, 023, 025, 028, 029, 030, 031, 
                033, 035, 037, 042, 043, 044, 045, 046, 047, 051, 
                052, 053, 059, 060, 061, 062, 063, 064, 065, 066, 
                068, 073, 074, 075, 076, 079, 080, 081, 082, 083, 
                084, 085, 086, 088, 096, 097, 098, 101, 109, 111, 
                112, 113, 114, 115, 116, 119, 122, 123, 130, 145, 
                146, 147, 148, 149, 150, 151, 152, 153, 155, 157, 
                158, 164, 165, 166, 167, 168, 169, 170, 173, 176, 
                181, 182, 184, 185, 186, 187, 189, 191, 192, 195, 
                197, 198, 204, 205, 207, 210, 211, 212, 218, 221, 
                228, 229, 231, 232, 234, 258, 260, 262, 263, 264, 
                265, 278, 280, 290, 291, 292, 293, 301, 306, 309, 
                312, 313, 314, 322)
   then rcer90d = cer90d;
   else wcer90d = cer90d;
if rcer90d=. then rcer90d = 0;
if wcer90d=. then wcer90d = 0;

run;


/*************************************************************************/
/************************ Constructing categories ************************/

/* Omitted cer90d because the dichotimized version was created above */

data h90_cat;
set  h90;

* /* Avocados */                *Not collected in 1990;
/* Bananas */               banana90    = sum(ban90d);
/* Beer */                  beer90      = sum(beer90d);
/* Blueberries */           blueb90     = sum(blueb90d);
/* Broccoli */              brocc90     = sum(brocc90d);
/* Brussels sprouts */      bruss90     = sum(bruss90d);
/* Candy */                 candy90     = sum(choco90d, cdyw90d, cdywo90d);
/* Carrots */               carrot90    = sum(rcar90d, ccar90d);
/* Celery */                celery90    = sum(cel90d);
/* Chowder or cream soup */ chowder90   = sum(chowd90d);

/* Coffee */                coffee90    = sum(cof90d, decaf90d);

/* Corn */              corn90      = sum(corn90d);
/* Crackers */              cracker90   = sum(crack90d);
/* Dark orange squash */            dksqa90     = sum(osqua90d);
/* Desserts */              dess90      = sum(cokr90d, cokh90d, brwn90d, donut90d, cakh90d, cakr90d, 
                    pieh90d, pier90d, srolh90d, srolr90d);
/* Diet beverage */         dietbev90   = sum(lccaf90d, lcnoc90d, lcoth90d);
/* Eggs */              eggs90      = sum(egg90d);
/* Fish and seafood */              fish90      = sum(ctuna90d, shrim90d, dkfsh90d, ofsh90d);   
/* French fries */          fries90     = sum(fries90d);
/* Fresh red meat */                frmeat90    = sum(hamb90d, bmix90d, PMAIN90D, bmain90d);    
/* Grapes */                grape90     = sum(rais90d);
/* High-fat dairy */                hfdairy90   = sum(sour90d, but90d, cream90d);
/* Liquor */                liq90       = sum(liq90d);
/* Low-fat milk */          lfmilk90    = sum(skim90d);
/* Margarine */             marg90      = sum(marg90d);
/* Mayo or creamy dress */          mayo90      = sum(mayo90d);
/* Melons */                melon90     = sum(cant90d, h2om90d);
/* Milk-based frzn dess */          milkdes90   = sum(sherb90d, icecr90d);
/* MISCELLANEOUS */         misc90      = sum(BEET90D); *Beets but mushrooms/other soups were not collected in 1990;
/* Mixed vegetables */              mixveg90    = sum(mixv90d);
/* Non-dairy cof whit */            nondai90    = sum(cofw90d);
/* Nuts */              othnut90    = sum(onut90d);
/* Oil-based dress */               oildres90   = sum(OOIL90D, oilv90d);

/* Organ meats */           organ90     = sum(livb90d, livc90d);
/* Other cruciferous veg */         othveg90    = sum(cauli90d, slaw90d, kale90d);
/* Other fruit juices */            othfrj90    = sum(othj90d);
/* Other leafy veg */               othleaf90   = sum(ilett90d, rlett90d);
/* Other legumes */         othleg90    = sum(peas90d, sbean90d, bean90d);
/* Other nightshades */             othnite90   = sum(eggpl90d);
/* Packaged savory snacks */            pksavsn90   = sum(pchip90d);
/* Peanuts */               pnut90      = sum(pnut90d, pbut90d);

/* Pome fruits */           pome90      = sum(appl90d, ASAU90D, aj90d);
/* Potatoes */              potato90    = sum(potb90d);
/* Poultry */               poultry90   = sum(chwi90d, chwo90d);
/* Processed red meat */    prmeat90    = sum(bacon90d, dog90d, procm90d);
/* Prune family */          prune90     = sum(PRUNE90D, peach90d);
/* Refined grain prod */    rgrain90    = sum(engl90d, muff90d, pcake90d, wrice90d, pasta90d, whbr90d, rcer90d);
/* Soft and hard cheese */  shchee90    = sum(cotch90d, crmch90d, otch90d);

/* Spinach */               spinach90   = sum(cspin90d, rspin90d);
/* Strawberries */          strawb90    = sum(straw90d);
/* SSBs */              ssb90       = sum(cola90d, cnoc90d, otsug90d, punch90d);
/* Tea */               tea90       = sum(tea90d);
/* Tomato products */        tomprod90  = sum(tom90d, toj90d, tosau90d);

/* Whole milk */            whlmilk90   = sum(whole90d);
/* Wine */                   wine90     = sum(rwine90d, wwine90d);
/* Yam or sweet potato */    yamswt90   = sum(yam90d);
/* Yellow vegetables */      yelveg90    = sum(yam90d, osqua90d);
/* Yogurt */                 yogurt90   = sum(yog90d);

/* cold breakfast cereal */  cereal90    = sum(cer90d);
/* Onions */                 onion90     = sum(ONIOG90D, ONIOV90D);
/* Poultry */                poultry90   = sum(chwi90d, chwo90d);
/* umb*/                     umb90       = sum(rcar90d, ccar90d, cel90d);
/* Orange juice*/            oj90        = sum(oj90d);
/* Other fruits  */          othfru90    = sum(ban90d,cant90d);
/* Mayo or creamy dress */   mayo90      = sum(mayo90d);
             
/* Whole grains */          wgrain90    = sum(oat90d, drbr90d, OATBR90D, bran90d, wgerm90d, brice90d, popc90d, ckcer90d, otgrn90d, wcer90d);
/* Juice */                 juice90     = sum(aj90d,othj90d);
/* Apple */                 apple90     = sum(appl90d);
/* Soy products */          soy90       = sum(tofu90d);
/* cruciferous veg */       crucveg90    = sum(cauli90d, slaw90d, kale90d);
/* Condiments */            condi90     = sum(jam90d, chsau90d);
/* Citrus fruits */         citrus90    = sum(oran90d, grfr90d, grj90d);

/* Pizza */                 pizza90     = sum(pizza90d);

/* carrot*/                  carrot90    = sum(rcar90d, ccar90d);
/* beans */                  beans90     = sum(peas90d,sbean90d, bean90d);

FI90 = -(blueb90 * -0.022359623 + shchee90 * -0.000357103 + dietbev90 * 0.037505123 + frmeat90 * 0.041039490 
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


data h90_cat;
set h90_cat;
drop    procm90d    bacon90d    dog90d      hamb90d     bmix90d     bmain90d    PMAIN90D    livb90d     livc90d     ctuna90d    
        dkfsh90d    ofsh90d     shrim90d    chwi90d     chwo90d     egg90d      but90d      marg90d     skim90d     sherb90d    
        yog90d      whole90d    cream90d    sour90d     icecr90d    crmch90d    otch90d     liq90d      rwine90d    wwine90d    
        beer90d     tea90d      cof90d      decaf90d    h2o90d      rais90d     ban90d      cant90d     h2om90d     appl90d     
        ASAU90D     PRUNE90D    oran90d     oj90d       grfr90d     straw90d    blueb90d    peach90d    aj90d       grj90d      
        othj90d     brocc90d    slaw90d     cauli90d    bruss90d    kale90d     rcar90d     ccar90d     osqua90d    yam90d      
        tom90d      toj90d      tosau90d    cspin90d    rspin90d    ilett90d    rlett90d    sbean90d    peas90d     bean90d     
        tofu90d     corn90d     mixv90d     cel90d      eggpl90d    BEET90D     ONIOG90D    ONIOV90D    potb90d     fries90d    
        oat90d      ckcer90d    drbr90d     brice90d    otgrn90d    OATBR90D    bran90d     wgerm90d    cer90d      whbr90d     
        engl90d     muff90d     wrice90d    pasta90d    pcake90d    pizza90d    pchip90d    crack90d    popc90d     pnut90d     
        onut90d     pbut90d     cola90d     cnoc90d     otsug90d    punch90d    lccaf90d    lcnoc90d    lcoth90d    OOIL90D     
        oilv90d     mayo90d     chowd90d    choco90d    cdyw90d     cdywo90d    cokh90d     cokr90d     brwn90d     donut90d    
        cakh90d     cakr90d     pieh90d     pier90d     srolh90d    srolr90d    chsau90d    jam90d      cotch90d    cofw90d
        salt90d     rcer90d     wcer90d     cer90d      cerbr90d;
run;


/**********************************************/
/******************** 1994 ********************/

%h94_dt (keep=
        cerbr94d 
        procm94d    bacon94d    dog94d      hamb94d     HAMBL94D    bmix94d     bmain94d    PMAIN94D    livb94d 
        livc94d     ctuna94d    dkfsh94d    ofish94d    shrim94d    chwi94d     chwo94d     CTDOG94D    egg94d
        but94d      marg94d     sherb94d    plyog94d    flyog94d    whole94d    cream94d    icecr94d    crmch94d 
        otch94d     skim194d    milk294d    liq94d      rwine94d    wwine94d    beer94d     LBEER94D    tea94d 
        coff94d     dcaf94d     h2o94d      rais94d     avo94d      ban94d      cant94d     appl94d     oran94d 
        oj94d       grfr94d     straw94d    blueb94d    peach94d    PRUNE94D    aj94d       grj94d      othj94d 
        brocc94d    cabb94d     cauli94d    bruss94d    kale94d     ccar94d     rcar94d     osqua94d    yam94d 
        tom94d      toj94d      tosau94d    cspin94d    rspin94d    ilett94d    ONIOV94D    ONIOG94D    rlett94d 
        sbean94d    peas94d     bean94d     tofu94d     corn94d     mixv94d     cel94d      eggpl94d    grpep94d 
        garl94d     pot94d      fries94d    oat94d      ckcer94d    dkbr94d     brice94d    otgrn94d    bran94d 
        wgerm94d    cer94d      OATBR94D    whbr94d     engl94d     muff94d     wrice94d    pasta94d    pcake94d 
        pizza94d    pchip94d    crack94d    popc94d     pnut94d     onut94d     pbut94d     cola94d     cnoc94d 
        otsug94d    punch94d    lccaf94d    lcnoc94d    lcoth94d    OOIL94D     DRESS94D    mayo94d     LMAYO94D
        chowd94d    choco94d    cdyw94d     cdywo94d    cokh94d     cokr94d     brwn94d     donut94d    cakh94d 
        cakr94d     pieh94d     pier94d     srolh94d    srolr94d    KETCH94D    jam94d      cotch94d    cofwh94d 
        salt94d     nutrs94d    salsa94d    tort94d, 
        noformat=T);
run;

data h94; set h94_dt;
array food {*}
        procm94d    bacon94d    dog94d      hamb94d     HAMBL94D    bmix94d     bmain94d    PMAIN94D 
        ctuna94d    dkfsh94d    ofish94d    shrim94d    chwi94d     chwo94d     CTDOG94D    egg94d 
        but94d      marg94d     sherb94d    plyog94d    flyog94d    whole94d    cream94d    icecr94d    crmch94d 
        otch94d     skim194d    milk294d    liq94d      rwine94d    wwine94d    beer94d     LBEER94D    tea94d 
        coff94d     dcaf94d     h2o94d      rais94d     avo94d      ban94d      cant94d     appl94d     oran94d 
        oj94d       grfr94d     straw94d    blueb94d    peach94d    PRUNE94D    aj94d       grj94d      othj94d 
        brocc94d    cabb94d     cauli94d    bruss94d    kale94d     ccar94d     rcar94d     osqua94d    yam94d 
        tom94d      toj94d      tosau94d    cspin94d    rspin94d    ilett94d    ONIOV94D    ONIOG94D    rlett94d 
        sbean94d    peas94d     bean94d     tofu94d     corn94d     mixv94d     cel94d      eggpl94d    grpep94d
        garl94d     pot94d      fries94d    oat94d      ckcer94d    dkbr94d     brice94d    otgrn94d    bran94d 
        wgerm94d    cer94d      OATBR94D    whbr94d     engl94d     muff94d     wrice94d    pasta94d    pcake94d 
        pizza94d    pchip94d    crack94d    popc94d     pnut94d     onut94d     pbut94d     cola94d     cnoc94d 
        otsug94d    punch94d    lccaf94d    lcnoc94d    lcoth94d    OOIL94D     DRESS94D    mayo94d     LMAYO94D 
        chowd94d    choco94d    cdyw94d     cdywo94d    cokh94d     cokr94d     brwn94d     donut94d    cakh94d 
        cakr94d     pieh94d     pier94d     srolh94d    srolr94d    KETCH94D    jam94d      cotch94d    cofwh94d 
        salt94d     nutrs94d    salsa94d    tort94d     ;

   do i=1 to DIM(food);
             if food{i}=8  then food{i}=6;
        else if food{i}=7  then food{i}=4.5;
        else if food{i}=6  then food{i}=2.5;
        else if food{i}=5  then food{i}=1;
        else if food{i}=4  then food{i}=0.79;
        else if food{i}=3  then food{i}=0.43;
        else if food{i}=2  then food{i}=0.14;
        else if food{i}=1  then food{i}=0.07;
        else if food{i}=0  then food{i}=0;
        else if food{i}=9  then food{i}=0;
        else if food{i}=.  then food{i}=0;
   end;
/** coding for livers **/
array liv94{2} livc94d livb94d;
   do i=1 to 2;
             if liv94{i} in (.,1,6)  then liv94{i}=0;
        else if liv94{i} in (2)      then liv94{i}=0.015;
        else if liv94{i} in (3)      then liv94{i}=0.03;
        else if liv94{i} in (4)      then liv94{i}=0.08;
        else if liv94{i} in (5)      then liv94{i}=0.14;
   end;

/** Distinguish between whole grain and refined grain breakfast cereals **/
if cerbr94d IN (004, 011, 012, 013, 015, 016, 017, 019, 020, 021, 022, 023, 025, 030, 031, 037, 
042, 043, 044, 046, 047, 056, 059, 060, 061, 064, 065, 066, 074, 075, 076, 079, 
080, 081, 082, 083, 084, 085, 086, 088, 097, 098, 109, 113, 119, 123, 127, 130, 
138, 141, 147, 149, 150, 151, 158, 173, 174, 175, 178, 182, 184, 190, 193, 195, 
196, 197, 198, 203, 204, 210, 212, 213, 232, 233, 234, 235, 236, 243, 245, 246, 
257, 258, 260, 263, 264, 265, 271, 275, 278, 279, 281, 284, 287, 288, 291, 292, 
293, 304, 305, 306, 309, 311, 312, 314, 324, 326, 327, 332, 336, 338, 339)
   then rcer94d = cer94d;
   else wcer94d = cer94d;
if rcer94d=. then rcer94d = 0;
if wcer94d=. then wcer94d = 0;

run;



/*************************************************************************/
/************************ Constructing categories ************************/             

data h94_cat;
set h94;

/* Avocados */              avocado94   = sum(avo94d);
/* Bananas */               banana94    = sum(ban94d);
/* Beer */              beer94      = sum(beer94d, LBEER94D);
/* Blueberries */           blueb94     = sum(blueb94d);
/* Broccoli */              brocc94     = sum(brocc94d);
/* Brussels sprouts */              bruss94     = sum(bruss94d);
/* Candy */             candy94     = sum(choco94d, cdyw94d, cdywo94d);
/* Carrots */               carrot94    = sum(ccar94d, rcar94d);
/* Celery */                celery94    = sum(cel94d);
/* Chowder or cream soup */         chowder94   = sum(chowd94d);

/* Coffee */                coffee94    = sum(coff94d, dcaf94d);

/* Corn */              corn94      = sum(corn94d);
/* Crackers */              cracker94   = sum(crack94d);
/* Dark orange squash */            dksqa94     = sum(osqua94d);
/* Desserts */              dess94      = sum(cokr94d, cokh94d, brwn94d, donut94d, cakh94d, cakr94d, 
                    pieh94d, pier94d, srolh94d, srolr94d);
/* Diet beverage */         dietbev94   = sum(lccaf94d, lcnoc94d, lcoth94d);
/* Eggs */              eggs94      = sum(egg94d);
/* Fish and seafood */              fish94      = sum(ctuna94d, shrim94d, dkfsh94d, ofish94d);
/* French fries */          fries94     = sum(fries94d);
/* Fresh red meat */                frmeat94    = sum(hamb94d, HAMBL94D, bmix94d, bmain94d, PMAIN94D); *Added new variable for lean hamburger here; 
/* Grapes */                grape94     = sum(rais94d);
/* High-fat dairy */                hfdairy94   = sum(but94d, cream94d); *Cream variable now encompasses "coffee, whipped, sour" so no more standalone sour cream variable;
/* Liquor */                liq94       = sum(liq94d);
/* Low-fat milk */          lfmilk94    = sum(skim194d);
/* Margarine */             marg94      = sum(marg94d);
/* Mayo or creamy dress */          mayo94      = sum(mayo94d, LMAYO94D);
/* Melons */                melon94     = sum(cant94d); *No watermelon this year - is it sporadic? If so then move to misc category;
/* Milk-based frzn dess */          milkdes94   = sum(sherb94d, icecr94d);
/* MISCELLANEOUS */         misc94      = sum(garl94d); *Garlic is sporadic or no? Mushrooms and other soup not collected in 1994;
/* Mixed vegetables */              mixveg94    = sum(mixv94d);
/* Non-dairy cof whit */            nondai94    = sum(cofwh94d);
/* Nuts */              othnut94    = sum(onut94d);
/* Oil-based dress */               oildres94   = sum(OOIL94D, DRESS94D);

/* Organ meats */           organ94     = sum(livb94d, livc94d);    
/* Other cruciferous veg */         othveg94    = sum(cauli94d, cabb94d, kale94d);
/* Other fruit juices */            othfrj94    = sum(othj94d);
/* Other leafy veg */               othleaf94   = sum(ilett94d, rlett94d);
/* Other legumes */         othleg94    = sum(peas94d, sbean94d, bean94d);
/* Other nightshades */             othnite94   = sum(eggpl94d, grpep94d);
/* Packaged savory snacks */            pksavsn94   = sum(pchip94d);
/* Peanuts */               pnut94      = sum(pbut94d, pnut94d);    

/* Pome fruits */           pome94      = sum(appl94d, aj94d);
/* Potatoes */              potato94    = sum(pot94d);

/* Processed red meat */    prmeat94    = sum(bacon94d, dog94d, procm94d);
/* Prune family */          prune94     = sum(PRUNE94D, peach94d);
/* Refined grain prod */    rgrain94    = sum(engl94d, muff94d, pcake94d, wrice94d, pasta94d, whbr94d, rcer94d, tort94d); *Added tortillas here;
/* Soft and hard cheese */  shchee94    = sum(cotch94d, crmch94d, otch94d);

/* Spinach */               spinach94   = sum(cspin94d, rspin94d);
/* Strawberries */          strawb94    = sum(straw94d);
/* SSBs */              ssb94       = sum(cola94d, cnoc94d, otsug94d, punch94d);
/* Tea */               tea94       = sum(tea94d);
/* Tomato products */       tomprod94   = sum(tom94d, toj94d, tosau94d, salsa94d, KETCH94D);    

/* Whole milk */            whlmilk94   = sum(whole94d, milk294d); *Added 2% here;
/* Wine */                  wine94      = sum(rwine94d, wwine94d);
/* Yam or sweet potato */   yamswt94    = sum(yam94d);
/* Yogurt */                yogurt94    = sum(plyog94d, flyog94d);
/* yellow vegetables  */    yelveg94    = sum(yam94d,osqua94d);

/* cold breakfast cereal */ cereal94    = sum(cer94d);
/* Onions */                onion94     = sum(ONIOV94D, ONIOG94D);
/* Poultry */               poultry94   = sum(chwi94d, chwo94d, CTDOG94D); *Added new variable for chicken/turkey dogs here because not red meat?;
/* umb*/                    umb94       = sum(ccar94d, rcar94d, cel94d);
/* Orange juice*/           oj94        = sum(oj94d);
/* Other fruits  */         othfru94    = sum(ban94d,cant94d);
/* Mayo or creamy dress */  mayo94      = sum(mayo94d, LMAYO94D);
/* Avocado  */              avo94       = sum(avo94d);

/* Whole grains */          wgrain94    = sum(oat94d, dkbr94d, OATBR94D, bran94d, wgerm94d,
                    brice94d, popc94d, ckcer94d, otgrn94d, wcer94d);
/* Juice */                 juice94     = sum(aj94d, othj94d);
/* Apple */                 apple94     = sum(appl94d);
/* Soy products */          soy94       = sum(tofu94d);
/* Cruciferous veg */       crucveg94   = sum(cauli94d,  kale94d);
/* Condiments */            condi94     = sum(jam94d); *No chili sauce anymore;
/* Citrus fruits */         citrus94    = sum(oran94d, grfr94d, grj94d);

/* Pizza */                 pizza94     = sum(pizza94d);

/* carrot*/                  carrot94    = sum(rcar94d, ccar94d);
/* beans */                  beans94     = sum(peas94d,sbean94d, bean94d);

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


data h94_cat;
set h94_cat;
drop    procm94d    bacon94d    dog94d      hamb94d     HAMBL94D    bmix94d     bmain94d    PMAIN94D    livb94d 
        livc94d     ctuna94d    dkfsh94d    ofish94d    shrim94d    chwi94d     chwo94d     CTDOG94D    egg94d
        but94d      marg94d     sherb94d    plyog94d    flyog94d    whole94d    cream94d    icecr94d    crmch94d 
        otch94d     skim194d    milk294d    liq94d      rwine94d    wwine94d    beer94d     LBEER94D    tea94d 
        coff94d     dcaf94d     h2o94d      rais94d     avo94d      ban94d      cant94d     appl94d     oran94d 
        oj94d       grfr94d     straw94d    blueb94d    peach94d    PRUNE94D    aj94d       grj94d      othj94d 
        brocc94d    cabb94d     cauli94d    bruss94d    kale94d     ccar94d     rcar94d     osqua94d    yam94d 
        tom94d      toj94d      tosau94d    cspin94d    rspin94d    ilett94d    ONIOV94D    ONIOG94D    rlett94d 
        sbean94d    peas94d     bean94d     tofu94d     corn94d     mixv94d     cel94d      eggpl94d    grpep94d 
        garl94d     pot94d      fries94d    oat94d      ckcer94d    dkbr94d     brice94d    otgrn94d    bran94d 
        wgerm94d    cer94d      OATBR94D    whbr94d     engl94d     muff94d     wrice94d    pasta94d    pcake94d 
        pizza94d    pchip94d    crack94d    popc94d     pnut94d     onut94d     pbut94d     cola94d     cnoc94d 
        otsug94d    punch94d    lccaf94d    lcnoc94d    lcoth94d    OOIL94D     DRESS94D    mayo94d     LMAYO94D
        chowd94d    choco94d    cdyw94d     cdywo94d    cokh94d     cokr94d     brwn94d     donut94d    cakh94d 
        cakr94d     pieh94d     pier94d     srolh94d    srolr94d    KETCH94D    jam94d      cotch94d    cofwh94d 
        salt94d     nutrs94d    salsa94d    tort94d     rcer94d     wcer94d     cer94d      cerbr94d;
run;

/******************** 1998 ********************/
%h98_dt (keep=id  cerbr98d cer98d  blueb98d cotch98d crmch98d otch98d lccaf98d lcnoc98d lcoth98d 
                 hamb98d bmix98d bmain98d rais98d liq98d skim198d 
                 livb98d livc98d mixv98d ooil98d dress98d tom98d toj98d tosau98d
                 yam98d osqua98d onut98d plyog98d flyog98d tea98d htea98d beer98d lbeer98d but98d cream98d 
                 egg98d jam98d bacon98d bfsh98d dog98d ctdog98d oprom98d sbol98d pot98d 
                 oniog98d oniov98d chwi98d chwo98d CTDOG98D ccar98d rcar98d cel98d oj98d
                 ban98d cant98d mayo98d avo98d   ckcer98d oat98d dkbr98d brice98d otgrn98d bran98d oatbr98d wgerm98d popc98d
aj98d othj98d appl98d tofu98d cauli98d kale98d jam98d oran98d grfr98d grj98d pizza98d corn98d  peas98d bean98d sbean98d
                 whbr98d  crack98d engl98d muff98d wrice98d pcake98d pasta98d pretz98d tort98d
                 rwine98d  wwine98d, noformat=T);


data h98; set h98_dt;

array food {*}
        blueb98d cotch98d crmch98d otch98d lccaf98d lcnoc98d lcoth98d 
                 hamb98d bmix98d bmain98d rais98d liq98d skim198d 
                 livb98d livc98d mixv98d ooil98d dress98d tom98d toj98d tosau98d
                 yam98d osqua98d onut98d plyog98d flyog98d tea98d htea98d beer98d lbeer98d but98d cream98d 
                 egg98d jam98d bacon98d bfsh98d dog98d ctdog98d oprom98d sbol98d pot98d cer98d 
                 oniog98d oniov98d chwi98d chwo98d CTDOG98D ccar98d rcar98d cel98d oj98d
                 ban98d cant98d mayo98d avo98d  ckcer98d oat98d dkbr98d brice98d otgrn98d bran98d oatbr98d wgerm98d popc98d
aj98d othj98d appl98d tofu98d cauli98d kale98d jam98d oran98d grfr98d grj98d pizza98d corn98d  peas98d bean98d sbean98d
                 whbr98d  crack98d engl98d muff98d wrice98d pcake98d pasta98d pretz98d tort98d
                 rwine98d  wwine98d ;

   do i=1 to DIM(food);
             if food{i}=8  then food{i}=6;
        else if food{i}=7  then food{i}=4.5;
        else if food{i}=6  then food{i}=2.5;
        else if food{i}=5  then food{i}=1;
        else if food{i}=4  then food{i}=0.79;
        else if food{i}=3  then food{i}=0.43;
        else if food{i}=2  then food{i}=0.14;
        else if food{i}=1  then food{i}=0.07;
        else if food{i}=0  then food{i}=0;
        else if food{i}=9  then food{i}=0;
        else if food{i}=.  then food{i}=0;
   end;

/** coding for livers **/
array liv98{2} livb98d livc98d;
   do i=1 to 2;
             if liv98{i} in (.,1,6)  then liv98{i}=0;
        else if liv98{i} in (2)               then liv98{i}=0.015;
        else if liv98{i} in (3)               then liv98{i}=0.03;
        else if liv98{i} in (4)               then liv98{i}=0.08;
        else if liv98{i} in (5)               then liv98{i}=0.14;
   end;

 if cerbr98d in (., 011, 015, 017, 018, 019, 020, 022, 030, 031, 035, 037, 044, 047, 060, 064, 
066, 075, 076, 079, 080, 083, 088, 123, 130, 150, 161, 210, 219, 263, 264, 
292, 310, 332, 339, 341, 362, 380, 384) 
  then rcer98d=cer98d;
  else wcer98d=cer98d;
   if rcer98d=. then rcer98d=.;
   if wcer98d=. then wcer98d=.;

run;

data h98_cat;
set  h98;

/* Blueberries */       blueb98     = sum(blueb98d);
/* Soft and hard cheese */  shchee98    = sum(cotch98d, crmch98d, otch98d);
/* Diet beverage */     dietbev98   = sum(lccaf98d, lcnoc98d, lcoth98d);
/* Fresh red meat */        frmeat98    = sum(hamb98d, bmix98d, bmain98d);  
/* Grapes */            grape98     = sum(rais98d);
/* Liquor */            liq98       = sum(liq98d);
/* Low-fat milk */      lfmilk98    = sum(skim198d);
/* Mixed vegetables */      mixveg98    = sum(mixv98d);
/* Oil-based dress */       oildres98   = sum(ooil98d,dress98d);
/* Organ meats */       organ98     = sum(livb98d, livc98d);
/* Tomato products */       tomprod98   = sum(tom98d, toj98d, tosau98d);
/* Wine */          wine98      = sum(rwine98d, wwine98d);

/* Yellow vegetables */      yelveg98    = sum(yam98d, osqua98d);
/* Nuts */                   othnut98    = sum(onut98d);
/* Yogurt */                 yogurt98    = sum(plyog98d, flyog98d);
/* Tea */                    tea98       = sum(tea98d,htea98d);
/* Beer */                   beer98      = sum(beer98d, lbeer98d);
/* High-fat dairy */         hfdairy98   = sum(but98d, cream98d); 
/* Eggs */                   eggs98      = sum(egg98d);

/* Processed red meat */     prmeat98    = sum(bacon98d, bfsh98d, dog98d,  oprom98d,sbol98d);
/* Potatoes */               potato98    = sum(pot98d);
/* Refined grain products */ rgrain98    = sum(rcer98d, whbr98d , crack98d, engl98d ,muff98d, wrice98d ,pcake98d ,pasta98d, pretz98d, tort98d);

/* cold breakfast cereal */ cereal98    = sum(cer98d);
/* Onions */                onion98     = sum(oniog98d, oniov98d);
/* Poultry */               poultry98   = sum(chwi98d, chwo98d, CTDOG98D); 
/* umb*/                    umb98       = sum(ccar98d, rcar98d, cel98d);
/* Orange juice*/           oj98        = sum(oj98d);
/* Other fruits  */         othfru98    = sum(ban98d,cant98d);
/* mayonnaise */            mayo98      = sum(mayo98d);
/* Avocado  */              avo98       = sum(avo98d);

/* Whole grains */          wgrain98    = sum(wcer98d ,ckcer98d ,oat98d, dkbr98d, brice98d, otgrn98d, bran98d, oatbr98d ,wgerm98d ,popc98d);
/* Juice */                 juice98     = sum(aj98d, othj98d);
/* Apple */                 apple98     = sum(appl98d);
/* Soy products */          soy98       = sum(tofu98d);
/* Cruciferous veg */       crucveg98   = sum(cauli98d, kale98d);
/* Condiments */            condi98     = sum(jam98d);
/* Citrus fruits */         citrus98    = sum(oran98d, grfr98d, grj98d);

/* Pizza */                 pizza98     = sum(pizza98d);

/* carrot*/                  carrot98    = sum(ccar98d, rcar98d);
/* corn*/                    corn98    = sum(corn98d);
/* beans */                  beans98     = sum(peas98d,sbean98d, bean98d);


FI98 = -(blueb98 * -0.022359623 + shchee98 * -0.000357103 + dietbev98 * 0.037505123 + frmeat98 * 0.041039490 
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


/******************** 2002 ********************/

%hp02 (keep=id cerbr02d cer02d blueb02d cotch02d crmch02d otch02d lccaf02d lcbnc02d 
                 hamb02d bmix02d bmain02d rais02d liq02d skim02d 
                 whbr02d  crack02d crklt02d engl02d muff02d pcake02d tort02d wrice02d pasta02d pretz02d
                 livb02d livc02d mixv02d ooilx02d dress02d tom02d toj02d tosau02d
                 whbr02d  crack02d crklt02d engl02d muff02d pcake02d tort02d wrice02d pasta02d pretz02d
                 yam02d osqua02d onut02d plyog02d flyog02d tea02d htea02d beer02d lbeer02d 
                 oniog02d oniov02d chwi02d chwo02d CTDOG02D ccar02d rcar02d cel02d ojca02d  ojreg02d
                 ban02d cant02d mayo02d avo02d  ckcer02d oat02d dkbr02d brice02d oatbr02d bran02d wgerm02d popcr02d popcl02d
aj02d othj02d prunj02d appl02d tofu02d cauli02d kale02d jam02d oran02d grfrj02d pizza02d
                 but02d cream02d egg02d jam02d bacon02d bfsh02d dog02d ctdog02d corn02d  peas02d bean02d sbean02d
                 oprom02d sbol02d pot02d
                 rwine02d  wwine02d, noformat=T);



data h02; set hp02;


array food {*}
                 blueb02d cotch02d crmch02d otch02d lccaf02d lcbnc02d
                 hamb02d bmix02d bmain02d rais02d liq02d skim02d 
                 livb02d livc02d mixv02d ooilx02d dress02d tom02d toj02d tosau02d
                 cer02d whbr02d  crack02d crklt02d engl02d muff02d pcake02d tort02d wrice02d pasta02d pretz02d
                 yam02d osqua02d onut02d plyog02d flyog02d tea02d htea02d beer02d lbeer02d 
                 oniog02d oniov02d chwi02d chwo02d CTDOG02D ccar02d rcar02d cel02d ojca02d  ojreg02d
                 ban02d cant02d mayo02d avo02d  ckcer02d oat02d dkbr02d brice02d oatbr02d bran02d wgerm02d popcr02d popcl02d
aj02d othj02d prunj02d appl02d tofu02d cauli02d kale02d jam02d oran02d grfrj02d pizza02d
                 but02d cream02d egg02d jam02d bacon02d bfsh02d dog02d ctdog02d  corn02d  peas02d bean02d sbean02d
                 oprom02d sbol02d pot02d
                 rwine02d  wwine02d ;

   do i=1 to DIM(food);
             if food{i}=8  then food{i}=6;
        else if food{i}=7  then food{i}=4.5;
        else if food{i}=6  then food{i}=2.5;
        else if food{i}=5  then food{i}=1;
        else if food{i}=4  then food{i}=0.79;
        else if food{i}=3  then food{i}=0.43;
        else if food{i}=2  then food{i}=0.14;
        else if food{i}=1  then food{i}=0.07;
        else if food{i}=0  then food{i}=0;
        else if food{i}=9  then food{i}=0;
        else if food{i}=.  then food{i}=0;
   end;

/** coding for livers **/
array liv02{2} livb02d livc02d;
   do i=1 to 2;
             if liv02{i} in (.,1,6)           then liv02{i}=0;
        else if liv02{i} in (2)               then liv02{i}=0.015;
        else if liv02{i} in (3)               then liv02{i}=0.03;
        else if liv02{i} in (4)               then liv02{i}=0.08;
        else if liv02{i} in (5)               then liv02{i}=0.14;
   end;

   if cerbr02d in (., 011, 015, 017, 018, 019, 020, 022, 030, 031, 035, 037, 044, 047, 
                060, 064, 066, 075, 076, 079, 080, 083, 088, 123, 130, 150, 161, 
                210, 219, 263, 264, 292, 310, 332, 339, 341, 362, 380, 384) 
then rcer02d = cer02d;
else wcer02d = cer02d;

if rcer02d = . then rcer02d = .;
if wcer02d = . then wcer02d = .;
run;

data h02_cat;
set  h02;

/* Blueberries */           blueb02     = sum(blueb02d);
/* Soft and hard cheese */  shchee02    = sum(cotch02d, crmch02d, otch02d);
/* Diet beverage */         dietbev02   = sum(lccaf02d, lcbnc02d);
/* Fresh red meat */        frmeat02    = sum(hamb02d, bmix02d, bmain02d);  
/* Grapes */            grape02     = sum(rais02d);
/* Liquor */            liq02       = sum(liq02d);
/* Low-fat milk */      lfmilk02    = sum(skim02d);
/* Mixed vegetables */      mixveg02    = sum(mixv02d);
/* Oil-based dress */       oildres02   = sum(ooilx02d,dress02d);
/* Organ meats */       organ02     = sum(livb02d, livc02d);
/* Tomato products */       tomprod02   = sum(tom02d, toj02d, tosau02d);
/* Wine */          wine02      = sum(rwine02d, wwine02d);

/* Yellow vegetables */      yelveg02    = sum(yam02d, osqua02d);
/* Nuts */                   othnut02    = sum(onut02d);
/* Yogurt */                 yogurt02    = sum(plyog02d, flyog02d);
/* Tea */                    tea02       = sum(tea02d, htea02d);
/* Beer */                   beer02      = sum(beer02d, lbeer02d);
/* High-fat dairy */         hfdairy02   = sum(but02d, cream02d); 
/* Eggs */                   eggs02      = sum(egg02d);

/* Processed red meat */     prmeat02    = sum(bacon02d, bfsh02d, dog02d,  oprom02d, sbol02d);
/* Potatoes */               potato02    = sum(pot02d);
/* Refined grain products */ rgrain02    = sum(rcer02d, whbr02d,  crack02d ,crklt02d, engl02d ,muff02d ,pcake02d, tort02d ,wrice02d,pasta02d, pretz02d);

/* Cold breakfast cereal */ cereal02 = sum(cer02d);
/* Onions */ onion02 = sum(oniog02d, oniov02d);
/* Poultry */ poultry02 = sum(chwi02d, chwo02d, CTDOG02D);
/* Umbrella category */ umb02 = sum(ccar02d, rcar02d, cel02d);
/* Orange juice */ oj02 = sum(ojca02d , ojreg02d);
/* Other fruits */ othfru02 = sum(ban02d, cant02d);
/* Mayonnaise */ mayo02 = sum(mayo02d);
/* Avocado */ avo02 = sum(avo02d);

/* Whole grains */          wgrain02    = sum(wcer02d, ckcer02d, oat02d, dkbr02d ,brice02d ,oatbr02d, bran02d ,wgerm02d, popcr02d, popcl02d);
/* Juice */                 juice02     = sum(aj02d, othj02d,prunj02d);
/* Apple */                 apple02     = sum(appl02d);
/* Soy products */          soy02       = sum(tofu02d);
/* Cruciferous veg */       crucveg02   = sum(cauli02d, kale02d);
/* Condiments */            condi02     = sum(jam02d);
/* Citrus fruits */         citrus02    = sum(oran02d, grfrj02d);

/* Pizza */                 pizza02     = sum(pizza02d);

/* carrot */                  carrot02    = sum(ccar02d, rcar02d);
/* corn */                    corn02    = sum(corn02d);
/* beans */                  beans02     = sum(peas02d, sbean02d, bean02d);
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


/******************** 2006 ********************/

%hp06(keep=id cerbr06d cer06d blueb06d  crmch06d otch06d lcbcf06d 
                 hamb06d bmix06d bmain06d rais06d liq06d skim06d 
                 livb06d livc06d mixv06d ooilx06d dress06d tom06d toj06d tosau06d
                 whbr06d  crack06d engl06d muff06d wrice06d  pcake06d pasta06d pretz06d tort06d crsbr06d
                 yam06d osqua06d onut06d plyog06d flyog06d tea06d htea06d beer06d lbeer06d 
                 oniog06d oniov06d chwi06d chwo06d CTDOG06D ccar06d rcar06d cel06d ojca06d  ojreg06d
                 ban06d cant06d mayo06d avo06d  ckcer06d oat06d wgrbr06d rye06d brice06d oatbr06d bran06d popcr06d popcl06d
aj06d othj06d prunj06d appl06d tofu06d cauli06d kale06d jam06d oran06d grfrj06d pizza06d
                 but06d cream06d egg06d jam06d bacon06d bfsh06d dog06d ctdog06d 
                 oprom06d sbol06d pot06d corn06d  peas06d bean06d sbean06d
                 rwine06d  wwine06d, noformat=T);


data h06; set hp06;


array food {*}
                 blueb06d  crmch06d otch06d lcbcf06d
                 hamb06d bmix06d bmain06d rais06d liq06d skim06d 
                 livb06d livc06d mixv06d ooilx06d dress06d tom06d toj06d tosau06d
                 cer06d whbr06d  crack06d engl06d muff06d wrice06d  pcake06d pasta06d pretz06d tort06d crsbr06d
                 yam06d osqua06d onut06d plyog06d flyog06d tea06d htea06d beer06d lbeer06d 
                 oniog06d oniov06d chwi06d chwo06d CTDOG06D ccar06d rcar06d cel06d ojca06d  ojreg06d 
                 ban06d cant06d mayo06d avo06d   ckcer06d oat06d wgrbr06d rye06d brice06d oatbr06d bran06d popcr06d popcl06d
aj06d othj06d prunj06d appl06d tofu06d cauli06d kale06d jam06d oran06d grfrj06d pizza06d
                 but06d cream06d egg06d jam06d bacon06d bfsh06d dog06d ctdog06d 
                 oprom06d sbol06d pot06d corn06d  peas06d bean06d sbean06d
                 rwine06d  wwine06d ;

   do i=1 to DIM(food);
             if food{i}=8  then food{i}=6;
        else if food{i}=7  then food{i}=4.5;
        else if food{i}=6  then food{i}=2.5;
        else if food{i}=5  then food{i}=1;
        else if food{i}=4  then food{i}=0.79;
        else if food{i}=3  then food{i}=0.43;
        else if food{i}=2  then food{i}=0.14;
        else if food{i}=1  then food{i}=0.07;
        else if food{i}=0  then food{i}=0;
        else if food{i}=9  then food{i}=0;
        else if food{i}=.  then food{i}=0;
   end;

/** coding for livers **/
array liv06{2} livb06d livc06d;
   do i=1 to 2;
             if liv06{i} in (.,1,6)           then liv06{i}=0;
        else if liv06{i} in (2)               then liv06{i}=0.015;
        else if liv06{i} in (3)               then liv06{i}=0.03;
        else if liv06{i} in (4)               then liv06{i}=0.08;
        else if liv06{i} in (5)               then liv06{i}=0.14;
   end;

   if cerbr06d in (0,4,11,12,13,15,16,17,19,20,21,22,23,25,30,31,33,35,37,38,42,45,46,47,59,
                60,61,62,63,64,65,66,68,73,74,75,76,79,80,81,82,83,85,86,88,95,97,98,101,
                109,113,123,124,130,149,150,153,158,170,173,177,182)
            then rcer06d=cer06d;
            else wcer06d=cer06d;
            if rcer06d=. then rcer06d=.;
            if wcer06d=. then wcer06d=.;

run;

data h06_cat;
set  h06;

/* Blueberries */       blueb06     = sum(blueb06d);
/* Soft and hard cheese */  shchee06    = sum(crmch06d, otch06d);
/* Diet beverage */     dietbev06   = sum(lcbcf06d);
/* Fresh red meat */    frmeat06    = sum(hamb06d, bmix06d, bmain06d);  
/* Grapes */            grape06     = sum(rais06d);
/* Liquor */            liq06       = sum(liq06d);
/* Low-fat milk */      lfmilk06    = sum(skim06d);
/* Mixed vegetables */  mixveg06    = sum(mixv06d);
/* Oil-based dress */   oildres06   = sum(ooilx06d,dress06d);
/* Organ meats */       organ06     = sum(livb06d, livc06d);
/* Tomato products */   tomprod06   = sum(tom06d, toj06d, tosau06d);
/* Wine */              wine06      = sum(rwine06d, wwine06d);

/* Yellow vegetables */      yelveg06    = sum(yam06d, osqua06d);
/* Nuts */                   othnut06    = sum(onut06d);
/* Yogurt */                 yogurt06    = sum(plyog06d, flyog06d);
/* Tea */                    tea06       = sum(tea06d, htea06d);
/* Beer */                   beer06      = sum(beer06d, lbeer06d);
/* High-fat dairy */         hfdairy06   = sum(but06d, cream06d); 
/* Eggs */                   eggs06      = sum(egg06d);

/* Processed red meat */     prmeat06    = sum(bacon06d, bfsh06d, dog06d,  oprom06d, sbol06d);
/* Potatoes */               potato06    = sum(pot06d);
/* Refined grain products */ rgrain06    = sum(rcer06d, whbr06d , crack06d, engl06d ,muff06d, wrice06d , pcake06d ,pasta06d, pretz06d ,tort06d, crsbr06d);

/* Cold breakfast cereal */ cereal06 = sum(cer06d);
/* Onions */ onion06 = sum(oniog06d, oniov06d);
/* Poultry */ poultry06 = sum(chwi06d, chwo06d, CTDOG06D);
/* Umbrella category */ umb06 = sum(ccar06d, rcar06d, cel06d);
/* Orange juice */ oj06 = sum(ojca06d, ojreg06d);
/* Other fruits */ othfru06 = sum(ban06d, cant06d);
/* Mayonnaise */ mayo06 = sum(mayo06d);
/* Avocado */ avo06 = sum(avo06d);

/* Whole grains */          wgrain06    = sum(wcer06d ,ckcer06d ,oat06d, wgrbr06d ,rye06d, brice06d, oatbr06d, bran06d, popcr06d, popcl06d);
/* Juice */                 juice06     = sum(aj06d, othj06d,prunj06d);
/* Apple */                 apple06     = sum(appl06d);
/* Soy products */          soy06       = sum(tofu06d);
/* Cruciferous veg */       crucveg06   = sum(cauli06d, kale06d);
/* Condiments */            condi06     = sum(jam06d);
/* Citrus fruits */         citrus06    = sum(oran06d,grfrj06d);

/* Pizza */                 pizza06     = sum(pizza06d);

/* carrot */                  carrot06    = sum(ccar06d, rcar06d);
/* corn */                    corn06    = sum(corn06d);
/* beans */                  beans06     = sum(peas06d, sbean06d, bean06d);


FI06 =-(blueb06 * -0.022359623 + shchee06 * -0.000357103 + dietbev06 * 0.037505123 + frmeat06 * 0.041039490 
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


/******************** 2010 ********************/

%hp10(keep=id  cerbr10d cer10d blueb10d cotch10d crmch10d otch10d lcbcf10d
                 hamb10d bmix10d bmain10d rais10d liq10d skim10d 
                 livb10d livc10d mixv10d ooilx10d dress10d tom10d toj10d tosau10d
                  yam10d osqua10d onut10d plyog10d artyog10d tea10d beer10d lbeer10d
                  oniog10d oniov10d chwi10d chwo10d CTDOG10D ccar10d rcar10d cel10d ojca10d  ojreg10d
                 ban10d cant10d mayo10d avo10d  ckcer10d oat10d wgrbr10d rye10d brice10d oatbr10d popcr10d popcl10d crackww10d
aj10d othj10d prunj10d appl10d tofu10d cauli10d kale10d jam10d oran10d grfrj10d pizza10d
                 but10d cream10d egg10d jam10d bacon10d bfsh10d dog10d ctdog10d oprom10d sbol10d pot10d
                 whbr10d crackot10d engl10d muff10d wrice10d pcake10d pasta10d pretz10d tort10d corn10d  peas10d bean10d sbean10d
                 rwine10d  wwine10d, noformat=T);

data h10; set hp10;
    
array food {*}
        blueb10d cotch10d crmch10d otch10d lcbcf10d
                 hamb10d bmix10d bmain10d rais10d liq10d skim10d 
                 livb10d livc10d mixv10d ooilx10d dress10d tom10d toj10d tosau10d
                 yam10d osqua10d onut10d plyog10d artyog10d tea10d beer10d lbeer10d
                 oniog10d oniov10d chwi10d chwo10d CTDOG10D ccar10d rcar10d cel10d ojca10d  ojreg10d
                 ban10d cant10d mayo10d avo10d   ckcer10d oat10d wgrbr10d rye10d brice10d oatbr10d popcr10d popcl10d crackww10d
aj10d othj10d prunj10d appl10d tofu10d cauli10d kale10d jam10d oran10d grfrj10d pizza10d
                 but10d cream10d egg10d jam10d bacon10d bfsh10d dog10d ctdog10d oprom10d sbol10d pot10d
                 cer10d whbr10d crackot10d engl10d muff10d wrice10d pcake10d pasta10d pretz10d tort10d corn10d  peas10d bean10d sbean10d
                 rwine10d  wwine10d ;

   do i=1 to DIM(food);
             if food{i}=8  then food{i}=6;
        else if food{i}=7  then food{i}=4.5;
        else if food{i}=6  then food{i}=2.5;
        else if food{i}=5  then food{i}=1;
        else if food{i}=4  then food{i}=0.79;
        else if food{i}=3  then food{i}=0.43;
        else if food{i}=2  then food{i}=0.14;
        else if food{i}=1  then food{i}=0.07;
        else if food{i}=0  then food{i}=0;
        else if food{i}=9  then food{i}=0;
        else if food{i}=.  then food{i}=0;
   end;

/** coding for livers **/
array liv10{2} livb10d livc10d;
   do i=1 to 2;
             if liv10{i} in (.,1,6)           then liv10{i}=0;
        else if liv10{i} in (2)               then liv10{i}=0.015;
        else if liv10{i} in (3)               then liv10{i}=0.03;
        else if liv10{i} in (4)               then liv10{i}=0.08;
        else if liv10{i} in (5)               then liv10{i}=0.14;
   end;

   if cerbr10d in (0,4,11,12,13,15,16,17,19,20,21,22,23,25,30,31,33,35,37,38,42,45,46,47,59,
                60,61,62,63,64,65,66,68,73,74,75,76,79,80,81,82,83,85,86,88,95,97,98,101,
                109,113,123,124,130,149,150,153,158,170,173,177,182)
            then rcer10d=cer10d;
            else wcer10d=cer10d;
            if rcer10d=. then rcer10d=.;
            if wcer10d=. then wcer10d=.;
run;

data h10_cat;
set  h10;

/* Blueberries */       blueb10     = sum(blueb10d);
/* Soft and hard cheese */  shchee10    = sum(cotch10d, crmch10d, otch10d);
/* Diet beverage */     dietbev10   = sum(lcbcf10d);
/* Fresh red meat */        frmeat10    = sum(hamb10d, bmix10d, bmain10d);  
/* Grapes */            grape10     = sum(rais10d);
/* Liquor */            liq10       = sum(liq10d);
/* Low-fat milk */      lfmilk10    = sum(skim10d);
/* Mixed vegetables */      mixveg10    = sum(mixv10d);
/* Oil-based dress */       oildres10   = sum(ooilx10d,dress10d);
/* Organ meats */       organ10     = sum(livb10d, livc10d);
/* Tomato products */       tomprod10   = sum(tom10d, toj10d, tosau10d);
/* Wine */          wine10      = sum(rwine10d, wwine10d);

/* Yellow vegetables */      yelveg10    = sum(yam10d, osqua10d);
/* Nuts */                   othnut10    = sum(onut10d);
/* Yogurt */                 yogurt10    = sum(plyog10d, artyog10d);
/* Tea */                    tea10       = sum(tea10d);
/* Beer */                   beer10      = sum(beer10d, lbeer10d);
/* High-fat dairy */         hfdairy10   = sum(but10d, cream10d); 
/* Eggs */                   eggs10      = sum(egg10d);

/* Processed red meat */     prmeat10    = sum(bacon10d, bfsh10d, dog10d,  oprom10d, sbol10d);
/* Potatoes */               potato10    = sum(pot10d);
/* Refined grain products */ rgrain10    = sum(rcer10d, whbr10d,  crackot10d, engl10d, muff10d,wrice10d,  pcake10d, pasta10d, pretz10d, tort10d);

/* Cold breakfast cereal */ cereal10 = sum(cer10d);
/* Onions */ onion10 = sum(oniog10d, oniov10d);
/* Poultry */ poultry10 = sum(chwi10d, chwo10d, CTDOG10D);
/* Umbrella category */ umb10 = sum(ccar10d, rcar10d, cel10d);
/* Orange juice */ oj10 = sum(ojca10d, ojreg10d);
/* Other fruits */ othfru10 = sum(ban10d, cant10d);
/* Mayonnaise */ mayo10 = sum(mayo10d);
/* Avocado */ avo10 = sum(avo10d);

/* Whole grains */          wgrain10    = sum(wcer10d, ckcer10d, oat10d, wgrbr10d, rye10d, brice10d, oatbr10d, popcr10d,popcl10d ,crackww10d);
/* Juice */                 juice10     = sum(aj10d, othj10d, prunj10d);
/* Apple */                 apple10     = sum(appl10d);
/* Soy products */          soy10       = sum(tofu10d);
/* Cruciferous veg */       crucveg10   = sum(cauli10d, kale10d);
/* Condiments */            condi10     = sum(jam10d);
/* Citrus fruits */         citrus10    = sum(oran10d, grfrj10d);

/* Pizza */                 pizza10     = sum(pizza10d);

/* carrot */                  carrot10    = sum(ccar10d, rcar10d);
/* corn */                    corn10    = sum(corn10d);
/* beans */                  beans10     = sum(peas10d, sbean10d, bean10d);

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


/******************** 2014 ********************/
%hp14(keep=id cerbr14d cer14d blueb14d cotch14d crmch14d otch14d lcbcf14d
                 hamb14d bmix14d bmain14d rais14d liq14d skim14d 
                 livb14d livc14d mixv14d ooilx14d dress14d tom14d toj14d tosau14d
                 yam14d osqua14d onut14d plyog14d artyog14d tea14d beer14d lbeer14d but14d cream14d egg14d jam14d
bacon14d bfsh14d dog14d ctdog14d oprom14d sbol14d pot14d
  oniog14d  oniov14d chwi14d chwo14d CTDOG14D ccar14d rcar14d ojca14d  ojreg14d 
ban14d cant14d mayo14d avo14d  ckcer14d oat14d wgrbr14d rye14d brice14d oatbr14d popcr14d popcl14d crackww14d
aj14d othj14d  appl14d tofu14d cauli14d kale14d jam14d oran14d grfrj14d pizza14d
 whbr14d crackot14d engl14d muff14d wrice14d pcake14d pasta14d pretz14d tort14d corn14d  peas14d bean14d sbean14d
                 rwine14d  wwine14d, noformat=T);


data h14; set hp14;


array food {*}
                 blueb14d cotch14d crmch14d otch14d lcbcf14d
                 hamb14d bmix14d bmain14d rais14d liq14d skim14d 
                 livb14d livc14d mixv14d ooilx14d dress14d tom14d toj14d tosau14d
                 yam14d osqua14d onut14d plyog14d artyog14d tea14d beer14d lbeer14d but14d cream14d egg14d jam14d
bacon14d bfsh14d dog14d ctdog14d oprom14d sbol14d pot14d cer14d  oniog14d  oniov14d chwi14d chwo14d CTDOG14D ccar14d rcar14d  ojca14d  ojreg14d 
ban14d cant14d mayo14d avo14d ckcer14d oat14d wgrbr14d rye14d brice14d oatbr14d popcr14d popcl14d crackww14d
aj14d othj14d  appl14d tofu14d cauli14d kale14d jam14d oran14d grfrj14d pizza14d
 whbr14d crackot14d engl14d muff14d wrice14d pcake14d pasta14d pretz14d tort14d corn14d  peas14d bean14d sbean14d
                 rwine14d  wwine14d ;

   do i=1 to DIM(food);
             if food{i}=8  then food{i}=6;
        else if food{i}=7  then food{i}=4.5;
        else if food{i}=6  then food{i}=2.5;
        else if food{i}=5  then food{i}=1;
        else if food{i}=4  then food{i}=0.79;
        else if food{i}=3  then food{i}=0.43;
        else if food{i}=2  then food{i}=0.14;
        else if food{i}=1  then food{i}=0.07;
        else if food{i}=0  then food{i}=0;
        else if food{i}=9  then food{i}=0;
        else if food{i}=.  then food{i}=0;
   end;

/** coding for livers **/
array liv14{2} livb14d livc14d;
   do i=1 to 2;
             if liv14{i} in (.,1,6)           then liv14{i}=0;
        else if liv14{i} in (2)               then liv14{i}=0.015;
        else if liv14{i} in (3)               then liv14{i}=0.03;
        else if liv14{i} in (4)               then liv14{i}=0.08;
        else if liv14{i} in (5)               then liv14{i}=0.14;
   end;

if cerbr14d in (0,4,11,12,13,15,16,17,19,20,21,22,23,25,30,31,33,35,37,38,42,45,46,47,59,
                60,61,62,63,64,65,66,68,73,74,75,76,79,80,81,82,83,85,86,88,95,97,98,101,
                109,113,123,124,130,149,150,153,158,170,173,177,182)
            then rcer14d=cer14d;
            else wcer14d=cer14d;
            if rcer14d=. then rcer14d=.;
            if wcer14d=. then wcer14d=.;
run;

data h14_cat;
set  h14;

/* Blueberries */           blueb14     = sum(blueb14d);
/* Soft and hard cheese */  shchee14    = sum(cotch14d, crmch14d, otch14d);
/* Diet beverage */         dietbev14   = sum(lcbcf14d);
/* Fresh red meat */        frmeat14    = sum(hamb14d, bmix14d, bmain14d);  
/* Grapes */                grape14     = sum(rais14d);
/* Liquor */                liq14       = sum(liq14d);
/* Low-fat milk */          lfmilk14    = sum(skim14d);
/* Mixed vegetables */      mixveg14    = sum(mixv14d);
/* Oil-based dress */       oildres14   = sum(ooilx14d,dress14d);
/* Organ meats */           organ14     = sum(livb14d, livc14d);
/* Tomato products */       tomprod14   = sum(tom14d, toj14d, tosau14d);
/* Wine */                  wine14      = sum(rwine14d, wwine14d);

/* Yellow vegetables */      yelveg14    = sum(yam14d, osqua14d);
/* Nuts */                   othnut14    = sum(onut14d);
/* Yogurt */                 yogurt14    = sum(plyog14d, artyog14d);
/* Tea */                    tea14       = sum(tea14d);
/* Beer */                   beer14      = sum(beer14d, lbeer14d);
/* High-fat dairy */         hfdairy14   = sum(but14d, cream14d); 
/* Eggs */                   eggs14      = sum(egg14d);

/* Processed red meat */     prmeat14    = sum(bacon14d, bfsh14d, dog14d, oprom14d, sbol14d);
/* Potatoes */               potato14    = sum(pot14d);
/* Refined grain products */ rgrain14    = sum(rcer14d, whbr14d , crackot14d, engl14d, muff14d, wrice14d,  pcake14d, pasta14d, pretz14d ,tort14d);

/* Cold breakfast cereal */ cereal14 = sum(cer14d);
/* Onions */ onion14 = sum(oniog14d, oniov14d);
/* Poultry */ poultry14 = sum(chwi14d, chwo14d, CTDOG14D);
/* Umbrella category */ umb14 = sum(ccar14d, rcar14d);
/* Orange juice */ oj14 = sum(ojca14d, ojreg14d );
/* Other fruits */ othfru14 = sum(ban14d, cant14d);
/* Mayonnaise */ mayo14 = sum(mayo14d);
/* Avocado */ avo14 = sum(avo14d);

/* Whole grains */          wgrain14    = sum(wcer14d, ckcer14d, oat14d, wgrbr14d, rye14d, brice14d, oatbr14d, popcr14d, popcl14d ,crackww14d);
/* Juice */                 juice14     = sum(aj14d, othj14d);
/* Apple */                 apple14     = sum(appl14d);
/* Soy products */          soy14       = sum(tofu14d);
/* Cruciferous veg */       crucveg14   = sum(cauli14d, kale14d);
/* Condiments */            condi14     = sum(jam14d);
/* Citrus fruits */         citrus14    = sum(oran14d, grfrj14d);

/* Pizza */                 pizza14     = sum(pizza14d);

/* carrot */                  carrot14    = sum(ccar14d, rcar14d);
/* corn */                    corn14    = sum(corn14d);
/* beans */                  beans14     = sum(peas14d, sbean14d, bean14d);

FI14 = -(blueb14 * -0.022359623 + shchee14 * -0.000357103 + dietbev14 * 0.037505123 + frmeat14 * 0.041039490 
     + grape14 * -0.005362665 + liq14 * 0.042291654 + lfmilk14 * -0.037611764 + organ14 * 0.039207711 
     + mixveg14 * 0.091345174 + oildres14 * 0.016648388 + tomprod14 * 0.022265025 + wine14 * 0.016825528);

FI14a = -(shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14b = -(blueb14*-0.022359623 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14c = -(blueb14*-0.022359623+shchee14*-0.000357103  +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14d = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14e = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14f = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14g = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14h = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14i = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+oildres14*0.016648388 
+tomprod14*0.022265025+wine14*0.016825528);

FI14j = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174
+tomprod14*0.022265025+wine14*0.016825528);

FI14k = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+wine14*0.016825528);

FI14l = -(blueb14*-0.022359623+shchee14*-0.000357103 +dietbev14*0.037505123 +frmeat14*0.041039490+grape14*-0.005362665 
+liq14*0.042291654+lfmilk14*-0.037611764+organ14*0.039207711+mixveg14*0.091345174+oildres14*0.016648388 
+tomprod14*0.022265025);

run;

 * ---------------------------------------------------------------------------------------------------------

                              Read in habitual diet quality

* ---------------------------------------------------------------------------------------------------------;

libname aheidat'/udd/n2xwa/hpfs_read';
data ahei;
 set aheidat.aheimod_hpfs;
run;
  

    /*** read physical activity data***/ 

* activity (86-16);
%hmet8616(keep= act86 act88 act90 act92 act94 act96 act98 act00 act02 act04 act06 act08 act10 act12 act14 act16);

    data hmet8616;
    set hmet8616;

    array acts{16} act86 act88 act90 act92 act94 act96 act98 act00 act02 act04 act06 act08 act10 act12 act14 act16;

    do i=1 to 16;
        if acts{i} in (998,999) then acts{i}=.;
    end;

    /* carry forward missing physical activity */
    do i=2 to 16;
        if acts{i}=. then acts{i}=acts{i-1};
    end;

    drop i;
run;

    /****** Nutrients ******/
%h86_nts  (keep=alco86n calor86n  na86n tfat86n sat86n  mon86n  poly86n prot86n carbo86n  afat86n vfat86n );
%h90_nts  (keep=alco90n calor90n  na90n tfat90n sat90n  mon90n  poly90n prot90n carbo90n  afat90n vfat90n );
%h94_nts  (keep=alco94n calor94n  na94n tfat94n sat94n  mon94n  poly94n prot94n carbo94n  afat94n vfat94n );
%h98_nts  (keep=alco98n calor98n  na98n tfat98n sat98n  mon98n  poly98n prot98n carbo98n  afat98n vfat98n );
%h02_nts  (keep=alco02n calor02n  na02n tfat02n sat02n  mon02n  poly02n prot02n carbo02n  afat02n vfat02n );
%h06_nts  (keep=alco06n calor06n  na06n tfat06n sat06n  mon06n  poly06n prot06n carbo06n  afat06n vfat06n );
%h10_nts  (keep=alco10n calor10n  na10n tfat10n sat10n  mon10n  poly10n prot10n carbo10n  afat10n vfat10n );
%h14_nts  (keep=alco14n calor14n  na14n tfat14n sat14n  mon14n  poly14n prot14n carbo14n  afat14n vfat14n );


   /****read in self-reported diabetes, cancer, CVD and hypertension data***/
   %hp_der (keep=dbmy86 dbmy09 rtmnyr86 rtmnyr88 rtmnyr90 rtmnyr92 rtmnyr94 rtmnyr96 rtmnyr98 rtmnyr00 rtmnyr02 rtmnyr04 rtmnyr06 
                 height bmi2186 wt86 wt88 wt90 wt92 wt94 wt96 wt98 wt00 wt02 wt04 wt06 
                 smoke86 smoke88 smoke90 smoke92 smoke94 smoke96 smoke98 smoke00 smoke02 smoke04 smoke06 
                 cgnm86 cgnm88 cgnm90 cgnm92 cgnm94 cgnm96 cgnm98 cgnm00 cgnm02 cgnm04 cgnm06
                 hbp86 hbp88 hbp90 db86 db88 db90f chol86 chol88 chol90 
                 mi86 mi88 mi90 cabg86 cabg88 cabg90 ang86 ang88 ang90 
                 str86 str88 str90 pe86 pe88 pe90 orhy86 orhy88 orhy90
                 can86 can88 can90  fmel90   mmel90   smel90 
                 fdb3087 mdb3087 sdb3087 bdb3087 fdb2987 mdb2987 sdb2987 bdb2987 dbfh87
                 fclc86 afclc86 mclc86 amclc86 
                 fclc90 fpro90  mclc90 sclc90 spro90 stpyr86);

/*Family history of DB*/

  if fdb3087=1 or mdb3087=1 or sdb3087=1 or bdb3087=1 then dbfh87=1;else dbfh87=0;                                                               
  if can86=1 then can88=1;
  if can88=1 then can90=1;


  %hp_der_2 (keep= smoke08  smoke10 smoke12 smoke14 smoke16 smoke18 
    cgnm08   cgnm10  cgnm12  cgnm14  cgnm16  cgnm18  
    pckyr08  pckyr10 pckyr12 pckyr14 pckyr16 pckyr18 
    wt08     wt10    wt12    wt14    wt16    wt18    
    bmi08    bmi10   bmi12   bmi14   bmi16   bmi18   
    rtmnyr08 rtmnyr10 rtmnyr12 rtmnyr14 rtmnyr16 rtmnyr18);


   %hp86(keep= colc86  pros86  lymp86  ocan86  mel86  trig86
              seuro86 scand86 ocauc86 afric86 asian86 oanc86  pe86 ucol86 asth86 mmi86 fmi86 
              asp86 mar86  livng86 gout86 
              betab86 lasix86 diur86 calcb86 ald86
              hbpd86 renf86 renfd86 antch86 race white); 

              if db86 ne 1 then db86=0; 
              if colc86 ne 1 then colc86=0; if mel86 ne 1 then mel86=0; if pros86 ne 1 then pros86=0;
              if lymp86 ne 1 then lymp86=0; if ocan86 ne 1 then ocan86=0;

         if afric86=1 then race=4;
    else if asian86=1 then race=3;
    else if oanc86=1  then race=2;
    else                   race=1;
   
    if race=1 then white=1;
    else white=0;


   %h86_dt(keep=mvt86d mvt86);  

   if mvt86d=0 then mvt86=2; else if mvt86d=2 then mvt86=1; else mvt86=3;
                                             

   %hp88(keep=hbp88 db88 colc88  pros88  lymp88  ocan88  mel88 chol88 trig88 mi88 ang88 str88 cabg88 renf88 pe88 ucol88 
              mvt88 asp88 mar88  livng88
              betab88 lasix88 diur88 ccblo88 ald88
              hbpd88  renf88 renfd88 
              pct588 pct1088 pct2088 pct3088 pct4088 pct88 physc88 chrx88 vite88); 
              if asp88=1 then asp88=1;else asp88=0;
        

   %hp90(keep=hbp90 db90 colc90  pros90  lymp90  ocan90  mel90 chol90 trig90 mi90 ang90 str90 cabg90 renf90 pe90 ucol90 
              asp90 mar90 livng90 antid90 betab90 lasix90 diur90 ccblo90 ald90
              renf90 renfd90  hbpd90
              mdb90 fdb90 sdb90 dbfh90 physc90 chrx90); 
              if asp90=1 then asp90=1;else asp90=0;
              if fdb90=1 or mdb90=1 or sdb90=1 then dbfh90=1; else dbfh90=0;

   %h90_dt(keep=mvt90d mvt90 );  mvt90=mvt90d; 

   %hp92(keep=hbp92 db92 colc92  pros92  lymp92  ocan92  mel92 chol92 trig92 mi92 ang92 str92 cabg92 renf92 pe92 ucol92 asth92 pneu92
              mvt92 asp92 mar92 livng92
              antid92 betab92 lasix92 thiaz92 ccblo92 ald92
              fdb92 mdb92 sdb92 dbfh92
              renf92 renfd92 hbpd92 vite92
              mlng92 mclc92 flng92 fclc92 fpro92 slng92 sclc92 spro92 cafh92 physx92 chrx92 mmel92  fmel92  smel92);

              if fdb92=1 or mdb92=1 or sdb92=1 then dbfh92=1; else dbfh92=0; vite92=3-vite92;
              if mlng92=1 or mclc92=1 or flng92=1 or fclc92=1 or fpro92=1 or slng92=1 or sclc92=1 or spro92=1 then cafh92=1; else cafh92=0;
              if asp92=1 then asp92=1;else asp92=0;

   %hp94(keep=hbp94 db94 colc94  pros94  lymp94  ocan94  mel94 chol94 trig94 mi94 ang94 str94 cabg94 pe94 ucol94 pneu94 
              asp94 mar94 livng94 /*Renal function was not collected in 1994 so I created one equal to zero since all missing CKD is later coded as zero*/ renf94 
              antid94 betab94 lasix94 thiaz94 ccblo94 ald94 hbpd94 physx94 chrx94);
              renf94=0;
              if asp94=1 then asp94=1;else asp94=0;



   %h94_dt(keep=mvt94d mvt94);
   mvt94=mvt94d;

   %hp96(keep=hbp96 db96 colc96  pros96  lymp96  ocan96  mel96 chol96 trig96 mi96 ang96 str96 cabg96 renf96
              pe96 ucol96 asth96 pneu96  emph96    
              asp96 aspd96 mvt96 
              hbpd96 renf96 renfd96 thiaz96 lasix96
              pclc96 sclc196 sclc296 fpro96 bpro196 bpro296 sbrc196 mbrcn96 cafh96 physx96 chrx96); 
             
              if aspd96 in (2,3,4,5) then asp96=1; else asp96=0;
              if pclc96=1 or sclc196=1 or sclc296=1 or fpro96=1 or bpro196=1 or bpro296=1 or sbrc196=1 or mbrcn96=1 then cafh96=1; else cafh96=0;

   %hp98(keep=hbp98 db98 colc98  pros98  lymp98  ocan98  mel98 chol98 trig98 mi98 ang98 str98 cabg98 renf98
              pe98 ucol98 asth98 pneu98  emph98   lasix98 
              mar98  livng98  przc98 tcyc98  thiaz98
              hbpd98 renf98 renfd98 physx98 chrx98); 
              

   %h98_dt(keep=mvt98d mvt98 vite98d vite98 dcaf98d coff98d tea98d );mvt98=mvt98d;vite98=9; if vite98d=2 then vite98=2; else if vite98d=1 then vite98=1;run; 
   %hp00(keep=hbp00 db00 colc00  pros00  lymp00  ocan00  mel00 chol00 trig00 mi00 ang00 strk00 cabg00
              slp00 snore00 bus00 indrs00 space00 ill00  htsc00 panic00 worry00 out00 
              slp00 snore00 renf00 thiaz00 lasix00
              pe00 ucol00 asth00 pneu00  emph00    
              asp00 mvt00  
              hbpd00);
             
   %hp02(keep=hbp02 db02 colc02  pros02  lymp02  ocan02  mel02 chol02 trig02 mi02 ang02 strk02 cabg02 przc02 tcyc02 antid02 ra02 oa02 smk02 ncig02 renal02
              betab02 lasix02 thiaz02 calcb02 anthp02    iron02 asp02 mvt02
              legpn02 rest02 night02
              pe02 ucol02 asth02 pneu02 pern02   copd02  
              mar02 lalon02  depr02 renf02
              renal02 renld02  hbpd02 vite02 physc02 stat02 ochrx02 dcaf02d coff02d tea02d ); 
   renf02=renal02; /* Made new variable to be consistent with previous years */

             
   %hp04(keep=hbp04 db04 colc04  pros04  lymp04  ocan04  mel04 chol04 trig04 mi04 mi1d04 ang04 angd04 strk04 cabg04 cabgd04 przc04 tcyc04 antid04 ra04 oa04 smk04 ncig04 
              dfslp04 wake04 early04 nap04 restd04 renal04 betab04 ace04 lasix04 thiaz04 calcb04 anthp04 iron04 asp04 mvt04
               vite04 physc04 stat04 mev04 zoc04 crest04 prav04 lip04 ostat04 ochrx04 renf04);
   renf04=renal04;  /* Made new variable to be consistent with previous years */

   %hp06(keep=hbp06 hbpd06 db06 colc06  pros06  lymp06  ocan06  mel06 chol06 trig06 mi06 ang06 angd06 strk06 cabg06 cabgd06 mib06 angd06 przc06 tcyc06 antid06 ra06 oa06 smk06 ncig06 renal06
              betab06 ace06 lasix06 thiaz06 calcb06 anthp06 iron06 asp06 mvt06
              mar06 lalon06 renf06
              hbpd06 renal06 renld06 vite06 physc06);
   renf06=renal06; /* Made new variable to be consistent with previous years */
   %hp08(keep=hbp08 hbpd08 db08 colc08  pros08  lymp08  ocan08  mel08 chol08 trig08 mi08 ang08 strk08 cabg08 cabgd08 mi1d08 angd08
              ra08 oa08 smk08 ncig08 renal08  betab08 ace08 lasix08 thiaz08 calcb08 arb08 anthp08 iron08 asp08 mvt08 wt08 renf08);        
          
    renf08=renal08; /* Made new variable to be consistent with previous years */
             
   %hp10(keep=wt10 mar10 physy10 physc10 lalon10 phypt10 hbp10 hbpd10 db10 dbd10 chol10 chold10 trig10 trigd10 cabg10 cabgd10 mi10 mi1d10 mih10 ang10 angd10 angc10 afib10 afibd10 chf10
              chfd10 dpvt10 dpvtd10 tia10 tiad10 strk10 strkd10 cart10 cartd10 clau10 claud10 artd10 artdd10 pe10 ped10 aort10 aortd10 gout10 goutd10 ra10 rad10 oa10 oad10
              renal10 renld10 dvrt10 dvrtd10 cpol10 cpold10 colc10 colcd10 pren10 prend10 pros10 prosd10 blad10 bladd10 sola10 solad10 bcc10 bccd10 scc10 sccd10 mel10 meld10 lymp10
              lympd10 ocan10 ocand10 canc10 ocanp10 glau10 glaud10 cat10 catd10 catx10 catxd10 macu10 macud10 ost10 ostd10 hipr10 hiprd10 per10 perd10 oral10 orald10 chct10 chctd10
              kid10 kidd10 park10 parkd10 als10 alsd10 dx2ptb10 ucol10 ucold10 gdul10 gduld10 besph10 besphd10 
              alcd10 hrloss10 hrlossd10 asth10 asthd10 pern10 pernd10 copd10 copdd10
              odx10 odxd10 icda10 icdaw10 odxpt10 nofra10 hfra10 wfra10 frapt10 fcdpt10 fcdpt10_extra medpt10 tyl10 meds tyld10 tylt10 asp10 aspd10 aspt10 aspds10 mtrn10 mtrnd10
              mtrnt10 cox2i10 cox2d10 analg10 stat10 mev10 zoc10 crest10 prav10 lip10 ostat10 statpt10 ochrx10 betab10 calcb10 ace10 arb10 thiaz10 lasix10 anthp10 ster10 insul10 ohypo10
              prosc10 alphb10 pril10 tag10 fosmx10 clopi10 couma10 andep10 slpmed10 nomed10 orx10 mvt10 nmvt10 censl10 centr10 othmv10 thera10 onday10 mvtpt10 mvtbr10 mvtop10 extra_3 vitpt10
              vita10 vitad10 k10 kd10 vitc10 vitcd10 vtb610 vtb6d10 vite10 vited10 vitet10 coff10d tea10d dcaf10d renf10);  
              renf10=renal10; /* Made new variable to be consistent with previous years */          
   %hp12(keep=drt12 smk12 ncig12 wt12 mar12 physy12 physc12 hbp12 hbpd12 db12 dbd12 chol12 chold12 trig12 trigd12 cabg12 cabgd12 mi12 mi1d12 mih12 ang12 angd12 angc12 afib12 afibd12 chf12
              chfd12 dpvt12 dpvtd12 tia12 tiad12 strk12 strkd12 cart12 cartd12 clau12 claud12 artd12 artdd12 pe12 ped12 aort12 aortd12 gout12 goutd12 ra12 rad12 oa12 oad12
              renal12 renld12 dvrt12 dvrtd12 cpol12 cpold12 colc12 colcd12 pren12 prend12 pros12 prosd12 blad12 bladd12 sola12 solad12 bcc12 bccd12 scc12 sccd12 mel12 meld12 lymp12
              lympd12 ocan12 ocand12 canc12 
              asp12 aspd12  aspds12 
              mvt12 nmvt12);

   %hp14(keep= hbp14 chol14 db14 mi14 cabg14 ang14 strk14     
            colc14 mel14 pros14 lymp14 ocan14 
            mvt14 blad14  bcc14  scc14 park14 parkd14 asp14 mar14 drt14 smk14 ncig14 wt14 ); 

   %hp16(keep= hbp16 chol16 db16 mi16 cabg16 ang16 stk16
            colc16 pros16 mel16 lymp16 blad16 ocan16 );
    * multivitamin was NOT asked in 2016 q;
    * will carry forward the value in mvt14;
   %hp18(keep= hbp18 chol18 db18 mi18 cabg18 ang18 strk18 /* different from stk18*/
            colc18 pros18 mel18 lymp18 blad18 ocan18);


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


                ******************************************
                *               merge data               *
                ******************************************;   

    data base0;
    merge gout_merged hp_der(in=mst) hp_der_2 h86_cat h90_cat h94_cat h98_cat h02_cat h06_cat h10_cat h14_cat
    dead hp86 hp88 hp90 hp92 hp94 hp96 hp98 hp00 hp02 hp04 hp06 hp08 hp10 hp12 hp14 hp16 hp18 hmet8616 ahei
    h86_nts h90_nts h94_nts h98_nts h02_nts h06_nts h10_nts h14_nts h86_dt h90_dt h94_dt h98_dt  GOUTPRS  
    end=_end_;
    by id;
    exrec=1;
    if first.id and mst then exrec=0; 

    
/** family history of DM **/
* onset after age 30 presumed to be NIDDM or T2D;
    if fdb3087=1 or mdb3087=1 or sdb3087=1 or bdb3087=1 then fhdb87=1;else fhdb87=0;
    if fdb92=1   or mdb92=1   or sdb92=1                then fhdb92=1;else fhdb92=0;
    if fhdb87=1 or fhdb92=1 then famhxdb=1;else famhxdb=0;
    if famhxdb ne 1 then famhxdb=0;


/**family history of Cancer**/
    if fclc86=1 or mclc86=1 or
       fclc90=1 or mclc90=1 or sclc90=1 or
       fpro90=1 or spro90=1 or
       fmel90=1 or mmel90=1 or smel90=1 or
       mlng92=1 or flng92=1 or slng92=1 or
       mclc92=1 or fclc92=1 or sclc92=1 or
       mmel92=1 or fmel92=1 or smel92=1 or
       fpro92=1 or spro92=1
       then famhxca=1;else famhxca=0;
       if famhxca ne 1 then famhxca=0;


/**family history of MI**/
    if fmi86=1 or  mmi86=1 then famhxmi=1;else famhxmi=0;
    if famhxmi ne 1 then famhxmi=0;

 /**baseline diabetes**/
    if db86=1 then dbbase=1; else dbbase=0;

/**baseline hypertension**/
    if hbp86=1 then hbpbase=1; else hbpbase=0;

/**baseline high blood cholesterol**/
    if chol86=1 then cholbase=1; else cholbase=0;
    
*Hypertension or hypercholesterolemia or diabetes at baseline;
    if hbpbase=1 or cholbase=1 or dbbase=1 then bcdbase=1; else bcdbase=0;

/**baseline cancer**/
    if can86=1 then canbase=1; else canbase=0;

/**Hypertension, hypercholesterolemia, or dibetes at baseline**/
    if hbp86=1 or chol86=1 or db86=1 then bcdbase=1; else bcdbase=0;

/**baseline heart disease**/
    if mi86=1 or ang86=1 then hrtbase=1; else hrtbase=0;
run;



 data base0;
 set base0 end=_end_;
   birthday=dbmy86;

   deadage=int((dtdth-birthday)/12);
   if dtdth in (0,.)then deadage=0;
   if dtdth eq 9999 then deadage=0;

   can86=0;
   if pros86=1 or lymp86=1 or ocan86=1 or colc86=1 or mel86=1 then can86=1;
   can88=0;
   if pros88=1 or lymp88=1 or ocan88=1 or colc88=1 or mel88=1 then can88=1;
   can90=0;
   if pros90=1 or lymp90=1 or ocan90=1 or colc90=1 or mel90=1 then can90=1;
   can92=0;
   if pros92=1 or lymp92=1 or ocan92=1 or colc92=1 or mel92=1 then can92=1;
   can94=0;
   if pros94=1 or lymp94=1 or ocan94=1 or colc94=1 or mel94=1 then can94=1;
   can96=0;
   if pros96=1 or lymp96=1 or ocan96=1 or colc96=1 or mel96=1 then can96=1;
   can98=0;
   if pros98=1 or lymp98=1 or ocan98=1 or colc98=1 or mel98=1 then can98=1;
   can00=0;
   if pros00=1 or lymp00=1 or ocan00=1 or colc00=1 or mel00=1 then can00=1;
   can02=0;
   if pros02=1 or lymp02=1 or ocan02=1 or colc02=1 or mel02=1 then can02=1;
   can04=0;
   if pros04=1 or lymp04=1 or ocan04=1 or colc04=1 or mel04=1 then can04=1;
   can06=0;
   if pros06=1 or lymp06=1 or ocan06=1 or colc06=1 or mel06=1 then can06=1;
   can08=0;
   if pros08=1 or lymp08=1 or ocan08=1 or colc08=1 or mel08=1 then can08=1;
   can10=0;
   if pros10=1 or lymp10=1 or ocan10=1 or colc10=1 or mel10=1 then can10=1;
   can12=0;
   if pros12=1 or lymp12=1 or ocan12=1 or colc12=1 or mel12=1 then can12=1;
   can14=0;
   if pros14=1 or lymp14=1 or ocan14=1 or colc14=1 or mel14=1 then can14=1;
   can16=0;
   if pros16=1 or lymp16=1 or ocan16=1 or colc16=1 or mel16=1 then can16=1;
   can18=0;
   if pros18=1 or lymp18=1 or ocan18=1 or colc18=1 or mel18=1 then can18=1;
   can8694=0;
   if can86=1 or can88=1 or can90=1 or can92=1 or can94=1 then can8694=1;

    run;
*First, make intermediate outcomes cumulative varibles: i.e. once cancer, always cancer;

    data base0;
    set base0 end=_end_; 
   array hbp     {17}  hbp86   hbp88   hbp90   hbp92   hbp94   hbp96   hbp98   hbp00    hbp02    hbp04    hbp06     hbp08  hbp10 hbp12 hbp14 hbp16 hbp18; 
   array chol    {17}  chol86  chol88  chol90  chol92  chol94  chol96  chol98  chol00   chol02   chol04   chol06    chol08 chol10 chol12 chol14 chol16 chol18;
   array diabb    {17}  db86    db88    db90    db92    db94    db96    db98    db00     db02     db04     db06     db08  db10 db12 db14 db16 db18;
   array repmii   {17}  mi86    mi88    mi90    mi92    mi94    mi96    mi98    mi00     mi02     mi04     mi06     mi08  mi10 mi12 mi14 mi16 mi18;
   array repstrkk {17}  str86   str88   str90   str92   str94   str96   str98   strk00   strk02   strk04   strk06   strk08 strk10 strk12 strk14 strk16 strk18;
   array cancc    {17}  can86   can88   can90   can92   can94   can96   can98   can00    can02    can04    can06    can08  can10 can12 can14 can16 can18;
   array cab      {17}  cabg86  cabg88  cabg90   cabg92   cabg94   cabg96   cabg98   cabg00   cabg02    cabg04   cabg06 cabg08  cabg10 cabg12 cabg14 cabg16 cabg18;
   array ang      {17}  ang86   ang88   ang90   ang92   ang94   ang96   ang98   ang00    ang02    ang04    ang06    ang08  ang10 ang12 ang14 ang16 ang18;


      do j=2 to dim(hbp);
      if hbp{j-1}=1    then hbp{j}=1;
      if chol{j-1}=1   then chol{j}=1;
      if diabb{j-1}=1   then diabb{j}=1;
      if repmii{j-1}=1   then repmii{j}=1;
      if repstrkk{j-1}=1   then repstrkk{j}=1;
      if cancc {j-1}=1   then cancc {j}=1;
      if cab {j-1}=1   then cab {j}=1;
      if ang {j-1}=1   then ang {j}=1;
     end;

        do i=1 to dim(hbp);
      
        if cancc{i} =. then cancc{i} =0;
        if hbp{i} =. then hbp{i} =0;
        if diabb{i}=. then diabb{i} =0;
       
        if chol{i}=. then chol{i}=0;
        if ang{i} =. then ang{i} =0;
        if repmii{i}  =. then repmii{i}  =0;
        if repstrkk{i} =. then repstrkk{i} =0;
        if cab{i}=. then cab{i}=0;
    end;

     /*updated and stop updated components UPFPDI*/

   array calorn  {8}  calor86n  calor90n  calor94n  calor98n   calor02n   calor06n calor10n calor14n;
   array ahei    {8}  ahei86_a  ahei90_a  ahei94_a  ahei98_a  ahei02_a  ahei06_a  ahei10_a   ahei14_a;
   array   FI      {8}   FI86     FI90    FI94    FI98     FI02    FI06    FI10  FI14;
   array   FIa     {8}   FI86a    FI90a   FI94a   FI98a    FI02a   FI06a   FI10a FI14a ;
   array   FIb     {8}   FI86b    FI90b   FI94b   FI98b    FI02b   FI06b   FI10b FI14b ;
   array   FIc     {8}   FI86c    FI90c   FI94c   FI98c    FI02c   FI06c   FI10c FI14c ;
   array   FId     {8}   FI86d    FI90d   FI94d   FI98d    FI02d   FI06d   FI10d FI14d ;
   array   FIe     {8}   FI86e    FI90e   FI94e   FI98e    FI02e   FI06e   FI10e  FI14e;
   array   FIf     {8}   FI86f    FI90f   FI94f   FI98f    FI02f   FI06f   FI10f  FI14f;
   array   FIg     {8}   FI86g    FI90g   FI94g   FI98g    FI02g   FI06g   FI10g  FI14g;
   array   FIh     {8}   FI86h    FI90h   FI94h   FI98h    FI02h   FI06h   FI10h  FI14h;
   array   FIi     {8}   FI86i    FI90i   FI94i   FI98i    FI02i   FI06i   FI10i  FI14i;
   array   FIj     {8}   FI86j    FI90j   FI94j   FI98j    FI02j   FI06j   FI10j  FI14j;
   array   FIk     {8}   FI86k    FI90k   FI94k   FI98k    FI02k   FI06k   FI10k  FI14k;
   array   FIl     {8}   FI86l    FI90l   FI94l   FI98l    FI02l   FI06l   FI10l  FI14l;

   array diab    {8}  db86 db90 db94 db98 db02 db06 db10 db14;
   array repmi   {8}  mi86 mi90 mi94 mi98 mi02 mi06 mi10 mi14 ;
   array repstrk {8}  str86 str90 str94 str98 strk02 strk06 strk10 strk14;
   array canc    {8}  can86 can90 can94 can98 can02 can06 can10 can14;
   array cabgg   {8}  cabg86 cabg90 cabg94 cabg98 cabg02 cabg06 cabg10 cabg14;
   array angg    {8}  ang86 ang90 ang94 ang98 ang02 ang06 ang10 ang14;

do i=2 to 8;
if  calorn {i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1  then    calorn  {i}=calorn  {i-1};
if  ahei  {i}=.  or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1  then     ahei {i}=ahei  {i-1};
if FI{i}=.  or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1  then FI{i}=FI{i-1};
if FIa{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIa{i}=FIa{i-1};
if FIb{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIb{i}=FIb{i-1};
if FIc{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIc{i}=FIc{i-1};
if FId{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FId{i}=FId{i-1};
if FIe{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIe{i}=FIe{i-1};
if FIf{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIf{i}=FIf{i-1};
if FIg{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIg{i}=FIg{i-1};
if FIh{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIh{i}=FIh{i-1};
if FIi{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIi{i}=FIi{i-1};
if FIj{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIj{i}=FIj{i-1};
if FIk{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIk{i}=FIk{i-1};
if FIl{i}=. or diab{i}=1 or repmi {i}=1  or repstrk{i}=1  or canc{i}=1 or cabgg{i}=1 then FIl{i}=FIl{i-1};

end;          

%macro cumavg (cycle=, cyclevar=, varin=, varout=);
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
 
%mend cumavg;

%cumavg(cycle=8, cyclevar=3, 
  varin=  

calor86n  alco86n  ahei86_a
calor90n  alco90n  ahei90_a
calor94n  alco94n  ahei94_a
calor98n  alco98n  ahei98_a
calor02n  alco02n  ahei02_a
calor06n  alco06n  ahei06_a
calor10n  alco10n  ahei10_a
calor14n  alco14n  ahei14_a, 
  varout= 

calor86nv alco86v  ahei86_av
calor90nv alco90v  ahei90_av
calor94nv alco94v  ahei94_av
calor98nv alco98v  ahei98_av
calor02nv alco02v  ahei02_av
calor06nv alco06v  ahei06_av
calor10nv alco10v  ahei10_av
calor14nv alco14v  ahei14_av);

  drop i j k ;
run;

data base0;
set base0;
%cumavg(cycle=8, cyclevar=13,
  varin= 
FI86 FI86a FI86b FI86c FI86d FI86e FI86f FI86g FI86h FI86i FI86j FI86k FI86l
FI90 FI90a FI90b FI90c FI90d FI90e FI90f FI90g FI90h FI90i FI90j FI90k FI90l  
FI94 FI94a FI94b FI94c FI94d FI94e FI94f FI94g FI94h FI94i FI94j FI94k FI94l  
FI98 FI98a FI98b FI98c FI98d FI98e FI98f FI98g FI98h FI98i FI98j FI98k FI98l  
FI02 FI02a FI02b FI02c FI02d FI02e FI02f FI02g FI02h FI02i FI02j FI02k FI02l  
FI06 FI06a FI06b FI06c FI06d FI06e FI06f FI06g FI06h FI06i FI06j FI06k FI06l  
FI10 FI10a FI10b FI10c FI10d FI10e FI10f FI10g FI10h FI10i FI10j FI10k FI10l
FI14 FI14a FI14b FI14c FI14d FI14e FI14f FI14g FI14h FI14i FI14j FI14k FI14l,
        
  varout=

FI86v FI86av FI86bv FI86cv FI86dv FI86ev FI86fv FI86gv FI86hv FI86iv FI86jv FI86kv FI86lv
FI90v FI90av FI90bv FI90cv FI90dv FI90ev FI90fv FI90gv FI90hv FI90iv FI90jv FI90kv FI90lv
FI94v FI94av FI94bv FI94cv FI94dv FI94ev FI94fv FI94gv FI94hv FI94iv FI94jv FI94kv FI94lv
FI98v FI98av FI98bv FI98cv FI98dv FI98ev FI98fv FI98gv FI98hv FI98iv FI98jv FI98kv FI98lv
FI02v FI02av FI02bv FI02cv FI02dv FI02ev FI02fv FI02gv FI02hv FI02iv FI02jv FI02kv FI02lv
FI06v FI06av FI06bv FI06cv FI06dv FI06ev FI06fv FI06gv FI06hv FI06iv FI06jv FI06kv FI06lv
FI10v FI10av FI10bv FI10cv FI10dv FI10ev FI10fv FI10gv FI10hv FI10iv FI10jv FI10kv FI10lv
FI14v FI14av FI14bv FI14cv FI14dv FI14ev FI14fv FI14gv FI14hv FI14iv FI14jv FI14kv FI14lv);

run;





 proc rank data=base0 out=quintile group=5;
var 
FI86v FI86av FI86bv FI86cv FI86dv FI86ev FI86fv FI86gv FI86hv FI86iv FI86jv FI86kv FI86lv
FI90v FI90av FI90bv FI90cv FI90dv FI90ev FI90fv FI90gv FI90hv FI90iv FI90jv FI90kv FI90lv
FI94v FI94av FI94bv FI94cv FI94dv FI94ev FI94fv FI94gv FI94hv FI94iv FI94jv FI94kv FI94lv
FI98v FI98av FI98bv FI98cv FI98dv FI98ev FI98fv FI98gv FI98hv FI98iv FI98jv FI98kv FI98lv
FI02v FI02av FI02bv FI02cv FI02dv FI02ev FI02fv FI02gv FI02hv FI02iv FI02jv FI02kv FI02lv
FI06v FI06av FI06bv FI06cv FI06dv FI06ev FI06fv FI06gv FI06hv FI06iv FI06jv FI06kv FI06lv
FI10v FI10av FI10bv FI10cv FI10dv FI10ev FI10fv FI10gv FI10hv FI10iv FI10jv FI10kv FI10lv
FI14v FI14av FI14bv FI14cv FI14dv FI14ev FI14fv FI14gv FI14hv FI14iv FI14jv FI14kv FI14lv

;

ranks       
FI86q FI86aq FI86bq FI86cq FI86dq FI86eq FI86fq FI86gq FI86hq FI86iq FI86jq FI86kq FI86lq
FI90q FI90aq FI90bq FI90cq FI90dq FI90eq FI90fq FI90gq FI90hq FI90iq FI90jq FI90kq FI90lq
FI94q FI94aq FI94bq FI94cq FI94dq FI94eq FI94fq FI94gq FI94hq FI94iq FI94jq FI94kq FI94lq
FI98q FI98aq FI98bq FI98cq FI98dq FI98eq FI98fq FI98gq FI98hq FI98iq FI98jq FI98kq FI98lq
FI02q FI02aq FI02bq FI02cq FI02dq FI02eq FI02fq FI02gq FI02hq FI02iq FI02jq FI02kq FI02lq
FI06q FI06aq FI06bq FI06cq FI06dq FI06eq FI06fq FI06gq FI06hq FI06iq FI06jq FI06kq FI06lq
FI10q FI10aq FI10bq FI10cq FI10dq FI10eq FI10fq FI10gq FI10hq FI10iq FI10jq FI10kq FI10lq
FI14q FI14aq FI14bq FI14cq FI14dq FI14eq FI14fq FI14gq FI14hq FI14iq FI14jq FI14kq FI14lq


;
run;


proc datasets nolist;
   delete hp_der hp_der_2 hp86 hp88 hp90 hp92 hp94 hp96 hp98 hp00 hp02 hp04 hp06 hp08 hp10 hp12 hp14 hp16 hp18 dead  gout
          h02_nts h06_nts h10_nts h14_nts h90_cat h94_cat h98_cat h02_cat h06_cat h10_cat h14_cat 
          h86_dt h90_dt h94_dt h98_dt  hmet8616 ahei
          ;
   run;

data one;  
 set quintile end=_end_;


array irt     {14} rtmnyr86 rtmnyr88 rtmnyr90 rtmnyr92 rtmnyr94 rtmnyr96 rtmnyr98 rtmnyr00 rtmnyr02 rtmnyr04 rtmnyr06 rtmnyr08 rtmnyr10 /* rtmnyr12 rtmnyr14  */cutoff ;
array period  {13} period1 period2 period3 period4 period5 period6 period7 period8 period9 period10 period11 period12 period13 /* period14 period15 */;
array tvar    {13} t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 /* t12 t14 */ ;
array age     {13} age86 age88 age90 age92 age94 age96 age98 age00 age02 age04 age06 age08 age10 /* age12 age14  */ ;

array mvyn   {13} mvt86 mvt88 mvt90 mvt92 mvt94 mvt96 mvt98 mvt00 mvt02 mvt04 mvt06 mvt08 mvt10 /* mvt12 mvt14 */  ;
array aspi   {13} asp86 asp88 asp90 asp92 asp94 asp96 asp00 asp02 asp04 asp06 asp08 asp10 /* asp10 asp12 */ asp12  ;

array ckdx   {13} renf86    renf88     renf90     renf92     renf94     renf96     renf98     renf00     renf02     renf04     renf06     renf08     renf10 ;

array diur   {13} diur86    diur88     diur90     thiaz92    thiaz94    thiaz96    thiaz98    thiaz00    thiaz02    thiaz04    thiaz06    thiaz08    thiaz10    ;
array lasi   {13} lasix86   lasix88    lasix90    lasix92    lasix94    lasix96    lasix98    lasix00    lasix02    lasix04    lasix06    lasix08    lasix10    ;

array calornv {13} calor86nv calor86nv calor90nv calor90nv calor94nv calor94nv calor98nv calor98nv calor02nv calor02nv calor06nv calor06nv calor10nv /* calor10nv calor14nv  */ ;
array aheinv  {13} ahei86_av ahei86_av ahei90_av ahei90_av ahei94_av ahei94_av ahei98_av ahei98_av ahei02_av ahei02_av ahei06_av ahei06_av ahei10_av ;


array calorq {13} calor86q calor86q calor90q calor90q calor94q calor94q calor98q calor98q calor02q calor02q calor06q calor06q calor10q ;
array qahei  {13} ahei86q  ahei86q  ahei90q  ahei90q  ahei94q  ahei94q  ahei98q  ahei98q  ahei02q  ahei02q  ahei06q  ahei06q  ahei10q ;
     
array smok {13} smoke86 smoke88 smoke90 smoke92 smoke94 smoke96 smoke98 smoke00 smoke02 smoke04 smoke06 smoke08 smoke10 /* smoke12 smoke14  */;
array cignm{13} cgnm86 cgnm88 cgnm90 cgnm92 cgnm94 cgnm96 cgnm98 cgnm00 cgnm02 cgnm04 cgnm06 cgnm08 cgnm10 /* cgnm12 cgnm14   */ ;
array smkm {13} smkm86 smkm88 smkm90 smkm92 smkm94 smkm96 smkm98 smkm00 smkm02 smkm04 smkm06 smkm08 smkm10 /* smkm12 smkm14 */  ;
array smm  {13} smm86   smm88   smm90   smm92   smm94   smm96   smm98   smm00    smm02    smm04    smm06  smm08 smm10 /* smm12 smm14  */ ;


array weight  {13} wt86    wt88    wt90    wt92    wt94    wt96    wt98    wt00    wt02    wt04    wt06    wt08    wt10    /* wt12     wt14   */      ;
array bmi     {13} bmi86   bmi88   bmi90   bmi92   bmi94   bmi96   bmi98   bmi00   bmi02   bmi04   bmi06   bmi08   bmi10   /* bmi12    bmi14  */     ;
array bmicq   {13} bmic86  bmic88  bmic90  bmic92  bmic94  bmic96  bmic98  bmic00  bmic02  bmic04  bmic06  bmic08  bmic10  /* bmic12   bmic14   */  ; 
array alcon   {13} alco86n alco86n alco90n alco90n alco94n alco94n alco98n alco98n alco02n alco02n alco06n alco06n alco10n /* alco10n  alco14n */  ;
array alcocum {13} alco86v alco86v alco90v alco90v alco94v alco94v alco98v alco98v alco02v alco02v alco06v alco06v alco10v /* alco10v  alco14v */  ;

array alcq    {13} alc86   alc86   alc90   alc90   alc94   alc94   alc98   alc98   alc02   alc02   alc06   alc06   alc10   /* alc10    alc14   */    ;

array actm    {13} act86   act88   act90   act92   act94   act96   act98   act00   act02   act04   act06   act08   act10  /*  act12    act14  */     ;

array    FIm {13}    FI86v  FI86v  FI90v  FI90v  FI94v  FI94v  FI98v  FI98v  FI02v  FI02v  FI06v  FI06v FI10v;
array    FIs {13}    FI86q  FI86q  FI90q  FI90q  FI94q  FI94q  FI98q  FI98q  FI02q  FI02q  FI06q  FI06q FI10q;


array    FIam   {13}       FI86av   FI86av   FI90av   FI90av   FI94av   FI94av   FI98av   FI98av   FI02av   FI02av   FI06av   FI06av  FI10av  ;
array    FIas   {13}       FI86aq   FI86aq   FI90aq   FI90aq   FI94aq   FI94aq   FI98aq   FI98aq   FI02aq   FI02aq   FI06aq   FI06aq  FI10aq  ;

array    FIbm   {13}       FI86bv   FI86bv   FI90bv   FI90bv   FI94bv   FI94bv   FI98bv   FI98bv   FI02bv   FI02bv   FI06bv   FI06bv  FI10bv  ;
array    FIbs   {13}       FI86bq   FI86bq   FI90bq   FI90bq   FI94bq   FI94bq   FI98bq   FI98bq   FI02bq   FI02bq   FI06bq   FI06bq  FI10bq  ;

array    FIcm   {13}       FI86cv   FI86cv   FI90cv   FI90cv   FI94cv   FI94cv   FI98cv   FI98cv   FI02cv   FI02cv   FI06cv   FI06cv  FI10cv  ;
array    FIcs   {13}       FI86cq   FI86cq   FI90cq   FI90cq   FI94cq   FI94cq   FI98cq   FI98cq   FI02cq   FI02cq   FI06cq   FI06cq  FI10cq ;

array    FIdm   {13}       FI86dv   FI86dv   FI90dv   FI90dv   FI94dv   FI94dv   FI98dv   FI98dv   FI02dv   FI02dv   FI06dv   FI06dv  FI10dv  ;
array    FIds   {13}       FI86dq   FI86dq   FI90dq   FI90dq   FI94dq   FI94dq   FI98dq   FI98dq   FI02dq   FI02dq   FI06dq   FI06dq  FI10dq  ;

array    FIem   {13}       FI86ev   FI86ev   FI90ev   FI90ev   FI94ev   FI94ev   FI98ev   FI98ev   FI02ev   FI02ev   FI06ev   FI06ev  FI10ev  ;
array    FIes   {13}       FI86eq   FI86eq   FI90eq   FI90eq   FI94eq   FI94eq   FI98eq   FI98eq   FI02eq   FI02eq   FI06eq   FI06eq  FI10eq  ;

array    FIfm   {13}       FI86fv   FI86fv   FI90fv   FI90fv   FI94fv   FI94fv   FI98fv   FI98fv   FI02fv   FI02fv   FI06fv   FI06fv  FI10fv  ;
array    FIfs   {13}       FI86fq   FI86fq   FI90fq   FI90fq   FI94fq   FI94fq   FI98fq   FI98fq   FI02fq   FI02fq   FI06fq   FI06fq  FI10fq  ;

array    FIgm   {13}       FI86gv   FI86gv   FI90gv   FI90gv   FI94gv   FI94gv   FI98gv   FI98gv   FI02gv   FI02gv   FI06gv   FI06gv    FI10gv  ;
array    FIgs   {13}       FI86gq   FI86gq   FI90gq   FI90gq   FI94gq   FI94gq   FI98gq   FI98gq   FI02gq   FI02gq   FI06gq   FI06gq    FI10gq  ;

array    FIhm   {13}       FI86hv   FI86hv   FI90hv   FI90hv   FI94hv   FI94hv   FI98hv   FI98hv   FI02hv   FI02hv   FI06hv   FI06hv    FI10hv  ;
array    FIhs   {13}       FI86hq   FI86hq   FI90hq   FI90hq   FI94hq   FI94hq   FI98hq   FI98hq   FI02hq   FI02hq   FI06hq   FI06hq    FI10hq  ;

array    FIim   {13}       FI86iv   FI86iv   FI90iv   FI90iv   FI94iv   FI94iv   FI98iv   FI98iv   FI02iv   FI02iv   FI06iv   FI06iv   FI10iv  ;
array    FIis   {13}       FI86iq   FI86iq   FI90iq   FI90iq   FI94iq   FI94iq   FI98iq   FI98iq   FI02iq   FI02iq   FI06iq   FI06iq   FI10iq  ;

array    FIjm   {13}       FI86jv   FI86jv   FI90jv   FI90jv   FI94jv   FI94jv   FI98jv   FI98jv   FI02jv   FI02jv   FI06jv   FI06jv   FI10jv ;
array    FIjs   {13}       FI86jq   FI86jq   FI90jq   FI90jq   FI94jq   FI94jq   FI98jq   FI98jq   FI02jq   FI02jq   FI06jq   FI06jq   FI10jq  ;

array    FIkm   {13}       FI86kv   FI86kv   FI90kv   FI90kv   FI94kv   FI94kv   FI98kv   FI98kv   FI02kv   FI02kv   FI06kv   FI06kv    FI10kv  ;
array    FIks   {13}       FI86kq   FI86kq   FI90kq   FI90kq   FI94kq   FI94kq   FI98kq   FI98kq   FI02kq   FI02kq   FI06kq   FI06kq    FI10kq  ;

array    FIlm   {13}       FI86lv   FI86lv   FI90lv   FI90lv   FI94lv   FI94lv   FI98lv   FI98lv   FI02lv   FI02lv   FI06lv   FI06lv   FI10lv  ;
array    FIls   {13}       FI86lq   FI86lq   FI90lq   FI90lq   FI94lq   FI94lq   FI98lq   FI98lq   FI02lq   FI02lq   FI06lq   FI06lq   FI10lq ;



   do m=1 to 13;
     if weight{m}=0 then weight{m}=.;      
      bmi{m}=.;   
     if height>0 and weight{m}>0 then bmi{m}=(weight{m}*0.45359237)/   
        ((height*25.4/1000)*(height*25.4/1000)); 
     end;


  do i=1 to 13;
  if ckdx{i}=.     then ckdx{i}=0;
  if diur{i}=.     then diur{i}=0;
  if lasi{i}=.     then lasi{i}=0;
    end;


   do j=2 to 13;
      if bmi{j}=.      then bmi{j}=bmi{j-1};
      if smok{j}=.     then smok{j}=smok{j-1};
      if cignm{j}=.    then cignm{j}=cignm{j-1};
      if smm{j}=.      then smm{j}=smm{j-1};
      if alcon{j}=.    then alcon{j}=alcon{j-1};
      if mvyn{j}=.     then mvyn{j}=mvyn{j-1};
      if aspi{j}=.     then aspi{j}=aspi{j-1};
      if actm{j}=.     then actm{j}=actm{j-1};

  
    end;
    
           /****** Indicator for Smoking ******/ 
      /***smoke  $label 1.Never;  2.Past; 3.No, unknown past history;   4.Current; 5.PASSTHRU;
          cgnm $label 1.1-4/d; 2.5-14; 3.15-24; 4.25-34; 5.35-44;6.45 or more; 7.PASSTHRU; 0.not app or no qx***/ 
      
do i=1 to 13;
      if smok{i}=5 then smok{i}=.;      
      if smok{i}<4 then cignm{i}=0;      
     
      if cignm{i}=7 then cignm{i}=.;      
      if cignm{i}=0 then cignm{i}=.;      
    
      if smok{i}=1 then smkm(i)=1;                    /**   smkm=1, never*/
      if smok{i}=2 then smkm(i)=2;                    /**   smkm=2, past*/
      if smok{i}=3 then smkm(i)=2;      
      if smok{i}=. then smkm(i)=1;      
      if smok{i}=4 then 
         do;  
         if      1<=cignm{i}<=2 then smkm(i)=3;           /**     smkm=3, 1-14*/
         else if cignm{i}=3 then smkm(i)=4;          /*      smkm=4,15-24*/
         else if 4<=cignm{i}<=6 then smkm(i)=5;     /** smkm=5: >=25/d */
         else if cignm{i}=. then smkm(i)=6;         /** smkm=6: currnt smker, amount unknown */
         end;  

      select(smkm{i});
  when (1)     smm{i}=1;
  when (2)     smm{i}=2;
  when (3,6)   smm{i}=3;
  when (4)     smm{i}=4; 
  when (5)     smm{i}=5; 
  otherwise    smm{i}=.;
  end;
      end;
   drop m j;

cutoff=1345; /* January 2012 is the last month yr for the study. 112*12+1=1345 */

     do i=1 to DIM(irt)-1;
        if irt{i}>0 then ltf=irt{i};
    end;
    if ltf=irt{dim(irt)-1} then ltf=.;



   do i=1 to DIM(irt)-1;
      if (irt{i}<(1009+24*i) | irt{i}>=(1033+24*i)) then irt{i}=1009+24*i;
      age{i}=int((irt{i}-dbmy86)/12);
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
  alldead=0;
  talld=irt{i+1}-irt{i}; 
    if (irt{i}<dtdth<=irt{i+1}) then do;
    alldead=1; 
    talld=dtdth-irt{i};
    end; 
    
    /* death from cancer */
dead_can=0;
if alldead=1 and 140<=newicda<=208 then dead_can=1;

/* death from CVD */
dead_cvd=0;
if alldead=1 and (390<=newicda<=459) then dead_cvd=1;
  


***** DEFINE THE GOUT CASE IN THE ith TIME PERIOD *****;

case=0;
tgt=irt{i+1}-irt{i};
if (irt{i}<goutdtdx<=irt{i+1}) and gtcase=1 then do;
  case=1;
  tgt=goutdtdx-irt{i};
end;
if irt{i} le dtdth lt irt{i+1} then tgt=min(tgt, dtdth-irt{i});
                                                
   /******AGE GROUP******/
      agecon=age{i};
      agemo=agecon*12;
       if 0<age{i}<40    then agegp=1;
        else if 40<=age{i}<45 then agegp=2;
        else if 45<=age{i}<50 then agegp=3;
        else if 50<=age{i}<55 then agegp=4;
        else if 55<=age{i}<60 then agegp=5;
        else if 60<=age{i}<65 then agegp=6;
        else if 65<=age{i}<70 then agegp=7;
        else if 70<=age{i}<75 then agegp=8;
        else if 75<=age{i}<80 then agegp=9;
        else if age{i}>=80    then agegp=10;
        else agegp=.;
  %indic3(vbl=agegp, prefix=agegp, min=2, max=10, reflev=1, usemiss=0);
    
    /***ethnicity data****/
    if race=1 then white=1;
    else white=0;

        %indic3(vbl=race,prefix=race,min=2,max=4,reflev=1,usemiss=0,
                label1='white',
                label2='other',
                label3='asian',
                label4='african american');
     

       /****** Indicator for BMI ******/
      bmicon=bmi{i};if bmi{i}=0 then bmicon=.;

      if 0<bmi{i}<21 then bmicq{i}=1;
         else if bmi{i}>=21 and bmi{i}<25 then bmicq{i}=2;
         else if bmi{i}>=25 and bmi{i}<30 then bmicq{i}=3;
         else if bmi{i}>=30 and bmi{i}<32 then bmicq{i}=4;
         else if bmi{i}>=32 then bmicq{i}=5;
         else bmicq{i}=3;
 
       bmic=bmicq{i};      
      %indic3(vbl=bmic, prefix=bmic, min=2, max=5, reflev=1, missing=., usemiss=0,
                label1='bmi<21', 
                label2='bmi 21-24.9',
                label3='bmi 25-29.9', 
                label4='bmi 30.0-31.9', 
                label5='bmi 32.0+');

  bmibase=bmi{1};
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

      /****** Indicator Physical Activity ******/
       actcon=actm{i}; /***continue, hours/wk***/
      
      if 0<=actcon<3 then actcc=1;
      else if actcon>=3 and actcon<9 then actcc=2;
      else if actcon>=9 and actcon<18 then actcc=3;
      else if actcon>=18 and actcon<27 then actcc=4;
      else if actcon>=27 then actcc=5;
      else  actcc=3;
      
%indic3(vbl=actcc, prefix=actc, min=2, max=5, reflev=1, missing=., usemiss=0,
        label1='<3 total mets/wk',
        label2='3 to < 9 mets/wk',
        label3='9 to < 18 mets/wk',
        label4='18 to < 27 mets/wk',
        label5='27+ mets/wk');  

       /*** new index ***/
    
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



     /****** Indicator for Smoking ******/ 
      smkever=smm{i};    
     %indic3(vbl=smkever, prefix=smkc,min=2,max=5, reflev=1, missing=., usemiss=1,
              label1='never smker',
              label2='past smker',
              label3='curr 1-14 smker',
              label4='curr 15+ smker',
              label5='curr 25+ smker');

   
      /****** Indicator Alcohol consumption ******/
       alcocon=alcocum{i}; /***continuous variable, g/day***/ 

               if  alcocum{i}=0  then alco_cumc=1;
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

     /*** qtei ***/
             calorm=calornv{i};
             teiq=calorq{i};
             if teiq=. then teiq=2;
             %indic3(vbl=teiq, prefix=qtei, reflev=0, missing=., usemiss=0, min=1, max=4); 

     /*** ahei ***/
             aheim=aheinv{i};
             aheiq=qahei{i};
         
             %indic3(vbl=aheiq, prefix=qahei, reflev=0, missing=., usemiss=0, min=1, max=4); 

      /*** multiple vitamin ***/
 
                select(mvyn{i});
                when (1) mvit=1;
                otherwise  mvit=0;
            end;     
      
      /*** aspirin ***/

                select(aspi{i});
                when (1)     aspirin=1;
                 otherwise    aspirin=0;
            end;

      /*For subgroup analysis*/
     if agecon>60 then agesub=1; else agesub=0;   
     if 
     smkever=1 then smknever=1; else smknever=0; 
  
if actcon>7.5 then active=1; else active=0;


     ckdcase = ckdx{i};

     if diur{i}=1 or lasi{i}=1 then diuret=1;
     else diuret=0;

     /****************  BASELINE EXCLUSIONS ********************************************/
      if i=1 then do;

   %exclude(exrec eq 1);                       *multiple records and not in master file;
   %exclude(birthday eq .);   
   %exclude(dbmy09 <= 0); 

   %exclude(0 lt dtdth le irt{i});             *Death before 1986;   
   %exclude(age86 eq .);   
   %exclude(ltf eq irt{1});                    *just responded to baseline questionnaire;
    
 %exclude(0 lt  goutdtdx le irt{i});        *** prevalent gout ***;
 %exclude(goutdtdx eq 9999);         *** missing gout diagnosis date ***;
 %exclude(gout86 eq 1);              *** baseline gout ***;
 %exclude(gtcase eq 0);              *** rejected gout cases from supplemental questionnaires ***;


   %exclude(FI86  eq .);
   %exclude(FI86a  eq .);
   %exclude(FI86b  eq .);
   %exclude(FI86c  eq .);
   %exclude(FI86d  eq .);
   %exclude(FI86e  eq .);
   %exclude(FI86f  eq .);
   %exclude(FI86g  eq .);
   %exclude(FI86h  eq .);
   %exclude(FI86i  eq .);
   %exclude(FI86j  eq .);
   %exclude(FI86k  eq .);
   %exclude(FI86l  eq .);




   %exclude(calor86n lt 800);
   %exclude(calor86n gt 4200);
   %exclude(calor86n eq .);
 
   %output();
  end;

  else if i> 1 then do;
  %exclude(irt{i-1} le dtdth    lt irt{i});                        
  %exclude(irt{i-1} lt goutdtdx le irt{i});  
  %exclude(0        lt ltf      le irt{i}); /*Censor lost to follow up*/   

   %output();
  end;

 end;

          /* END OF DO-LOOP OVER TIME PERIODs */
      
      %endex();
      
proc means;
run;

data hpfs;
  set one end=_end_;
    keep id  agemo  interval 
  rtmnyr86 rtmnyr88  rtmnyr90 rtmnyr92 rtmnyr94 rtmnyr96 rtmnyr98 rtmnyr00 rtmnyr02 rtmnyr04 rtmnyr06 rtmnyr08 rtmnyr10 /* rtmnyr12 rtmnyr14   */
  t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 /* t12 t14   */
 age86 famhxdb famhxmi  famhxca  bmi86 act86 calor86n  hbpbase cholbase
 cutoff  dtdth  goutdtdx tgt case 
 agecon  asp86  mvt86   bmib25 bmib30 active agesub smknever bmicon white aheiq &qahei_ aheim
 ckdcase  diuret prs_urate
 alldead dead_can dead_cvd talld
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
  alco86n  neverdrinker calorm
  agegp &agegp_ race   &race_  actcc &actc_ alco_cumc &alco_cumc_ smkever &smkc_  mvit aspirin teiq  &qtei_    &bmic_  bmib  &bmib_  ;
proc means;
run;
  
proc sort data=hpfs;
  by id;
  run;

