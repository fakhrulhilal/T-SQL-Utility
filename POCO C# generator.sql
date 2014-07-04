/* ----- CONFIGURATION ----- */
declare 
	@table varchar(max), --table name
	@enableAnnotation bit; --show data annotation?
set @table = 'TableName';
set @enableAnnotation = 1;
/* ----- END OF CONFIGURATION ----- */

declare 
	@column varchar(max), @length int, @type varchar(max), @isNullable bit, 
	@pocoType varchar(max), @attribute varchar(max),
	@poco varchar(max), @linebreak char(2), @enter char(1), @tab char(1), @totalPK int, @indexPK int, @isPK bit, @isFirstRow bit,
	@identitySeed bigint, @identityIncrement int;
declare @identities table(ColumnName varchar(max), Seed bigint, Increment int);
declare @primaryKeys table(ColumnName varchar(max));

set @enter = char(13);
set @tab = char(9);
set @linebreak = @enter + @tab;
set @isFirstRow = 1;
set nocount on;
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

declare cursorPoco cursor fast_forward for
	select
		COLUMN_NAME ColumnName,
		CHARACTER_MAXIMUM_LENGTH,
		DATA_TYPE,
		case IS_NULLABLE when 'YES' then 1 when 'NO' then 0 else null end IsNullable
	from information_schema.columns
	where
		TABLE_NAME = @table;

if (@enableAnnotation = 1)
	print '[Table("' + @table + '")]';
print 'public class ' + @table;
print '{';
open cursorPoco;
fetch cursorPoco into @column, @length, @type, @isNullable;
while @@FETCH_STATUS = 0
begin
	set @pocoType = '';
	set @poco = 'public ';
	set @isPK = 0;
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
	--determine wether column is primary key or not
	if exists (select 1 from @primaryKeys where ColumnName = @column)
	begin
		set @attribute = @attribute + '[Key]' + @linebreak;
		set @isPK = 1;
	end
	if (@isPK = 1 and @totalPK > 1)
	begin
		set @attribute = @attribute + '[Column("' + @column + '", Order = ' + cast(@indexPK as varchar) + ')]' + @linebreak;
		set @indexPK = @indexPK + 1;
	end
	else
		set @attribute = @attribute + '[Column("' + @column + '")]' + @linebreak;
	--determine wether column is identity or not
	select top 1
		@identitySeed = Seed,
		@identityIncrement = Increment
	from @identities
	where
		ColumnName = @column;
	if (@identityIncrement is not null and @identitySeed is not null)
	begin
		set @attribute = @attribute + '[DatabaseGenerated(DatabaseGeneratedOption.Identity)]' + @linebreak;
	end
	if (@type in ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext'))
	begin
		set @pocoType = 'string';
		if (@length is not null and @length > 0)
			set @attribute = @attribute + '[MaxLength(' + cast(@length as varchar) + ')]' + @linebreak;
		if (@isNullable = 0)
			set @attribute = @attribute + '[Required]' + @linebreak;
		if (@type in ('ntext', 'text'))
			set @attribute = @attribute + '[DataType(DataType.MultilineText)]' + @linebreak;
	end
	else
	begin
		if (@type = 'bigint')
			set @pocoType = 'long';
		else if (@type in ('tinyint', 'smallint'))
			set @pocoType = 'short';
		else if (@type in ('date', 'datetime', 'time'))
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
		else
			set @pocoType = @type;
		if (@isNullable = 1)
			set @pocoType = @pocoType + '?';
	end
	if (@enableAnnotation = 1)
		set @poco = @attribute + @poco + @pocoType + ' ' + @column + ' { get; set; }';
	else
		set @poco = @tab + @poco + @pocoType + ' ' + @column + ' { get; set; }';
	print @poco;
	fetch cursorPoco into @column, @length, @type, @isNullable;
end
close cursorPoco;
deallocate cursorPoco;
print '}';
set nocount off;