-- ica03Demo from class
-- d1
-- rand() - returns a random number between 0 and 1, exclusively !
-- rand(seed) - set the seed, ensure identical sequence of values

declare @num as int
declare @fnum as float
declare @dnum as decimal(7,6)

set @num = rand() * 10 + 11 -- between 11 and 20
set @fnum = rand() -- full precision of float
set @dnum = rand() -- 6 decimal places

select
	@num as 'num',
	@fnum as 'fnum',
	@dnum as 'dnum'
go

--d2-- case
/*-- Syntax for SQL Server and Azure SQL Database  
  
Simple CASE expression:   
CASE input_expression   
     WHEN when_expression THEN result_expression [ ...n ]   
     [ ELSE else_result_expression ]   
END   
Searched CASE expression:  
CASE  
     WHEN Boolean_expression THEN result_expression [ ...n ]   
     [ ELSE else_result_expression ]   
END  
*/
declare @var int = 8 -- king card
set @var = -- assign counting value
	case @var -- Simple Matching CASE
		when 11 then 10
		when 12 then 10
		when 13 then 10
		else @var
	end
select @var as 'Card Value'

declare @name nvarchar(max) = N'Scaotty' -- N prefix converts to UNICODE
declare @result nvarchar(18)
set @result = 
	case
		when len(@name) = 5 then 'Only 5'
		when len(@name) = 6 then 'Yup, Good'
		when CHARINDEX('o', @name ) = 3 then 'Beam me up'
		else 'Signal Lost Captain'
	end
select @result as 'Result'

-- d3 While loops
declare @total int = 0
declare @loopNum int = rand() * 10 -- up to 10 times
while @loopNum > 0
begin
	set @total += ( rand() * 2 ) * 10
	set @loopNum -= 1
end
select @total as 'Total', @loopNum as 'loopNum'
go
