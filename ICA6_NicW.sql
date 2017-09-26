--Nic Wasylyshyn
--ica 06

--use NorthwindTraders
--go

--q1
declare @lowerBound as money = 17.45
declare @upperBound as money = 19.45
select
	ProductName as 'Product Name',
	UnitPrice as 'Unit Price'
from Products
where UnitPrice between @lowerBound and @upperBound
go

--q2
declare @lowerBound as int = 1150
declare @upperBound as int = 5000
select
	ProductName,
	UnitPrice as 'Unit Price',
	ReorderLevel as 'Reorder Level',
	ReorderLevel * UnitPrice as 'Reorder Cost'
from Products
where ReorderLevel * UnitPrice between @lowerBound and @upperBound
order by [Reorder Cost] asc
go

--q3
declare @string as nvarchar(max) = 'ade'
select
	ProductName as 'Product Name',
	QuantityPerUnit as 'Quantity Per Unit'
from Products
where ProductName like '%' + @string
order by [Product Name]
go

--q4
declare @discountMin as int = 1375
select
	UnitPrice as 'Unit Price',
	Quantity,
	Discount,
	UnitPrice * Quantity * Discount as 'Discount Value'
from [Order Details]
where UnitPrice * Quantity * Discount >= @discountMin
order by [Discount Value] desc
go

--q5
select
	Country,
	City,
	CompanyName as 'Company Name'
from Customers
where Phone like '([159][0-9][0-9])%'
order by Country asc, City asc
go

--q6
select
	CustomerID as 'Customer ID',
	OrderID as 'Order ID',
	DATEDIFF(day, RequiredDate, ShippedDate) as 'Delay Days'
from Orders
where CustomerID not like '[m-z]%' and DATEDIFF(day, RequiredDate, ShippedDate) > 7
order by [Delay Days] asc
go

--q7
select
	CompanyName as 'Company Name',
	City,
	PostalCode as 'Postal Code'
from Customers
where CompanyName not like '%s' and 
	  (PostalCode like '[a-z0-9][a-z0-9][a-z0-9] [a-z0-9][a-z0-9][a-z0-9]' or         --123 456
	   PostalCode like '[a-z0-9][a-z0-9][a-z0-9][a-z0-9] [a-z0-9][a-z0-9][a-z0-9]')   --1234 567
order by City asc
go

--q8
select distinct Discount
from [Order Details]
order by Discount desc
go

--q9
declare @maxValue as int = 20
select
	distinct ProductID,
	Quantity * UnitPrice * (1-Discount) as 'Value'
from [Order Details]
where Quantity * UnitPrice * (1-Discount) < @maxValue and
	round(Quantity * UnitPrice * (1-Discount), 0) = Quantity * UnitPrice * (1-Discount)
order by Value desc
go