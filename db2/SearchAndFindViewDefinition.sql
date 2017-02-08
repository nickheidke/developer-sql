SELECT NAME, CAST(STATEMENT as varchar(8000)) as TEXT
FROM SYSIBM.SYSVIEWS
WHERE NAME LIKE 'AGMT%'
ORDER BY OWNER, NAME
;