--Clear all Tables from database
EXEC sp_MSForEachTable 'TRUNCATE TABLE ?';