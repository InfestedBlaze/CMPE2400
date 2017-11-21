-- ica15
-- This ICA is comprised of 2 parts, but should be tackled as described by your instructor.
-- To ensure end-to-end running, you will have to complete the ica in pairs where possible :
--  q1A + q2A, then q1B + q2B
-- You will need to install a personal version of the ClassTrak database
-- The Full and Refresh scripts are on the Moodle site.
-- Once installed, you can run the refresh script to restore data that may be modified or 
--  deleted in the process of completing this ica.

use nwasylyshyn1_ClassTrak
go

-- q1
-- All in one batch, to retain your variable contexts/values

-- A
-- Insert a new Instructor : Donald Trump
--  Check column types, supply necessary values, it may require a column list
--  Save your identity into a variable

declare @q1Identity as int
insert into Instructors (first_name, last_name)
values ('Donald', 'Trump')
set @q1Identity = @@IDENTITY

-- B
-- Insert a new Course : cmpe2442 "Fast and Furious - SQL Edition"
--  Check column types, supply necessary values, it may require a column list
--  Save your identity into a variable

declare @q2Identity as int
insert into Courses (course_abbrev, course_desc)
values ('cmpe2442', 'Fast and Furious - SQL Edition')
set @q2Identity = @@IDENTITY

-- C
-- Insert a record indicating your new instructor is teaching the new course
--  description : "Beware the optimizer"
--  start_date : use 01 Sep 2016
--  Save the identity into a variable

declare @q3Identity as int
insert into Classes ([class_desc], [instructor_id], [course_id], [start_date])
values (N'Beware the optimizer', @q1Identity, @q2Identity, CAST('01 Sep 2016' AS DateTime))
set @q3Identity = @@IDENTITY

-- D Insert a bunch in one insert
-- Generate the insert statement to Add all the students with a last name that
--  starts with a vowel to the new class

insert into class_to_student (class_id, student_id, active)
	select 
		@q3Identity,
		student_id,
		1
	from Students
	where last_name like '[aeiou]%'

-- E
--  Prove it all, generate a select to show :
--   All instructors - see your new entry
--   All courses that have SQL in description
--   All classes that have a start_date after 1 Aug 2016
--   All students in the new class - filter by description having "Beware"
--       sort by first name in last name

select 
	i.first_name + ' ' + i.last_name as 'Instructor',
	co.course_abbrev + ' : ' + co.course_desc as 'Course',
	c.class_desc as 'Class',
	s.first_name + ' ' + s.last_name as 'Student'
from Instructors as i
	left outer join Classes as c
	on i.instructor_id = c.instructor_id
		left outer join Courses as co
		on c.course_id = co.course_id
		left outer join class_to_student as cts
		on c.class_id = cts.class_id
			inner join Students as s
			on cts.student_id = s.student_id
where 
	co.course_desc like '%SQL%' and
	c.start_date > '1 Aug 2016' and
	c.class_desc like '%Beware%'
order by s.last_name, s.first_name

go
-- end q1



-- q2 - Undo all your changes to reset the database, you must do this in reverse order to
--      ensure you do not attempt to corrupt Referencial Integrity.
--     As such, work backwards from D to A, deleting what we added, but you must query the DB
--      to find and save the relevant keys.

-- q2 - Undo all your changes to reset the database, you must do this in reverse order to
--      ensure you do not attempt to corrupt Referencial Integrity.
--     As such, work backwards from D to A.

-- D - Delete all students that have been assigned to your new class, do this without a 
--     variable, rather perform a join with proper filtering for this delete

delete class_to_student
where class_id like (
	select class_id
	from Classes
	where 
)

-- C - declare, query and set class id to your new class based on above filter.
--     declare, query and save the linked course and instructor ( use in B and A )
--     Delete the new class



-- B - Delete the new course as saved in C



-- A - Delete the new instructor as saved in C



-- E - Repeat q1 part E to verify the removal of all the data.

select 
	i.first_name + ' ' + i.last_name as 'Instructor',
	co.course_abbrev + ' : ' + co.course_desc as 'Course',
	c.class_desc as 'Class',
	s.first_name + ' ' + s.last_name as 'Student'
from Instructors as i
	left outer join Classes as c
	on i.instructor_id = c.instructor_id
		left outer join Courses as co
		on c.course_id = co.course_id
		left outer join class_to_student as cts
		on c.class_id = cts.class_id
			inner join Students as s
			on cts.student_id = s.student_id
where 
	co.course_desc like '%SQL%' and
	c.start_date > '1 Aug 2016' and
	c.class_desc like '%Beware%'
order by s.last_name, s.first_name

go