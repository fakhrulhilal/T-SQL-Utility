/* ----- CONFIGURATION ----- */
declare 
	@table varchar(max), --table name
	@enableAnnotation bit, --show data annotation?
	@enableColumnAnnotation bit, --show data 'Column' annotation? ignored when @enableAnnotation = 0
	@enableDocumentation bit, --show table documentation?
	@tableAnnotation varchar(50) = 'Alias', -- table annotation if the entity name is different with table name, default: Table
	@columnAnnotation varchar(50) = 'Alias', -- column annotation if the property name is different with column name, default: Column
	@primaryKeyAnnotation varchar(50) = 'PrimaryKey', -- primary key annotation, default: Key
	@identityAnnotation varchar(50) = 'AutoIncrement', -- annotation for auto generated number, default: DatabaseGenerated(DatabaseGeneratedOption.Identity)
	@useC6 bit = 1 -- Use C# v6.0 style?
set @table = 'Table';
set @enableAnnotation = 1;
set @enableColumnAnnotation = 1;
set @enableDocumentation = 1;
/* ----- END OF CONFIGURATION ----- */

declare 
	@column varchar(max), @length int, @type varchar(max), @isNullable bit, 
	@pocoType varchar(max), @attribute varchar(max),
	@poco varchar(max), @linebreak char(2), @linebreak3 char(3), @enter char(1), @tab char(1), @totalPK int, @indexPK int, @isPK bit, @isFirstRow bit,
	@identitySeed bigint, @identityIncrement int, @counter int, @totalDefaultValue int, @defaultValues varchar(max), @defaultValue varchar(max), @printableDefaultValue varchar(max),
	@docTable varchar(max), @docColumn varchar(max), @documentation varchar(max);
declare @identities table(ColumnName varchar(max), Seed bigint, Increment int);
declare @primaryKeys table(ColumnName varchar(max));

set @enter = char(13);
set @tab = char(9);
set @linebreak = @enter + @tab;
set @linebreak3 = @enter + @tab + @tab;
set @isFirstRow = 1;
set @counter = 1;
set @totalDefaultValue = 0;
set @defaultValues = '';
set nocount on;
--data preparation
--type
if object_id('[TempDB]..[#type]') is not null
	drop table #type;
select * into #type from sys.types;
--find database documentation
if object_id('[TempDB]..[#extended_properties]') is not null
	drop table #extended_properties;
select * into #extended_properties from sys.extended_properties;
--column
if object_id('[TempDB]..[#column]') is not null
	drop table #column;
select 
	ROW_NUMBER() OVER(order by c.column_id) RowNumber,
	case when sep.value is not null then convert(varchar(max), sep.value) end Documentation,
	t.name TypeName,
	object_definition(c.default_object_id) DefaultValue, 
	case
		when t.name in ('bit', 'smallint', 'int', 'tinyint', 'bigint', 'numeric', 'float', 'decimal') then 2
		when t.name in ('datetime', 'date', 'datetime2') then 1
		when t.name in ('varchar', 'char', 'nvarchar', 'nchar', 'text') then 2
		else 0
	end LeftSubstractor,
	case
		when t.name in ('bit', 'smallint', 'int', 'tinyint', 'bigint', 'numeric', 'float', 'decimal') then 2
		when t.name in ('datetime', 'date', 'datetime2') then 1
		when t.name in ('varchar', 'char', 'nvarchar', 'nchar', 'text') then 2
		else 0
	end RightSubstractor,
	case 
		when c.max_length = -1 then -1
		when t.name in ('nvarchar', 'nchar') then c.max_length / 2
		when t.name in ('varchar', 'char') then c.max_length
		else null
	end MaximumLength,
	c.* 
into #column 
from sys.columns c
left join sys.types t on c.system_type_id = t.system_type_id and c.user_type_id = t.user_type_id
left join #extended_properties sep on sep.major_id = object_id(@table) and sep.name = 'MS_Description' and sep.minor_id = c.column_id
where c.object_id = object_id(@table);
--find all primary key
insert into @primaryKeys(ColumnName)
select ccu.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu on tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
where
	tc.CONSTRAINT_TYPE = 'Primary Key'
	and tc.TABLE_NAME = @table;
select @totalPK = count('') from @primaryKeys;
set @indexPK = 0;
--find all identity columns 
insert into @identities(ColumnName, Seed, Increment)
select
	id.name,
	cast(id.seed_value as bigint),
	cast(id.increment_value as int)
from 
	sys.identity_columns as id inner join sys.objects as so
	on object_name(id.object_id)=so.name
where 
	so.type='u'
	and so.name = @table
	and id.is_identity = 1
--find table documentation
select top 1 @docTable = convert(varchar(max), sep.value)
from #extended_properties sep
join #column sc on 
	sep.major_id = object_id(@table) 
	and sep.minor_id = 0
	and sep.name = 'MS_Description';
if (@enableDocumentation = 1 and @docTable is not null)
begin
	print '/// <Summary>';
	print '/// ' + @docTable;
	print '/// </Summary>';
end
if (@enableAnnotation = 1)
	print '[' + @tableAnnotation + '("' + @table + '")]';
--determine wether table has default value or not
select @totalDefaultValue = count('')
from #column c
where c.DefaultValue is not null
print 'public class ' + @table;
print '{';
set @counter = 1;
while exists (select 1 from #column where RowNumber = @counter)
begin
	set @printableDefaultValue = null;
	select
		@column = c.name,
		@docColumn = c.Documentation,
		@type = c.TypeName,
		@isNullable = c.is_nullable,
		@length = c.MaximumLength,
		@defaultValue = substring(c.DefaultValue, c.LeftSubstractor + 1, len(c.DefaultValue) - c.LeftSubstractor - c.RightSubstractor)
	from #column c
	where c.RowNumber = @counter;
	set @pocoType = '';
	set @poco = 'public ';
	set @isPK = 0;
	set @documentation = '';
	set @identitySeed = null;
	set @identityIncrement = null;
	if (@isFirstRow = 1)
	begin
		set @attribute = @tab;
		set @isFirstRow = 0;
	end
	else
	begin
		set @attribute = @linebreak;
	end
	--generate documentation
	if (@enableDocumentation = 1 and @docColumn is not null)
	begin
		set @documentation = @documentation + @enter + @tab +'/// <Summary>' + @lineBreak;
		set @documentation = @documentation + '/// ' + @docColumn + @lineBreak;
		set @documentation = @documentation + '/// </Summary>';
	end
	--determine wether column is primary key or not
	if exists (select 1 from @primaryKeys where ColumnName = @column)
	begin
		set @attribute = @attribute + '[' + @primaryKeyAnnotation + ']' + @linebreak;
		set @isPK = 1;
	end
	if (@isPK = 1 and @totalPK > 1)
	begin
		set @attribute = @attribute + '[' + @columnAnnotation + '("' + @column + '", Order = ' + cast(@indexPK as varchar) + ')]' + @linebreak;
		set @indexPK = @indexPK + 1;
	end
	else if (@enableColumnAnnotation = 1)
		set @attribute = @attribute + '[' + @columnAnnotation + '("' + @column + '")]' + @linebreak;
	--determine wether column is identity or not
	select top 1
		@identitySeed = Seed,
		@identityIncrement = Increment
	from @identities
	where
		ColumnName = @column;
	if (@identityIncrement is not null and @identitySeed is not null)
	begin
		set @attribute = @attribute + '[' + @identityAnnotation + ']' + @linebreak;
	end
	if (@type in ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext'))
	begin
		set @pocoType = 'string';
		if (@isNullable = 0)
			set @attribute = @attribute + '[Required]' + @linebreak;
		if (@length is not null and @length > 0)
			set @attribute = @attribute + '[MaxLength(' + cast(@length as varchar) + ')]' + @linebreak;
		if (@type in ('ntext', 'text'))
			set @attribute = @attribute + '[DataType(DataType.MultilineText)]' + @linebreak;
		if (@defaultValue is not null)
		begin
			set @printableDefaultValue = '"' + @defaultValue + '"';
			set @defaultValues = @defaultValues + @linebreak3 + @column + ' = ' + @printableDefaultValue + ';';
		end
	end
	else
	begin
		if (@type = 'bigint')
			set @pocoType = 'long';
		else if (@type in ('tinyint', 'smallint'))
			set @pocoType = 'short';
		else if (@type in ('date', 'datetime', 'datetime2', 'time'))
		begin
			set @pocoType = 'System.DateTime';
			if (@type = 'date')
				set @attribute = @attribute + '[DataType(DataType.Date)]' + @linebreak;
			else if (@type = 'time')
				set @attribute = @attribute + '[DataType(DataType.Time)]' + @linebreak;
		end
		else if (@type = 'bit')
			set @pocoType = 'bool';
		else if (@type in ('decimal', 'money', 'numeric', 'smallmoney'))
		begin
			set @pocoType = 'decimal';
			if (@type in ('money', 'smallmoney'))
				set @attribute = @attribute + '[DataType(DataType.Currency)]' + @linebreak;
		end
		else if (@type = 'binary')
			set @pocoType = 'byte[]';
		else if (@type = 'uniqueidentifier')
			set @pocoType = 'System.Guid';
		else
			set @pocoType = @type;
		if (@isNullable = 1 and @type not in ('binary'))
			set @pocoType = @pocoType + '?';
		if (@defaultValue is not null)
		begin
			if (@type in ('bigint', 'int', 'tinyint', 'smallint', 'decimal', 'money', 'smallmoney', 'numeric'))
			begin
				set @printableDefaultValue = @defaultValue;
				set @defaultValues = @defaultValues + @linebreak3 + @column + ' = ' + @printableDefaultValue + ';';
			end
			else if (@type in ('date', 'time', 'datetime', 'datetime2'))
			begin
				if (@defaultValue = 'getdate()')
				begin
					set @printableDefaultValue = case @type when 'date' then 'System.DateTime.Now.Date;' else 'System.DateTime.Now;' end;
					set @defaultValues = @defaultValues + @linebreak3 + @column + ' = ' + @printableDefaultValue + ';';
				end
			end
			else if (@type = 'bit')
			begin
				set @printableDefaultValue = case @defaultValue when '1' then 'true' else 'false' end;
				set @defaultValues = @defaultValues + @linebreak3 + @column + ' = ' + @printableDefaultValue + ';';
			end
		end
	end
	if (@enableAnnotation = 1)
		set @poco = @documentation + @attribute + @poco + @pocoType + ' ' + @column + ' { get; set; }';
	else
		set @poco = @tab + @documentation + @poco + @pocoType + ' ' + @column + ' { get; set; }';
	if (@printableDefaultValue is not null and @useC6 = 1)
		set @poco = @poco + ' = ' + @printableDefaultValue + ';';
	print @poco;
	set @counter = @counter + 1;
end
if (@totalDefaultValue > 0 and @useC6 = 0)
begin
	print @lineBreak + 'public ' + @table + '()';
	print @tab + '{' + @defaultValues + @linebreak + '}';
end
print '}';
set nocount off;
