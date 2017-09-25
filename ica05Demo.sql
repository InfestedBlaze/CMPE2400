-- ica05Demo.sql
--use NorthwindTraders
--go
-- basic * (all) select
select * from titles
go
-- is null
select 
	title_id,
	title,
	advance
from titles
where advance is null and price <> 20
go
-- is not, bool or/and 
select title_id, title, price, advance
from titles
where advance is not null and price <> 20
go
-- add and/or comboselect title_id, title, price, advance
select title_id, title, price, advance
from titles
where advance is not null and price < 10 or price > 20
go

-- combo with precedence
select title, price * 100 as 'Pennies' -- , royalty add when debugging
from titles
where price > 20 and ( royalty > 15  or title like '%it%' )
go

-- in operator
declare @unknown as nvarchar(max) = 'undecided'
select title, type
from titles
where type in ('business', 'mod_cook', @unknown )
go

-- convert on select list items
select
	cast( title as char(10)) as 'Title',
	price,
	'$' + convert( nvarchar(12), price ) as 'Actual Cost',
	'Your cost is : $' + convert( nvarchar(12), price * 2.3 ) as 'User Cost',
	'Your cost is : $' + convert( nvarchar(12), cast(price * 2.3 as money)) as 'Formatted Cost'
from titles