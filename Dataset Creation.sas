libname IPEDS '~/IPEDS';
options fmtsearch=(IPEDS);

proc sql;
    create view SalaryTot as
    select unitid, sum(sa09mot) as totalSalary, sum(sa09mct) as TotalFaculty
    from ipeds.salaries
    group by unitid
    ;
    create view RegModelPre as
    select gradrates.unitid, Rate, Cohort, /*From GradRates*/
                iclevel, control, hloffer, locale, instcat, c21enprf, /*From Characteristics*/
                (uagrntn/scfa2) * 100 as GrantRate
                        label='Percent of undergraduate students awarded federal, state, local, institutional or other sources of grant aid',
                (uagrntt/scfa2) / 1000 as GrantAvg  
                        label='Average amount of federal, state, local, institutional or other sources of grant aid awarded to undergraduate students',
                (upgrntn/scfa2) * 100 as PellRate
                        label='Percent of undergraduate students awarded Pell grants',
                (ufloann/scfa2) * 100 as LoanRate
                        label='Percent of undergraduate students awarded federal student loans',        
                (uagrntt/scfa2) / 1000 as LoanAvg  
                        label='Average amount of federal student loans awarded to undergraduate students', scfa2, /*From Aid*/
                tuition1 / 1000 as tuition1, fee1 / 1000 as fee1, tuition2 / 1000 as tuition2, fee2 / 1000 as fee2, tuition3 / 1000 as tuition3,
                 fee3 /1000 as fee3, room, roomcap, board, roomamt, boardamt, /*From TuitionAndCosts*/
                totalSalary/TotalFaculty as AvgSalary label='Average Salary for 9-month faculty',
                scfa2/TotalFaculty as StuFacRatio label='Student to Faculty Ratio' format=6.1
    from ipeds.gradrates, ipeds.characteristics, ipeds.aid, ipeds.tuitionandcosts, SalaryTot
    where gradrates.unitid eq characteristics.unitid eq aid.unitid eq tuitionandcosts.unitid eq SalaryTot.unitid
    ;
quit;

data regmodel;
    set regmodelpre;
    InDistrictTDiff = tuition2-tuition1;
    if tuition1 ne tuition2 then InDistrictT = 1;
        else InDistrictT = 0;
    InDistrictFDiff = fee2-fee1;
    if fee1 ne fee2 then InDistrictF = 1;
        else InDistrictF = 0;

    OutStateTDiff = tuition3-tuition2;
    if tuition3 ne tuition2 then OutStateT = 1;
        else OutStateT = 0;
    OutStateFDiff = fee3-fee2;
    if fee1 ne fee2 then OutStateF = 1;
        else OutStateF = 0;

    if room eq 2 then do;
        Housing=0;
        roomamt=0;
    end;
        else Housing=room;

    if roomcap ge 1 then ScaledHousingCap = scfa2/roomcap;              
        else ScaledHousingCap = 0;

    if board eq 3 then do;
        board = 0;
        boardamt = 0;
    end;
    rename tuition2=InStateT fee2=InStateF;
    drop tuition1 tuition3 fee1 fee3 room roomcap scfa2;
    format board 1.;
run;
