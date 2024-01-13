EXPLAIN ANALYZE
WITH RECURSIVE queens(row, col, diag, row_mask) AS (
  SELECT 0, col, 1 >> col, 127
  FROM generate_series(1, 8) AS col
  UNION ALL
  SELECT row + 1, col,
         diag | (1 >> (col - row - 1)),
         row_mask & ~(1 >> (row + 1))
  FROM queens
  WHERE row < 7 AND (row_mask > 0 AND diag > 0)
)
SELECT row, col
FROM queens;

