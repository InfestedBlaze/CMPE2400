--Nic Wasylyshyn
--ICA 10

--use NorthwindTraders
--go

--q1
select 
	CompanyName as 'Company Name',
	ProductName as 'Product Name',
	UnitPrice as 'Unit Price'
from Suppliers as s
	left outer join Products as P
	on s.SupplierID = P.SupplierID
order by [Company Name], [Product Name]
go

--q2
select 
	CompanyName as 'Company Name',
	ProductName as 'Product Name',
	UnitPrice as 'Unit Price'
from Suppliers as s
	left outer join Products as P
	on s.SupplierID = P.SupplierID
where ProductName is null
order by [Company Name], [Product Name]
go

--q3
select 
	LastName +', '+ FirstName as 'Name',
	OrderDate as 'Order Date'
from Employees as e
	left outer join Orders as o
	on e.EmployeeID = o.EmployeeID
where OrderDate is null
go

--q4
select top(5)
	ProductName as 'Product Name',
	Quantity
from Products as p
	left outer join [Order Details] as od
	on p.ProductID = od.ProductID
order by Quantity
go

--q5
select top(10)
	CompanyName as 'Company',
	ProductName as 'Product',
	Quantity
from Suppliers as s
	left outer join Products as p
	on s.SupplierID = p.SupplierID
		left outer join [Order Details] as od
		on p.ProductID = od.ProductID
order by Quantity
go

--q6
	select CompanyName as 'Customer/Supplier with Nothing'
	from Customers
		left outer join Orders
		on Customers.CustomerID = Orders.CustomerID
		where Orders.CustomerID is null
union
	select CompanyName as 'Customer/Supplier with Nothing'
	from Suppliers 
		left outer join Products
		on Suppliers.SupplierID = Products.SupplierID
		where Products.SupplierID is null
order by CompanyName
go

--q7
	select 'Customer' as 'Type', CompanyName as 'Customer/Supplier with Nothing'
	from Customers
		left outer join Orders
		on Customers.CustomerID = Orders.CustomerID
		where Orders.CustomerID is null
union
	select 'Supplier' as 'Type', CompanyName as 'Customer/Supplier with Nothing'
	from Suppliers 
		left outer join Products
		on Suppliers.SupplierID = Products.SupplierID
		where Products.SupplierID is null
order by [Type], CompanyName desc
go