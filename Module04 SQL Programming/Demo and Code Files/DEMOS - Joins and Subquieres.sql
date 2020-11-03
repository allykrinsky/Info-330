--*************************************************************************--
-- Title: Joins, Unions, and Subqueries
-- Author: RRoot
-- Desc: This file demonstrates selecting data using Joins and Subqueries
--       1) Inner Joins
--       2) Outer Joins
--       3) Cross Joins
--       4) Self Joins
--       5) Unions
--       6) Subqueries
--       7) Temp Tables
--       8) Common Table Expression

-- Change Log: When,Who,What
-- 2017-10-02,RRoot,Created File
--**************************************************************************--

'*** Inner Joins ***'
-----------------------------------------------------------------------------------------------------------------------
Use Pubs;

-- Let's looks at some simple sales data.
Select * From Titles;
Select * From Sales;
go

-- Now, let's focus on just the data we want to look at.
Select title_id, title 
 From Titles 
  Order by title_id;
Select title_id, ord_date, qty 
 From Sales 
  Order by title_id;
go

-- We can combine (or join) these five columns of data into one result set!
Select Titles.title_Id, title, ord_date, qty
 From Titles , Sales 
  Where Titles.title_id = sales.title_id;
go

-- In 1992, the American National Standards Institute (ANSI) asked people to change to this syntax.
Select Titles.title_Id, title, ord_date, qty
 From Titles Join Sales 
  On Titles.title_id = sales.title_id;
go

-- Or this verion, which is more formal.
Select Titles.title_Id, title, ord_date, qty
 From Titles Inner Join Sales 
  On Titles.title_id = sales.title_id;
go

-- If you want to combine results from more than two tables you just add on another Join clause.
Select Stores.stor_id, stor_name, Titles.title_Id, title, ord_date, qty
 From Titles 
 Inner Join Sales 
  On Titles.title_id = Sales.title_id
 Inner Join Stores
  On Sales.stor_id = Stores.stor_id;
go

-- Using table aliases may make your code more readable (at least for some people).
Select St.stor_id, stor_name, T.title_Id, title, ord_date, qty
 From Titles as T
 Inner Join Sales as S
  On T.title_id = S.title_id
 Inner Join Stores as St
  On S.stor_id = St.stor_id;
go

-- Using column aliases may make your results more readable (at least for some people).
Select 
  [Store ID] = St.stor_id
 ,[Store Name] = stor_name
 ,[Title ID] = T.title_Id
 ,[Title] = title
 ,[Sales Date] = ord_date
 ,[Sales Quantity] = qty
 From Titles as T
 Inner Join Sales as S
  On T.title_id = S.title_id
 Inner Join Stores as St
  On S.stor_id = St.stor_id;
go

-- Sometimes you want data from two tables that are not directly connected. 
-- This happens most often when there is a many to many relationship between the data. 
-- In this case you just add connect 'Bridge Table' to each of the tables. 
Select 
  [Authors Name] = A.au_fname + ' ' + A.au_lname  
 ,[Title] = title
 From Authors as A
  Inner Join TitleAuthor as TA
   On A.au_id = TA.au_id
  Inner Join Titles as T  
  On T.title_id = TA.title_id
go

-- It can also happen between table that are connected through a long chain of tables.
Select 
  [Store Name] = stor_name
 ,[Author Name] = A.au_fname + ' ' + A.au_lname 
 From Authors as A
  Inner Join TitleAuthor as TA
   On A.au_id = TA.au_id
  Inner Join Titles as T  
   On T.title_id = TA.title_id
  Inner Join Sales as S
   On T.title_id = S.title_id
  Inner Join Stores as St
   On S.stor_id = St.stor_id;
go

-- Joins are created easiest by using this technique: 
-- 1) List the columns you want
-- 2) List the tables that have those columns
-- 3) List how those these columns are connected
-- 4) Use these ingredients to create your SQL Join!

-- 1) I want a list of publisher names the titles they publish 
pub_name 
title

-- 2) List the tables that have those columns
Publishers
Titles 

-- 3) List how those these columns are connected
Titles.pub_id
Publishers.pub_id

-- 4) Use these ingredients to create your SQL Join!
Select 
  pub_name 
 ,title
 From Publishers
  Join Titles 
   On Titles.pub_id = Publishers.pub_id;

  
'*** Outer Joins ***'
-----------------------------------------------------------------------------------------------------------------------
-- Sometimes you want all of the data from one or more table, even if the
-- you not have a connecting value between them.
-- What is in these table?
Select pub_id, pub_name From Publishers;
Select pub_id, title From Titles;
go
-- Which publishers have titles?
Select Distinct pub_id from Titles;
go
-- What are the name of these publishers?
Select pub_id, pub_name From Publishers Where pub_id in ('1389', '0736', '0877');
-- Same as...
Select pub_id, pub_name From Publishers Where pub_id in (Select Distinct pub_id from Titles);
go
-- Which publishers have no titles
Select pub_id, pub_name From Publishers Where pub_id NOT in (Select Distinct pub_id from Titles);
go

-- Now, let's use a join to see this information in one result
Select pub_name, title
 From Publishers
  LEFT OUTER Join Titles 
   On Titles.pub_id = Publishers.pub_id;

-- Same as...
Select pub_name, title
 From Titles
  RIGHT OUTER Join Publishers
   On Titles.pub_id = Publishers.pub_id;

-- Only the Null ones
Select pub_name, title
 From Titles
  RIGHT OUTER Join Publishers
   On Titles.pub_id = Publishers.pub_id
  Where title is Null;


--( Mixing Inner and Outer Joins )--
-----------------------------------------------------------------------------------------------------------------------
-- When you Mix Inner and Outer Joins be careful to check that you did not look some rows!!!
Select pub_name, title, qty
 From Titles RIGHT OUTER Join Publishers
   On Titles.pub_id = Publishers.pub_id
 LEFT Join Sales
   On Titles.title_id = Sales.title_id
-- 28 rows

Select pub_name, title, qty
 From Titles RIGHT OUTER Join Publishers
   On Titles.pub_id = Publishers.pub_id
 INNER Join Sales
   On Titles.title_id = Sales.title_id
-- 28 rows


--( Joining by Non-Foreign Key columns )--
-- You can also join data on columns that are not a FK of another.
Select pub_name, au_fname + ' ' + au_lname as author_name
 From Publishers Inner Join Authors
   On  Publishers.city = Authors.city
-- 2 rows

Select pub_name, au_fname + ' ' + au_lname as author_name
 From Publishers Left Join Authors
   On  Publishers.city = Authors.city
-- 9 rows

Select pub_name, au_fname + ' ' + au_lname as author_name
 From Publishers Right Join Authors
   On  Publishers.city = Authors.city
-- 23 rows

Select pub_name, au_fname + ' ' + au_lname as author_name
 From Publishers FULL Join Authors
   On  Publishers.city = Authors.city
-- 30 rows


'*** Cross Joins ***'
-----------------------------------------------------------------------------------------------------------------------
-- Cross Joins give you all the possible combinations of values
Select pub_name, title
 From Titles CROSS Join Publishers;
-- 144 rows
go 
-- This Inner Join only give you only the ones that have a matching values (Equi-Join)
Select pub_name, title
 From Publishers INNER Join Titles 
   On Titles.pub_id = Publishers.pub_id; 
-- 18 rows;    
-- This is not a Cross Join, as is gives you only the NON-Matching values(Non Equi-Join)!
Select pub_name, title
 From Titles INNER Join Publishers
   On Titles.pub_id <> Publishers.pub_id;   
-- 126 rows

-- What is 18 + 126?
Select 18 + 126; -- 144! Which is all the Match AND Non-Matching rows!

-- Cross Joins are not used much, but can come in handy!
Select 
  [Store Name] = stor_name
 ,[Title] = title
 ,[Inventory Count] = '?'
 From Titles Cross Join Stores
 Order By 1, 2;
go

'*** Self Joins ***'
-----------------------------------------------------------------------------------------------------------------------
Use Northwind;
-- Here is a table that is self-referencing
Select * from Employees;
go
-- There is a FK on the Reports too column that references the EmployeeID column
Select ReportsTo, * from Employees;
go

-- We can select the Name of a manager, but join the RESULTS of table twice!
Select Mgr.EmployeeId, Mgr.LastName, Emp.EmployeeID, Emp.LastName 
 From Employees as Emp
  Inner Join Employees Mgr
   On Emp.ReportsTo = Mgr.EmployeeID
 Order By 1,2,3,4;   
go

-- Note, this is not the same as...
Select Mgr.EmployeeId, Mgr.LastName, Emp.EmployeeID, Emp.LastName 
 From Employees as Emp
  Inner Join Employees Mgr
   On Emp.EmployeeID = Mgr.ReportsTo --< LOOK HERE 
   -- Wrong because, you need to look up the MANAGER's ID for EACH EMPLOYEE Row, NOT the Employee's ID
 Order By 1,2,3,4;   
go

-- If we change to a Outer Join, we can see more data
Select Mgr.EmployeeId, Mgr.LastName, Emp.EmployeeID, Emp.LastName 
 From Employees as Emp
  Left Join Employees Mgr
   On Emp.ReportsTo = Mgr.EmployeeID 
 Order By 1,2,3,4;   
go

-- We can use the various functions and column aliases to make is look better!
Select 
  [Manager ID] = IsNull(Mgr.EmployeeId, 0)
 ,[Manager] = IIF(IsNull(Mgr.EmployeeId, 0) = 0, 'General Manager', Mgr.LastName)
 ,[Employee ID] =  Emp.EmployeeID
 ,[Employee Name] =  Emp.FirstName + ' ' + Emp.LastName 
 From Employees as Emp
  Left Join Employees Mgr
   On Emp.ReportsTo = Mgr.EmployeeID 
 Order By 1,3;   
go

-- Let's keep the order based on the IDs, but not display the ID...
Select 
  [Manager] = IIF(IsNull(Mgr.EmployeeId, 0) = 0, 'General Manager', Mgr.LastName)
 ,[Employee Name] =  Emp.FirstName + ' ' + Emp.LastName 
 From Employees as Emp
  Left Join Employees Mgr
   On Emp.ReportsTo = Mgr.EmployeeID 
 Order By IsNull(Mgr.EmployeeId, 0), Emp.EmployeeID;   
go  

'*** Unions ***'
-----------------------------------------------------------------------------------------------------------------------
-- While Joins combine columns from results, Unions combine ROWs from results
Use Pubs;
go

Select * From Stores; -- 6 rows
Select * From Authors; -- 23 rows

-- Let's Make a Mailing List using these two tables:
	-- 1) Here is our data
	Select stor_name, stor_address, city, state, zip From Stores;
	Select au_lname + ' ' + au_fname, address, city, state, zip From Authors;

	-- 2) We use Union to combine them
	Select stor_name, stor_address, city, state, zip From Stores
	Union
	Select au_lname + ' ' + au_fname, address, city, state, zip From Authors
	Order By 4,3,1

	-- 3) We use Aliases to make the resultes look better!
	Select 
	 [Name] = stor_name
	,[Address] = stor_address
	,[City] = city
	,[State] = state
	,[ZipCode] = zip 
	From Stores
	Union
	Select au_lname + ' ' + au_fname, address, city, state, zip From Authors
	Order By 4,3,1

'*** Subqueries ***'
-----------------------------------------------------------------------------------------------------------------------
-- In the Where Clause
Select * 
 From Authors 
  Where state in (Select Distinct state From Stores); -- Note: Do not use a Double Semi-Colon ;;
-- 16 rows

Select Distinct au_fname + ' ' + au_lname as [Author]
 From Authors 
  Where State in (Select Distinct state 
				   From Stores Join Sales 
				    On Stores.stor_id = Sales.stor_id
				    Where Sales.qty >= 50);
-- 15 rows


--( In the From Clause )-
Select 
  StoreState
 ,[Total By Store] = Sum(Sales.qty)
 From Sales 
 Join (Select Stor_id as StoreID, state as StoreState from Stores) as Stores
  On Stores.StoreID = Sales.stor_id
 Group by StoreState;


--( In the Select Clause )-- 
-- What is the grand total of sale quantity?
Select Sum(Sales.qty) From Sales

-- What is the totals by store when compared to the grand total?
Select 
  [State] = state
 ,[Total By Store] = Sum(Sales.qty)
 ,[Grand Total] = (Select Sum(Sales.qty) From Sales)
 From Sales Join Stores 
  On Stores.stor_id = Sales.stor_id
 Group by state;

-- Now let's use this to calculate a percentage
Select 
  [State] = state
 ,[Total By Store] = Sum(Sales.qty)
 ,[Grand Total] = (Select Sum(Sales.qty) From Sales)
 ,[Percentage] = str((100 * Sum(Sales.qty)) / (Select Sum(Sales.qty) From Sales), 5, 2) + '%'
 From Sales Join Stores 
  On Stores.stor_id = Sales.stor_id
 Group by state;

-- (In the Select, From, and Where! OH NOOOooooo!!!)
Select 
  [State] = StoreState
 ,[Total By Store] = Sum(Sales.qty)
 ,[Grand Total] = (Select Sum(Sales.qty) From Sales)
 ,[Percentage] = str((100 * Sum(Sales.qty)) / (Select Sum(Sales.qty) From Sales), 5, 2) + '%'
 From Sales Join (Select Stor_id as StoreID, state as StoreState from Stores) as Stores 
  On Stores.StoreID = Sales.stor_id
 Where StoreState in (Select Distinct state 
                       From Stores Join Sales 
				        On Stores.stor_id = Sales.stor_id
				        Where Sales.qty >= 50)
 Group by StoreState;
  
'*** Temp Tables ***'
-----------------------------------------------------------------------------------------------------------------------
-- You can use a temp table to store data and refer back to it. This can make your code eaiser to read!
Select Stor_id as StoreID, state as StoreState
Into #StoresByState
From Stores;

-- We can make many temp tables and each is unique to the current connection!
Select Distinct state 
 Into #StoreWithAnIndividualSaleOf50orMore
 From Stores Join Sales 
  On Stores.stor_id = Sales.stor_id
  Where Sales.qty >= 50;

-- We use them just like standard tables
Select * From #StoresByState;
Select * From #StoreWithAnIndividualSaleOf50orMore;

-- We can join to them as well
Select 
  [State] = StoreState
 ,[Total By Store] = Sum(Sales.qty)
 ,[Grand Total] = (Select Sum(Sales.qty) From Sales)
 ,[Percentage] = str((100 * Sum(Sales.qty)) / (Select Sum(Sales.qty) From Sales), 5, 2) + '%'
 From Sales Join (Select * From #StoresByState) as Stores 
  On Stores.StoreID = Sales.stor_id
 Where StoreState in (Select * from #StoreWithAnIndividualSaleOf50orMore) 
 Group by StoreState;

-- We can Drop the Temp tables (if they exist!) or just wait until our connection is closed!
If Object_ID('tempdb..#StoresByState') is not null 
  Drop Table #StoresByState;
If Object_ID('tempdb..#StoreWithAnIndividualSaleOf50orMore') is not null 
  Drop Table #StoreWithAnIndividualSaleOf50orMore;

'*** Common Table Expressions (CTEs) ***'
-----------------------------------------------------------------------------------------------------------------------

-- CTEs are like Temp tables, but are delete once the query finishes!
With StoresByState AS
  (Select Stor_id as StoreID, state as StoreState  From Stores )
,StoreWithAnIndividualSaleOf50orMore AS
  (Select Distinct state 
    From Stores Join Sales 
     On Stores.stor_id = Sales.stor_id
     Where Sales.qty >= 50)
Select 
  [State] = StoreState
 ,[Total By Store] = Sum(Sales.qty)
 ,[Grand Total] = (Select Sum(Sales.qty) From Sales)
 ,[Percentage] = str((100 * Sum(Sales.qty)) / (Select Sum(Sales.qty) From Sales), 5, 2) + '%'
 From Sales Join (Select * From StoresByState) as Stores 
  On Stores.StoreID = Sales.stor_id
 Where StoreState in (Select * from StoreWithAnIndividualSaleOf50orMore) 
 Group by StoreState;