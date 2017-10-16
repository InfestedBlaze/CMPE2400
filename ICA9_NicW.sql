--Nic Wasylyshyn
--Ica 9

--use NorthwindsTraders
--go

--q1
declare @country as nvarchar(3) = 'USA'
select
	s.CompanyName as 'Company Name',
	p.ProductName as 'Product Name',
	p.UnitPrice as 'Unit Price'
from Suppliers as s 
	inner join Products as p
	on s.SupplierID = p.SupplierID
where s.Country like @country
order by s.CompanyName, p.ProductName
go

--q2
declare @includes as nvarchar(2) = 'ul'
select 
	e.LastName + ', ' + e.FirstName as 'Name',
	t.TerritoryDescription as 'Territory Desription'
from Employees as e
	inner join EmployeeTerritories as et
	on e.EmployeeID = et.EmployeeID
		inner join Territories as t
		on t.TerritoryID = et.TerritoryID
where e.LastName like '%'+@includes+'%'
order by t.TerritoryDescription
go

--q3
declare @country as nvarchar(6) = 'Sweden'
select distinct
	o.CustomerID as 'Customer ID',
	p.ProductName as 'Product Name'
from Orders as o
	inner join [Order Details] as od
	on o.OrderID = od.OrderID
		inner join Products as p
		on od.ProductID = p.ProductID
where o.ShipCountry like @country and p.ProductName like '[U-Z]%'
order by p.ProductName
go

--q4
declare @minPrice as money = 69
select distinct
	c.CategoryName as 'Category Name',
	p.UnitPrice as 'Product Price',
	od.UnitPrice as 'Selling Price'
from Categories as c
	inner join Products as p
	on c.CategoryID = p.CategoryID
		inner join [Order Details] as od
		on p.ProductID = od.ProductID
where p.UnitPrice <> od.UnitPrice and od.UnitPrice > @minPrice
order by [Selling Price]
go

--q5
declare @date as int = 34
select 
	o.ShipName as 'Shipper',
	p.ProductName as 'Product Name'
from Orders as o
	inner join [Order Details] as od
	on o.OrderID = od.OrderID
		inner join Products as p
		on od.ProductID = p.ProductID
where p.Discontinued = 1 and DATEDIFF(d, o.ShippedDate, o.RequiredDate) > @date
order by o.ShipName
go