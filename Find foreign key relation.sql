declare @fk varchar(max), @destinationTable varchar(max), @sourceTable varchar(max);
--set @fk = 'FK_TableSource_Target';
--set @destinationTable = 'DestinationTable';
--set @sourceTable = 'SourceTable';

with 
	cte_tables as (select t.[object_id], t.name from sys.tables t),
	cte_columns as (select c.[object_id], c.column_id, c.name from sys.columns c)
select 
	fk.name [Foreign Key Name],
	t1.name + '.' + c1.name [Foreign Key Column],
	t2.name + '.' + c2.name [Reference To],
	fk.delete_referential_action_desc [On Delete],
	fk.update_referential_action_desc [On Update]
from sys.foreign_keys fk
join cte_tables t1 on fk.parent_object_id = t1.object_id
join cte_tables t2 on fk.referenced_object_id = t2.object_id
join sys.foreign_key_columns fkc on fk.object_id = fkc.constraint_object_id
join cte_columns c1 on fkc.parent_column_id = c1.column_id and t1.object_id = c1.object_id
join cte_columns c2 on fkc.referenced_column_id = c2.column_id and t2.object_id = c2.object_id
where 
	fk.name = isnull(@fk, fk.name) and fk.[type] = 'F'
	and t1.name = isnull(@sourceTable, t1.name)
	and t2.name = isnull(@destinationTable, t2.name)
