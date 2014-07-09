if TYPE_ID('TDocumentation') is null
	-- user defined table/scalar type
	create type TDocumentation as table
	(
		TableName varchar(50),
		ColumnName varchar(50), --gunakan '#TABLE#' untuk description table
		[Description] varchar(1000) null
	)
go
if exists (select 1 
	from sys.objects 
	where object_id = OBJECT_ID(N'SaveDocumentation') and type in (N'P', N'PC'))
	drop procedure SaveDocumentation;
go
create procedure SaveDocumentation(@docs TDocumentation readonly) as
begin
	declare @no int, @schema varchar(max), @table varchar(max), @column varchar(max), @description varchar(1000);
	select ROW_NUMBER() OVER(order by TableName, ColumnName) RowNumber, * into #docs from @docs;
	set @schema = SCHEMA_NAME();
	set @no = 1;
	while exists(select 1 from #docs where RowNumber = @no)
	begin
		select
			@table = TableName,
			@column = ColumnName,
			@description = [Description]
		from #docs
		where RowNumber = @no;
		if (@table = '#DATABASE#')
		begin
			if exists (select 1 
				from sys.extended_properties sep
				where sep.name = 'MS_Description' and sep.major_id = 0 and sep.minor_id = 0 and sep.class = 0)
				exec sp_dropextendedproperty @name = N'MS_Description';
			exec sp_addextendedproperty @name = N'MS_Description', @value = @description;
		end
		else if (@column = '#TABLE#')
		begin
			if exists (select 1 
				from sys.extended_properties sep
				join sys.tables st on sep.major_id = st.object_id
				join sys.columns sc on st.object_id = sc.object_id and sep.minor_id = 0
				where sep.name = 'MS_Description' and st.name = @table)
				exec sp_dropextendedproperty @name = N'MS_Description', @level0type = N'Schema', @level0name = @schema, @level1type = N'Table',  @level1name = @table;
			exec sp_addextendedproperty @name = N'MS_Description', @value = @description, @level0type = N'Schema', @level0name = @schema, @level1type = N'Table',  @level1name = @table;
		end
		else
		begin
			if exists (select 1 
				from sys.extended_properties sep
				join sys.tables st on sep.major_id = st.object_id
				join sys.columns sc on st.object_id = sc.object_id and sep.minor_id = sc.column_id
				where sep.name = 'MS_Description' and sc.name = @column and st.name = @table)
				exec sp_dropextendedproperty @name = N'MS_Description', @level0type = N'Schema', @level0name = @schema, @level1type = N'Table',  @level1name = @table, @level2type = N'Column', @level2name = @column;
			exec sp_addextendedproperty @name = N'MS_Description', @value = @description, @level0type = N'Schema', @level0name = @schema, @level1type = N'Table',  @level1name = @table, @level2type = N'Column', @level2name = @column;
		end
		set @no = @no + 1;
	end
end
go
/******************************************************/
/* START: Documentation                               */
/******************************************************/
declare @documentation TDocumentation
insert into @documentation(TableName, ColumnName, [Description]) values
('#DATABASE#', '', 'Database description'),
('Table', '#TABLE#', 'Table description'),
('Table', 'Column1', 'Table.Column1 description'),
('Table', 'Column2', 'Table.Column2 description');
exec SaveDocumentation @documentation;
go
/******************************************************/
/* END: Documentation                                 */
/******************************************************/
drop procedure SaveDocumentation;
drop type TDocumentation;
go