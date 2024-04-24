
/* # 2. SAS SQL */

/* ## 2.1 Select unique values from table. */

proc sql;
    select distinct col-name from table
;quit;

/* ## 2.2 Calc with functions. */

proc sql;
select max(PopEstimate1) as MaxEst format=comma16.,
       min(PopEstimate1) as MinEst format=comma16.,
       avg(PopEstimate1) as AvgEst format=comma16.
    from sq.statepopulation;
quit;

/* ## 2.3 Count funciton specify the rows inside table: */
proc sql;
select count(*) as TotalCustomers format=comma12.
    from sq.customer;
quit;

/* ## 2.4 having limited the group expression: */
SELECT col-name, summary function(column)
        FROM input-table
        WHERE expression
        GROUP BY col-name <,col-name>
        HAVING expression
        ORDER BY col-name DESC;

proc sql;
select State, count(*) as TotalCustomers format=comma7.
    from sq.customer
    where BankID is not null
    group by State
    having TotalCustomers > 6000
    order by TotalCustomers desc;
quit;


/* ## 2.5 directly using the boolean value to the query: */
proc sql;
create table CustomerCount as
select State, 
       sum(yrdif(DOB,'01JAN2020'd,'age')<25) as Under25,
       sum(yrdif(DOB,'01JAN2020'd,'age')>64) as Over64
    from sq.customer
    group by State;
quit;

/* ## 2.6 Create table: */
proc sql;
create table work.highcredit as
select FirstName, LastName,  
       UserID, CreditScore
    from sq.customer
    where CreditScore > 700;
quit;

proc sql;
create table work.highcredit       
    like sq.customer(keep=FirstName LastName 
                          UserID CreditScore);
quit;

proc sql;
create table work.employee
    (FirstName char(20),
     LastName char(20),
     DOB date format=mmddyy10.,
     EmpID num format=z6.);
quit;

/* ## 2.7 insert values */
proc sql;
insert into work.highcredit
    (FirstName, LastName, UserID, CreditScore)
    select FirstName, LastName,  
           UserID, CreditScore
        from sq.customer
        where CreditScore > 700;
quit;

proc sql;
insert into employee
    (FirstName, LastName, DOB, EmpID)
    values("Diego", "Lopez", "01SEP1980"d, 1280)
    values("Omar", "Fayed", "21MAR1989"d, 1310);
quit;

proc sql;
insert into employee
    set FirstName = "Diego", 
    LastName = "Lopez", 
    DOB = "01SEP1980"d,
    EmpID = 1280;
quit;

/* ## 2.8 delete table */
proc sql;
drop table work.employee;
quit;

/* ## 2.9 dictionary tables */
proc sql inobs=100;
describe table dictionary.tables;
select *
    from dictionary.tables;
quit;

proc sql;
select *
    from dictionary.tables
    where Libname = 'SQ';
quit;

proc print data=sashelp.vtable;
    where Libname = "SQ";
run;


proc sql;
describe table dictionary.columns;
select *
    from dictionary.columns
    where Libname = "SQ";
quit;


proc print data=sashelp.vcolumn(obs=100);
    where Libname = "SQ";
run;

proc sql;
describe table dictionary.libnames;
select *
    from dictionary.libnames;
quit;

proc sql;
describe table dictionary.libnames;
select distinct libname
   from dictionary.libnames;
quit;

proc print data=sashelp.vlibnam;
    where Libname = "SQ";
run;

/* ## 2.10 contains */
proc sql;
select distinct MemName, Name 
    from dictionary.columns 
    where Libname = 'SQ' and Name contains 'ID';
quit;

/* ## 2.11 Joins */

Type of Joins: inner joins and outter join. *full outter join, left outter join and right outter joins

Primary key and foreign key

/* ### 2.11.1 inner join: */
proc sql;
select FirstName, LastName, State, Income, DateTime, Amount
    from sq.smallcustomer inner join sq.smalltransaction
    on smallcustomer.AccountID = smalltransaction.AccountID;
quit;

proc sql;
select FirstName, LastName, State, Income, DateTime, c.AccountID
    from sq.smallcustomer as c inner join 
         sq.smalltransaction as t
    on c.AccountID = t.AccountID;
quit;

proc sql;
select FirstName, LastName, State, Income, DateTime, Amount
    from sq.smallcustomer, sq.smalltransaction
    where smallcustomer.AccountID = smalltransaction.AccountID;
quit;

/* ### 2.11.2 self inner join: */
proc sql;
select e.EmployeeID, e.EmployeeName, 
       e.StartDate format=date9., 
       e.ManagerID, 
       m.EmployeeName as ManagerName
    from sq.employee as e inner join 
         sq.employee as m 
    on e.ManagerID = m.EmployeeID;
quit;

/* ### 2.11.3 nature join: */
proc sql feedback;
select *
    from sq.smallcustomer as c natural join 
         sq.smalltransaction as t;
quit;

remove the missing values for join since the missing values are matched each other for the join;
proc sql;
   select *
   from sq.smallcustomer2 as c inner join 
        sq.smalltransaction2 as t
   on c.AccountID = t.AccountID and 
      c.AccountID is not null;
quit;

/* ### 2.11.4 not equal joins: */
proc sql;
select FirstName, LastName, Income, 
       TaxBracket
    from sq.smallcustomer as c inner join 
         sq.taxbracket as t
    on c.Income >= t.LowIncome and
       c.Income <= t.HighIncome;
quit;

/* ### 2.11.5 join multiple tables */
proc sql;
select FirstName, LastName, c.State, Income, DateTime, 
       MerchantName, Amount, c.AccountID, b.Name
    from sq.smallcustomer as c inner join 
         sq.smalltransaction as t
    on c.AccountID = t.AccountID inner join 
       sq.merchant as m
    on t.MerchantID = m.MerchantID inner join 
       sq.bank as b
    on c.BankID = b.BankID;
quit;

proc sql;
	create table work.births3 as 
	select b.RegionName, c.DivisionName, d.Statename, a.Births3
	from sq.statepopulation as a 
	inner join sq.regioncode as b 	on a.region = b.regioncode 
	inner join sq.divisioncode as c	on a.division = c.DivisionCode
	inner join sq.statecode as d	on a.name = d.statecode;
quit;

/* ### 2.11.6 full join: */
proc sql;
select *
    from sq.smallcustomer as c full join  
         sq.smalltransaction as t
    on c.AccountID = t.AccountID;
quit;

select coalesce(c.AccountID, t.AccountID) as AccountID ---> return the first non missing element;

/* ## 2.12 any */
select Name, PopEstimate1
    from sq.statepopulation
    where PopEstimate1 > any(select PopEstimate1
                                 from sq.statepopulation
                                 where Name in ("NY","FL"));

select Name, PopEstimate1
    from sq.statepopulation
    where PopEstimate1 > (select min(PopEstimate1)
                                 from sq.statepopulation
                                 where Name in ("NY","FL"));

/* ## 2.13 correlated queries - Not recommanded */
proc sql;
select count(*) as TotalCustomer
    from sq.customer as c
    where '1' = (select Division
	              from sq.statepopulation as a
	              where a.Name = c.State);
quit;


/* ## 2.14 Using Temporary Tables */

an In-Line View
proc sql;
create table totalcustomer as
select State,count(*) as TotalCustomer
    from sq.customer
    group by State
    order by TotalCustomer desc;
quit;

proc sql;
select c.State, 
       c.TotalCustomer, 
       s.EstimateBase, 
       c.TotalCustomer/s.EstimateBase as PctCustomer format=percent7.3
    from totalcustomer as c inner join 
         sq.statepopulation as s
    on c.State = s.Name
    order by PctCustomer;
quit;

proc sql;
select c.State, 
       c.TotalCustomer, 
       s.EstimateBase, 
       c.TotalCustomer/s.EstimateBase as PctCustomer format=percent7.3
    from (select State,count(*) as TotalCustomer
             from sq.customer
             group by State) as c inner join 
         sq.statepopulation as s
      on c.State = s.Name
    order by PctCustomer;
quit;


/* ## 2.15 create a view */
proc sql;
create view sq.totalcustomer as
select State,count(*) as TotalCustomer
    from sq.customer
    group by State;
quit;

/* ## 2.16 subquery in the select function */
proc sql;
select Name, PopEstimate1 / sum(PopEstimate1) 
             as PctPop format=percent7.2
    from sq.statepopulation
    order by PctPop desc;
quit;

/* ## 2.17 no remerge */
proc sql noremerge;
select Region, 
       sum(PopEstimate1) as TotalRegion format=comma14.
    from sq.statepopulation;
quit;

/* ## 2.18 SET Operators */

intersect, union, except, outerunion

intersect:
proc sql;
select CustomerID
    from sq.salesemail
intersect
select CustomerID
    from sq.salesphone;
quit;

intersect corr
 
The CORR keyword matches columns by name, and nonmatching columns are removed from the intermediate result sets.

union

proc sql;
select count(*)/(select count(*)
                   from sq.saleslist) as PctResp format=percent5.
                                         label='Offer Acceptance Rate'
    from(select CustomerID
             from sq.salesemail
	         where EmailResp = 'Accepted'
	         union
         select CustomerID
             from sq.salesphone
	         where PhoneResp = 'Accepted');
quit;


proc sql;
create table response1 as
select CustomerID, EmailResp as Resp
    from sq.salesemail
outer union corr
select CustomerID, SalesRep, 
       PhoneResp as Resp
    from sq.salesphone;
quit;

=

data response2;
    length Resp $12;
    set sq.salesemail(rename=(EmailResp=Resp)) 
        sq.salesphone(rename=(PhoneResp=Resp));
run;

# 3. Macro Variable in sql

/* ## 3.1 use the into statement: */

proc sql;
select avg(PopEstimate1)
    into :AvgEst1
    from sq.statepopulation;
quit;
%put &=AvgEst1;

/* ## 3.2 use the put statement: */

%put AvgEst is &AvgEst1;

%put &=AvgEst1;

options symbolgen;
title "Average Estimated Population for Next Year:&AvgEst1";
proc sql;
select Name, PopEstimate1
    from sq.statepopulation
    where PopEstimate1 > &AvgEst;
quit;
title;
options nosymbolgen;

/* ## multiple data-driven macro variables: */

proc sql noprint;
select avg(PopEstimate1), min(PopEstimate1), 
       max(PopEstimate1), count(PopEstimate1)
    into :AvgEst1 trimmed, :MinEst1 trimmed, 
         :MaxEst1 trimmed, :TotalCount trimmed
    from sq.statepopulation;
quit;
%put &=AvgEst1; 
%put &=TotalCount;
%put Min Value is &MinEst1;
%put Max: &MaxEst1;

/* ## Concatenating Values into one macro variable include eg list */

%let Division=9;
proc sql noprint;
select quote(strip(Name))
    into :StateList SEPARATED BY ","
    from sq.statepopulation
    where Division = "&Division";
quit;
%put &=Division;
%put &=StateList;

options symbolgen;
proc sql;
create table division&Division as 
select *
    from sq.customer
    where State in (&StateList);
quit;
options nosymbolgen;

quote(strip()) -> necessary for the quotes in the later sql step.

FORMAT=$QUOTEw.

proc sql noprint;
select Name format=$quote4.
    into :StateList SEPARATED BY ","
    from sq.statepopulation
    where Division = '3';
quit;

%put &=StateList;

Strings larger than 6 characters will be truncated when using the QUOTE format. To ensure values are not truncated, you should specify a width as long as the longest value +2.

/* ## splite dataset: */

/* define which libname.member table, and by which column */
%let TABLE=sashelp.cars;
%let COLUMN=origin;
 
proc sql noprint;
/* build a mini program for each value */
/* create a table with valid chars from data value */
select distinct 
   cat("DATA out_",compress(&COLUMN.,,'kad'),
   "; set &TABLE.(where=(&COLUMN.='", &COLUMN.,
   "')); run;") length=500 into :allsteps separated by ';' 
  from &TABLE.;
quit;
 
/* macro that includes the program we just generated */
%macro runSteps;
 &allsteps.;
%mend;
 
/* and...run the macro when ready */
%runSteps;

/* ## connection to other databases: */

Oracle:

proc sql;
connect to oracle(user=sas_user pw=sastest 
                  path=localhost);
select UserID, Income format=dollar16., State 
    from connection to oracle
       (select UserID, Income, State
            from customer
            where Income is not null
            order by Income desc
            fetch first 10 rows only);
disconnect from oracle;
quit;


MS access:

proc sql;
connect to pcfiles(path="&path/database/SQL_DB.accdb"  
                   dbpassword=sastest);
select UserID, Income format=dollar16., State 
    from connection to pcfiles
      (select top 10, UserID, Income, State
           from customer
           order by Income desc);
disconnect from pcfiles;
quit;

Use libname to connect first, then use sas sql codes to modify the statements.

libname db pcfiles path="&path/database/SQL_DB.accdb" 
                   dbpassword=sastest;

proc sql outobs=10;
select UserID, Income format=dollar16., State
    from db.customer
    order by Income desc;
quit;

libname db clear;


# SAS Proc Fedsql

libname mkt oracle user=sas_user password=sastest
                   path=localhost;

proc fedsql iptrace;
select State, 
       count(*) as TotalCustomer
    from mkt.customer
    where CreditScore > 700
    group by State
    order by TotalCustomer desc;
quit;

libname mkt clear;
