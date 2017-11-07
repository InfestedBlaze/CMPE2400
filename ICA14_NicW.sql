--ICA 14
--Nic Wasylyshyn

--q1
if exists(
	select *
	from sysobjects
	where name like 'ica14_01'
)
	drop procedure ica14_01
go

create procedure ica14_01
@Type as nvarchar(20),
@Name as nvarchar(20) output,
@Quantity as int output
as
	select top(1)
		@Name = p.ProductName,
		@Quantity = od.Quantity
	from NorthwindTraders.dbo.Products as p
		left outer join NorthwindTraders.dbo.[Order Details] as od
		on p.ProductID = od.ProductID
		left outer join NorthwindTraders.dbo.Categories as c
		on p.CategoryID = c.CategoryID
	where c.CategoryName like @Type
	order by Quantity desc
go

--Exec 1
declare @ProdType as nvarchar(20) = 'Beverages',
		@ProdName as nvarchar(20),
		@TopQuantity as int

exec ica14_01 @ProdType, @ProdName output, @TopQuantity output
select	@ProdType as 'Category',
		@ProdName as 'ProductName', 
	    @TopQuantity as 'Highest Qty'

--Exec 2
set @ProdType = 'Confections'

exec ica14_01 @Type = @ProdType, @Name = @ProdName output, @Quantity = @TopQuantity output
select	@ProdType as 'Category',
		@ProdName as 'ProductName', 
	    @TopQuantity as 'Highest Qty'
go



















--q2
if exists(
	select *
	from sysobjects
	where name like 'ica14_02'
)
	drop procedure ica14_02
go

create procedure ica14_02
@Year as int,
@Name as nvarchar(64) output,
@AvgFreight as money output
as
	select top(1)
		@Name = e.LastName + ', ' + e.FirstName,
		@AvgFreight = avg(o.Freight)
	from NorthwindTraders.dbo.Employees as e
		inner join NorthwindTraders.dbo.Orders as o
		on e.EmployeeID = o.EmployeeID
	where datepart(year, o.OrderDate) like @Year
	group by e.LastName, e.FirstName
	order by avg(o.Freight) desc
	
go

declare @myYear as int = 1996,
		@name as nvarchar(64),
		@freight as money
exec ica14_02 @myYear, @name output, @freight output
select
	@myYear as 'Year',
	@name as 'Name',
	@freight as 'Biggest Avg Freight' 

set @myYear = 1997
exec ica14_02 @Year = @myYear, @Name = @name output, @AvgFreight = @freight output
select
	@myYear as 'Year',
	@name as 'Name',
	@freight as 'Biggest Avg Freight' 




















--q3
if exists(
	select *
	from sysobjects
	where name like 'ica14_03'
)
	drop procedure ica14_03
go

create procedure ica14_03
as
	
go

exec ica14_03
go















--q4
if exists(
	select *
	from sysobjects
	where name like 'ica14_04'
)
	drop procedure ica14_04
go

create procedure ica14_04
as
	
go

exec ica14_04
go

















--q5
if exists(
	select *
	from sysobjects
	where name like 'ica14_05'
)
	drop procedure ica14_05
go

create procedure ica14_05
as
	
go

exec ica14_05
go