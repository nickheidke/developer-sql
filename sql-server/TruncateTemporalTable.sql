ALTER TABLE dbo.DimProject SET (SYSTEM_VERSIONING = OFF)

TRUNCATE TABLE DimProject

TRUNCATE TABLE DimProjectHistory

ALTER TABLE dbo.DimProject SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DimProjectHistory))