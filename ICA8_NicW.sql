
--ica 08
--Nic Wasylyshyn

--use NorthwindTraders
--go

--q1
select top 1
	CompanyName as 'Supplier Company Name',
	Country
from Suppliers
order by Country
go

--q2
select top 1 with ties
	CompanyName as 'Supplier Company Name',
	Country
from Suppliers
order by Country
go

--q3
select top 10 percent
	ProductName as 'Product Name',
	UnitsInStock as 'Units in Stock'
from Products
order by UnitsInStock desc
go

--q4
select
	CompanyName as 'Customer Company Name',
	Country
from Customers
where CustomerID in (
	select top 8 CustomerID
	from Orders
	order by Freight desc
)
go

--q5
select
	CustomerID,
	OrderID,
	format(OrderDate, 'dd MMM yyyy') as 'Order Date'
from Orders
where OrderID in (
	select top 3 OrderID
	from [Order Details]
	order by Quantity desc
)
go

--q6
select
	CustomerID,
	OrderID,
	format(OrderDate, 'dd MMM yyyy') as 'Order Date'
from Orders
where OrderID in (
	select top 3 with ties OrderID
	from [Order Details]
	order by Quantity desc
)
go

--q7
select
	CompanyName as 'Supplier Company Name',
	Country
from Suppliers
where SupplierID in (
	select SupplierID
	from Products
	where ProductID in (
		select top 1 percent ProductID
		from [Order Details]
		order by UnitPrice * Quantity desc
	)
)
go