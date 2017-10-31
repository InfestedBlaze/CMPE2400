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
declare @number as int = 123
select 
	S.last_name as 'Last',
	at.ass_type_desc,
	round(min((res.score / req.max_score) * 100),1) as 'Low',
	round(max((res.score / req.max_score) * 100),1) as 'High',
	round(avg((res.score / req.max_score) * 100), 1) as 'Avg'
from Students as S
	left outer join Results as res
	on S.student_id = res.student_id
		left outer join Requirements as req
		on res.req_id = req.req_id
			left outer join Assignment_type as at
			on req.ass_type_id = at.ass_type_id
where res.class_id like @number
group by S.last_name, at.ass_type_desc
having avg((res.score / req.max_score) * 100) > 70
order by at.ass_type_desc, [Avg]
go

--q4
select 
	I.last_name as 'Instructor',
	convert(nvarchar(12), C.start_date, 106) as 'Start',
	count(cts.class_to_student_id) as 'Num Registered',
	sum(cast(cts.active as int)) as 'Num Active'
from Instructors as I
	left outer join Classes as C
	on I.instructor_id = C.instructor_id
		left outer join class_to_student as cts
		on C.class_id = cts.class_id
group by I.last_name, C.start_date
having count(cts.class_to_student_id) - sum(cast(cts.active as int)) > 3
order by C.start_date, I.last_name
go

--q5
declare @year as int = 2011
declare @score as int = 40
select 
	cast(S.last_name + ', ' + S.first_name as nvarchar(24)) as 'Student',
	c.class_desc as 'Class',
	at.ass_type_desc as 'Type',
	count(res.req_id) as 'Submitted',
	round( avg((res.score / req.max_score) * 100), 1) as 'Avg'
from Students as s
	left outer join Results as res
	on S.student_id = res.student_id
		left outer join Classes as c
		on res.class_id = C.class_id

		left outer join Requirements as req
		on res.req_id = req.req_id
			left outer join Assignment_type as at
			on req.ass_type_id = at.ass_type_id
where DATEPART(year, c.start_date) like @year 
	and res.score is not null
group by s.last_name, s.first_name, c.class_desc, at.ass_type_desc
having round( avg((res.score / req.max_score) * 100), 1) < @score and
	 count(res.req_id) > 10
order by Submitted
go