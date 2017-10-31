--Nic W
--Ica 12

--use ClassTrak
--go

--q1
declare @number as int = 88
select 
	at.ass_type_desc as 'Type',
	avg(res.score) as 'Raw Avg',
	avg((res.score / req.max_score) * 100) as 'Avg',
	count(res.score) as 'Num'
from Assignment_type as at
	left outer join Requirements as req
	on at.ass_type_id = req.ass_type_id
		left outer join Results as res
		on req.req_id = res.req_id
where res.class_id like @number
group by at.ass_type_desc
order by at.ass_type_desc
go

--q2
declare @number as int = 88
select 
	req.ass_desc+ '('+at.ass_type_desc+')' as 'Desc(Type)',
	round(avg((res.score / req.max_score) * 100), 2) as 'Avg',
	count(res.req_id) as 'Num Score'
from Assignment_type as at
	left outer join Requirements as req
	on at.ass_type_id = req.ass_type_id
		left outer join Results as res
		on req.req_id = res.req_id
where res.class_id like @number
group by at.ass_type_desc,  req.ass_desc
having avg((res.score / req.max_score) * 100) > 57
order by req.ass_desc, at.ass_type_desc
go

--q3

go

--q4

go

--q5

go