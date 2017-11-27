-- ica16
-- You will need to install a personal version of the ClassTrak database
-- The Full and Refresh scripts are on the Moodle site.
-- Once installed, you can run the refresh script to restore data that may be modified or 
--  deleted in the process of completing this ica.

use  nwasylyshyn1_ClassTrak
go

-- q1
-- Complete an update to change all classes to have their descriptions be lower case
-- select all classes to verify your update

update Classes
set class_desc = LOWER(class_desc)

select class_desc as 'All Lower Case'
from Classes
go

-- q2
-- Complete an update to change all classes that are "cmpe" courses to be upper case
-- select all classes to verify your selective update

update Classes
set class_desc = UPPER(class_desc)
where class_desc like '%cmpe%'

select class_desc as 'Upper CMPE'
from Classes
go

-- q3
-- For class_id = 123
-- Update the score of all results which have a real percentage of less than 50
-- The score should be increased by 10% of the max score value, maybe more pass ?
-- Use ica13_06 select statement to verify pre and post update values,
--  put one select before and after your update call.
declare @class_id as int = 123

select 
	at.ass_type_desc as 'Type',
	round(avg(res.score), 2) as 'Raw Avg',
	round(avg((res.score / req.max_score) * 100), 2) as 'Avg',
	count(res.score) as 'Num'
from Assignment_type as at
	inner join Requirements as req
	on at.ass_type_id = req.ass_type_id
		inner join Results as res
		on req.req_id = res.req_id
where res.class_id = @class_id and req.class_id = @class_id
group by at.ass_type_desc
order by at.ass_type_desc

update Results
set score = score + (req.max_score * 0.1)
from Results as res
	inner join Requirements as req
	on res.req_id = req.req_id
where ((res.score / req.max_score) * 100) < 50
	and res.class_id = @class_id

select 
	at.ass_type_desc as 'Type',
	round(avg(res.score), 2) as 'Raw Avg',
	round(avg((res.score / req.max_score) * 100), 2) as 'Avg',
	count(res.score) as 'Num'
from Assignment_type as at
	inner join Requirements as req
	on at.ass_type_id = req.ass_type_id
		inner join Results as res
		on req.req_id = res.req_id
where res.class_id = @class_id and req.class_id = @class_id
group by at.ass_type_desc
order by at.ass_type_desc

go