/*==============================================================*/
/* Table: Mst_Table                                             */
/*==============================================================*/
--drop create table
if exists (select 1
	from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	where r.fkeyid = object_id('Mst_Table') and o.name = 'FK_Table_Target')
	alter table Mst_Table
		drop constraint FK_Table_Target;
go
if exists (select 1
	from sysobjects
	where id = object_id('Mst_Table') and  type = 'U')
	drop table Mst_Table;
go
create table Mst_Table (
	Id bigint identity(-9223372036854775808,1) not null,
	Code varchar(50) not null,
	Name varchar(max) not null,
	IsActive bit not null default(1),
	CreatedTime datetime not null default(getdate()),
	CreatedBy nvarchar(50) not null default(N'SYSTEM'),
	ModifiedTime datetime null,
	ModifiedBy nvarchar(50) null
constraint PK_Mst_Table primary key clustered 
(
	Id asc
)with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [primary]
) on [primary]
go
alter table Mst_Table with nocheck 
	add constraint FK_Table_Target foreign key(TargetId)
		references Mst_Target (Id)
go
alter table Mst_Table nocheck constraint FK_Table_Target
go
/*==============================================================*/
/* Table: Mst_Table                                             */
/*==============================================================*/
--create index
if not exists (select 1
	from sys.indexes
	where name = 'Idx_Table' and object_id = object_id(N'Mst_Table'))
	--drop index Idx_Table on Mst_Table;
	create nonclustered index Idx_Table ON Mst_Table 
	(
		Code ASC,
		[Status] ASC
	) on [primary]
go
/*==============================================================*/
/* Table: Mst_Table                                             */
/*==============================================================*/
--CUD kolom
if not exists (select 1 
	from sys.columns 
	where Name = N'ColumnName' and Object_ID = Object_ID(N'Mst_Table'))
	alter table Mst_Table
		add ColumnName int null;
go
if exists (select 1 
	from sys.columns 
	where Name = N'OldColumnName' and Object_ID = Object_ID(N'Mst_Table'))
	exec sp_rename @objname='Mst_Table.OldColumnName', @newname='NewColumnName', @objtype='COLUMN';
go
if exists (select 1 
	from sys.columns 
	where Name = N'ColumnName' and Object_ID = Object_ID(N'Mst_Table'))
	alter table Mst_Table 
		alter column ColumnName decimal(20,5) null;
if exists (select 1 
	from sys.columns 
	where Name = N'ColumnName' and Object_ID = Object_ID(N'Mst_Table'))
	alter table Mst_Table 
		drop column ColumnName;
/*==============================================================*/
/* Type: TUserDefinedType                                       */
/*==============================================================*/
if TYPE_ID('TUserDefinedType') is not null
	drop type TUserDefinedType;
go
-- user defined table/scalar type
create type TUserDefinedType as table
(
	Id int null,
	Code nvarchar(max) null,
	Name varchar(max) null,
	Quantity int null,
	Total decimal(20,5) null
)
go
/*==============================================================*/
/* SP: SP_Mod_ModuleName                                        */
-- Implementation of......
/*==============================================================*/
if exists (select 1 
	from sys.objects 
	where 
		object_id = OBJECT_ID(N'SP_Mod_ModuleName') and 
		type in (N'P', N'PC'))
	drop procedure SP_Mod_ModuleName;
go

create procedure SP_Mod_ModuleName as
begin
	select 1;
end
/*==============================================================*/
/* UDF: FN_NumberFormat                                         */
--Digunakan memformat angka, diawali dengan nol sebanyak X digit
/*==============================================================*/
if exists (select 1 
	from sys.objects 
	where 
		object_id = OBJECT_ID(N'[dbo].[FN_NumberFormat]') and 
		type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function FN_NumberFormat;
go
create function dbo.FN_NumberFormat(@p_Number bigint, @p_Length int) returns nvarchar(max) as
begin
	return RIGHT(REPLICATE('0', @p_Length) + cast(@p_Number as nvarchar), @p_Length) ;
end
go
/*==============================================================*/
/* UDF: FN_NumberFormat                                         */
--Digunakan untuk mengambil susunan hirarki tree downline
/*==============================================================*/
if exists (select 1 
	from sys.objects 
	where 
		object_id = OBJECT_ID(N'[dbo].[FN_AgentTeam]') and 
		type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function FN_AgentTeam;
go
create function dbo.FN_AgentTeam(@p_AgentId bigint, @p_IsActive bit = null) 
	returns @agentTeam table(
		LeaderId bigint null,
		LeaderLevelNumber int null,
		LeaderDistributionChannelId int null,
		LeaderBranchCode nvarchar(25) null,
		DownlineId bigint null,
		DownlineLevelNumber int null,
		DownlineDistributionChannelId int null,
		DownlineBranchCode nvarchar(25) null,
		DownlineIsActive bit null,
		NestedLevel int null
	) as
begin
	set @p_IsActive = ISNULL(@p_IsActive, 1);
	with Agent_Subtree(
		leaderId, leaderLevelNumber, leaderDistributionChannelId, leaderBranchCode,
		downlineId, downlineLevelNumber, downlineDistributionChannelId, downlineBranchCode, downlineIsActive, nestedLevel)
	as (
		-- anchor member
		select 
			leader.Id,
			alLeader.LevelNumber,
			bLeader.DistributionChannelId,
			bLeader.BranchCode,
			downline.Id,
			alDownline.LevelNumber,
			bDownline.DistributionChannelId,
			bDownline.BranchCode,
			downline.IsActive,
			1
		from Mst_Agent downline
		join Mst_AgentLevel alDownline on downline.AgentLevelId = alDownline.Id
		join Mst_Branch bDownline on downline.BranchId = bDownline.Id
		join Mst_Agent leader on downline.AgentLeadedById = leader.Id
		join Mst_AgentLevel alLeader on leader.AgentLevelId = alLeader.Id
		join Mst_Branch bLeader on leader.BranchId = bLeader.Id
		where
			downline.IsDeleted = 0
			and downline.IsActive = case @p_IsActive
				when 0 then downline.IsActive -- jika diisi dengan 0, asumsinya mencari semua agent yg aktif & non aktif
				else @p_IsActive
			end
			and leader.Id = @p_AgentId

		union all
		   
		-- recursive member
		select 
			downlineTree.downlineId,
			downlineTree.downlineLevelNumber,
			downlineTree.downlineDistributionChannelId,
			downlineTree.downlineBranchCode,
			downline.Id,
			alDownline.LevelNumber,
			bDownline.DistributionChannelId,
			bDownline.BranchCode,
			downline.IsActive,
			(downlineTree.nestedLevel + 1)
		from Mst_Agent downline
		join Mst_AgentLevel alDownline on downline.AgentLevelId = alDownline.Id
		join Mst_Branch bDownline on downline.BranchId = bDownline.Id
		join Agent_Subtree downlineTree on downlineTree.downlineId = downline.AgentLeadedById
		where
			downline.IsDeleted = 0
			and downline.IsActive = case @p_IsActive
				when 0 then downline.IsActive -- jika diisi dengan 0, asumsinya mencari semua agent yg aktif & non aktif
				else @p_IsActive
			end
		--order by alDownline.LevelNumber asc
	)
	insert into @agentTeam(
		LeaderId, LeaderLevelNumber, LeaderDistributionChannelId, LeaderBranchCode, 
		DownlineId, DownlineLevelNumber, DownlineDistributionChannelId, DownlineBranchCode, DownlineIsActive, NestedLevel)
	select 
		leaderId, leaderLevelNumber, leaderDistributionChannelId, leaderBranchCode,
		downlineId, downlineLevelNumber, downlineDistributionChannelId, downlineBranchCode, downlineIsActive, nestedLevel 
	from Agent_Subtree;
	return;
end
go
/*==============================================================*/
/* Table: Mst_Table                                             */
/*==============================================================*/
--create primary key
if not exists(select * 
	from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	where 
		CONSTRAINT_TYPE = 'PRIMARY KEY'
		and TABLE_NAME = 'Mst_Table')
	alter table Mst_Table
		add constraint PK_Mst_Table primary key(Column1, Column2);
go
/*==============================================================*/
/* Table: Mst_Table                                             */
-- Log audit for any change in table
-- action: insert modified (delete, update, insert) to audit table
/*==============================================================*/
if OBJECT_ID('TG_Audit_Table', 'TR') is not null
	drop trigger TG_Audit_Table;
go

create trigger TG_Audit_Table
	on Mst_Table
	for insert, update, delete
as
begin
	-- audit data
	declare @action nvarchar(max), @time datetime, @actor nvarchar(max), @detail nvarchar(max), @primaryKey int, @table nvarchar(max), @changes nvarchar(max);
	-- query data
	declare 
		@oldCode nvarchar(max), @oldName nvarchar(max), @oldIsDeleted bit,
		@newCode nvarchar(max), @newName nvarchar(max), @newIsDeleted bit;
	set @table = 'Table';
	-- event: update
	if exists(select 1 from inserted) and exists(select 1 from deleted)
	begin
		set @action = 'update';
		-- query old data
		select
			@time = d.ModifiedTime,
			@actor = d.ModifiedBy,
			@primaryKey = d.Id,
			@oldCode = d.Code,
			@oldName = d.Name,
			@oldIsDeleted = d.IsDeleted
		from deleted d;
		-- query new data
		select
			@time = i.CreatedTime,
			@actor = i.CreatedBy,
			@primaryKey = i.Id,
			@newCode = i.Code,
			@newName = i.Name,
			@newIsDeleted = i.IsDeleted
		from inserted i;
		-- compare what's changed
		set @changes = '';
		if @oldCode <> @newCode
			set @changes = @changes + '; Code: ' + @oldCode + ' -> ' + @newCode;
		if @oldName <> @newName
			set @changes = @changes + '; Name: ' + @oldName + ' -> ' + @newName;
		-- special case for table that has IsDeleted field
		if @newIsDeleted = 1
		begin
			set @action = 'delete';
			set @changes = '';
		end
		set @detail = @actor + ' ' + @action + ' ' + ' Table (PK = ' + CONVERT(nvarchar, @primaryKey) + ') ' + @changes;
	end
	-- event: insert
	else if exists (select 1 from inserted)
	begin
		set @action = 'insert';
		select
			@time = i.CreatedTime,
			@actor = i.CreatedBy,
			@primaryKey = i.Id,
			@newCode = i.Code,
			@newName = i.Name
		from inserted i;
		set @detail = @actor + ' ' + @action + ' ' + ' new Table (PK = ' + CONVERT(nvarchar, @primaryKey) + '): Code = ' + @newCode + '; Name = ' + @newName;
	end
	-- event: delete
	else if exists (select 1 from deleted)
	begin
		set @action = 'delete';
		select
			@time = d.ModifiedTime,
			@actor = d.ModifiedBy,
			@primaryKey = d.Id,
			@oldCode = d.Code,
			@oldName = d.Name
		from deleted d;
		set @detail = @actor + ' ' + @action + ' ' + ' Table (PK = ' + CONVERT(nvarchar, @primaryKey) + '): Code = ' + @oldCode + '; Name = ' + @oldName;
	end
	else
	begin
		set @action = 'unknown';
		set @detail = 'Unknown action to Table';
	end 
		
	--insert to audit table
	insert into Mst_AuditLog(IssueTime, [Object], Actor, [Action], Detail)
	values (@time, @table, @actor, @action, @detail);
end
go

