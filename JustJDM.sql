-- Create a Common Table Expression (CTE) named JDMSALES that combines product and sales data
WITH JDMSALES AS (
    SELECT 
        -- Product details from the Part_Description_URL table (alias A)
        A.Part,
        A.Category,
        A.Brand,
        A.Description,
        A.Sale_Price,
        A.Cost_Price,
        A.ImageURL,
        
        -- Sales details from the Products_Sold table (alias B)
        B.Date,
        B.Customer_Type,
        B.Discount_Band,
        B.country,
        B.Product,
        B.Units_Sold,
        
        -- Calculate revenue by multiplying the sale price by the units sold
        (Sale_Price * Units_Sold) AS revenue,
        
        -- Calculate total cost by multiplying the cost price by the units sold
        (Cost_Price * Units_Sold) AS total_cost,
        
        -- Extract the month name from the sales date (e.g., "January")
        DATENAME(MONTH, B.Date) AS month, 
        
        -- Extract the year from the sales date
        YEAR(B.Date) AS year
    FROM 
        Part_Description_URL AS A  -- Source table containing product details
    JOIN 
        Products_Sold AS B         -- Source table containing sales transactions
    ON 
        A.Product_ID = B.Product   -- Join condition to match products between the two tables
)

-- Final query: Use the JDMSALES CTE and join with the discountData table to calculate discounted revenue
SELECT 
    *,
    -- Calculate discounted revenue:
    -- Multiply the revenue by (1 - discount percentage converted to a decimal).
    -- The expression discount*1.0/100 ensures a floating-point division.
    (1 - discount * 1.0 / 100) * revenue AS Discount_revenue
FROM JDMSALES AS JS
JOIN discountData AS DD
    -- Join condition to match the discount band and month for applying the correct discount rate
    ON JS.Discount_Band = DD.Discount_Band 
    AND JS.month = DD.month;