-- Sales person YTD sales
select
	BusinessEntityID,
	TerritoryID,
	SalesQuota,
	Bonus,
	CommissionPct,
	SalesYTD,
	SalesLastYear,
	[Total YTD Sales] = SUM(salesYTD) over(),
	[Max YTD Sales] = MAX(salesYTD) over(),
	[% of Best Performer] = (SalesYTD/MAX(salesYTD) over()) * 100
from AdventureWorks2019.Sales.SalesPerson


-- Personnel Rates comparison
select
	A.FirstName,
	A.LastName,
	B.JobTitle,
	C.Rate,
	AVG(c.rate) over() as AverageRate,
	MAX(c.rate) over() as MaximumRate,
	c.Rate - AVG(c.rate) over() as DiffFromAvgRate,
	(c.Rate / MAX(c.rate) over()) * 100 as PercentofMaxRate
from 
	AdventureWorks2019.Person.Person a
	join HumanResources.Employee b
	on a.BusinessEntityID = b.BusinessEntityID

	join AdventureWorks2019.HumanResources.EmployeePayHistory c
	on a.BusinessEntityID = c.BusinessEntityID


-- Sum of line totals
Select
	ProductID,
	SalesOrderID,
	SalesOrderDetailID,
	OrderQty,
	UnitPrice,
	UnitPriceDiscount,
	LineTotal,
	ProductIDLineTotal = sum(linetotal) over( partition by ProductID, OrderQty)
from
	[AdventureWorks2019].[Sales].[SalesOrderDetail]

order by
	ProductID, OrderQty desc


-- Product vs Category Delta
select
	A.Name as ProductName,
	A.ListPrice,
	B.Name as ProductSubcategory,
	C.Name as ProductCategory,
	AVG(A.ListPrice) over(partition by C.Name) as AvgPriceByCategory,
	AVG(A.ListPrice) over(partition by C.Name, B.Name) as AvgPriceByCategoryAndSubcategory,
	(A.ListPrice - AVG(A.ListPrice) over(partition by C.Name)) as ProductVsCategoryDelta 

from 
	AdventureWorks2019.Production.Product A
	join AdventureWorks2019.Production.ProductSubcategory B
	on A.ProductSubcategoryID = B.ProductSubcategoryID

	join AdventureWorks2019.Production.ProductCategory C
	on B.ProductCategoryID = C.ProductCategoryID



-- Sum of line totals by sales order ID
select
	SalesOrderID,
	SalesOrderDetailID,
	LineTotal,
	SalesOrderIDLineTotal = sum([LineTotal]) over (partition by SalesOrderID)
from 
	[AdventureWorks2019].[Sales].[SalesOrderDetail]

order by
	SalesOrderID


-- Ranking all records within each group of sales order IDs
select
	SalesOrderID,
	SalesOrderDetailID,
	LineTotal,
	SalesOrderIDLineTotal = sum([LineTotal]) over (partition by SalesOrderID),
	Ranking = ROW_NUMBER() over (order by LineTotal desc)

from 
	[AdventureWorks2019].[Sales].[SalesOrderDetail]

order by
	5	


-- Price Ranking
select
	A.name as ProductName,
	A.ListPrice,
	B.name as ProductSubcategory,
	C.name as ProductCategory,
	[Price Rank] = ROW_NUMBER() over( order by a.ListPrice desc),
	[Category Price Rank] = ROW_NUMBER() over( partition by c.name order by a.ListPrice desc),
	[Top 5 Price In Category] =
		CASE 
			when 
				ROW_NUMBER() over( partition by c.name order by a.ListPrice desc) <= 5 then 'Yes'
			else 'No'
		end 

from
	[AdventureWorks2019].[Production].[Product] A
	join AdventureWorks2019.Production.ProductSubcategory B
	on A.ProductSubcategoryID = B.ProductSubcategoryID

	join AdventureWorks2019.Production.ProductCategory C
	on B.ProductCategoryID = C.ProductCategoryID


-- Ranking all records by line totals - no groups
select
	SalesOrderID,
	SalesOrderDetailID,
	LineTotal,
	Ranking = ROW_NUMBER() over (partition by SalesOrderID order by LineTotal desc),
	[Ranking with Rank] = RANK() over (partition by SalesOrderID order by LineTotal desc),
	[Ranking with Dense_Rank] = DENSE_RANK() over (partition by SalesOrderID order by LineTotal desc)

from 
	[AdventureWorks2019].[Sales].[SalesOrderDetail]

order by
	SalesOrderID, LineTotal desc


-- Ranking
select
	A.name as ProductName,
	A.ListPrice,
	B.name as ProductSubcategory,
	C.name as ProductCategory,
	[Price Rank] = ROW_NUMBER() over( order by a.ListPrice desc),
	[Category Price Rank] = ROW_NUMBER() over( partition by c.name order by a.ListPrice desc),
	[Category Price Rank With Rank] = RANK() over( partition by c.name order by a.ListPrice desc),
	[Category Price Rank With Dense Rank] = Dense_RANK() over( partition by c.name order by a.ListPrice desc),
	[Top 5 Price In Category] =
		CASE 
			when 
				Dense_Rank() over( partition by c.name order by a.ListPrice desc) <= 5 then 'Yes'
			else 'No'
		end

from
	[AdventureWorks2019].[Production].[Product] A
	join AdventureWorks2019.Production.ProductSubcategory B
	on A.ProductSubcategoryID = B.ProductSubcategoryID

	join AdventureWorks2019.Production.ProductCategory C
	on B.ProductCategoryID = C.ProductCategoryID


-- Lead and Lag Due	
select
	SalesOrderID,
	OrderDate,
	CustomerID,
	TotalDue,
	[NextTotalDue] = LEAD(totaldue, 1) over(partition by CustomerID order by SalesOrderID),
	[PrevtotalDue] = lag(totaldue,1) over(partition by CustomerID order by SalesOrderID)
from
	AdventureWorks2019.Sales.SalesOrderHeader

order by
	3,1


-- Lead and Lag vendors
select
	a.PurchaseOrderID,
	a.OrderDate,
	a.TotalDue,
	b.name as VendorName,
	[PrevOrderFromVendorAmt] = LAG(a.totaldue,1) over(partition by a.vendorID order by a.OrderDate),
	[NextOrderByEmployeeVendor] = lead(b.name) over( partition by a.employeeID order by a.OrderDate),
	[Next2OrderByEmployeeVendor] = lead(b.name,2) over( partition by a.employeeID order by a.OrderDate)
		
from
	AdventureWorks2019.Purchasing.PurchaseOrderHeader a
	join Purchasing.Vendor b
	on a.VendorID = b.BusinessEntityID

where
	a.TotalDue > 500 and 
	YEAR(a.OrderDate) >= 2013

order by
	a.EmployeeID,
	a.OrderDate


-- All rank 1 of line total
select 
	*
from
	(
		select
			SalesOrderID,
			SalesOrderDetailID,
			LineTotal,
			[LineTotalRanking] = ROW_NUMBER() over( partition by SalesOrderID order by linetotal desc)

		from
			AdventureWorks2019.Sales.SalesOrderDetail
	) A

where 
	LineTotalRanking =1


-- Total Due Ranking
select
	PurchaseOrderID,
	VendorID,
	OrderDate,
	TaxAmt,
	Freight,
	TotalDue
from
	(
		select
			PurchaseOrderID,
			VendorID,
			OrderDate,
			TaxAmt,
			Freight,
			TotalDue,
			dense_rank() over( partition by vendorID order by totalDue desc) as PurchaseOrderRank

		from
			AdventureWorks2019.Purchasing.PurchaseOrderHeader
	) A

where 
	PurchaseOrderRank in (1,2,3)


-- Above Avg Prices
select
	ProductID,
	Name,
	StandardCost,
	ListPrice,
	AvgListPrice = (select AVG(listprice) from AdventureWorks2019.Production.Product),
	AvgListPriceDiff = ListPrice - (select AVG(listprice) from AdventureWorks2019.Production.Product)
from 
	AdventureWorks2019.Production.Product
where
	ListPrice > (select AVG(listprice) from AdventureWorks2019.Production.Product)
Order by
	4


-- Vacation Hours
select
	BusinessEntityID,
	JobTitle,
	VacationHours,
	MaxVacationHours = (select MAX(VacationHours) from AdventureWorks2019.HumanResources.Employee),
	PercentOfMaxVacationHours = (VacationHours * 1.0) / (select MAX(VacationHours) from AdventureWorks2019.HumanResources.Employee)
from
	AdventureWorks2019.HumanResources.Employee
where (VacationHours * 1.0) / (select MAX(VacationHours) from AdventureWorks2019.HumanResources.Employee) >= 0.80


-- Multi Order Count

select
	SalesOrderID,
	OrderDate,
	SubTotal,
	TaxAmt,
	Freight,
	TotalDue,
	MultiOrderCount =
		(
			select
			COUNT(*)
			from
				AdventureWorks2019.Sales.SalesOrderDetail b
			where
				a.SalesOrderID = b.SalesOrderID
				AND b.OrderQty > 1
		)
from
	AdventureWorks2019.Sales.SalesOrderHeader a


-- Non Rejected Items Count
select
	PurchaseOrderID,
	VendorID,
	OrderDate,
	TotalDue,
	NonRejectedItems =
		(
			select
				count(*)
			from
				AdventureWorks2019.Purchasing.PurchaseOrderDetail b
			where
				a.PurchaseOrderID = b.PurchaseOrderID
				AND b.RejectedQty = 0
		),
	MostExpensiveItem =
		(
			select
				MAX(UnitPrice)
			from
				AdventureWorks2019.Purchasing.PurchaseOrderDetail b
			where a.PurchaseOrderID = b.PurchaseOrderID
		)
from
	AdventureWorks2019.Purchasing.PurchaseOrderHeader a


-- Record ID without duplicating
select
	a.SalesOrderID,
	a.OrderDate,
	a.TotalDue

from
	AdventureWorks2019.Sales.SalesOrderHeader a

where Exists (
			select
				1
			from
				AdventureWorks2019.Sales.SalesOrderDetail b
			where
				b.LineTotal > 10000
				and a.SalesOrderID = b.SalesOrderID
			)

order by 1


-- Orders above 500Q and $50
select
	*

from 
	AdventureWorks2019.Purchasing.PurchaseOrderHeader a

where Exists (
			select
				1

			from 
				AdventureWorks2019.Purchasing.PurchaseOrderDetail b

			where OrderQty > 500
				and UnitPrice > 50
				and a.PurchaseOrderID = b.PurchaseOrderID
			)
						
order by
		1


-- Records with RejectedQty
select
	*

from
	AdventureWorks2019.Purchasing.PurchaseOrderHeader a

where 
	Not Exists
	(
	select 
		*

	from 
		AdventureWorks2019.Purchasing.PurchaseOrderDetail b
	where
		b.RejectedQty > 0
		and a.PurchaseOrderID = b.PurchaseOrderID
	)

order by
	1


--Jamming Total Lines by SalesOrderID
select
	SalesOrderID,
	OrderDate,
	SubTotal,
	TaxAmt,
	Freight,
	TotalDue,
	LineTotals = STUFF(
							(
							select
							concat(',',CAST(CAST(LineTotal as money) as varchar))

							from 
								AdventureWorks2019.Sales.SalesOrderDetail A

							where
								A.SalesOrderID = B.SalesOrderID
								FOR XML PATH('')
								),1,1,''
						)

from
	AdventureWorks2019.Sales.SalesOrderHeader B


--Jamming Total Lines by ListPrice
select
	Name as SubcategoryName,
	Product = STUFF(
						(
						select
							concat(',',name)

						from
							AdventureWorks2019.Production.Product A

						where a.ProductSubcategoryID = b.ProductSubcategoryID
							AND ListPrice > 50
							FOR XML PATH('')
						),1,1,''
					)		
						
from
	AdventureWorks2019.Production.ProductSubcategory B


-- Pivoting lineTotal
select
	[Order Quantity] = OrderQty,
	Bikes,
	Accessories,
	Clothing,
	Components

from
	(
		select
			D.Name as ProductCategoryName,
			A.LineTotal,
			A.OrderQty

		from
			AdventureWorks2019.Sales.SalesOrderDetail A
			join AdventureWorks2019.Production.Product B
			on A.ProductID = B.ProductID

			join AdventureWorks2019.Production.ProductSubcategory C
			on B.ProductSubcategoryID = C.ProductSubcategoryID

			join AdventureWorks2019.Production.ProductCategory D
			on C.ProductCategoryID = D.ProductCategoryID
	) A

PIVOT(
sum(lineTotal)
for ProductCategoryName IN([Bikes],[Accessories],[Clothing],[Components])
) B

order by 1


-- Pivoting Avg vacationHours
select
	[Employee Gender] = gender,
	[Sales Representative], 
	[Buyer], 
	[Janitor]

from
	(
	select
		Jobtitle,
		vacationHours,
		Gender

	from
		AdventureWorks2019.HumanResources.Employee
	) A

pivot(
avg(vacationHours)
FOR JobTitle IN([Sales Representative], [Buyer], [Janitor])
) B 


-- Comparison between each month's total sum of top 10 orders against previous month's
With Sales as
(
	select
		OrderDate,
		TotalDue,
		OrderMonth = DATEFROMPARTS(year(OrderDate),month(OrderDate),1),
		OrderRank = ROW_NUMBER() over(partition by DATEFROMPARTS(year(OrderDate),month(OrderDate),1) order by TotalDue desc)

	from
		AdventureWorks2019.Sales.SalesOrderHeader
),
Top10 as
(
	select
		OrderMonth,
		Top10Total = SUM(TotalDue)

	from
		Sales

	where
		OrderRank <= 10

	Group by
		OrderMonth
)

select
	A.OrderMonth,
	A.Top10Total,
	B.Top10Total as PrevTop10Total
		
from 
	Top10 A
	Left join Top10 B
	on A.OrderMonth = DATEADD(MONTH,1,B.OrderMonth)

order by
	1


-- sum of sales AND purchases (minus the outliers which are top10 orders every month) listed side by side, by month
With Sales As
(
	select
		OrderDate,
		TotalDue,
		OrderMonth = DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1),
		OrderRank = ROW_NUMBER() Over( partition by DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1) order by TotalDue desc)

	from
		AdventureWorks2019.Sales.SalesOrderHeader
),
SaleMinusTop10 As
(
	select
		OrderMonth,
		TotalSales = sum(totalDue)

	from
		Sales

	where
		OrderRank > 10

	Group by
		OrderMonth
),
Purchases As
(
	select
		OrderDate,
		TotalDue,
		OrderMonth = DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1),
		OrderRank = ROW_NUMBER() Over( partition by DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1) order by TotalDue desc)

	from
		AdventureWorks2019.Purchasing.PurchaseOrderHeader
),
PurchasesMinusTop10 As
(
	select
		OrderMonth,
		TotalPurchases = Sum(TotalDue)

	from
		Purchases

	where
		OrderRank > 10

	group by
		OrderMonth
)
select
	A.OrderMonth,
	A.TotalSales,
	B.TotalPurchases

from 
	SaleMinusTop10 A
	join PurchasesMinusTop10 B
	on A.OrderMonth = B.OrderMonth

Order By 1


-- Generating Date Series

With DateSeries As
(
	select 
		CAST('01-01-2022' as date) As MyDate

	Union all

	select
		DATEADD(DAY,1,MyDate)

	from
		DateSeries

	where
		MyDate < CAST('12-31-2022' as date)
)
select
	MyDate

from 
	DateSeries

OPTION(MAXRECURSION 365)


-- Recursive FirstDayofMonth
With FirstDayofMonth As
(
	select
		CAST('01-01-2020' as date) as MyDate

	union all

	select
		DATEADD(MONTH,1, MyDate)
	from
		FirstDayofMonth
	where
		MyDate < CAST('12-01-2029' as date)
)

select
	MyDate
from 
	FirstDayofMonth
Option(MAXRECURSION 120)


-- Temp Tables for EDA purposes "Current Month vs PrevMonth #Top10Sales"
Create Table #Sales
(
	OrderDate Date,
	OrderMonth Date,
	TotalDue Money,
	OrderRank Int
)

Insert Into #Sales
(
	OrderDate,
	OrderMonth,
	TotalDue,
	OrderRank
)
select
	OrderDate,
	OrderMonth = DATEFROMPARTS(year(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() Over( Partition by DATEFROMPARTS(year(OrderDate),MONTH(OrderDate),1) order by TotalDue desc)

from
	AdventureWorks2019.Sales.SalesOrderHeader


Create Table #Top10Sales
(
	OrderMonth Date,
	Top10Total Money

)

Insert Into #Top10Sales
(
	OrderMonth,
	Top10Total

)
select
	OrderMonth,
	Top10Total = SUM(totalDue)
from
	#Sales
where
	OrderRank <= 10
group by
	OrderMonth
	select * from #Top10Sales


select
	A.OrderMonth,
	A.Top10Total,
	B.Top10Total As PrevTop10Total

from  
	#Top10Sales A
	Left Join #Top10Sales B
	on A.OrderMonth = DATEADD(Month, 1, B.OrderMonth)

order by
	1


select 
	* 
from 
	#Sales 
where 
	OrderRank <= 10

DROP TABLE #Sales
DROP TABLE #Top10Sales


-- Temp Tables for EDA purposes "Total Sales & Purchases, Excluding Top10"
select
	OrderDate,
	TotalDue,
	OrderMonth = DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1),
	OrderRank = ROW_NUMBER() Over( partition by DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1) order by TotalDue desc)

INTO #Sales
from
	AdventureWorks2019.Sales.SalesOrderHeader


select
	OrderMonth,
	TotalSales = sum(totalDue)

INTO #SaleMinusTop10
from
	#Sales

where
	OrderRank > 10

Group by
	OrderMonth


select
	OrderDate,
	TotalDue,
	OrderMonth = DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1),
	OrderRank = ROW_NUMBER() Over( partition by DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1) order by TotalDue desc)

INTO #Purchases

from
	AdventureWorks2019.Purchasing.PurchaseOrderHeader


select
	OrderMonth,
	TotalPurchases = Sum(TotalDue)
	
INTO #PurchasesMinusTop10

from
	#Purchases

where
	OrderRank > 10

group by
	OrderMonth


select
	A.OrderMonth,
	A.TotalSales,
	B.TotalPurchases

from 
	#SaleMinusTop10 A
	join #PurchasesMinusTop10 B
	on A.OrderMonth = B.OrderMonth

Order By 1

DROP TABLE #Sales
DROP TABLE #SaleMinusTop10
DROP TABLE #Purchases
DROP TABLE #PurchasesMinusTop10


-- Temp Tables for EDA purposes #Top10Orders
Create Table #Orders
(
	OrderDate Date,
	TotalDue Money,
	OrderMonth Date,
	OrderRank Int
)

Insert Into #Orders
(
	OrderDate,
	TotalDue,
	OrderMonth,
	OrderRank
)
select
	OrderDate,
	TotalDue,
	OrderMonth = DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1),
	OrderRank = ROW_NUMBER() Over( partition by DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1) order by TotalDue desc)
from
	AdventureWorks2019.Sales.SalesOrderHeader
----
Create Table #Top10Orders
(
	OrderMonth Date,
	OrderType Varchar(32),
	Top10Orders Money
)

Insert Into #Top10Orders
(
	OrderMonth,
	OrderType,
	Top10Orders
)
select
	OrderMonth,
	OrderType = 'Sales',
	Top10Orders = sum(totalDue)
from
	#Orders
where
	OrderRank <= 10
Group by
	OrderMonth

----

Truncate Table #orders

Insert Into #Orders
(
	OrderDate,
	TotalDue,
	OrderMonth,
	OrderRank
)
select
	OrderDate,
	TotalDue,
	OrderMonth = DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1),
	OrderRank = ROW_NUMBER() Over( partition by DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1) order by TotalDue desc)

from
	AdventureWorks2019.Purchasing.PurchaseOrderHeader
----
Insert Into #Top10Orders
(
	OrderMonth,
	OrderType,
	Top10Orders
)

select
	OrderMonth,
	OrderType = 'Purchases',
	Top10Orders = Sum(TotalDue)
from
	#Orders
where
	OrderRank <= 10
group by
	OrderMonth
	select * from #Top10Orders
----
select
	A.OrderMonth,
	A.OrderType,
	A.Top10Orders,
	B.Top10Orders as PrevTop10Ttoal

from 
	#Top10Orders A
	Left join #Top10Orders B
	on A.OrderMonth = DATEADD(month, 1, B.OrderMonth)
	And A.OrderType = B.OrderType

Order By 1,2

DROP TABLE #Orders
DROP TABLE #Top10Orders


-- Temp Tables for EDA purposes ##OrdersMinusTop10
Create Table #Orders
(
	OrderDate Date,
	OrderMonth Date,
	TotalDue Money,
	OrderRank Int
)

Insert Into #Orders --Insert sales data:
(
	OrderDate,
	OrderMonth,
	TotalDue,
	OrderRank
)
select
	OrderDate,
	OrderMonth = DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() Over( partition by DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1) order by TotalDue desc)
from
	AdventureWorks2019.Sales.SalesOrderHeader --sales data



Create Table #OrdersMinusTop10
(
	OrderMonth Date,
	OrderType Varchar(32),
	TotalDue Money
)


Insert Into #OrdersMinusTop10 --Insert sales data:
(
	OrderMonth,
	OrderType,
	TotalDue
)
select
	OrderMonth,
	OrderType = 'Sales', 
	TotalDue = sum(totalDue)
from
	#Orders
where
	OrderRank > 10
Group by
	OrderMonth


Truncate Table #Orders --Empty out #Orders table


Insert Into #Orders --Insert purchase data:
(
	OrderDate,
	OrderMonth,
	TotalDue,
	OrderRank
)
select
	OrderDate,
	OrderMonth = DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() Over( partition by DATEFROMPARTS(year(OrderDate), MONTH(OrderDate),1) order by TotalDue desc)

from
	AdventureWorks2019.Purchasing.PurchaseOrderHeader  --purchase data


Insert Into #OrdersMinusTop10 --Insert purchase data:
(
	OrderMonth,
	OrderType,
	TotalDue
)

select
	OrderMonth,
	OrderType = 'Purchase',
	TotalDue = Sum(TotalDue)
from
	#Orders
where
	OrderRank > 10
group by
	OrderMonth


select
	A.OrderMonth,
	TotalSales = A.TotalDue,
	TotalPurchases = B.TotalDue

from 
	#OrdersMinusTop10 A
	join #OrdersMinusTop10 B
	on A.OrderMonth = B.OrderMonth
	And B.OrderType = 'Purchase'

where A.OrderType = 'Sales'

Order By 1

DROP TABLE #Orders
DROP TABLE #OrdersMinusTop10


-- Updating Temp Tables if needed based on "Holiday vs Non-Holiday"
Create Table #SalesOrders
(
	SalesOrderID Int,
	OrderDate Date,
	TaxAmt Money,
	Freight Money,
	TotalDue Money,
	TaxFreightPercent Float,
	TaxFreightBucket Varchar(32),
	OrderAmtBucket Varchar(32),
	OrderCategory Varchar(32),
	OrderSubcategory Varchar(32)
)

Insert Into #SalesOrders
(
	SalesOrderID,
	OrderDate,
	TaxAmt,
	Freight,
	TotalDue,
	OrderCategory
)

Select
	SalesOrderID,
	OrderDate,
	TaxAmt,
	Freight,
	TotalDue,
	OrderCategory = 'Non-holiday Order'
from
	AdventureWorks2019.Sales.SalesOrderHeader
where
	YEAR(OrderDate) = 2013


Update #SalesOrders
SET TaxFreightPercent = ((TaxAmt + Freight)/TotalDue ) * 100,
OrderAmtBucket = 
	CASE
		when TotalDue < 100 then 'Small'
		When TotalDue < 1000 then 'Medium'
		Else 'Large'
	End


Update #SalesOrders
SET TaxFreightBucket = 
	CASE
		when TaxFreightPercent < 10 then 'Small'
		when TaxFreightPercent < 20 then 'Medium'
		Else 'Large'
	End


Update #SalesOrders
SET OrderCategory = 'Holiday'
Where DATEPART(Quarter, OrderDate) = 4

Drop table #SalesOrders


-- Updating Temp Tables if needed based on "CONCAT OrderCategory + OrderAmtBucket"
Update #SalesOrders
SET OrderSubcategory = CONCAT(OrderCategory, ' - ', OrderAmtBucket)

SELECT * FROM #SalesOrders

DROP TABLE #SalesOrders


-- Optimizing Data when needed
Create Table #Sales2012
(
	SalesOrderID Int,
	OrderDate Date
)

Insert into #Sales2012
(
	SalesOrderID,
	OrderDate
)

Select
	SalesOrderID,
	OrderDate
from 
	AdventureWorks2019.Sales.SalesOrderHeader
where
	YEAR(OrderDate) = 2012


Create Table #ProductSold2012 	-- Creating a master temp table for Data Optimization purposes
(
	SalesOrderID Int,
	OrderDate Date,
	LineTotal Money,
	ProductID Int,
	ProductName Varchar(64),
	ProductSubcategoryID Int,
	ProductSubcategory Varchar(64),
	ProductCategoryID Int,
	ProductCategory Varchar(64)
)

Insert Into #ProductSold2012
(
	SalesOrderID,
	OrderDate,
	LineTotal,
	ProductID
)

Select
	A.SalesOrderID,
	A.OrderDate,
	B.LineTotal,
	B.ProductID
from
	#Sales2012 A
	join AdventureWorks2019.Sales.SalesOrderDetail B
	on A.SalesOrderID = B.SalesOrderID


Update A
SET ProductName = B.Name,
	ProductSubcategoryID = B.ProductSubcategoryID
from #ProductSold2012 A
join AdventureWorks2019.Production.Product B
on A.ProductID = B.ProductID


Update A
SET ProductSubcategory = B.Name,
	ProductCategoryID = B.ProductCategoryID
from #ProductSold2012 A
join AdventureWorks2019.Production.ProductSubcategory B
on A.ProductSubcategoryID = B.ProductSubcategoryID


Update A
SET ProductCategory = B.Name
from #ProductSold2012 A
join AdventureWorks2019.Production.ProductCategory B
on A.ProductCategoryID = B.ProductCategoryID


select * from #ProductSold2012

Drop table #ProductSold2012
Drop table #Sales2012


-- Data Optimization #PersonContactInfo
Create Table #PersonContactInfo
(
	BusinessEntityID Int,
	Title Varchar(8),
	FirstName Varchar(50),
	MiddleName Varchar(50),
	LastName Varchar(50),
	PhoneNumber Varchar(50),
	PhoneNumberTypeID Varchar(25),
	PhoneNumberType Varchar(50),
	EmailAddress Varchar(50)
)

Insert Into #PersonContactInfo
(
	BusinessEntityID,
	Title,
	FirstName,
	MiddleName,
	LastName
)

select
	BusinessEntityID,
	Title,
	FirstName,
	MiddleName,
	LastName
from 
	AdventureWorks2019.Person.Person


Update #PersonContactInfo
SET PhoneNumber = B.phoneNumber,
	PhoneNumberTypeID = B.PhoneNumberTypeID
from #PersonContactInfo A
join AdventureWorks2019.Person.PersonPhone B
on A.BusinessEntityID = B.BusinessEntityID


Update #PersonContactInfo
SET PhoneNumberType = B.Name
from #PersonContactInfo A
join AdventureWorks2019.Person.PhoneNumberType B
on A.PhoneNumberTypeID = B.PhoneNumberTypeID


Update #PersonContactInfo
SET EmailAddress = B.EmailAddress
from #PersonContactInfo A
join AdventureWorks2019.Person.EmailAddress B
on A.BusinessEntityID = B.BusinessEntityID


select * from #PersonContactInfo

Drop Table #PersonContactInfo


-- Lookup Tables "Creating a Calendar Table"
Create Table AdventureWorks2019.dbo.Calendar
(
DateValue Date,
DayOfWeekNumber int,
DayOfWeekName Varchar(32),
DayOfMonthNumber int,
MonthNumber int,
YearNumber int,
WeekendFlag tinyint,
HolidayFlag tinyint
)

With Dates As
(
select
	Cast('01-01-2011' as Date) as MyDate
Union All
select
	DATEADD(DAY,1,MyDate)
from
	Dates
Where
	MyDate < Cast('12-31-2030' as Date)
)

Insert Into AdventureWorks2019.dbo.Calendar
(
DateValue
)

Select
	MyDate
from
	Dates
Option (Maxrecursion 10000)


Update AdventureWorks2019.dbo.Calendar
SET 
DayOfWeekNumber = DATEPART(WEEKDAY,DateValue),
DayOfWeekName = FORMAT(DateValue,'dddd'),
DayOfMonthNumber = DAY(DateValue),
MonthNumber = MONTH(DateValue),
YearNumber = YEAR(DateValue)


Update AdventureWorks2019.dbo.Calendar
SET
WeekendFlag =
	Case
		when DayOfWeekName IN ('Saturday', 'Sunday') then 1
		else 0
	End


Update AdventureWorks2019.dbo.Calendar
SET
HolidayFlag =
	Case
		when DayOfMonthNumber = 1 and MonthNumber = 1 then 1
		else 0
	End

select * from AdventureWorks2019.dbo.Calendar


select 
	A.*
from
	AdventureWorks2019.Sales.SalesOrderHeader A
	join AdventureWorks2019.dbo.Calendar B
	on A.OrderDate = B.DateValue
where
	B.WeekendFlag = 1


-- Variable #1 "getting data for previous month"
Declare @Today Date = Cast(Getdate() as Date)
Declare @BOM Date = Datefromparts(year(@Today), month(@Today), 1)
Declare @PrevBOM Date = Dateadd(Month,-1, @BOM)
Declare @PrevEOM Date = Dateadd(Day, -1, @BOM)

Select
	*
from
	AdventureWorks2019.dbo.Calendar
where
	DateValue between @PrevBOM and @PrevEOM