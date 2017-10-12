--Ica 09 demo
--Joins

use PublishersDatabase
go

select pub_name, p.pub_id, t.pub_id, title
from 
	publishers as p inner join titles as t
	on p.pub_id = t.pub_id
where 
	t.type like 'business'
order by p.pub_id
go

select 
	a.au_id as 'Author ID', 
	a.au_lname as 'Last Name',
	t.title
from 
	authors as a inner join titleauthor as ta
	on a.au_id = ta.au_id
		inner join titles as t
		on t.title_id = ta.title_id
where t.price < $10.00 and title like 'T%'
order by a.au_id
go

select 
	a.au_fname + ' ' +a.au_lname as 'Author',
	title,
	st.stor_name as 'Store Name'
from 
	authors as a 
	inner join titleauthor as ta
	on a.au_id = ta.au_id
		inner join titles as t
		on ta.title_id = t.title_id
			inner join sales as s
			on s.title_id = t.title_id
				inner join stores as st
				on st.stor_id = s.stor_id
where
	ord_date > '1 Jan 1990' and-- implicit conversion from string to date
	s.qty > 40
order by Author