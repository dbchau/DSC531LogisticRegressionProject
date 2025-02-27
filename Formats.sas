libname IPEDS '~/IPEDS';


proc means data=regmodel median;
    var rate;
run;

proc means data=regmodel median;
    var rate;
    where cohort >= 200;
run;

proc means data=regmodel median;
    var rate;
    where cohort >= 400;
run;

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
    low -< 0.625 = 'Under Median'
    other = 'Over Median'
    ;
run;