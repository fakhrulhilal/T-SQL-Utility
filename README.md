T-SQL Utility
=============

Various T-SQL script for managing SQL server database

## Database Documentation

There are two documentor: 

- Individual table: (use `Documentation generator (table).sql`) which used to generate table like output. You can use it for preview table documentation. I use it by copy paste to my database documentation in word.
- All table: (use `Documentation generator (HTML).sql`) which used to generate all table documentation. It will generate HTML code in output window. Just copy paste it in your favorite editor and save it as HTML file. You can also export it to Microsoft Word by open generated HTML in Microsoft Word and _save as_ Word file

### How does it work

Basically, it will scan extended attribute `MS_Description` which is widely used for documenting SQL server database. In SQL Management Studio, it is located in Description field per column. For table and database, you must **add it manually** by right click table/database and click `Properties` and select `Extended Properties`, fill name with `MS_Description` and write your description in value.

Or you can use `Documentation editor.sql`, please refer to `START: Documentation` section, I give it some example as below:
```sql
/******************************************************/
/* START: Documentation                               */
/******************************************************/
declare @documentation TDocumentation
insert into @documentation(TableName, ColumnName, [Description]) values
('#DATABASE#', '', 'Database description'), --this is for database description
('Table', '#TABLE#', 'Table description'), --this is for table description
('Table', 'Column1', 'Table.Column1 description'), --this is for column description
('Table', 'Column2', 'Table.Column2 description');
exec SaveDocumentation @documentation;
go
/******************************************************/
/* END: Documentation                                 */
/******************************************************/
```

### What does it support

Currently, it only supports for table documentation. I hope, I can support for stored procedure. For detail, it generate additional description for:

- Primary key
- Foreign key (set its format by changing `@formatForeignKey` variable value)
- Generated field: identity and computed
- Field with default value

## .NET POCO Generator

There're two POCO generator: for C# (`POCO C# generator.sql`) and VB.NET (`POCO VB.NET generator.sql`). I use it to generate POCO class for my project. You can read my blog posts[^C-Sharp POCO][^VB.NET POCO]

## T-SQL Database Patch Template

This script (`Database patch template.sql`) is used to generate table patch. I prefer to use it than editing using designer, because I'm working with local and remote database. So I create and test patch script in local database, and execute it in remote database. I also prefer to create table using this script than designer, because I can copy paste similiar table. I've many tables which have standar field for master table (Id, Code, Name, IsActive, CreatedBy, CreatedTime, ModifiedBy, ModifiedTime). So it make me faster for creating table.

### What does it support

Currently, it supports for:

- Drop create table with foreign key
- Create index (unclustered)
- User defined table type
- Create, update, delete field in table
- Stored procedure
- User defined function
- Primary key
- Trigger
 

Feel free to fork my repo :-)


[^C-Sharp POCO]: [T-SQL C# POCO Generator](http://blog.fakhrulhilal.com/post/70766076969/t-sql-c-poco-generator)
[^VB.NET POCO]: [T-SQL VB.NET POCO Generator](http://blog.fakhrulhilal.com/post/72161861229/t-sql-vb-net-poco-generator)