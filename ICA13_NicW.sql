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
@class_id as int = 0
as
	select 
		at.ass_type_desc as 'Type',
		round(avg(res.score), 2) as 'Raw Avg',
		round(avg((res.score / req.max_score) * 100), 2) as 'Avg',
		count(res.score) as 'Num'
	from ClassTrak.dbo.Assignment_type as at
		left outer join ClassTrak.dbo.Requirements as req
		on at.ass_type_id = req.ass_type_id
			left outer join ClassTrak.dbo.Results as res
			on req.req_id = res.req_id
	where res.class_id like @class_id
	group by at.ass_type_desc
	order by at.ass_type_desc	
go

exec ica13_06 88
go
exec ica13_06 @class_id = 89
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
@year as int,
@minAvg as int = 50,
@minSize as int = 10
as
	select 
		cast(S.last_name + ', ' + S.first_name as nvarchar(24)) as 'Student',
		c.class_desc as 'Class',
		at.ass_type_desc as 'Type',
		count(res.req_id) as 'Submitted',
		round( avg((res.score / req.max_score) * 100), 1) as 'Avg'
	from ClassTrak.dbo.Students as s
		left outer join ClassTrak.dbo.Results as res
		on S.student_id = res.student_id
			left outer join ClassTrak.dbo.Classes as c
			on res.class_id = C.class_id

			left outer join ClassTrak.dbo.Requirements as req
			on res.req_id = req.req_id
				left outer join ClassTrak.dbo.Assignment_type as at
				on req.ass_type_id = at.ass_type_id
	where DATEPART(year, c.start_date) like @year 
		and res.score is not null
	group by s.last_name, s.first_name, c.class_desc, at.ass_type_desc
	having round( avg((res.score / req.max_score) * 100), 1) < @minAvg and
		 count(res.req_id) > @minSize
	order by Submitted	
go

exec ica13_07 @year=2011
go
exec ica13_07 @year=2011, @minAvg=40, @minSize=15
go