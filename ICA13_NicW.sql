--ica 13
--Nic Wasylyshyn

--q1
if exists(
	select *
	from sysobjects
	where name like 'ica13_01'
)
	drop procedure ica13_01
go

create procedure ica13_01
as
	select 
		e.LastName + ', ' + e.FirstName as 'Name',
		count(o.OrderID) as 'Num Orders'
	from NorthwindTraders.dbo.Employees as e
		inner join NorthwindTraders.dbo.Orders as o
		on e.EmployeeID = o.EmployeeID
	group by e.LastName, e.FirstName
	order by [Num Orders] desc
go

exec ica13_01
go

--q2
if exists(
	select *
	from sysobjects
	where name like 'ica13_02'
)
	drop procedure ica13_02
go

create procedure ica13_02
as
	select 
		e.LastName + ', ' + e.FirstName as 'Name',
		cast(sum(od.UnitPrice * od.Quantity) as money) as 'Sales Total',
		count(od.OrderID) as 'Detail Items'
	from NorthwindTraders.dbo.Employees as e
		left outer join NorthwindTraders.dbo.Orders as o
		on e.EmployeeID = o.EmployeeID
			left outer join NorthwindTraders.dbo.[Order Details] as od
			on o.OrderID = od.OrderID
	group by e.LastName, e.FirstName
	order by [Sales Total] desc
go

exec ica13_02
go

--q3
if exists(
	select *
	from sysobjects
	where name like 'ica13_03'
)
	drop procedure ica13_03
go

create procedure ica13_03
@maxPrice as money = null
as
	select
		CompanyName as 'Company Name',
		Country
	from NorthwindTraders.dbo.Customers
	where CustomerID in (
		select CustomerID
		from NorthwindTraders.dbo.Orders
		where OrderID in (
			select OrderID
			from NorthwindTraders.dbo.[Order Details]
			where UnitPrice * Quantity < @maxPrice
		)
	)
	order by Country
go

exec ica13_03 15
go

--q4
if exists(
	select *
	from sysobjects
	where name like 'ica13_04'
)
	drop procedure ica13_04
go

create procedure ica13_04
@minPrice as money = null,
@categoryName as nvarchar(max) = ''
as
	select ProductName 
	from NorthwindTraders.dbo.Products as outerTable
	where exists (
		select CategoryID
		from NorthwindTraders.dbo.Categories as innerTable
		where CategoryName like @categoryName and
			  UnitPrice > @minPrice and
			  innerTable.CategoryID = outerTable.CategoryID
	)
	order by CategoryID, ProductName
go

exec ica13_04 20, 'Confections'
go

--q5
if exists(
	select *
	from sysobjects
	where name like 'ica13_05'
)
	drop procedure ica13_05
go

create procedure ica13_05
@minPrice as money = null,
@country as nvarchar(max) = 'USA'
as
	select 
		s.CompanyName as 'Supplier',
		s.Country,
		MIN(coalesce(p.UnitPrice, 0)) as 'Min Price',
		MAX(coalesce(p.UnitPrice, 0)) as 'Max Price'
	from NorthwindTraders.dbo.Suppliers as s
		left outer join NorthwindTraders.dbo.Products as p
		on s.SupplierID = p.SupplierID
	where s.Country like @country
	group by s.CompanyName, s.Country
	having MIN(coalesce(p.UnitPrice, 0)) > @minPrice
	order by [Min Price]
go

exec ica13_05 15
go
exec ica13_05 @minPrice = 15
go
exec ica13_05 @minPrice = 5, @country = 'UK'
go

--q6
if exists(
	select *
	from sysobjects
	where name like 'ica13_06'
)
	drop procedure ica13_06
go

create procedure ica13_06
as
	
go

exec ica13_06
go

--q7
if exists(
	select *
	from sysobjects
	where name like 'ica13_07'
)
	drop procedure ica13_07
go

create procedure ica13_07
as
	
go

exec ica13_07
go