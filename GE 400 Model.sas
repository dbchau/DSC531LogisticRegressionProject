libname IPEDS '~/IPEDS';
options fmtsearch=(IPEDS);

proc format;
    value med
    low -< 0.563 = 'Under Median'
    other = 'Over Median'
    ;
    value medtwo
    low -< 0.599 = 'Under Median'
    other = 'Over Median'
    ;
    value medfour
    low -< 0.626 = 'Under Median'
    other = 'Over Median'
    ;
run;

proc logistic data=regmodel;
    format rate medfour.;
    where cohort >= 400;
    class iclevel--c21enprf board;
    model Rate = Cohort -- ScaledHousingCap;
run;

proc logistic data=regmodel;
    format rate medfour.;
    where cohort >= 400;
    class iclevel--c21enprf board;
    model Rate = Cohort -- ScaledHousingCap / selection=stepwise slentry=.15 slstay=.15;
run;

proc logistic data=regmodel;
    format rate medfour.;
    where cohort >= 400;
    class iclevel--c21enprf board;
    model Rate = Cohort iclevel control hloffer locale instcat c21enprf grantrate grantavg pellrate loanrate loanavg
                 indistrictt indistricttdiff indistrictf indistrictfdiff instatet instatef outstatet outstatetdiff outstatef 
                 outstatefdiff housing scaledhousingcap avgsalary / selection=stepwise slentry=.1 slstay=.1;
    ods output OddsRatios=test;
run;

proc print data=test;
    format OddsRatioEst oddsr.5;
run;