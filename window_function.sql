USE AdventureWorkLight1
-- Công ty đang muốn review lại Revenue lũy tiến của các category theo từng tháng. Bạn hãy giúp team tính toán và tổng hợp view báo cáo này 
SELECT * From Sales_orders
SELECT * From Sales_orders_detail
SELECT * From Sales_orders_reasons
-- normal join 
WITH running_revenue_per_cat AS (
    SELECT 
        SUM(t1.LineTotal) AS Revenue,
        cat.ProductCategoryID,
        cat.ProductCategoryName,
        MONTH(t2.OrderDate) AS OrderMonth, 
        YEAR(t2.OrderDate) AS OrderYear
    FROM Sales_orders_detail t1 
    LEFT JOIN Sales_orders t2 
        ON t1.SalesOrderID = t2.SalesOrderID
    LEFT JOIN Dim_Product t3
        ON t1.ProductID = t3.ProductID
    LEFT JOIN Dim_ProductSubCategory t4
        ON t3.ProductSubcategoryID = CAST(t4.ProductSubcategoryID AS nvarchar)
    LEFT JOIN Dim_ProductCategory cat 
        ON cat.ProductCategoryID = t4.ProductCategoryID
    WHERE t2.OrderDate IS NOT NULL
    GROUP BY 
        YEAR(t2.OrderDate), 
        MONTH(t2.OrderDate), 
        cat.ProductCategoryID, 
        cat.ProductCategoryName
)
SELECT * FROM running_revenue_per_cat ORDER BY revenue 

-- dung window function 
With running_total_per_cat AS (
    SELECT 
        cat.ProductCategoryName,
        MONTH(t2.OrderDate) AS OrderMonth, 
        YEAR(t2.OrderDate) AS OrderYear,
         SUM(t1.LineTotal) AS Revenue

    FROM Sales_orders_detail t1 
    LEFT JOIN Sales_orders t2 
        ON t1.SalesOrderID = t2.SalesOrderID
    LEFT JOIN Dim_Product t3
        ON t1.ProductID = t3.ProductID
    LEFT JOIN Dim_ProductSubCategory t4
        ON t3.ProductSubcategoryID = CAST(t4.ProductSubcategoryID AS nvarchar)
    LEFT JOIN Dim_ProductCategory cat 
        ON cat.ProductCategoryID = t4.ProductCategoryID
    WHERE t2.OrderDate IS NOT NULL
    GROUP BY YEAR(t2.OrderDate), MONTH(t2.OrderDate), ProductCategoryName)

SELECT *, SUM(Revenue)  over (partition by ProductCategoryName order by revenue desc) As acc_rev FROM running_total_per_cat

-- buoc 1: viet base CTE: co nhung level gi, theo level gi 
-- minh muon nhom dong nay theo tieu chi nao, thuc hien tinh toan nao theo tieu chi nao 

-- window frame: gioi han so dong can lay 
-- khong thuc hien tren toan bo data
-- limit so luong dong query thuc hien
-- current row: dong hien tai
-- N row preccedding: N dong truoc do
-- M following: N dong truoc do 
-- rows between N row precceding, M following: row giua N dong truoc, va N dong sau dong current rơư
-- thuong gap trong gia moving average cua gia stock luon luon la trung binh 3 ngay gan nhat 
-- cac option co the co 
-- unbounded following
-- unbounded preccedding 
-- 1 precceding current row 1 folowing 
-- 