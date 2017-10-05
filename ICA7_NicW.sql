--Nic Wasylyshyn
--Ica 07

--use NorthWindTraders
--go

--q1
declare @freight as int = 800;
select 
	LastName as 'Last Name',
	Title
from Employees
where EmployeeID in (
	select EmployeeID
	from Orders
	where Freight > @freight
)
order by [Last Name]
go

--q2
declare @freight as int = 800;
select 
	LastName as 'Last Name',
	Title
from Employees as outerTable
where exists(
	select 
		EmployeeID
	from Orders as innerTable
	where Freight > @freight and 
		  outerTable.EmployeeID = innerTable.EmployeeID
)
order by [Last Name]
go

--q3
select
	ProductName as 'Product Name',
	UnitPrice as 'Unit Price'
from Products
where SupplierID in (
	select SupplierID
	from Suppliers
	where Country in ('Sweden', 'Italy')
)
order by [Unit Price]
go

--q4
select
	ProductName as 'Product Name',
	UnitPrice as 'Unit Price'
from Products as outerTable
where exists (
	select SupplierID
	from Suppliers as innerTable
	where Country in ('Sweden', 'Italy') and 
		  innerTable.SupplierID = outerTable.SupplierID
)
order by [Unit Price]
go

--q5
declare @price as int = 20
select ProductName 
from Products
where CategoryID in (
	select CategoryID
	from Categories
	where CategoryName in ('Confections', 'Seafood') and
		  UnitPrice > @price
)
order by CategoryID, ProductName
go

--q6
declare @price as int = 20
select ProductName 
from Products as outerTable
where exists (
	select CategoryID
	from Categories as innerTable
	where CategoryName in ('Confections', 'Seafood') and
		  UnitPrice > @price and
		  innerTable.CategoryID = outerTable.CategoryID
)
order by CategoryID, ProductName
go

--q7
declare @PriceMax as int = 15
select
	CompanyName as 'Company Name',
	Country
from Customers
where CustomerID in (
	select CustomerID
	from Orders
	where OrderID in (
		select OrderID
		from [Order Details]
		where UnitPrice * Quantity < @PriceMax
	)
)
order by Country
go

--q8
declare @PriceMax as int = 15
select
	CompanyName as 'Company Name',
	Country
from Customers as outShell
where exists (
	select CustomerID
	from Orders as midShell
	where outShell.CustomerID = midShell.CustomerID and 
	exists (
		select OrderID
		from [Order Details] as botShell
		where midShell.OrderID = botShell.OrderID and
			UnitPrice * Quantity < @PriceMax
	)
)
order by Country
go

--q9
declare @date as int = 7
select
	ProductName
from Products
where ProductID in (
	select ProductID
	from [Order Details]
	where OrderID in (
		select OrderID
		from Orders
		where DATEDIFF(d, RequiredDate, ShippedDate) > 7
			and CustomerID in (
				select CustomerID
				from Customers
				where Country in ('UK', 'USA')
			  )
	)
)
order by ProductName
go

--q10
select
	OrderID,
	ShipCity
from Orders as outTable
where OrderID in(
	select OrderID
	from [Order Details]
	where ProductID in (
		select ProductID
		from Products
		where SupplierID in (
			select SupplierID
			from Suppliers as inTable
			where outTable.ShipCity = inTable.City
		)
	)
)
order by ShipCity
go