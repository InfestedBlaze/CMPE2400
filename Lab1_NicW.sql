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


----Stored Procedures--------------------------------------

--Shell
--if exists(
--	select *
--	from sysobjects
--	where name like 'ica13_01'
--)
--	drop procedure ica13_01
--go
--create procedure ica13_01
--@input as int,
--@output as int output
--as
--	return 0  --Success
--	return -1 --Failure
--go


if exists(
	select *
	from sysobjects
	where name like 'PopulateBikes'
)
	drop procedure PopulateBikes
go
create procedure PopulateBikes
as
	
go