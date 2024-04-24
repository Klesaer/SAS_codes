/*
PROC UNIVARIATE DATA=data-set-name;
    var *col-names*
    where *conditions*
Run;
*/

data testset;
	set sashelp.cars;
run;

proc univariate data=testset;
	var MSRP;
run;

PROC FREQ DATA=testset;
    TABLES MSRP/*col-names<options>*/;
/*    where *conditions**/
Run;

proc freq data=testset order=freq noprint;
    tables MSRP / out=testset_count;
/*    format MSRP monname.;*/
run;

/* 11 - Test the rules */
