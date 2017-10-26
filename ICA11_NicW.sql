--ica 11

--use NorthwindTraders
--use

--q1
select 
	e.LastName + ', ' + e.FirstName as 'Name',
	count(o.OrderID) as 'Num Orders'
from Employees as e
	inner join Orders as o
	on e.EmployeeID = o.EmployeeID
group by e.LastName, e.FirstName
order by [Num Orders] desc
go

--q2
select 
	e.LastName + ', ' + e.FirstName as 'Name',
	AVG(o.Freight) as 'Average Freight',
	convert(varchar(11), MAX(o.OrderDate), 106) as 'Newest Order Date'
from Employees as e
	inner join Orders as o
	on e.EmployeeID = o.EmployeeID
group by e.LastName, e.FirstName
order by  MAX(o.OrderDate), e.LastName
go

--q3
select 
	s.CompanyName as 'Supplier',
	s.Country,
	count(p.ProductID) as 'Num Products',
	avg(p.UnitPrice) as 'Avg Price'
from Suppliers as s
	left outer join Products as p
	on s.SupplierID = p.SupplierID
where s.CompanyName like '[HURT]%'
group by s.CompanyName, s.Country
order by [Num Products]
go

--q4
select 
	s.CompanyName as 'Supplier',
	s.Country,
	MIN(coalesce(p.UnitPrice, 0)) as 'Min Price',
	MAX(coalesce(p.UnitPrice, 0)) as 'Max Price'
from Suppliers as s
	left outer join Products as p
	on s.SupplierID = p.SupplierID
where s.Country like 'USA'
group by s.CompanyName, s.Country
order by [Min Price]
go

--q5
select 
	c.CompanyName as 'Customer',
	c.City,
	convert(nvarchar(15),o.OrderDate, 106) as 'Order Date',
	count(od.OrderID) as 'Products in Order'
from Customers as c
	left outer join Orders as o
	on c.CustomerID = o.CustomerID
		left outer join [Order Details] as od
		on o.OrderID = od.OrderID
where c.City like 'Walla Walla' or c.Country like 'Poland'
group by c.CompanyName, c.City, o.OrderDate
order by [Products in Order]
go

--q6
select 
	e.LastName + ', ' + e.FirstName as 'Name',
	cast(sum(od.UnitPrice * od.Quantity) as money) as 'Sales Total',
	count(od.OrderID) as 'Detail Items'
from Employees as e
	left outer join Orders as o
	on e.EmployeeID = o.EmployeeID
		left outer join [Order Details] as od
		on o.OrderID = od.OrderID
group by e.LastName, e.FirstName
order by [Sales Total] desc
go