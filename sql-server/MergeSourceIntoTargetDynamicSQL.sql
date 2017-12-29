/****** Object:  StoredProcedure [dbo].[msp_MergeSourceIntoTarget]    Script Date: 12/29/2017 1:09:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Nick Heidke
-- Create Date: 2017-08-30
-- Description: Constructs a merge statement to merge data into target from source then executes that statement
-- =============================================
CREATE PROCEDURE [dbo].[msp_MergeSourceIntoTarget] (
	@SourceTable AS VARCHAR(255),
	@SourceSchema AS VARCHAR(50),
	@TargetTable AS VARCHAR(255),
	@TargetSchema AS VARCHAR(50),
	@KeyColumn AS VARCHAR(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL AS NVARCHAR(MAX) = '';
	DECLARE @Columns AS VARCHAR(MAX);
	DECLARE @SourceColumns AS VARCHAR(MAX);
	DECLARE @TargetColumns AS VARCHAR(MAX);
	DECLARE @SetColumns AS VARCHAR(MAX);

	SELECT @SourceColumns = COALESCE(@SourceColumns + ', ', '') + '[S].[' + [c].[COLUMN_NAME] + ']'
	FROM [INFORMATION_SCHEMA].[COLUMNS] [c]
INNER	JOIN [INFORMATION_SCHEMA].[TABLES] [t]
	ON [c].[TABLE_NAME] = [t].[TABLE_NAME]
	AND [c].[TABLE_SCHEMA] = [t].[TABLE_SCHEMA]
	AND [t].[TABLE_TYPE] = 'BASE TABLE'
	AND [t].[TABLE_SCHEMA] = @SourceSchema
	AND COLUMNPROPERTY(OBJECT_ID([t].[TABLE_NAME]), [c].[COLUMN_NAME], 'IsIdentity') = 0
	WHERE [t].[TABLE_NAME] = @SourceTable;

	SELECT @TargetColumns = COALESCE(@TargetColumns + ', ', '') + '[T].[' + [c].[COLUMN_NAME] + ']'
	FROM [INFORMATION_SCHEMA].[COLUMNS] [c]
INNER	JOIN [INFORMATION_SCHEMA].[TABLES] [t]
	ON [c].[TABLE_NAME] = [t].[TABLE_NAME]
	AND [c].[TABLE_SCHEMA] = [t].[TABLE_SCHEMA]
	AND [t].[TABLE_TYPE] = 'BASE TABLE'
	AND [t].[TABLE_SCHEMA] = @SourceSchema
	AND COLUMNPROPERTY(OBJECT_ID([t].[TABLE_NAME]), [c].[COLUMN_NAME], 'IsIdentity') = 0
	WHERE [t].[TABLE_NAME] = @SourceTable;

	SELECT @SetColumns
		= COALESCE(@SetColumns + ', ', '') + '[' + [c].[COLUMN_NAME] + '] = [S].[' + [c].[COLUMN_NAME] + ']'
	FROM [INFORMATION_SCHEMA].[COLUMNS] [c]
INNER	JOIN [INFORMATION_SCHEMA].[TABLES] [t]
	ON [c].[TABLE_NAME] = [t].[TABLE_NAME]
	AND [c].[TABLE_SCHEMA] = [t].[TABLE_SCHEMA]
	AND [t].[TABLE_TYPE] = 'BASE TABLE'
	AND [t].[TABLE_SCHEMA] = @SourceSchema
	AND COLUMNPROPERTY(OBJECT_ID([t].[TABLE_NAME]), [c].[COLUMN_NAME], 'IsIdentity') = 0
	WHERE [t].[TABLE_NAME] = @SourceTable;

	SELECT @Columns = COALESCE(@Columns + ', ', '') + '[' + [c].[COLUMN_NAME] + ']'
	FROM [INFORMATION_SCHEMA].[COLUMNS] [c]
INNER	JOIN [INFORMATION_SCHEMA].[TABLES] [t]
	ON [c].[TABLE_NAME] = [t].[TABLE_NAME]
	AND [c].[TABLE_SCHEMA] = [t].[TABLE_SCHEMA]
	AND [t].[TABLE_TYPE] = 'BASE TABLE'
	AND [t].[TABLE_SCHEMA] = @SourceSchema
	AND COLUMNPROPERTY(OBJECT_ID([t].[TABLE_NAME]), [c].[COLUMN_NAME], 'IsIdentity') = 0
	WHERE [t].[TABLE_NAME] = @SourceTable;

	SET @SQL += 'MERGE [' + @TargetSchema + '].[' + @TargetTable + '] AS [T] ';
	SET @SQL += 'USING [' + @SourceSchema + '].[' + @SourceTable + '] AS [S] ';
	SET @SQL += 'ON ([T].[' + @KeyColumn + '] = [S].[' + @KeyColumn + ']) ';
	SET @SQL += 'WHEN NOT MATCHED BY TARGET THEN ';
	SET @SQL += 'INSERT (' + @Columns + ')';
	SET @SQL += 'VALUES (' + @SourceColumns + ')';
	SET @SQL += 'WHEN MATCHED AND (';
	SET @SQL += 'HASHBYTES(''sha'', CONCAT(' + @SourceColumns + '))';
	SET @SQL += ' <> HASHBYTES(''sha'', CONCAT(' + @TargetColumns + '))) THEN ';
	SET @SQL += 'UPDATE SET' + @SetColumns + ' ';
	SET @SQL += 'WHEN NOT MATCHED BY SOURCE THEN DELETE;';

	EXEC [sp_executesql] @SQL;
END;
GO


