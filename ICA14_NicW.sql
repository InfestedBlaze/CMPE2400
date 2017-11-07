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
as
	
go

exec ica14_01
go