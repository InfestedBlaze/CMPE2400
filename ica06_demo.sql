-- Demo ica06 - distinct, order by
use PublishersDatabase
go

-- d1 - between * Inclusive Range
select *
from titles
where price between 19 and 20
go

select *
from stores
where zip like '[0-9][68][0-9][0-9][6]' -- X 6or8 X X 6
-- '[A-Z]-[0-9][abc]'   match M-6a, 
go

-- d3 distinct
select distinct type, pub_id
from titles
go

-- d4 - template
select title, price, ytd_sales * price
from titles
where ytd_sales * price > 10000
go

-- by column name and expression
select title, price, ytd_sales * price
from titles
where ytd_sales * price > 10000
-- order by goes last
order by price, ytd_sales * price
go

-- column alias
select title, price, ytd_sales * price as 'Gross'
from titles
where ytd_sales * price > 10000
order by price desc, Gross
go

-- column heading 
select title, price, 'Gross Sales' = ytd_sales * price
from titles
where ytd_sales * price > 10000
order by [Gross Sales], price
go

-- select list item number
select title, price, ytd_sales * price
from titles
where ytd_sales * price > 10000
order by 1 desc, 3 asc
go
