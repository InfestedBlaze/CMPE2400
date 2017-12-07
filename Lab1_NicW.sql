--Lab 1
--Nicholas Wasylyshyn
--Bike riders database

USE [master]
GO

if exists
(
	select	*
	from	sysdatabases
	where name='nwasylyshyn1_Riders'
)
		drop database nwasylyshyn1_Riders
go

CREATE DATABASE [nwasylyshyn1_Riders]
GO

USE [nwasylyshyn1_Riders]
GO

----Class Table--------------------------------------------
CREATE TABLE [dbo].[Class](
	[ClassID] [NVARCHAR](30) NOT NULL,
	[ClassDescription] [NVARCHAR](50) NULL,
	CONSTRAINT [PK_Class] PRIMARY KEY([ClassID])
)
GO

ALTER TABLE Class ADD CONSTRAINT CHK_ClassDescription_Length CHECK (len([ClassDescription]) > 2)
GO

----Riders Table-------------------------------------------
CREATE TABLE [dbo].[Riders](
	[RiderID] [INT] IDENTITY(10, 1) NOT NULL
		CONSTRAINT [PK_Riders] PRIMARY KEY,
	[Name] [NVARCHAR](30) NOT NULL
		CONSTRAINT CHK_Name_Length CHECK (len([Name]) > 4),
	[ClassID] [NVARCHAR](30) NULL,
	CONSTRAINT FK_Riders_ClassID FOREIGN KEY ([ClassID])
	REFERENCES Class(ClassID) ON DELETE NO ACTION
)
GO

----Bikes Table--------------------------------------------
CREATE TABLE [dbo].[Bikes](
	[BikeID] [NVARCHAR](6) NOT NULL
		CONSTRAINT CHK_BikeID CHECK ([BikeID] like '[0-9][0-9][0-9][A-Z]-[AP]'), --###N-M Format
	[StableDate] [DATETIME] NULL,
	CONSTRAINT [PK_Bikes] PRIMARY KEY([BikeID])
)
GO

----Sessions Table-----------------------------------------
CREATE TABLE [dbo].[Sessions](
	[RiderID] [INT] NOT NULL,
	[BikeID] [NVARCHAR](6) NOT NULL,
	[SessionDate] [DATETIME] NOT NULL
		DEFAULT getdate()
		CONSTRAINT CHK_SDate_StartTime CHECK ([SessionDate] > '1 Sep 2017'),
	[Laps] [INT] NULL
		CONSTRAINT DEF_Laps DEFAULT 0,
	CONSTRAINT [PK_Sessions] PRIMARY KEY(
		[RiderID],
		[BikeID],
		[SessionDate]
	),
	CONSTRAINT FK_Sessions_RiderID FOREIGN KEY ([RiderID])
	REFERENCES Riders(RiderID) ON DELETE NO ACTION
)
GO

CREATE NONCLUSTERED INDEX NCI_RiderSession ON [Sessions] ([RiderID], [SessionDate])
ALTER TABLE [Sessions] ADD
	CONSTRAINT FK_Sessions_BikeID FOREIGN KEY ([BikeID])
	REFERENCES Bikes(BikeID) ON DELETE NO ACTION
GO


---Stored Procedures-------------------------------------------------------------------------------
---Bike Procedures--------------------------------
if exists(
	select *
	from sysobjects
	where name like 'PopulateBikes'
)
	drop procedure PopulateBikes
go
create procedure PopulateBikes
as
	declare @looperBike as int = 0

	while @looperBike < 20
	begin
		insert Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'H-A')

		insert Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'H-P')

		insert Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'Y-A')

		insert Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'Y-P')

		insert Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'S-A')

		insert Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'S-P')

		set @looperBike += 1;
	end
go

if exists(
	select
		*
	from sysobjects
	where name like 'RemoveBike'
)
drop procedure RemoveBike
go
create procedure RemoveBike
@BikeID as nvarchar (6)= null,
@ErrorMessage as nvarchar(max) output
as
	if @BikeID is null
	begin
		set @ErrorMessage  = 'RemoveBike : BikeID can''t be NULL'
		return -1
	end

	if not exists (
		select *
		from Bikes
		where BikeID = @BikeID
	)
	begin
		set @ErrorMessage  = 'RemoveBike : ' + @BikeID + ' doesn''t exist'
		return -1
	end

	if exists (
		select *
		from Sessions
		where BikeID = @BikeID
	)
	begin
		set @ErrorMessage  = 'RemoveBike : ' + @BikeID + ' Currently in Session'
		return -1
	end

	delete
	from Bikes
	where BikeID = @BikeID
	set @ErrorMessage = 'OK'
	return 0
go
---Rider Procedures-------------------------------
if exists(
	select *
	from sysobjects
	where name like 'AddRider'
)
	drop procedure AddRider
go
create procedure AddRider
@Name as nvarchar(30),
@ClassID as nvarchar(30) = null,
@ErrorMessage as nvarchar(max) output
as
	--Name is null
	if @Name is null or @Name like ''
	begin
		set @ErrorMessage = 'Name is null or empty'
		return -1
	end
	--Class does not exist
	if @ClassID is not null and not exists(
		select ClassId
		from Class
		where ClassID like @ClassID
	)
	begin
		set @ErrorMessage = 'Class does not exist'
		return -1
	end

	insert Riders ([Name], [ClassID])
	values (@Name, @ClassID);

	set @ErrorMessage = 'Ok'
	return 0
go

if exists(
	select *
	from sysobjects
	where name like 'RemoveRider'
)
	drop procedure RemoveRider
go
create procedure RemoveRider
@RiderID as int,
@force as bit = 0,
@ErrorMessage as nvarchar(max) output
as
	if @RiderID is null or not exists (
		select RiderID
		from Riders
		where RiderID = @RiderID
	)
	begin
		set @ErrorMessage = 'RiderID is null or not exists'
		return -1
	end


	declare @count as int
	select
		@count = count(s.RiderID)
	from Sessions as s
	where s.RiderID = @RiderID

	if @count > 0 and @force = 0
	begin
		set @ErrorMessage = 'More than 0 riders, not forcing'
		return -1
	end

	if @force = 1
		delete Sessions
		where RiderID = @RiderID

	delete Riders
	where Riders.RiderID = @RiderID

	set @ErrorMessage = 'Ok'
	return 0
go
---Session Procedures-----------------------------

if exists(
	select *
	from sysobjects
	where name like 'AddSession'
)
	drop procedure AddSession
go
create procedure AddSession
@RiderID as int,
@BikeID as nvarchar(6),
@Date as datetime,
@ErrorMessage as nvarchar(max) output
as
	if @RiderID is null or not exists(
		select RiderID
		from Riders
		where RiderID = @RiderID
	)
	begin
		set @ErrorMessage = 'RiderID is null or not exists'
		return -1
	end

	if @BikeID is null or not exists(
		select BikeID
		from Bikes
		where BikeID = @BikeID
	)
	begin
		set @ErrorMessage = 'BikeID is null or not exists'
		return -1
	end

	if @Date is null or @Date < GETDATE()
	begin
		set @ErrorMessage = 'Date is null or before now'
		return -1
	end

	if exists(
		select BikeID
		from Sessions
		where BikeId = @BikeID and SessionDate = @Date --Same bike at the same time
	)
	begin
		set @ErrorMessage = 'Bike already in use'
		return -1
	end

	insert Sessions ([RiderID], [BikeID], [SessionDate])
	values (@RiderID, @BikeID, @Date)

	set @ErrorMessage = 'Ok'
	return 0
go

if exists(
	select *
	from sysobjects
	where name like 'UpdateSession'
)
	drop procedure UpdateSession
go
create procedure UpdateSession
@RiderID as int,
@BikeID as nvarchar(6),
@Date as datetime,
@Laps as int,
@ErrorMessage as nvarchar(max) output
as

	if not exists(
		select 
			SessionDate
		from Sessions
		where
			RiderID = @RiderID and
			BikeID like @BikeID and
			SessionDate = @Date
	)
	begin
		set @ErrorMessage = 'Session does not exist'
		return -1
	end

	declare @lap as int

	select
		@lap = Laps --Get our current number of laps
	from Sessions
	where
		BikeID like @BikeID and
		RiderID = @RiderID and
		SessionDate = @Date

	--our current laps are less than the laps to change it to
	--Also have a session that has laps
	if @lap < @Laps and @lap != null
		update Sessions
		set Laps = @lap
		where
			BikeID like @BikeID and
			RiderID = @RiderID and
			SessionDate = @Date
	else
	begin
		set @ErrorMessage = 'Can not lower the amount of laps'
		return -1
	end

	set @ErrorMessage = 'Ok'
	return 0
go
---Class Procedures-------------------------------

if exists(
	select *
	from sysobjects
	where name like 'RemoveClass'
)
	drop procedure RemoveClass
go
create procedure RemoveClass
@ClassID as nvarchar(30),
@force as bit = 0,
@ErrorMessage as nvarchar(max) output
as
	declare @rows as int, @RiderID as int

	select @RiderID = RiderID
	from Riders
	where ClassID = @ClassID
	set @rows = @@ROWCOUNT

	--ClassID can't be null or empty
	if @ClassID is null or @ClassID like ''
	begin
		set @ErrorMessage = 'ClassID null or empty'
		return -1
	end

	--We have a rider in this class, don't force
	if @rows > 0 and @force = 0
	begin
		set @ErrorMessage = 'There is a rider, do not force'
		return -1
	end
	else if @rows > 0 and @force = 1 begin
		delete Sessions
		where RiderID in (
			select RiderID
			from Riders
			where ClassID like(
				select ClassID
				from Class
				where ClassID = @ClassID
			)
		)

		delete Riders
		where ClassID = (
			select ClassID
			from Class
			where ClassID = @ClassID
		)
	end

	--Delete the class
	delete Class
	where ClassID = @ClassID

	set @ErrorMessage = 'Ok'
	return 0
go

if exists(
	select *
	from sysobjects
	where name like 'ClassInfo'
)
	drop procedure ClassInfo
go
create procedure ClassInfo
@ClassID as nvarchar(30),
@RiderID as int = null,
@ErrorMessage as nvarchar(max) output
as
	--ClassID can't be null or empty
	if @ClassID is null or @ClassID like ''
	begin
		set @ErrorMessage = 'ClassID is null or empty'
		return -1
	end
	--ClassID has to exist
	if not exists(
		select ClassID
		from Class
		where ClassID like @ClassID
	)
	begin
		set @ErrorMessage = 'Class does not exist'
		return -1
	end
	--RiderID has to exist if it isn't null
	if @RiderID is not null and not exists(
		select RiderID
		from Riders
		where RiderID = @RiderID
	)
	begin
		set @ErrorMessage = 'RiderID is null or not exist'
		return -1
	end

	if @RiderID is NULL or not exists (select RiderID from Riders where RiderID = @RiderID)
		select *
		from Class as c
			left outer join Riders as r
			on c.ClassID = r.ClassID
		where
			c.ClassID like @ClassID
	else
		select *
		from Class as c
			left outer join Riders as r
			on c.ClassID = r.ClassID
		where
			c.ClassID like @ClassID and
			r.RiderID = @RiderID

	set @ErrorMessage = 'Ok'
	return 0
go

if exists(
	select *
	from sysobjects
	where name like 'ClassSummary'
)
	drop procedure ClassSummary
go
create procedure ClassSummary
@ClassID as nvarchar(30) = null,
@RiderID as int = null,
@ErrorMessage as nvarchar(max) output
as
	--ClassID can't be empty
	if @ClassID like ''
	begin
		set @ErrorMessage = 'ClassID is empty'
		return -1
	end
	--ClassID has to exist if it isn't null
	if @ClassID is not null and not exists(
		select ClassID
		from Class
		where ClassID like @ClassID
	)
	begin
		set @ErrorMessage = 'ClassID does not exist'
		return -1
	end
	--RiderID has to exist if it isn't null
	if @RiderID is not null and not exists(
		select RiderID
		from Riders
		where RiderID = @RiderID
	)
	begin
		set @ErrorMessage = 'RiderID does not exist'
		return -1
	end

	if @ClassID is not null and @RiderID is null --Have just a classID
		select 
			c.ClassID as 'Class',
			c.ClassDescription as 'Description',
			r.Name as 'Rider',
			count(s.SessionDate) as 'Session Count',
			avg(coalesce(s.Laps, 0)) as 'Average Laps',
			min(coalesce(s.Laps, 0)) as 'Minumum Laps',
			max(coalesce(s.Laps, 0)) as 'Maximum Laps'
		from Class as c
			left outer join Riders as r
			on c.ClassID = r.ClassID
				left outer join Sessions as s
				on r.RiderID = s.RiderID
		where c.ClassID like @ClassID --------Different line
		group by r.Name, c.ClassID, c.ClassDescription
	else if @ClassID is null and @RiderID is not null --Have just a RiderID
		select 
			c.ClassID as 'Class',
			c.ClassDescription as 'Description',
			r.Name as 'Rider',
			count(s.SessionDate) as 'Session Count',
			avg(coalesce(s.Laps, 0)) as 'Average Laps',
			min(coalesce(s.Laps, 0)) as 'Minumum Laps',
			max(coalesce(s.Laps, 0)) as 'Maximum Laps'
		from Class as c
			left outer join Riders as r
			on c.ClassID = r.ClassID
				left outer join Sessions as s
				on r.RiderID = s.RiderID
		where r.RiderID = @RiderID --------Different line
		group by r.Name, c.ClassID, c.ClassDescription
	else-----------------------------------------------Have a class and rider ID
		select 
			c.ClassID as 'Class',
			c.ClassDescription as 'Description',
			r.Name as 'Rider',
			count(s.SessionDate) as 'Session Count',
			avg(coalesce(s.Laps, 0)) as 'Average Laps',
			min(coalesce(s.Laps, 0)) as 'Minumum Laps',
			max(coalesce(s.Laps, 0)) as 'Maximum Laps'
		from Class as c
			left outer join Riders as r
			on c.ClassID = r.ClassID
				left outer join Sessions as s
				on r.RiderID = s.RiderID
		group by r.Name, c.ClassID, c.ClassDescription
		order by c.ClassID, r.Name

	set @ErrorMessage = 'Ok'
	return 0
go

---Table Filling------------------------------------------------
--Add the bikes
exec PopulateBikes

---Making classes
insert Class ([ClassID], [ClassDescription])
values ('150cc - Motorcycle', 'Intense 150cc motorcycle action!')
insert Class ([ClassID], [ClassDescription])
values ('100cc - GoKarts', 'Standard Racing')
go

---Making Riders
declare @identityM as int, @identityL as int, @identityP as int, @identityT as int, @error as nvarchar(max)
exec AddRider @Name = 'Mario', @ClassID = '150cc - Motorcycle', @ErrorMessage = @error output
set @identityM = @@IDENTITY
exec AddRider @Name = 'Luigi', @ClassID = '150cc - Motorcycle', @ErrorMessage = @error output
set @identityL = @@IDENTITY

exec AddRider @Name = 'Peach', @ClassID = '100cc - GoKarts', @ErrorMessage = @error output
set @identityP = @@IDENTITY
exec AddRider @Name = 'Toadette', @ClassID = '100cc - GoKarts', @ErrorMessage = @error output
set @identityT = @@IDENTITY

---Making sessions, using riders
exec AddSession @RiderID = @identityM, @BikeID = '000H-A', @Date = '24 December 2020', @ErrorMessage = @error output
exec UpdateSession @RiderID = @identityM, @BikeID = '000H-A', @Date = '24 December 2020', @Laps = 5, @ErrorMessage = @error output
exec AddSession @RiderID = @identityM, @BikeID = '000H-A', @Date = '25 December 2020',  @ErrorMessage = @error output
exec UpdateSession @RiderID = @identityM, @BikeID = '000H-A', @Date = '24 December 2020', @Laps = 2, @ErrorMessage = @error output

exec AddSession @RiderID = @identityL, @BikeID = '005Y-P', @Date = '12 December 2020', @ErrorMessage = @error output
exec UpdateSession @RiderID = @identityL, @BikeID = '005Y-P', @Date = '12 December 2020', @Laps = 10, @ErrorMessage = @error output
exec AddSession @RiderID = @identityL, @BikeID = '005Y-P', @Date = '19 December 2020', @ErrorMessage = @error output
exec UpdateSession @RiderID = @identityL, @BikeID = '005Y-P', @Date = '12 December 2020', @Laps = 2, @ErrorMessage = @error output

exec AddSession @RiderID = @identityP, @BikeID = '010S-A', @Date = '12 December 2020', @ErrorMessage = @error output
exec UpdateSession @RiderID = @identityP, @BikeID = '010S-A', @Date = '12 December 2020', @Laps = 6, @ErrorMessage = @error output
exec AddSession @RiderID = @identityP, @BikeID = '010S-A', @Date = '19 December 2020', @ErrorMessage = @error output
exec UpdateSession @RiderID = @identityP, @BikeID = '010S-A', @Date = '12 December 2020', @Laps = 4, @ErrorMessage = @error output

exec AddSession @RiderID = @identityT, @BikeID = '019H-A', @Date = '24 December 2020', @ErrorMessage = @error output
exec UpdateSession @RiderID = @identityT, @BikeID = '019H-A', @Date = '24 December 2020', @Laps = 1, @ErrorMessage = @error output
exec AddSession @RiderID = @identityT, @BikeID = '019H-A', @Date = '25 December 2020', @ErrorMessage = @error output
exec UpdateSession @RiderID = @identityT, @BikeID = '019H-A', @Date = '24 December 2020', @Laps = 6, @ErrorMessage = @error output

--Retrieve additions
exec ClassInfo @ClassID = '150cc - Motorcycle', @ErrorMessage = @error output
exec ClassInfo @ClassID = '100cc - GoKarts', @ErrorMessage = @error output
exec ClassSummary @ErrorMessage = @error output
go

---Error Testing-----------------------------------------------------------------------------------
---AddRider Testing--------------------------------------------------------------------------------
declare @ret as int, @error as nvarchar(max)
declare @name as nvarchar(30), @classID as nvarchar(30)

--Name is null test
set @Name = null
set @ClassID = null
exec @ret = AddRider @Name = @name, @ClassID = @classID, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
--Name is empty
set @Name = ''
set @ClassID = null
exec @ret = AddRider @Name = @name, @ClassID = @classID, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
--Class does not exist test
set @Name = 'Mario'
set @ClassID = 'Not Exist'
exec @ret = AddRider @Name = @name, @ClassID = @classID, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
go

---RemoveRider Testing-----------------------------------------------------------------------------
declare @ret as int, @error as nvarchar(max)
declare @riderid as int, @forceIt as bit

--RiderID is null
set @riderid = null
set @forceIt = 0;
exec @ret = RemoveRider @RiderID = @riderid, @force = @forceIt, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--RiderID not exist
set @riderid = -1
set @forceIt = 0;
exec @ret = RemoveRider @RiderID = @riderid, @force = @forceIt, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Rider with sessions, not force
declare @ident as int
exec AddRider 'Testing', null, @error output
set @ident = @@IDENTITY
exec AddSession @ident, '019H-P', '10 Sep 2020', @error output
set @riderid = @ident
set @forceIt = 0;
exec @ret = RemoveRider @RiderID = @riderid, @force = @forceIt, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Rider with Sessions, force
set @riderid = @ident
set @forceIt = 1;
exec @ret = RemoveRider @RiderID = @riderid, @force = @forceIt, @ErrorMessage = @error output
if @ret >= 0 select @ret as 'Error Value', @error as 'Error Message'
go

---AddSession Testing------------------------------------------------------------------------------

declare @ret as int, @error as nvarchar(max)
declare @rider as int, @bike as nvarchar(6), @date as datetime

--Rider is null
set @rider = null
set @bike = '000H-A'
set @date = '20 Sep 2020'
exec @ret = AddSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Bike is null
set @rider = 10
set @bike = null
set @date = '20 Sep 2020'
exec @ret = AddSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Date is null
set @rider = 10
set @bike = '000H-A'
set @date = null
exec @ret = AddSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Rider is not exist
set @rider = 9
set @bike = '000H-A'
set @date = '20 Sep 2020'
exec @ret = AddSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Bike is not exist
set @rider = 10
set @bike = '020H-A'
set @date = '20 Sep 2020'
exec @ret = AddSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Date Invalid
set @rider = 10
set @bike = '020H-A'
set @date = '20 Sep 2000'
exec @ret = AddSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Bike is booked
set @rider = 11
set @bike = '000H-A'
set @date = '24 December 2020'
exec @ret = AddSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
go

---UpdateSession Testing---------------------------------------------------------------------------
declare @ret as int, @error as nvarchar(max)
declare @rider as int, @bike as nvarchar(6), @date as datetime, @lap as int

--rider no match
set @rider = 9
set @bike = '000H-A'
set @date = '24 Dec 2020'
set @lap = 0
exec @ret = UpdateSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @Laps = @lap, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--bike no match
set @rider = 10
set @bike = '020H-A'
set @date = '24 Dec 2020'
set @lap = 0
exec @ret = UpdateSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @Laps = @lap, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--date no match
set @rider = 10
set @bike = '000H-A'
set @date = '27 Dec 2020'
set @lap = 0
exec @ret = UpdateSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @Laps = @lap, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Lap too low
set @rider = 10
set @bike = '000H-A'
set @date = '24 Dec 2020'
set @lap = 0
exec @ret = UpdateSession @RiderID = @rider, @BikeID = @bike, @Date = @date, @Laps = @lap, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
go

---RemoveClass Testing-----------------------------------------------------------------------------
declare @ret as int, @error as nvarchar(max)
declare @class as nvarchar(30), @forceIt as bit

--Class is null
set @class = null
set @forceIt = 0
exec @ret = RemoveClass @ClassID = @class, @force = @forceIt, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Class is empty
set @class = ''
set @forceIt = 0
exec @ret = RemoveClass @ClassID = @class, @force = @forceIt, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Force remove testing
insert Class (ClassID) values ('This is a test')
exec AddRider 'Test Case', 'This is a test', @error output
--Fail force
set @class = 'This is a test'
set @forceIt = 0
exec @ret = RemoveClass @ClassID = @class, @force = @forceIt, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

--Success on force
set @class = 'This is a test'
set @forceIt = 1
exec @ret = RemoveClass @ClassID = @class, @force = @forceIt, @ErrorMessage = @error output
if @ret >= 0 select @ret as 'Error Value', @error as 'Error Message'
go

---ClassInfo Testing-------------------------------------------------------------------------------
declare @ret as int, @error as nvarchar(max)
declare @class as nvarchar(30), @rider as int

--Class is null
set @class = null
set @rider = null
exec @ret = ClassInfo @ClassID = @class, @RiderID = @rider, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
--Class is empty
set @class = ''
set @rider = null
exec @ret = ClassInfo @ClassID = @class, @RiderID = @rider, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
--CLass is not exist
set @class = 'Not exist'
set @rider = null
exec @ret = ClassInfo @ClassID = @class, @RiderID = @rider, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
--Rider is null
set @class = '150cc - Motorcycle'
set @rider = null
exec @ret = ClassInfo @ClassID = @class, @RiderID = @rider, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
--Rider not null
set @class = '150cc - Motorcycle'
set @rider = 10
exec @ret = ClassInfo @ClassID = @class, @RiderID = @rider, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
--No riders
insert Class (ClassID, ClassDescription) values ('This is a test', 'Desc')
set @class = 'This is a test'
set @rider = null
exec @ret = ClassInfo @ClassID = @class, @RiderID = @rider, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
exec RemoveClass 'This is a test', 1, @error output
--RiderID not exist
set @class = '150cc - Motorcycle'
set @rider = 9
exec @ret = ClassInfo @ClassID = @class, @RiderID = @rider, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'
go

---ClassSummary Testing----------------------------------------------------------------------------
declare @ret as int, @error as nvarchar(max)
declare @class as nvarchar(30), @rider as int

set @class = null
set @rider = null
exec @ret = ClassSummary @ClassID = @class, @RiderID = @rider, @ErrorMessage = @error output
if @ret < 0 select @ret as 'Error Value', @error as 'Error Message'

go