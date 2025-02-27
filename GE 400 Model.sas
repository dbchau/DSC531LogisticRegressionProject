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
    model Rate = Cohort -- ScaledHousingCap / selection=stepwise slentry=.1 slstay=.1;
run;
/* Run again without room and board amount*/
data regmodel2;
set regmodel;
    avgsalary1000 = avgsalary / 1000;
    outstatetdiff1000 = outstatetdiff/1000;
    grantavg1000 = grantavg / 1000;
run;

proc logistic data=regmodel2;
    format rate medfour.;
    where cohort >= 400;
    class iclevel--c21enprf board;
    model Rate = Cohort iclevel control hloffer locale instcat c21enprf grantrate grantavg1000 pellrate loanrate loanavg
                 indistrictt indistricttdiff indistrictf indistrictfdiff instatet instatef outstatet outstatetdiff1000 outstatef 
                 outstatefdiff housing scaledhousingcap avgsalary1000 / selection=stepwise slentry=.1 slstay=.1;
run;