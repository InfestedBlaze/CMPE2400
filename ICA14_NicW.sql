--ICA 14
--Nic Wasylyshyn

--q1
if exists(
	select *
	from sysobjects
	where name like 'ica14_01'
)
	drop procedure ica14_01
go

create procedure ica14_01
@Type as nvarchar(20),
@Name as nvarchar(20) output,
@Quantity as int output
as
	select top(1)
		@Name = p.ProductName,
		@Quantity = od.Quantity
	from NorthwindTraders.dbo.Products as p
		left outer join NorthwindTraders.dbo.[Order Details] as od
		on p.ProductID = od.ProductID
		left outer join NorthwindTraders.dbo.Categories as c
		on p.CategoryID = c.CategoryID
	where c.CategoryName like @Type
	order by Quantity desc
go

--Exec 1
declare @ProdType as nvarchar(20) = 'Beverages',
		@ProdName as nvarchar(20),
		@TopQuantity as int

exec ica14_01 @ProdType, @ProdName output, @TopQuantity output
select	@ProdType as 'Category',
		@ProdName as 'ProductName', 
	    @TopQuantity as 'Highest Qty'

--Exec 2
set @ProdType = 'Confections'

exec ica14_01 @Type = @ProdType, @Name = @ProdName output, @Quantity = @TopQuantity output
select	@ProdType as 'Category',
		@ProdName as 'ProductName', 
	    @TopQuantity as 'Highest Qty'
go



















--q2
if exists(
	select *
	from sysobjects
	where name like 'ica14_02'
)
	drop procedure ica14_02
go

create procedure ica14_02
@Year as int,
@Name as nvarchar(64) output,
@AvgFreight as money output
as
	select top(1)
		@Name = e.LastName + ', ' + e.FirstName,
		@AvgFreight = avg(o.Freight)
	from NorthwindTraders.dbo.Employees as e
		inner join NorthwindTraders.dbo.Orders as o
		on e.EmployeeID = o.EmployeeID
	where datepart(year, o.OrderDate) like @Year
	group by e.LastName, e.FirstName
	order by avg(o.Freight) desc
	
go

declare @myYear as int = 1996,
		@name as nvarchar(64),
		@freight as money
exec ica14_02 @myYear, @name output, @freight output
select
	@myYear as 'Year',
	@name as 'Name',
	@freight as 'Biggest Avg Freight' 

set @myYear = 1997
exec ica14_02 @Year = @myYear, @Name = @name output, @AvgFreight = @freight output
select
	@myYear as 'Year',
	@name as 'Name',
	@freight as 'Biggest Avg Freight' 




















--q3
if exists(
	select *
	from sysobjects
	where name like 'ica14_03'
)
	drop procedure ica14_03
go

create procedure ica14_03
@classID as int,
@AssignDescript as varchar(3) = 'all'
as
	select 
		s.last_name as 'Last',
		at.ass_type_desc,
		round(min((res.score / req.max_score) * 100), 1) as 'Low',
		round(max((res.score / req.max_score) * 100), 1) as 'High',
		round(avg((res.score / req.max_score) * 100), 1) as 'Avg'
	into #tempTable
	from ClassTrak.dbo.Students as s
		left outer join ClassTrak.dbo.Results as res
		on s.student_id = res.student_id
			left outer join ClassTrak.dbo.Requirements as req
			on res.req_id = req.req_id
				left outer join ClassTrak.dbo.Assignment_type as at
				on req.ass_type_id = at.ass_type_id
	where res.class_id like @classID
	group by s.last_name, at.ass_type_desc
	order by [Avg] desc

	if @AssignDescript like 'all'
		--We want everything, no bias to assignment type
		select *
		from #tempTable
		order by [Avg] desc
	 
	else if @AssignDescript like 'ica'
		--Only show assignments
		select *
		from #tempTable
		where #tempTable.ass_type_desc like 'Assignment'
		order by [Avg] desc
	
	else if @AssignDescript like 'lab'
		--Only show labs
		select *
		from #tempTable
		where #tempTable.ass_type_desc like 'Lab'
		order by [Avg] desc
	
	else if @AssignDescript like 'le'
		--Only show Lab Exams
		select *
		from #tempTable
		where #tempTable.ass_type_desc like 'Lab Exam'
		order by [Avg] desc
	
	else if @AssignDescript like 'fe'
		--Only show Final Exams
		select *
		from #tempTable
		where #tempTable.ass_type_desc like 'Final'
		order by [Avg] desc
go


declare @cid as int
set @cid = 123
exec ica14_03 @cid, 'ica'
set @cid = 123
exec ica14_03 @classID = @cid, @AssignDescript = 'le'
go












--q4
if exists(
	select *
	from sysobjects
	where name like 'ica14_04'
)
	drop procedure ica14_04
go

create procedure ica14_04
@student as nvarchar(24),
@summary as int = 0
as
--do the name check first
declare @stuName as nvarchar(30)
	select 
		@stuName = s.first_name + ' ' + s.last_name
	from ClassTrak.dbo.Students as s
	where (s.first_name + ' ' + s.last_name) like @student + '%'

	if @@ROWCOUNT <> 1
		return -1

	select 
		s.first_name + ' ' + s.last_name as 'Name',
		c.class_desc,
		at.ass_type_id,
		ROUND( AVG((res.score / req.max_score) * 100), 1) as 'Avg'
	into #tempTable
	from ClassTrak.dbo.Students as s
		left outer join ClassTrak.dbo.Results as res
		on s.student_id = res.student_id
			inner join ClassTrak.dbo.Classes as c
			on res.class_id = c.class_id
			inner join ClassTrak.dbo.Requirements as req
			on res.req_id = req.req_id
				left outer join ClassTrak.dbo.Assignment_type as at
				on req.ass_type_id = at.ass_type_id
	where (s.first_name + ' ' + s.last_name) like @student + '%'
	group by s.first_name, s.last_name, c.class_desc, at.ass_type_id



	if @summary = 0
		select *
		from #tempTable;
	else if @summary = 1
		select
			Name,
			class_desc,
			[Avg]
		from #tempTable

	return 1
go



declare @retVal as int
exec @retVal = ica14_04 @student = 'Ro'
select @retVal
exec @retVal = ica14_04 @student = 'Ron'
select @retVal
exec @retVal = ica14_04 @student = 'Ron', @summary = 1
select @retVal
















--q5
if exists(
	select *
	from sysobjects
	where name like 'ica14_05'
)
	drop procedure ica14_05
go

create procedure ica14_05
@lastName as nvarchar(20),
@InstructName as nvarchar(30) output,
@NumClasses as int output,
@NumStudents as int output,
@NumGraded as int output,
@AvgAwarded as float output
as
	declare @rows as int

	select 
		@InstructName = i.first_name + ' ' + i.last_name
	from ClassTrak.dbo.Instructors as i
	where i.last_name like @lastName+'%'

	set @rows = @@ROWCOUNT

	select 
		@NumClasses = count(c.class_id)
	from ClassTrak.dbo.Instructors as i
		inner join ClassTrak.dbo.Classes as c
		on i.instructor_id = c.instructor_id
	where i.last_name like @lastName+'%'

	select 
		@NumStudents = count(s.student_id)
	from ClassTrak.dbo.Instructors as i
		inner join ClassTrak.dbo.Classes as c
		on i.instructor_id = c.instructor_id
			inner join ClassTrak.dbo.class_to_student as cts
			on c.class_id = cts.class_id
				inner join ClassTrak.dbo.Students as s
				on cts.student_id = s.student_id
	where i.last_name like @lastName+'%'

	select
		@NumGraded = count(res.score),
		@AvgAwarded = avg((res.score / req.max_score) * 100)
	from ClassTrak.dbo.Instructors as i
		inner join ClassTrak.dbo.Classes as c
		on i.instructor_id = c.instructor_id
			inner join ClassTrak.dbo.Results as res
			on c.class_id = res.class_id
				inner join ClassTrak.dbo.Requirements as req
				on res.req_id = req.req_id
	where i.last_name like @lastName+'%'

	return @rows
go

declare
	@fullName as nvarchar(30),
	@return as int,
	@classes as int,
	@students as int,
	@graded as int,
	@avg as float

exec @return = ica14_05 @lastName = 'Cas', @InstructName = @fullName output, @NumClasses = @classes output, @NumStudents = @students output, @NumGraded = @graded output, @AvgAwarded = @avg output

if @return = 1
	select
		@fullName as 'Instructor',
		@return as 'Return',
		@classes as 'Num Classes',
		@students as 'Total Students',
		@graded as 'Total Graded',
		@avg as 'Total Awarded'

go

