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
	declare @looperBike as int = 0;
	declare @looperMake as int = 0;
	declare @looperTime as int = 0;
	declare @maker as nvarchar(3) = 'HYS'
	declare @timer as nvarchar(2) = 'AP'

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
		set @ErrorMessage  = 'RemoveBike : ‘ + @BikeID + ‘ Currently in Session' 
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
	insert Riders ([Name], [ClassID])
	values (@Name, @ClassID);
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
	declare @count as int
	select 
		@count = count(s.RiderID)
	from Sessions as s
	where s.RiderID = @RiderID

	if @count > 0 and @force = 0
		return -1

	if @force = 1
		delete Sessions
		where Sessions.RiderID = @RiderID

	delete Riders
	where Riders.RiderID = @RiderID
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
as
	
go

if exists(
	select *
	from sysobjects
	where name like 'UpdateSession'
)
	drop procedure UpdateSession
go
create procedure UpdateSession
as
	
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
as
	
go

if exists(
	select *
	from sysobjects
	where name like 'ClassInfo'
)
	drop procedure ClassInfo
go
create procedure ClassInfo
as
	
go

if exists(
	select *
	from sysobjects
	where name like 'ClassSummary'
)
	drop procedure ClassSummary
go
create procedure ClassSummary
as
	
go

---Error Testing-----------------------------------------