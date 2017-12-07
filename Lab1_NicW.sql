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
	CONSTRAINT FK_Sessions_BikeID FOREIGN KEY (BikeID)
	REFERENCES Bikes(BikeID) ON DELETE NO ACTION
GO


---Stored Procedures--------------------------------------
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
	declare @looperMake as int = 0
	declare @looperTime as int = 0

	while @looperBike < 20
	begin
		insert into nwasylyshyn1_Riders.dbo.Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'H-A')

		insert into nwasylyshyn1_Riders.dbo.Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'H-P')

		insert into nwasylyshyn1_Riders.dbo.Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'Y-A')

		insert into nwasylyshyn1_Riders.dbo.Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'Y-P')

		insert into nwasylyshyn1_Riders.dbo.Bikes (BikeID)
		values ( RIGHT('000'+CAST(@looperBike AS VARCHAR(3)),3) + 'S-A')

		insert into nwasylyshyn1_Riders.dbo.Bikes (BikeID)
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
@BikeID as nchar (6)= null,
@ErrorMessage as nvarchar(max) output
as
	if @BikeID is	null
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
		set @ErrorMessage  = 'RemoveBike : � + @BikeID + � Currently in Session'
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
@ClassID as nvarchar(30) = null
as
	--Name is null
	if @Name is null or @Name like ''
		return -1
	--Class does not exist
	if @ClassID is not null and not exists(
		select ClassId
		from Class
		where ClassID like @ClassID
	)
		return -1

	insert Riders ([Name], [ClassID])
	values (@Name, @ClassID);

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
@force as bit = 0
as
	if @RiderID is null or not exists (
		select RiderID
		from Riders
		where RiderID = @RiderID
	)
		return -1


	declare @count as int
	select
		@count = count(s.RiderID)
	from Sessions as s
	where s.RiderID = @RiderID

	if @count > 0 and @force = 0
		return -1

	if @force = 1
		delete Sessions
		where RiderID = @RiderID

	delete Riders
	where Riders.RiderID = @RiderID

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
@Date as datetime
as
	if @RiderID is null or not exists(
		select RiderID
		from Sessions
		where RiderID = @RiderID
	)
		return -1

	if @BikeID is null or not exists(
		select BikeID
		from Sessions
		where BikeID = @BikeID
	)
		return -1

	if @Date is null or @Date < GETDATE()
		return -1

	if exists(
		select BikeID
		from Sessions
		where BikeId = @BikeID and SessionDate = @Date --Same bike at the same time
	)
		return -1

	insert Sessions ([RiderID], [BikeID], [SessionDate])
	values (@RiderID, @BikeID, @Date)

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
@Laps as int
as

	if not exists(
		select *
		from Sessions
		where
			RiderID = @RiderID and
			BikeID like @BikeID and
			SessionDate = @Date
	)
		return -1

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
		return -1

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
@force as bit = 0
as
	declare @rows as int, @RiderID as int

	select @RiderID = RiderID
	from Riders
	where ClassID = @ClassID
	set @rows = @@ROWCOUNT

	--ClassID can't be null or empty
	if @ClassID is null or @ClassID like ''
		return -1

	--We have a rider in this class, don't force
	if @rows > 0 and @force = 0
		return -1
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
@RiderID as int = null
as
	--ClassID can't be null or empty
	if @ClassID is null or @ClassID like ''
		return -1
	--ClassID has to exist
	if not exists(
		select ClassID
		from Class
		where ClassID like @ClassID
	)
		return -1
	--RiderID has to exist if it isn't null
	if @RiderID is not null and not exists(
		select RiderID
		from Class
		where RiderID = @RiderID
	)
		return -1

	if @RiderID is NULL
		select *
		from Class as c
			outer join Riders as r
			on c.RiderID = r.RiderID
		where
			c.ClassID like @ClassID
	else
		select *
		from Class as c
			outer join Riders as r
			on c.RiderID = r.RiderID
		where
			c.ClassID like @ClassID and
			c.RiderID = @RiderID
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
@RiderID as int = null
as
	--ClassID can't be null or empty
	if @ClassID is null or @ClassID like ''
		return -1
	--ClassID has to exist
	if not exists(
		select ClassID
		from Class
		where ClassID like @ClassID
	)
		return -1
	--RiderID has to exist if it isn't null
	if @RiderID is not null and not exists(
		select RiderID
		from Class
		where RiderID = @RiderID
	)
		return -1

	
go

---Table Filling------------------------------------------------
