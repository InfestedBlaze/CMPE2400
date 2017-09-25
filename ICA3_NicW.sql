--Nic Wasylyshyn
--ica3


--q1
declare @num int = rand() * 100 + 1 -- A number from 1-100
select
	@num as 'Random Number',
	iif(@num % 3 = 0, 'Yes', 'No') as 'Factor of 3'
go

--q2
declare @num int = rand() * 60 + 1 -- A number from 1-60
declare @time varchar(12) = 
	case 
		when @num<15 then 'on the hour'
		when @num<30 then 'quarter past'
		when @num<45 then 'half past'
		else 'quarter to'
	end
select
	@num as 'Minutes',
	@time as 'Ballpark'
go

--q3
--get the day of the week with a random num of days added
declare @day int = datepart(dw, dateadd(day, FLOOR(RAND()*7), getdate()) )
declare @class nvarchar(9) =
	case @day
		when 1 then 'Yahoo'
		when 7 then 'Yahoo'
		else 'Got Class'
	end
select
	@day as 'Day Number',
	@class as 'Status'
go

--q4
declare @loopNum as int = rand()*10000 + 1 -- Number from 1 to 10000
declare @temp as int = @loopNum
declare @randNum as int = 0
declare @factor2 as int = 0
declare @factor3 as int = 0
declare @factor5 as int = 0

while @temp > 0
	begin
		set @randNum = rand() * 10 + 1 -- From 1-10
		--Check its factors
		if @randNum % 2 = 0 
			set @factor2 += 1 
		if @randNum % 3 = 0
			set @factor3 += 1
		if @randNum % 5 = 0
			set @factor5 += 1
		--Decrement loop count
		set @temp -= 1
	end

select
	@loopNum as 'Number of Iterations',
	@factor2 as 'Factor of 2',
	@factor3 as 'Factor of 3',
	@factor5 as 'Factor of 5'
go

--q5
declare @estimate as decimal(18, 9) = 0
declare @x as int = 0
declare @y as int = 0
declare @in as decimal = 0
declare @try as decimal = 0

while @try < 1000
	begin
		--Increment loop counter
		set @try += 1

		set @x = FLOOR(RAND()*101) -- Random number from 0-100
		set @y = FLOOR(RAND()*101)

		if sqrt(power(@x, 2) + power(@y, 2)) <= 100 --inside circle sqrt(x^2 + y^2) <= 100
			set @in += 1

		--Get our estimate (in/tries)
		set @estimate = 4 * (@in/@try)

		--Leave if we are close enough
		if abs(@estimate - PI()) <= 0.0002
			break
	end

select
	@estimate as 'Estimate',
	pi() as 'PI',
	cast(@in as varchar(6)) as 'In',
	cast(@try as varchar(6)) as 'Tries'
go