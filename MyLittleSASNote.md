
# 1. SAS 9.4 notes
---

## 1.1 Basics

### 1.1.1 Hello world

"Hello World" Salute for SAS is 2 kinds of the Steps in SAS programming:

DATA step

```{.line-numbers}
data myclass;
    set sashelp.class;
    heightcm=height*2.54;
run;
```

PROC step
```{.line-numbers}
proc means data=myclass;
    var age heightcm;
run;
```

### 1.1.2 Global Statements
There is also **Global statements**(TITLE, OPTIONS, and LIBNAME, etc.)

4 types are like:

     OPTIONS...;

Setting system options like `<Options Validname=V7;>` 

    TITLE <Options> "title text";
    TITLE2 just=| "classroom=5";

Setting up to 10 titles.

    FOOTNOTE <Options> "footnote text";

Setting up to 10 footnotes.

    LIBNAME libref <engine> "...";

Sets a shortcut ref to data of a specific type in a location
- libref: **8-character max**, name of the library.
- engine: rules to read data. like xlsx.
- "...": location

such as `<libname mylib xlsx "C:/docu/class.xlsx">`. We can disconnect with `<libname libref clear>`.

### 1.1.3 Comment
2 types of comments
    /* comment*/
    * comment ;

### 1.1.4 Accessing Data

#### 1.1.4.1 structured Data
Structured Data is the data with columns, like xlsx files.
Access it with `libname` or `proc import`.
Eg:
```{.line-numbers}
PROC import datafile="text.xlsx" dbms=xlsx out=mylib.example replace;
    sheet=table1; /* which sheet to import; */
Run;
```
Special one: SAS table(`.sas7bdat`), which has rows/Observations, columnes/variables.
Name: 1-32 char, start with char or _, can't have blanks or special char. like Hash key.
Type: number(sas date), char
Length: Num 8 bytes, char 1-3xxxx.

#### 1.1.4.2 unstructured Data: PROC IMPORT
Unstructured Data has no columns like csv, json files. They must be **import**.
Access it with `proc import` to define the rules.
Eg:
```{.line-numbers}
PROC import datafile="test.csv" 
    dbms=csv 
    out=mylib.example 
    replace;
    guessingrows=100;
Run;
```
`guessingrows=n|max;` by default, it guesse 20 rows.

### 1.1.5 Procedures for exploring and analyzing data
There we have some PROC process for sas data access:
#### 1.1.5.1 PROC CONTENTS
very useful to check the columns
```{.line-numbers}
PROC CONTENTS DATA=data-set-name;
Run;
```
#### 1.1.5.2 PROC PRINT
This is also used for report writing:

```{.line-numbers}
PROC PRINT DATA=data-set-name<label>(OBS=n);
    var col-names /*columnes to list. */
    where conditions /* multiple conditions, like, in, missing, etc. */
    by descending *col-name sorting*
    Format col-name format; /* Formating columns*, like Format date */
    Label col-name="Lable";
Run;
```
This outputs some parts from the dataset by conditions. Like listing the dataset.

Format:
```{.line-numbers}
PROC PRINT DATA=data-set-name<label>(OBS=n);
    var col-name(s) /*columnes to list. */
    Format col-name format; /* Formating columns*, like Format date */
    Format startdate date.9 Height Weight 3.;
    Format name $ v7;
Run;
```
#### 1.1.5.3 PROC MEANS
Show information about means, quantiles etc.
```{.line-numbers}
PROC Means DATA=data-set-name;
    var *col-names*
    where *conditions*
    Class *col-name*
    Ways n
    Output out=output-table <statistic=col-name>
Run;

proc means data=work.storm_final maxdec=0 n mean min;
    var MinPressure;
    where Season >=2010;
    class Season Ocean;
    ways 0 1 2;
    output out=wind_stats mean=AvgWind max=MaxWind;
run;
```

#### 1.1.5.4 PROC UNIVARIATE
```{.line-numbers}
PROC UNIVARIATE DATA=data-set-name;
    var *col-names*
    where *conditions*
Run;
```
This returns a summary for statistical for each variable. We can view distribution, extreme values, etc.

#### 1.1.5.5 PROC FREQ
This also create statistics, etc.
```{.line-numbers}
PROC FREQ DATA=data-set-name;
    TABLES *col-names*<options>
    where *conditions*
Run;

proc freq data=work.storm_final order=freq noprint;
    tables StartDate / out=storm_count;
    format StartDate monname.;
run;
```
This creates frequency table for each variable. Table limits the col. Create a crosstabulation report by adding (*) between 2 variable names on the Table statement.
The `NOPROCTITLE` option can be placed in the `PROC FREQ` statement to remove the procedure title **The FREQ Procedure**.


## 1.2 Data Manipulations

### 1.2.1 PROC SORT and PROC TRANSPOSE
The duplicates are removed in `Proc Sort` step by using `no dupkey` parameter.
There are many PROC to manipulate data like:

```{.line-numbers}
PROC SORT data=input-data out=output-table nodupkey dupout=output-table;
    by descending col-name1 col-name2; /*by _ALL_; */
Run;
```
``PROC SORT`` is required with a **BY statement**.
``NODUPKEY``: keeps only the first row for each unique value.
``DUPOUT``: creates an output table containing duplicates.

```{.line-numbers}
PROC TRANSPOSE data=input-data out=output-table prefix=col-name Name=col-name;
    by descending col-name1 col-name2;
    ID col-name;
    Var col-names;
Run;
```
``Var``: columns to be transposed.
``ID``: create a separate column for each value of the ID variable and can only be one column.
``BY``: transpose data within groups. Unique combinations of by values create one row in the output table.
``prefix``: provide a prefix for each value f the ID column.


### 1.2.2 Preparing Data: Data Step

Basic data step is simply like this:
```{.line-numbers}
DATA output-dataset;
    set input-dataset;
Run;
```
It is processed with 2 steps:
1. Compilation: creates the PDV, establishes data attributes and rules for execution;
2. Execution: SAS reads, manipulates and writes data.

There are also functions(macro/macro variables) behaves differently in those 2 steps. like `%STR(), %NRSTR()` or `%SUPERQ(), %QLEFT()` etc.

There are 2 default variables created in DATA process:
1.  <span style="color:black">`_N_`</span>: counts the numbers of iteration.
2.  `_ERROR_`: should be 0, but if there is, then it is 1.

It also could be output with multiple datasets, like this:

```{.line-numbers}
DATA work.cheap work.expensive;
    set work.shopping;
    if price>100 then output work.expensive;
    else output work.cheap;
Run;
```

### 1.2.2.1 Data Step: Controlling Output
USE Keep=/Drop= statements.
```{.line-numbers}
DATA work.expensive(keep=price item_name);
    set work.shopping(drop=city state);
    keep store_name;
Run;
```
1. both can be used under DATA statement or SET statment.
2. They are flagged in PDV to the later outcomes.
3. if a col is dropped in SET, it will not be able to used later.
   
### 1.2.2.2 Data Step: Processing Data in Groups

Processing should after sorting. so
`by col-names;` sort first.
`First.bycol<expression>;` is 1 for first row within a group and 0 for others.
`Last.bycol<expression>;` is 1 for last row with a group and 0 for others.

Can create column with `column +expression`.

### 1.2.2.3 Data Step: Conditional processing and loops.

Conditions are ofc like `IF`,`ELSE IF`,`ELSE`. 
Execute multiple statements by using a `DO` statement
```{.line-numbers}
DATA sastest.new;
    set input-table;
    if price>100 then do;
        newVar = "expensive";
        output work.expensive;
    end;
Run;
```
then with `DO` loop like:
```{.line-numbers}
DATA sastest.new;
    set input-table;
    DO index-col= start TO stop <By increment>;
        new Var= .....;
        output work.expensive;
    end;
Run;
```
or variations like `DO WHILE|UNTIL expression;` instead of `DO`.
- WHILE: check top.
- UNTIL: check bottom.

### 1.2.2.4 Data Step: **Combining Data.**

Tables: concatenating, matching based on variable.

1. concatencating:
```{.line-numbers}
DATA output-dataset;
    set input-dataset1 input-dataset2 (rename=(currentName=Newname));
Run;
```
SAS reads rows from first table and writes to output table, then second table, so on.
Same name columns are aligned.

2. Merging:
```{.line-numbers}
DATA output-dataset;
    Merge input-dataset1<(in = Var1)> input-dataset2 <(in = var2)>;
    by sort-colname(s);
        if var1 = 1 and var2 = 1; /* this means all matching rows.*/
        ...
        end;
Run;
```
The merge statment has to be sorted from by statement first and where the by values match.
Identify matching and no matching by using the `IN=` option.
- 0 means table did not include the by col value.
- 1 means table did include the by col value.

### 1.2.2.5 Data Step: Functions
There are some functions to manipulate data in SAS:

> `new-var = function(arg1, arg2,...);`  /* general format. */
> `char-var = put(number-var, format);`  /* Convert number to char. */
> `Num-var = input(char-var, informat);`  /* Convert Char to Number. */

There are common Numeric functions like:

`Rand('distribution, parameter1,..)` generate random variables from a distribution.


`round(num-var, <rounding unit>)` round numbers.

`Largest(k, value1, value2, ...)` returns $k^{th}$ largest non missing value.

`sum(var1, var2, ...)` sum up non missing values.

There are common Char functions like:

`Trim(string)` remove trailing blanks.
`strip(string)` remove all leading and trailing blanks.
`scan(string, count, <char-list, <modifier>>)` return the $n^{th}$ word from string.
`Propcase()`, `upcase()`, `lowcase()` change casing.
`substr(string, start-from, lenghth)` extract a substring, -1 in lenght means from right.

There are common date functions like:
SAS dates are in numeric based on Jan.1.1960

`MDY(month, day, year)` creates a sas date.
`today()` returns today as a sas numeric value.
`year(date-var)`, `month(date-var)`, `day(date-var)`, `qtr()` returns the year/month/day/qtr from the date-var input.
`INTCK(interval, start-from, increment)` returns a date/time/datetime value by a given interval.

### 1.2.3 Customizing SAS output: Labels and Formats
Labels and formats are attributes in data step.

Label: up to 256 characters.

Add Label:
```{.line-numbers}
Label col-name1 = "label text1" col-name2 = "label text2";
```
Formats are for both num-var and char-var.Mainly are for display in the reports.

Add Format:
```{.line-numbers}
FORMAT date-var mmddyyyy10. num-var dollar13.2;
```

This can be also created by PROC process like this:
```{.line-numbers}
PROC FORMAT;
    VALUE format-name <$>
    value-or-range1= 'formatted-value'
    value-or-range2= 'formatted-value';
Run;
```
This `<$>` is for char-var, num-var don't need this simbol.


### 1.2.4 Filtering Data
This is mainly with the `where` statement in both `proc` and `data` process.
where can be used only with the exist col, not the ones are calculated.

<span style="color:red">Note: The Char-var must be quoted with "" and they are case sensitive!</span>

`where` can be used with componded conditions like `and` `or` `not` `in` etc.
Date could be filtered also with format like `"ddMONyyyy"d`

```{.line-numbers}
where 
    = or EQ,
    ^=，~= or NE
    > or GT
    >= GE
    < or LT
    <= or LE
/* in */
where col-name in (val1, val2,...);
where col-name not in (val1, val2,...);

/*Special Operators*/
where col-name IS MISSING
where col-name IS NOT MISSING
where col-name IS NULL
where col-name BETWEEN value1 AND value2
where col-name like "%Value%"
where col-name like "Value_"
```
### 1.2.5 Macro Variables

```{.line-numbers}
%LET macrovar = value;

where numvar = &macrovar;
where charvar = "&macrovar";
```

### 1.2.6 Exporting Data
`PROC EXPORT` is used to export data for xlsx, txt, csv etc.
```{.line-numbers}
proc export data=public.CustomerData
	outfile='/Public/test.csv'
	dbms=csv replace;
run;
```
It is used to export unstructured data type.
It is used with the `DBMS=xlsx REPLACE` parameters to define the export.
It is necessary to clear the libname after the export to close the connection with the engine.
```{.line-numbers}
LIBNAME myXl xlsx "C:/document/shopping.xlsx";
Data myXL.shopping;
    set work.shopping;
Run;
LIBNAME myXL Clear
```

### 1.2.7 Exporting Reports: Using ODS

SAS ODS is the Output delivering system, which provides multiple ways to export results.

For excel export:

```{.line-numbers}
ODS EXCEL File="filename.xlsx"
    STYLE=style
    Options(sheetname='label');
    /* SAS code for output*/
    ODS EXCEL OPTIONS(Sheet_NAME='label');
    /* SAS code for second sheet. */
ODS EXCEL CLOSE;
```
For PDF exports:

```{.line-numbers}
ODS PDF File="filename.xlsx"
    STYLE=style
    STARTPAGE = NO PDFTOC = 1;
    ODS PROCLABEL "label";
    /* SAS code for pdf output. */
ODS PDF CLOSE;
```

---
#### drafts: to do
#### SAS Hash Object

Character Literal:
declare hash States(dataset: 'pg3.population_usstates');

Character Column:
declare hash States(dataset: tablename);

Character Expression:
declare hash States(dataset: cats('pg3.population_',location));

#####  Define a Hash Object

The DEFINEKEY method specifies the name of one or more columns that make up the key components. 

The DEFINEDATA method specifies the names of one or more columns that make up the data components. 

The DEFINEDONE method indicates that all key and data components have been defined. This method is responsible for loading the hash object if a table is specified in the DECLARE statement.

CALL MISSING sets the key and data columns in the PDV to missing values.

```
DECLARE object object-name(<argument_tag-1: value-1, … > );
object-name.DEFINEKEY('key-1' < , … 'key-n' >);
object-name.DEFINEDATA('data-1' < , … 'data-n' >);
object-name.DEFINEDONE( );

eg:

data work.StateCityPopulation;
    length StateName $ 20 Capital $ 14 StatePop2017 8;
    if _N_=1 then do;
       declare hash States(dataset: 'pg3.population_usstates');
       States.definekey('StateName');
       States.definedata('Capital','StatePop2017');
       States.definedone();
       call missing(StateName,Capital,StatePop2017);
    end;
run;

```

using 2 hash object:

```
data work.storm_cat345_facts work.nonmatches;
    if _N_=1 then do;
       if 0 then do;
          set pg3.storm_range;
          set pg3.storm_basincodes;
       end;
       declare hash Storm(dataset:'pg3.storm_range');
       Storm.definekey('StartYear','Name','Basin');
       Storm.definedata('Wind1','Wind2','Wind3','Wind4');
       Storm.definedone(); 
       declare hash BasinDesc(dataset:'pg3.storm_basincodes');
       BasinDesc.definekey('Basin');
       BasinDesc.definedata('BasinName');
       BasinDesc.definedone();
    end;
    set pg3.storm_summary_cat345;
    ReturnCode1=Storm.find(key:year(StartDate),key:Name,key:Basin); 
    ReturnCode2=BasinDesc.find(key:Basin);
    if ReturnCode1=0 and ReturnCode2=0 then 
       output work.storm_cat345_facts;
    else output work.nonmatches;
    drop StartYear;
run;
```

TO allow duplicated key values:

declare hash CapitalPopSort(ordered: 'descending', multidata: 'YES');

Add to the end

```
data work.acreage;
    length ParkCode $ 4 ParkName $ 115 Type $ 28;
    if _N_=1 then do;
       declare hash ParkDesc(dataset:'pg3.np_codelookup');
       ParkDesc.definekey('ParkCode');
       ParkDesc.definedata('ParkName','Type');
       ParkDesc.definedone();
       call missing(ParkCode,ParkName,Type);
       /* declare and define a hash object */
	   declare hash Acreage(ordered: 'descending', multidata:'y');
	   Acreage.definekey('GrossAcres');
	   Acreage.definedata('ParkCode', 'ParkName','Type', 'State', 'GrossAcres');
	   Acreage.definedone();
	   call missing(ParkCode,ParkName,Type);
    end;
    set pg3.np_acres2 end=last;
    ParkCode=upcase(ParkCode);
    RC=ParkDesc.find(key:ParkCode); 
    /* change the subsetting IF statement to be IF/THEN statement */
    if RC=0 then Acreage.add();
    /* add an IF/THEN statement */
	if last=1 then Acreage.output(dataset:'work.acreage_sort'); 
    drop RC;
run; 
```

#### PROC fcmp

Use the FCMP proc to create custom functions:
```
proc fcmp outlib=pg3.funcs.temps;
    function CnvTemp(Temp, Unit $, FinalUnit $);
       if upcase(Unit)='F' and upcase(FinalUnit)='C'  
          then NewTemp=round((Temp-32)*5/9,.01);
       else if upcase(Unit)='F' and upcase(FinalUnit)='F' 
          then NewTemp=Temp;
       else if upcase(Unit)='C' and upcase(FinalUnit)='F' 
          then NewTemp=round(Temp*9/5+32,.01);
       else if upcase(Unit)='C' and upcase(FinalUnit)='C' 
          then NewTemp=Temp;
       return(NewTemp);
    endsub;
run;

/*----------*/
proc fcmp outlib=pg3.myfunctions.class;
	function CalcScore(T1, T2, T3, T4, F);
	FScore=round(sum(of T1-T4, 2*F)/6,.01);
    return(FScore);
	endsub;
run;

/* add an OPTIONS statement */
option cmplib=pg3.myfunctions;

data work.scores;
    set pg3.class_tests;
    /* add an assignment statement */
	Finalscore=CalcScore(Test1,Test2,Test3,Test4,Final);
run;
```
