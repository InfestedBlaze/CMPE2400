--ica 13 demo

if exists(
	select *
	from sysobjects
	where name like 'sp_GetAuthors'
)
	drop procedure sp_GetAuthors
go

create procedure sp_GetAuthors
@authName as varchar(max) = ''
as
	select a.au_lname + ', ' + a.au_fname as 'Author'
	from PublishersDatabase.dbo.authors as a
	where a.au_lname like @authName + '%';
go

exec sp_GetAuthors
exec sp_GetAuthors 'S' -- can be a literal or a variable
exec sp_GetAuthors @authName = 'D' --param  = value