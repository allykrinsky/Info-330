--*************************************************************************--
-- Title: Module07 
-- Author: RRoot
-- Desc: This file demonstrates selecting data using Functions 
--		Built-in Functions
--      User Defined Functions (UDF)
--      UDF for Validation
--		Functions vs Views 
--      Functions for Reporting
--      Functions for ETL Processing

-- Change Log: When,Who,What
-- 2017-08-01,RRoot,Created File
--**************************************************************************--

'*** Setup Code ***'
-----------------------------------------------------------------------------------------------------------------------
-- Let's make a demo database for this module
Begin Try
	Use Master;
	If (Select DB_ID('Module07Demos')) is not null -- Using the DB_ID function
	 Begin 
	  Alter Database [Module07Demos] set Single_user With Rollback Immediate;
	  Drop Database Module07Demos;
	 End
	Create Database Module07Demos;
End Try
Begin Catch
	Print Error_Message();
End Catch
go
Use Module07Demos;
go
-- Create Views to DISPLAY Data
Create View vCategories 
 AS 
  Select CategoryID, CategoryName 
   From Northwind.dbo.Categories;
go
Create View vProducts 
 AS 
 Select ProductID, ProductName,CurrentPrice = UnitPrice, CategoryID 
  From Northwind.dbo.Products; 
go
Create View vOrderDetails 
 AS 
 Select OrderID, ProductID, UnitPrice, Quantity
  From Northwind.dbo.[Order Details]; 
go
Create View vOrders 
 AS 
 Select OrderID, CustomerID,  OrderDate, RequiredDate, ShippedDate
  From Northwind.dbo.[Orders]; 
go


'*** Built-in Functions ***'
-----------------------------------------------------------------------------------------------------------------------
-- Most SQL Functions  return a single value
Select GetDate(), IsNull(null,0);

-- But, you can use them in a select, and apply the function to many rows
Select GetDate(), IsNull(CurrentPrice, 0), ProductName
 From vProducts;
go

-- You can combine functions to create better looking results
Select 
  Cast(GetDate() as Date)
, IsNull(CurrentPrice, 0)
, IsNull(Cast(CurrentPrice as varchar(50)), 'Not For Sale!')
, ProductName
 From vProducts;
go

-- There are LOTS of functions! Here are some I use often...
-- Conversions
Select Cast('1' as int), Cast('1' as decimal(3,2)), Cast(1 as nVarchar(50));
Select Convert(int,'1'), Convert(decimal(3,2),'1'), Convert(nvarchar(50), 1);

-- Convert has more features than Cast
Select 
 [Simple Cast] = Cast(GetDate() as Date)
,[Simple Convert] = Convert(Date, GetDate())
,[US with Slash] = Convert(varchar(50), GetDate(), 101) 
,[US with Dash] = Convert(varchar(50), GetDate(), 110) 
,[ANSI YearMonthDay] =Convert(varchar(50), GetDate(), 112) 
;
go

--( Logical Functions )--
-- Immediate IF
Select IIF(5 = 5, 'T', 'F');
Select 
  [ProductName] = IIF(ProductID = 3,  ProductName + ' (Not For Sale!)', ProductName)
 From vProducts;
go

-- Choose
Select Choose(1, 'A', 'B', 'C'), Choose(2, 'A', 'B', 'C') 
Select 
 ProductName
,[Category] = Choose(CategoryID, 'A','B','C')   
 From vProducts;
go

-- Case
Select Case (5 + 5) When 10 Then 'Ten' When 9 Then 'Nine' End
Select
 ProductName
,[Category] = Case CategoryID 
				When 1 Then 'A' 
				When 2 Then 'B'
				When 3 Then 'C' 
				End
 From vProducts;
go

-- a Better example of Case
Select 
 CustomerID
 ,OrderID
 ,RequiredDate
 ,ShippedDate 
 ,[OnTime] = Case 
			  When RequiredDate > ShippedDate Then 'Early' 
			  When RequiredDate = ShippedDate Then 'On Time' 
			  When RequiredDate < ShippedDate Then 'Late' 
			  Else 'No Info Yet'
			 End				
 From vOrders
 Order by [OnTime];
go

-- IsNumeric
Select IsNumeric('1'), IsNumeric('a1'), IsNumeric('1.23');

-- IsDate
Select 
 IsDate('1/1/2001')
,IsDate('01-01-2001')
,IsDate('20010101')
,IsDate('Jan,01,2001')
,IsDate('1st of Jan,2001')
;


--( String Functions )--
SELECT UPPER('Test');
SELECT LOWER('Test');
go

SELECT '|' + LTRIM('    Test   ') + '|';
SELECT '|' + RTRIM('    Test   ') + '|';
SELECT '|' + LTRIM(RTRIM('    Test   ')) + '|';
go

SELECT SUBSTRING('Test', 2, 2); 
SELECT PATINDEX('%s%','Test');
go

SELECT STR(3.147); 
SELECT STR(3.147, 5, 2); 
SELECT STR(3.147, 3, 3);
-- Simliar to >> SELECT CONVERT(char(15), 123.456) 
-- But, this will cause an error >> SELECT CONVERT(char(3), 123.456)
go

-- Format
Select Format(GetDate(), 'd', 'en-US' ) AS 'US Result'  
      ,Format(GetDate(), 'd', 'en-gb' ) AS 'Great Britain Result'  
      ,Format(GetDate(), 'd', 'de-de' ) AS 'Germany Result'  
      ,Format(123.456, 'C', 'en-US') AS 'US Format'  
      ,Format(123.456, 'C', 'en-gb') AS 'Great Britain Format'  
      ,Format(123.456, 'C', 'de-de') AS 'Germany Format' 
; 
go

-- Left and Right
DECLARE @string varchar(100) = 'This is some data'
SELECT [Left] = Left(@string,4),[Right] = Right(@string,4)
;
go

-- LTrim and RTrim
DECLARE @string_to_trim varchar(100) = '    This is some data    '
SELECT 
 [Without spaces] = '|' + LTrim(RTrim(@string_to_trim)) + '|'
,[With spaces:] = '|' + @string_to_trim + '|'
;
go

-- Upper and Lower
Select Upper('Bob Smith'), Lower('Bob Smith');
go

-- STUFF ( character_expression , start , length , replaceWith_expression )  
Select Stuff('Bob Smith',1,3,'Robert'); 
go

-- REPLACE ( string_expression , string_pattern , string_replacement )  
Select Replace('Bob Smith','Bob','Robert');
Select Replace('Bob Jim-Bob Smith','Bob','Robert');
go

-- PATINDEX ( '%pattern%' , expression ) 
Declare @Email varchar(50) = 'BSmith@MyCo.com'; 
SELECT 
 [Name Ends] = PatIndex('%@%', @Email)
,[Domain Starts] = PatIndex('%.%', @Email) 
;
go

-- SUBSTRING ( expression ,start , length ) 
Declare @Email varchar(50) = 'BSmith@MyCo.com';  
SELECT 
 [Name] = SubString(@Email,0,PatIndex('%@%',@Email))   
,[Company] = SubString(@Email,PatIndex('%@%',@Email) + 1, patindex('%.%',@Email) - patindex('%@%',@Email) - 1) 
,[Domain] = SubString(@Email,PatIndex('%.%',@Email) + 1,20)
go


--( Aggregate Functions )--
Select 
 ProductID
,[Sum] = Sum(Quantity)
,[Max] = Max(Quantity)
,[Min] = Min(Quantity)
,[Avg] = Avg(Quantity)
,[Count] = Count(Quantity)
From vOrderDetails
Group By ProductID

--( Date/Time Functions )--
Declare @Date as DateTime = GetDate();
Select 
 [Isdate()] = Isdate(@Date)
,[Datename()] = DateName(mm,@Date) + ', ' + DateName(Weekday,@Date)  
,[Datepart()] = str(DatePart(mm, @Date)) + ', ' + str(DatePart(Weekday,@Date)) 
,[Dateadd()] = DateAdd(mm, 1, @Date)
,[Datediff()] = DateDiff(yy, '20000101', @Date)
,[Day()Month()Year()] = str(Day(@Date)) + ', ' + str(Month(@Date)) + ', ' + str(Year(@Date))
go

'*** User Defined Functions (UDF) ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Single Value (Scalar) Functions
Create Function dbo.AddValues(@Value1 Float,@Value2 Float)
 Returns Float 
 As
  Begin
   Return(Select @Value1 + @Value2);
  End 
go

-- Calling the function
Select dbo.AddValues(4, 5);
go

-- Simple Table Value (Tabluar) Functions
Create Function dbo.ArithmeticValues(@Value1 Float, @Value2 Float)
 Returns Table 
 As
  --Begin << Cannot use Begin 
   Return(
    Select [Sum] = @Value1 + @Value2,
	[Difference] = @Value1 - @Value2, 
	   [Product] = @Value1 * @Value2,
	  [Quotient] = @Value1 / @Value2	    	
	);
  --End << Or End with Simple Table Value Functions
go

-- Complex Table Value (Tabluar) Functions with Multiple Statements
Create Function dbo.fArithmeticValuesWithFormat(@Value1 Float, @Value2 Float, @FormatAs char(1))
 Returns @MyResults Table 
		( [Sum] sql_variant 
		, [Difference] sql_variant
		, [Product] sql_variant
		, [Quotient] sql_variant
		)
 As
  Begin --< Must use Begin and End with Complex table value functions
   If @FormatAs = 'f' 
    Insert Into @MyResults
	 Select Cast(@Value1 + @Value2 as Float)
	       ,Cast(@Value1 - @Value2 as Float)
		   ,Cast(@Value1 * @Value2 as Float)
		   ,Cast(@Value1 / @Value2 as Float)
   Else If @FormatAs = 'i' 
    Insert Into @MyResults
	 Select Cast(@Value1 + @Value2 as int)
	       ,Cast(@Value1 - @Value2 as int)
		   ,Cast(@Value1 * @Value2 as int)
		   ,Cast(@Value1 / @Value2 as int)
	Else 	   		    	
    Insert Into @MyResults
	 Select Cast(@Value1 + @Value2 as varchar(100))
	       ,Cast(@Value1 - @Value2 as varchar(100))
		   ,Cast(@Value1 * @Value2 as varchar(100))
		   ,Cast(@Value1 / @Value2 as varchar(100))
  Return
  End 
go

-- Calling the function
Select * FROM dbo.fArithmeticValuesWithFormat(10, 3, 'f');
Select * FROM dbo.fArithmeticValuesWithFormat(10, 3, 'i');
Select * FROM dbo.fArithmeticValuesWithFormat(10, 3, null);
go

-- Deleting a function 
Drop Function dbo.fArithmeticValuesWithFormat
go

-- Using built-in functions with custom functions
Create Function dbo.fFancyDateString (@Date Date)
 Returns nvarchar(100) 
 As
  Begin
   Return(
    Select DateName(Weekday,@Date) + ', ' 
  		 + DateName(mm,@Date)
  		 + str(DatePart(dd, @Date), 2) + ' ' 
  		 + str(DatePart(yyyy, @Date), 4)
  )
 End; 
go

-- Calling the function
Select dbo.fFancyDateString('20010203'),dbo.fFancyDateString(GetDate()), GetDate();
go

-- Changing custom functions
Alter Function dbo.fFancyDateString (@Date Date)
 Returns nvarchar(100) 
 As
  Begin
   Return( -- Declare @Date as DateTime = '20010203';
    Select DateName(Weekday,@Date) 
           + ', ' 
  		 + DateName(mm,@Date)
  		 + str(DatePart(dd, @Date), 2)
  		 + Case  
  		    When DatePart(dd, @Date) In (1,21,31) Then 'st'
  		    When DatePart(dd, @Date) In (2,22) Then 'nd'
  		    When DatePart(dd, @Date) In (3,23) Then 'rd'
  			Else 'th'
  		   End
           + ' ' 
  		 + str(DatePart(yyyy, @Date), 4)
  )
 End; 
go

-- Calling the function
Select dbo.fFancyDateString('20010203'),dbo.fFancyDateString(GetDate()), GetDate();
go


'*** UDF for Validation ***'
-----------------------------------------------------------------------------------------------------------------------
Create -- Drop
table Meetings 
 (MeetingId int Primary Key, MeetingDateAndTime datetime);
go
Insert Into Meetings Values(1, '1/1/2017 10:00:00');
go

Create Function dbo.fGetMeetingDateTime
(@MeetingId int)
Returns datetime
as
 Begin
  Return (Select MeetingDateAndTime 
           From Meetings
            Where Meetings.MeetingId = @MeetingID)
 End;
go

Select dbo.fGetMeetingDateTime(1)
Select IIF(dbo.fGetMeetingDateTime(1) > Cast('12/31/2016 07:00:00' as Datetime), 't', 'f');
Select IIF(dbo.fGetMeetingDateTime(1) > Cast('1/1/2017 07:30:00' as Datetime), 't', 'f');
go

Create table Signups 
 (SignupId int
 ,SignupDateTime datetime
 ,MeetingID int Foreign Key References Meetings(MeetingID)
 ,IsCurrent bit
 );
go

Alter Table Signups Add Constraint chSignupDateTime
 Check(SignupDateTime < dbo.fGetMeetingDateTime(MeetingID));
go

Insert Into Signups Values(100, '12/31/2016 07:00:00', 1, 1); 
go

Insert Into Signups Values(100, '1/1/2017 11:30:00', 1, 1); 
go

'*** Functions vs Views ***'
-----------------------------------------------------------------------------------------------------------------------
go 
-- Both Functions and Views can be used as a table 
-- View 
Alter View vProducts 
  AS 
   Select ProductID, ProductName,CurrentPrice = UnitPrice, CategoryID, Discontinued
    From Northwind.dbo.Products;
go 
Select * from vProducts; 
go
-- Function
Create Function fProducts() 
 Returns Table 
 AS 
   Return(
    Select ProductID, ProductName, CategoryId, Discontinued 
	 From Northwind.dbo.Products
	);
go
Select * from fProducts(); 
go

-- But only functions can use Parameters
Alter Function fProducts(@CategoryId int) 
 Returns Table 
 AS 
   Return(
   Select ProductID, ProductName 
    From Northwind.dbo.Products 
	 Where CategoryID = @CategoryId
   );
go
Select * from fProducts(1)
go

-- However, you could always apply the where clause to the View like this...
Select * From vProducts Where CategoryID = 1
go

-- TIP: Since table functions are more complex and provide similar functionality, 
--      use Views to 'Keep It Simple' when you can!

'*** Functions for Reporting ***' --(TIP: This is on the Assignment!)-- 
-----------------------------------------------------------------------------------------------------------------------
-- To create reporting queiers, you start off with a simple Select statement
Select Distinct
  OrderDate
 From vOrders

-- Then add simple functions and test the results
Select Distinct
  [OrderYear] = Year(OrderDate)
 From vOrders

-- Next, add more columns, functions, or tables as needed
Select Distinct 
  [OrderYear] = Year(OrderDate)
 ,[YearlyTotalQty] = Sum(Quantity)
 From vOrders as O
  Join vOrderDetails as OD
   On o.OrderID = o.OrderID
 Group By Year(OrderDate);

-- and start adding more complex function, as needed (like using the Lag Function) 
Select 
  [OrderYear] = Year(OrderDate)
 ,[YearlyTotalQty] = Sum(Quantity)
 ,[PreviousYearlyTotalQty] = Lag(Sum(Quantity)) Over(Order By Year(OrderDate)) 
 From vOrders as O
  Join vOrderDetails as OD
   On o.OrderID = o.OrderID
 Group By Year(OrderDate);
go

-- Keep adding more features until you get what you are looking for
Select 
  ProductName
 ,[OrderYear] = Year(OrderDate)
 ,[YearlyTotalQty] = Sum(Quantity)
 ,[PreviousYearlyTotalQty] = IsNull( Lag(Sum(Quantity)) Over (Order By ProductName,Year(OrderDate)), 0)
 From vOrders as O
  Join vOrderDetails as OD
   On o.OrderID = o.OrderID
  Join vProducts as P
   On OD.ProductID = P.ProductID
 Group By ProductName, Year(OrderDate);
go

-- Finally, create a reporting View that includes these functions
Create -- Drop
View vProductOrderQtyByYear
AS 
Select 
  ProductName
 ,[OrderYear] = Year(OrderDate)
 ,[YearlyTotalQty] = Sum(Quantity)
 ,[PreviousYearlyTotalQty] = Lag(Sum(Quantity)) Over (Order By ProductName,Year(OrderDate))
 From vOrders as O
  Join vOrderDetails as OD
   On o.OrderID = o.OrderID
  Join vProducts as P
   On OD.ProductID = P.ProductID
 Group By ProductName, Year(OrderDate);
go

-- When using the View, you can always add on more funtions
-- as needed. For example our current view
-- makes it easy to create a Key Performance Indicators (KPIs) report
Select 
  ProductName
 ,[OrderYear]
 ,YearlyTotalQty
 ,PreviousYearlyTotalQty 
 ,[QtyChangeKPI] = Case 
   When YearlyTotalQty > PreviousYearlyTotalQty Then 1
   When YearlyTotalQty = PreviousYearlyTotalQty Then 0
   When YearlyTotalQty < PreviousYearlyTotalQty Then -1
   End
 From vProductOrderQtyByYear
go

-- or this one...
Select 
  ProductName
 ,[OrderYear]
 ,YearlyTotalQty
 ,PreviousYearlyTotalQty = IsNull(PreviousYearlyTotalQty, 0)
 ,[QtyChangeKPI] = IsNull(Case 
   When YearlyTotalQty > PreviousYearlyTotalQty Then 1
   When YearlyTotalQty = PreviousYearlyTotalQty Then 0
   When YearlyTotalQty < PreviousYearlyTotalQty Then -1
   End, 0) 
 From vProductOrderQtyByYear
go

-- or even this one...
Select 
  ProductName
 ,[OrderYear]
 ,YearlyTotalQty
 ,PreviousYearlyTotalQty = IsNull(PreviousYearlyTotalQty, 0) 
 ,[QtyChangeKPI] = IsNull(Case 
				   When YearlyTotalQty > PreviousYearlyTotalQty Then ':)'
				   When YearlyTotalQty = PreviousYearlyTotalQty Then ' :0'
				   When YearlyTotalQty < PreviousYearlyTotalQty Then '  :('
				   End, ':|') 
 From vProductOrderQtyByYear
go


'*** Functions for ETL Processing ***'
-----------------------------------------------------------------------------------------------------------------------
-- Function can help 
-- if you need to EXTRACT data from a SOURCE,
Create -- Drop
Table StagingForCustomers 
 (Name Varchar(100), Phone Varchar(100));
go
Insert Into StagingForCustomers(Name, Phone)
 Values ('Bob Smith', '(206)555-1212'), ('Sue Jones', '(425)123-4567')
go

-- then TRANSFORM that data,
Create Function fGetFirstName(@Name varchar(100))
 Returns nChar(5)
 As
 Begin
  Return(------------ Start From Zero
   SELECT FirstName = SubString(@Name,0,PatIndex('% %',@Name) + 1) 
  )
 End  
go

Create Function fGetLastName(@Name varchar(100))
 Returns nChar(5)
 As
 Begin
  Return(------------- Start From First Space 
   SELECT [LastName] = SubString(@Name,PatIndex('% %',@Name) + 1,100)
  )
 End  
go

Create Function fGetAreaCode(@Phone varchar(50))
 Returns nChar(5)
 As
 Begin
  Return(------------ Start From end parenthesis
   SELECT AreaCode = SubString(@Phone,0,PatIndex('%)%',@Phone) + 1) 
  )
 End  
go

Create Function fGetPhoneNumber(@Phone varchar(100))
 Returns nVarchar(100)
 As
 Begin
  Return(------------- Start From First parenthesis 
   SELECT [PhoneNumber] = SubString(@Phone,PatIndex('%)%',@Phone) + 1,100)
  )
 End  
go


-- before you LOAD it into its DESTINATION!
Create Table Customers 
 (CustomerID int Primary Key Identity
 ,CustomerFirstName nVarchar(100)
 ,CustomerLastName nVarchar(100)
 ,PhoneAreaCode nVarchar(100)
 ,PhoneNumber nVarchar(100)
 );
go

Insert Into Customers(CustomerFirstName,CustomerLastName,PhoneAreaCode,PhoneNumber)
Select 
 [CustomerFirstName] = dbo.fGetFirstName(Name) 
,[CustomerLastName] = dbo.fGetLastName(Name)
,[CustomerPhoneAreaCode] = dbo.fGetAreaCode(Phone) 
,[CustomerPhoneNumber] = dbo.fGetPhoneNumber(Phone) 
 From StagingForCustomers;
go

Select * From Customers;


'*** When to use Functions ***'
-----------------------------------------------------------------------------------------------------------------------
-- Functions in the Select Clause
Select Year(OrderDate) as [OrderYear], * 
 From Northwind.dbo.Orders
go
-- Functions in the From Clause
Create Function fNorthwindOrdersByYear()
 Returns Table
As 
 Return (Select Year(OrderDate) as [OrderYear], * 
          From Northwind.dbo.Orders
);
go

Select * 
 From fNorthwindOrdersByYear();
go

-- Functions in the Where Clause
Select * 
 From Northwind.dbo.Orders
  Where Year(OrderDate) = 1996
go

-- Functions in the Group By Clause
Select CustomerID, Year(OrderDate) as [OrderYear], Count(*) as [NumberOfOrders]
 From Northwind.dbo.Orders
  Group By CustomerID, Year(OrderDate)
-- Group By CustomerID, [OrderYear] -- Group By cannot use an Alias!
go

-- Functions in the Order By Clause
Select CustomerID, Year(OrderDate) as [OrderYear], Count(*) as [NumberOfOrders]
 From Northwind.dbo.Orders
  Group By CustomerID, Year(OrderDate)
-- Group By CustomerID, [OrderYear] -- Group By CANNOT use an Alias!
   Order By CustomerID, Year(OrderDate)
--  Order By  CustomerID, [OrderYear] -- Group By CAN use an Alias!
go