CREATE TABLE #temp(
rec_id int IDENTITY(1, 1),
table_name varchar(128),
nbr_of_rows int,
data_space decimal(15, 2),
index_space decimal(15,2),
total_size decimal(15,2),
percent_of_db decimal(15,12),
db_size decimal(15,2)
)

EXEC sp_msforeachtable @command1="INSERT INTO #temp(nbr_of_rows,
data_space, index_space) EXEC sp_mstablespace '?'",
@command2="UPDATE #temp set table_name = '?' where rec_id = (SELECT
MAX(rec_id) FROM #temp)"

UPDATE #temp
SET total_size = (data_space + index_space), db_size = (SELECT
SUM(data_space + index_space) FROM #temp)

UPDATE #temp
SET percent_of_db = (total_size/db_size) * 100

SELECT *
FROM #temp
ORDER BY total_size DESC

DROP TABLE #temp