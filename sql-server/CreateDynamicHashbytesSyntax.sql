DECLARE @TableSchema AS VARCHAR(4) = 'tmp'
DECLARE @TableName AS VARCHAR(30) = 'DimEmployee'
DECLARE @TablePrefix AS VARCHAR(3) = '[T]'

DECLARE @Columns AS VARCHAR(8000)
DECLARE @Sql AS NVARCHAR(4000)
SELECT @Columns = COALESCE(@Columns + ', ', '') + @TablePrefix +  '.[' + c.[COLUMN_NAME] + ']'
FROM     information_schema.columns c
         INNER JOIN information_schema.tables t
           ON c.table_name = t.table_name
              AND c.table_schema = t.table_schema
              AND t.table_type = 'BASE TABLE'
			  AND t.[TABLE_SCHEMA] = @TableSchema
			  AND COLUMNPROPERTY(object_id(t.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') = 0
WHERE t.[TABLE_NAME] = @TableName

SET @SQL = 'HASHBYTES(''sha'', CONCAT('  + @Columns + '))'

PRINT @SQL

