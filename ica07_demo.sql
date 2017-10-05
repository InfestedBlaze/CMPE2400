--demo subquery
--Nic Wasylyshyn

use PublishersDatabase
go

--q1 - titles and books with sales from may
select
	title,
	price
from titles
where title_id in (
	select 
		distinct title_id
	from sales
	where datepart(M, ord_date) = 5 -- May is month 5
)
go

--q2 - single nested with in and top
--Want title and price of top 3 selling book
select
	title,
	price
from titles
where title_id in(
	select top(3)
		title_id as 'Title ID'
	from sales
	order by qty desc
)
order by 1 -- Ordered by select list item 1 (title)
go

--q3 - three nested queries, simple subquery
--Get title, price for books written by authors in Utah and Oregon
select
	title,
	price
from titles
where title_id in (
	select
		distinct title_id
	from titleauthor
	where au_id in (
		select
			au_id
		from authors
		where state in ('OR', 'UT')
	)
)
order by title
go

--q4 - title stuff for books with any sales - any usually implies EXISTS
select
	title,
	price
from titles as outerTable --alias the outer table
where exists (
	select title_id
	from sales as innerTable --alias the inner table
	where innerTable.title_id = outerTable.title_id-- use alias for all common fields
)
go

--q5 - stores that don't have any sales from 1993
--select ord_date from sales
select
	stor_name,
	state
from stores as outerTable
where not exists(
	select *
	from sales as innerTable
	where innerTable.stor_id = outerTable.stor_id and
		  DATEPART(yy, ord_date) = 1993
)