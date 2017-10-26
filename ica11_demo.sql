--aggregate demo

use PublishersDatabase
go

--start with all, then use expression, then summarize
select 
	sum( t.price * s.qty) as 'sum()',
	sum(t.price) * sum(s.qty) as 'sum2()' --probably not what we want
from titles as t
	inner join sales as s
	on t.title_id = s.title_id
go

--rolled up by title, watch for additional select list items
--polluting our rollup (group by)
select 
	t.title as 'Title',
	sum( t.price * s.qty) as 'sum()'
from titles as t
	inner join sales as s
	on t.title_id = s.title_id
group by t.title
go

--All publisher, any titles and any sales of those
select 
	p.pub_name as 'Publisher',
	t.title as 'Title',
	sum(t.price * s.qty) as 'Sales Value',
	count(s.title_id) as 'Num Sales Records'
	--avg(t.price * s.qty) as 'Average'
from publishers as p
	left outer join titles as t
	on p.pub_id = t.pub_id
		left outer join sales as s
		on t.title_id = s.title_id
where s.qty > 5 -- before rollup, include only if qty > 5
group by p.pub_name, t.title
having count(s.title_id) > 1
order by Publisher, Title
go

--All publisher, any titles and any 0 based sales of those, no exclusions in rollup
select 
	p.pub_name as 'Publisher',
	sum(coalesce(t.price,0) * coalesce(s.qty, 0)) as 'Sales Value'
from publishers as p
	left outer join titles as t
	on p.pub_id = t.pub_id
		left outer join sales as s
		on t.title_id = s.title_id
--where s.qty > 5 -- before rollup, include only if qty > 5
group by p.pub_name
having avg(coalesce(t.price,0) * coalesce(s.qty, 0)) > 300
order by Publisher
go