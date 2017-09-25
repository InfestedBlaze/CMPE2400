--ica05
--Nic Wasylyshyn

--use NorthwindTraders
--go

--q1
select * from Customers
go

--q2
select
	CustomerID as 'Customer ID',
	CompanyName as 'Company Name',
	ContactName as 'Contact Name',
	City
from Customers
go

--q3
select
	OrderID as 'Order ID',
	ShipName as 'Ship Name',
	OrderDate as 'Order Date',
	ShipRegion as 'Ship Region'
from Orders
where ShippedDate is null and ShipRegion is not null
go

--q4
select
	ProductName as 'Product Name',
	UnitPrice as 'Unit Price',
	UnitsInStock as 'Units in Stock'
from Products
where UnitsOnOrder < 11 and UnitsInStock < 10
go

--q5
select
	CompanyName as 'Company Name',
	City,
	Address
from Customers
where Country in ('Argentina', 'Bolivia', 'Brazil', 'Chile', 'Columbia', 'Ecuador', 'Guyana', 'Paraguay', 'Peru', 'Suriname', 'Uruguay', 'Venezuela')
	and ContactTitle in('Owner', 'Sales Agent')
go

--q6
select
	ProductName as 'Product Name',
	QuantityPerUnit as 'Quantity Per Unit',
	UnitPrice as 'Unit Price'
from Products
where CategoryID not in(1, 8) and (QuantityPerUnit like '%bottles%' or QuantityPerUnit like '%jars%')
go

--q7
select
	ProductName as 'Product Name',
	UnitPrice as 'Unit Price',
	UnitsInStock as 'Units in Stock',
	UnitPrice * UnitsInStock as 'Inventory Value'
from Products
where UnitPrice * UnitsInStock < 100 and Discontinued <> 1
go