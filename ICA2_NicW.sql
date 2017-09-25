-- Nic W
-- ica02

--q1
declare @diff as int
declare @hall as date = '2017.10.31'
set @diff = DATEDIFF(DAY, GETDATE(), @hall)
select
	@diff as 'Days',
	convert(nvarchar, @hall, 102)  as 'Halloween'
go

--q2
declare @today as datetime
declare @future as datetime
set @today = GETDATE()
set @future = DATEADD(minute,1000000, @today)
select 
	convert(nvarchar, DATENAME(month,@today) +
	' ' +
	cast(datepart(day,@today) as nvarchar) +
	' ' +
	cast(DATEPART(year, @today) as nvarchar)) as 'Today',
	cast(@future as smalldatetime) as 'Future'
go

--q3
declare @recieved float = @@PACK_RECEIVED
declare @sent float = @@PACK_SENT
select
	cast(@@LANGUAGE as nvarchar(12)) as 'Lang',
	cast(@@SERVERNAME as nvarchar(12)) as 'Server',
	@@PACK_RECEIVED as 'Recieved',
	@@PACK_SENT as 'Sent',
	cast(cast(@recieved / @sent * 100 as int) as nvarchar(3)) + '%' as 'Percentage'
go

--q4
declare @day	 as int		 = day(getDate())
declare @dayweek as nvarchar(24) = datename(dw, getdate())
select
	@dayweek + '(' + cast(@day as nvarchar(2)) + ')' as 'Name(#)',
	iif(@day % 2 = 0, 'Even day', 'Odd day') as 'Day Kind',
	iif(charindex('u', @dayweek) > 0, 'Yup', 'Nope') as 'Gotta u' 
go