-- Question One - Achieving 1NF
-- Create a new table for 1NF transformation
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100)
);

-- Insert data into the new 1NF table
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT OrderID,
       CustomerName,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', numbers.n), ',', -1)) AS Product
FROM (
    SELECT OrderID,
           CustomerName,
           Products,
           (CASE
               WHEN LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) > 0
               THEN LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) + 1
               ELSE 1
           END) AS n
    FROM ProductDetail
) AS product_data
JOIN (
    SELECT 1 AS n
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
) AS numbers
ON CHAR_LENGTH(Products) <= CHAR_LENGTH(REPLACE(Products, ',', '')) + 1 - numbers.n
ORDER BY OrderID, Product;

-- Question Two - Achieving 2NF
-- Create a new table for 2NF transformation
CREATE TABLE OrderDetails_2NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    ProductID INT,  -- Assuming there is a Products table with ProductID as primary key
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID)
);

-- Insert data into the new 2NF table
INSERT INTO OrderDetails_2NF (OrderID, CustomerName, ProductID, Quantity)
SELECT od.OrderID,
       od.CustomerName,
       p.ProductID,
       od.Quantity
FROM (
    SELECT DISTINCT OrderID, CustomerName
    FROM OrderDetails
) AS o
JOIN OrderDetails AS od ON o.OrderID = od.OrderID AND o.CustomerName = od.CustomerName
JOIN (
    SELECT DISTINCT Product, ROW_NUMBER() OVER (ORDER BY Product) AS ProductID
    FROM (
        SELECT DISTINCT Product
        FROM OrderDetails
    ) AS p
) AS p ON od.Product = p.Product;

