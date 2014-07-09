declare
	@table varchar(max), --table name
	@formatForeignKey varchar(max); --foreign key format
set @table = 'TableName';
set @formatForeignKey = 'Foreign key to !TABLE_NAME! field !COLUMN_NAME!. ';
--data preparation
if object_id('TempDB..#column') is not null
	drop table #column;
select 
	object_definition(c.default_object_id) DefaultValue, 
	case
		when t.name in ('bit', 'smallint', 'int', 'tinyint', 'bigint') then 2
		when t.name in ('datetime', 'date', 'datetime2') then 1
		when t.name in ('varchar', 'char', 'text') then 1
		when t.name in ('nvarchar', 'nchar') then 2
		else 0
	end LeftSubstractor,
	case
		when t.name in ('bit', 'smallint', 'int', 'tinyint', 'bigint') then 2
		when t.name in ('datetime', 'date', 'datetime2') then 1
		when t.name in ('varchar', 'char', 'nvarchar', 'nchar', 'text') then 1
		else 0
	end RightSubstractor,
	c.* 
into #column 
from sys.columns c
left join sys.types t on c.system_type_id = t.system_type_id and c.user_type_id = t.user_type_id;
if object_id('TempDB..#table') is not null
	drop table #table;
select * into #table from sys.tables;
if object_id('TempDB..#extended_properties') is not null
	drop table #extended_properties;
select * into #extended_properties from sys.extended_properties;
select top 1 sep.value [Table Description]
from #extended_properties sep
join #column sc on 
	sep.major_id = object_id(@table) 
	and sep.minor_id = 0
	and sep.name = 'MS_Description';
--exec sp_help @table
select 
	sc.column_id [No.],
	sc.name Field,
	case
		when [type].name in ('nvarchar', 'varchar', 'nchar', 'char', 'binary') and sc.max_length = -1 then [type].name + '(max)'
		when [type].name in ('nvarchar', 'varchar', 'nchar', 'char', 'binary') and sc.max_length <> -1 then [type].name + '(' + cast(sc.max_length as varchar) + ')'
		when [type].name in ('decimal', 'numeric') then [type].name + '(' + cast(sc.precision as varchar) + ',' + cast(sc.scale as varchar) +')'
		when [type].name in ('datetime2') then [type].name + '(' + cast(sc.scale as varchar) + ')'
		else [type].name
	end [Data Type],
	case sc.is_nullable
		when 1 then 'yes'
		else 'no'
	end Nullable,
	case when pk.ColumnId is not null then 'Primary Key. ' else '' end +
	case when sc.is_identity = 1 then 'Auto increment. ' else '' end +
	case when fk.ColumnTargetId is not null then replace(replace(@formatForeignKey, '!TABLE_NAME!', fk.TableTargetName), '!COLUMN_NAME!', fk.ColumnTargetName) else '' end + 
	case when cc.Formula is not null then 'Computed -> ' + substring(cc.Formula, 2, len(cc.Formula) - 2) + '. ' else '' end +
	case when sep.value is not null then cast(sep.value as varchar(max)) else '' end + ' ' +
	case when sc.DefaultValue is not null then 'Default: ' + substring(sc.DefaultValue, sc.LeftSubstractor + 1, len(sc.DefaultValue) - sc.LeftSubstractor - sc.RightSubstractor) + '. ' else '' end
	[Description]
from #table st
inner join #column sc on st.object_id = sc.object_id
left join sys.types [type] on 
	sc.system_type_id = [type].system_type_id
	and sc.user_type_id = [type].user_type_id
left join #extended_properties sep on 
	st.object_id = sep.major_id
    and sc.column_id = sep.minor_id
    and sep.name = 'MS_Description'
--search for foreign key
left join (
	select 
		fk.name RelationName,
		t1.object_id TableSourceId,
		t1.name TableSourceName,
		sc1.column_id ColumnSourceId,
		sc1.name ColumnSourceName,
		t2.object_id TableTargetId,
		convert(varchar(100), t2.name) collate DATABASE_DEFAULT TableTargetName,
		sc2.column_id ColumnTargetId,
		convert(varchar(100), sc2.name) collate DATABASE_DEFAULT ColumnTargetName
	from sys.foreign_keys fk
	left join #table t1 on fk.parent_object_id = t1.object_id
	left join #table t2 on fk.referenced_object_id = t2.object_id
	left join sys.foreign_key_columns fkc on fk.object_id = fkc.constraint_object_id
	left join #column sc1 on t1.object_id = sc1.object_id and sc1.column_id = fkc.parent_column_id
	left join #column sc2 on t2.object_id = sc2.object_id and sc2.column_id = fkc.referenced_column_id
	where
		t1.name = @table
) fk on 
	fk.TableSourceId = st.object_id
	and sc.column_id = fk.ColumnSourceId
--search for primary key
left join (
	select
		i.object_id TableId,
		c.column_id ColumnId,
		c.name ColumnName
	from sys.indexes i
	left join sys.index_columns ic on 
		i.object_id = ic.object_id
		and i.index_id = ic.index_id
	left join #column c on 
		i.object_id = c.object_id
		and ic.column_id = c.column_id
	left join #table t on i.object_id = t.object_id
	where
		t.name = @table
		and i.is_primary_key = 1
) pk on 
	st.object_id = pk.TableId
	and sc.column_id = pk.ColumnId
--search for computed columns
left join (
	select 
		cc.object_id TableId,
		cc.column_id ColumnId,
		cc.definition Formula
	from sys.computed_columns cc
) cc on 
	cc.TableId = st.object_id
	and cc.ColumnId = sc.column_id
where
	st.name = @table
order by sc.column_id asc;
