use project;
ALTER TABLE amazon
CHANGE COLUMN `Invoice ID` `Invoice_ID` VARCHAR(20) NOT NULL PRIMARY KEY;
ALTER TABLE amazon
CHANGE COLUMN `Customer type` `Customer_Type` ENUM('Member', 'Normal') NOT NULL;
ALTER TABLE amazon
CHANGE COLUMN `Unit price` `Unit_price` DECIMAL(10,2) NOT NULL;
ALTER TABLE amazon 
CHANGE COLUMN `Product line` `Product_line` VARCHAR(100) NOT NULL;
ALTER TABLE amazon
CHANGE COLUMN `Tax 5%` `Tax5%` DECIMAL(10,4) NOT NULL;

UPDATE amazon
SET `gross margin percentage` = ROUND(`gross margin percentage`, 6);
ALTER TABLE amazon 
CHANGE COLUMN `gross margin percentage` `gross_margin_percentage` DECIMAL(10,7) NOT NULL;

ALTER TABLE amazon 
CHANGE COLUMN `gross income` `gross_income` DECIMAL(10,4) NOT NULL;

select * from amazon;

ALTER TABLE amazon 
MODIFY COLUMN Branch CHAR(1) NOT NULL;
ALTER TABLE amazon 
MODIFY COLUMN City VARCHAR(20) NOT NULL;
ALTER TABLE amazon 
MODIFY COLUMN Gender ENUM('Male', 'Female') NOT NULL;
ALTER TABLE amazon 
MODIFY COLUMN Quantity INT UNSIGNED NOT NULL;

-- Disable safe updates
SET SQL_SAFE_UPDATES = 0;

UPDATE amazon 
SET Total = ROUND(Total, 2);
ALTER TABLE amazon 
MODIFY COLUMN Total DECIMAL(10,2) NOT NULL;

ALTER TABLE amazon 
MODIFY COLUMN Date DATE NOT NULL;
ALTER TABLE amazon 
MODIFY COLUMN Time TIME NOT NULL;
ALTER TABLE amazon 
MODIFY COLUMN Payment ENUM('Cash', 'Credit card', 'Ewallet') NOT NULL;
ALTER TABLE amazon 
MODIFY COLUMN COGS DECIMAL(10,2) NOT NULL;
ALTER TABLE amazon 
MODIFY COLUMN Rating DECIMAL(3,1);

select * from amazon;

# Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.

-- Add the new column (if it doesn’t already exist) 
ALTER TABLE amazon ADD COLUMN Timeofday VARCHAR(20);

-- Update the Timeofday column based on Time
UPDATE amazon
SET Timeofday = 
    CASE 
        WHEN TIME(Time) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN TIME(Time) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
    END;

-- Re-enable safe updates (optional but recommended)
# SET SQL_SAFE_UPDATES = 1; 

-- Select the data to verify the update
SELECT Time, Timeofday FROM amazon LIMIT 10;

## Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri)

-- Add the new column (if it doesn’t already exist)
ALTER TABLE amazon ADD COLUMN dayname VARCHAR(20);

-- Update the dayname column with the day of the week
UPDATE amazon
SET dayname = DAYNAME(Date);

-- Verify the update
SELECT Date, dayname FROM amazon LIMIT 10;

### Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar)

-- Add the new column (if it doesn’t already exist) 
ALTER TABLE amazon ADD COLUMN monthname VARCHAR(20);

-- Update the monthname column with the month of the transaction
UPDATE amazon
SET monthname = MONTHNAME(Date);

-- Verify the update
SELECT Date, monthname FROM amazon LIMIT 10;       


select * from amazon;

###############################################################

# 1 - What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT City) AS distinct_city_count
FROM amazon;

# It counts the number of unique cities that appear in the City column of the amazon table.
# This means there are 3 unique cities where sales transactions occurred.
# Sales Distribution Analysis:
# Knowing the number of distinct cities helps in analyzing how sales and customer behaviors differ regionally. 

# 2 - For each branch, what is the corresponding city?
SELECT Branch, City
FROM amazon
GROUP BY Branch, City;

# It returns a unique pair of Branch and City from the amazon table.
# Since each branch is located in a specific city, this helps map which branch belongs to which city.


# 3 - What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT Product_line) AS distinct_product_lines
FROM amazon;

# It counts how many unique product categories (product lines) exist in the amazon table.
# The business offers 6 distinct product lines, showing a diverse range of categories which can attract a wide customer base

# 4 - Which payment method occurs most frequently?
SELECT payment FROM amazon;

SELECT Payment, COUNT(*) AS count
FROM amazon
GROUP BY Payment
ORDER BY count DESC
LIMIT 1;

# It counts how many times each payment method was used.
# It then orders the results in descending order of frequency.
# Finally, it returns only the most frequently used payment method.
# Most customers prefer Ewallets over Cash or Credit cards. This suggests a strong trend toward digital payments
# It can help segment customers by payment behavior, which is useful for targeted marketing or UX improvements.

# 5 - Which product line has the highest sales?
SELECT Product_line FROM amazon;

SELECT Product_line, SUM(Total) AS total_sales
FROM amazon
GROUP BY Product_line
ORDER BY total_sales DESC
LIMIT 1;

# The "Food and beverages" product line generated the highest total sales. This indicates it is the most profitable or popular category
# Customers are more inclined to purchase products from this line, suggesting a strong demand.
# Businesses could explore Because this product line outperforms others—e.g., pricing, seasonal demand, or promotions—and apply similar strategies to boost lower-performing lines

# 6 - How much revenue is generated each month?
SELECT monthname AS Month, ROUND(SUM(Total), 2) AS Revenue
FROM amazon
GROUP BY monthname
ORDER BY 
  FIELD(monthname, 'January', 'February', 'March');
  
# The query helps identify which months are most profitable.
# if March has the highest revenue, it shows a growing sales trend over time.
# Useful for spotting seasonal patterns
# You can align marketing campaigns, inventory restocking, and staffing based on high-revenue months.
  
# 7 - In which month did the cost of goods sold reach its peak?
SELECT COGS FROM amazon;

SELECT monthname AS Month, ROUND(SUM(COGS), 2) AS Total_COGS
FROM amazon
GROUP BY monthname
ORDER BY Total_COGS DESC
LIMIT 1;

# A high COGS often indicates higher sales volume since more goods were sold
# Cross-referencing with total revenue for that month can tell whether profit margins were high or low.
# Businesses can plan procurement and budgeting better by anticipating high COGS months

# 8 - Which product line generated the highest revenue?
SELECT Product_line, ROUND(SUM(Total), 2) AS Total_Revenue
FROM amazon
GROUP BY Product_line
ORDER BY Total_Revenue DESC
LIMIT 1;

# This product line is the main driver of revenue for the business.
# It might be the most popular or highly priced segment.
# Strong sales could reflect customer preference or seasonal trends.
# Could indicate successful marketing efforts or pro

# 9 - In which city was the highest revenue recorded?
SELECT City, ROUND(SUM(Total), 2) AS Total_Revenue
FROM amazon
GROUP BY City
ORDER BY Total_Revenue DESC
LIMIT 1;

# The city returned in the result has the highest revenue contribution to the company.
# Indicates strong demand and higher purchasing activity in this city.
# The city may represent a strategic location for expanding operations, introducing new product lines, or running targeted promotions
# Other branches or cities can be benchmarked against this top performer to identify improvement opportunities.

# 10 - Which product line incurred the highest Value Added Tax?
SELECT Product_line, ROUND(SUM(`Tax5%`), 2) AS Total_VAT
FROM amazon
GROUP BY Product_line
ORDER BY Total_VAT DESC
LIMIT 1;

# the product line with the highest VAT is also likely to be one of the highest revenue generators, since VAT is calculated as a percentage of sales.
# This gives a proxy measure of product line profitability and sales volume.
# Indicates which product line is selling the most in quantity or price.
# Useful for understanding customer demand trends.
# Helpful for tax planning, forecasting government liabilities, and managing compliance.

# 11 - For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
WITH ProductSales AS (
    SELECT 
        Product_line,
        SUM(Total) AS Total_Sales
    FROM amazon
    GROUP BY Product_line
),
AverageSales AS (
    SELECT 
        AVG(Total_Sales) AS Avg_Sales
    FROM ProductSales
)
SELECT 
    ps.Product_line,
    ROUND(ps.Total_Sales, 2) AS Total_Sales,
    CASE
        WHEN ps.Total_Sales > avg.Avg_Sales THEN 'Good'
        ELSE 'Bad'
    END AS Sales_Performance
FROM ProductSales ps, AverageSales avg;

# Helps identify which product lines are driving business growth.
# "Bad" performers may need marketing attention, bundling, or possibly product line review.
# Provides an easy-to-digest summary for decision-makers to quickly understand product-level performance

# 12 - Identify the branch that exceeded the average number of products sold.
SELECT 
  Branch, 
  SUM(Quantity) AS total_quantity
FROM amazon
GROUP BY Branch
HAVING SUM(Quantity) > (
  SELECT AVG(branch_total)
  FROM (
    SELECT SUM(Quantity) AS branch_total
    FROM amazon
    GROUP BY Branch
  ) AS sub
);

# Identifies which branch(es) are selling more items than the average branch.
# Helps you understand which branch contributes more to volume-based sales.
# High-volume branches may need:
# More inventory
# Additional staff
# Better logistics
# Location-based promotion analysis
# The query provides a benchmark for normal sales activity—any branch above this benchmark is a top performer.


# 13 - Which product line is most frequently associated with each gender?

WITH gender_product_rank AS (
    SELECT 
        Gender,
        Product_line,
        COUNT(*) AS count_per_product,
        ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY COUNT(*) DESC) AS Grank
    FROM amazon
    GROUP BY Gender, Product_line
)
SELECT Gender, Product_line, count_per_product
FROM gender_product_rank
WHERE Grank = 1;

# This reveals the most popular product line for each gender, allowing businesses to understand gender-specific trends.
#it helps target marketing and product recommendations more effectively.
# Promotions: Design gender-specific offers to boost engagement.
# Inventory planning: Ensure sufficient stock of gender-preferred products in specific locations.
# This is a form of segmentation based on behavioral purchasing patterns, valuable for retail personalization.

# 14 - Calculate the average rating for each product line
SELECT Product_line, ROUND(AVG(Rating), 2) AS Average_Rating
FROM amazon
GROUP BY Product_line;

# Identifying Top-Performing Product Lines:
          # Product lines with the highest average ratings are likely satisfying customers the most.
          # Indicates quality, satisfaction, or expectation alignment.
# Product lines with lower average ratings may need attention.
# Focus on promoting high-rated products in marketing campaigns.
# Consider investigating low-rated products for potential improvements.

# 15 - Count the sales occurrences for each time of day on every weekday.
SELECT Timeofday, dayname, COUNT(invoice_iD) AS Sales_Count
FROM amazon
GROUP BY Timeofday, dayname
ORDER BY dayname, Timeofday;

# Helps identify the most active sales periods on each weekday.
# Reveals when customers are most likely to shop.
# Tracks which days of the week see the most action.
# Useful for staff scheduling, inventory planning, or special weekday offers.

# 16 - Identify the customer type contributing the highest revenue.
SELECT Customer_Type, 
       ROUND(SUM(Total), 2) AS Total_Revenue
FROM amazon
GROUP BY Customer_Type
ORDER BY Total_Revenue DESC
LIMIT 1;

# Identifies which customer group is more financially valuable to the business.
# Helps businesses decide where to focus marketing or retention efforts:
    # If Normal customers contribute more, it might be time to convert them into members.
    # If Members dominate, maintaining or enhancing member perks could retain them.

# 17 - Determine the city with the highest VAT percentage.
SELECT City, 
       ROUND(SUM('Tax5%'), 2) AS Total_VAT
FROM amazon
GROUP BY City
ORDER BY Total_VAT DESC
LIMIT 1;

# Identifies the city that contributed the most in VAT.
# Suggests this city had either higher-priced sales, more transactions, or a combination of both.
# Indicates where most economic activity is occurring.
# Useful for strategic decisions like store expansion, marketing investment, or logistical prioritization.
# Can help with financial planning, tax reporting, and city-level performance assessments.


-- measuring average VAT rate per city
SELECT City,
       ROUND(AVG(`Tax5%` / Total * 100), 2) AS Avg_VAT_Percentage
FROM amazon
GROUP BY City
ORDER BY Avg_VAT_Percentage DESC
LIMIT 1;

# Differences in product price mix,Sales tax rules if they vary by product or location.
# The city with the highest average VAT percentage might have:
        #More high-margin products,
        # A larger proportion of taxable items
        # Or just more accurate transaction reporting

# 18 - Identify the customer type with the highest VAT payments.
SELECT Customer_Type, 
       ROUND(SUM(`Tax5%`), 2) AS Total_VAT
FROM amazon
GROUP BY Customer_Type
ORDER BY Total_VAT DESC
LIMIT 1;

# The customer type with the highest total VAT also likely spends more overall, since VAT is a percentage of total purchase value.
# This customer group may represent higher-value transactions or greater purchase frequency.
# Helps businesses target high-contributing customer segments for retention, loyalty programs, or marketing campaigns.

# 19 - What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT Customer_Type) AS Distinct_Customer_Types
FROM amazon;

# This allows for customer segmentation analysis, helping businesses tailor marketing or loyalty programs to each group.
# Businesses can compare revenue, frequency of purchases

# 20 - What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT Payment) AS Distinct_Payment_Methods
FROM amazon;
#The dataset contains two distinct customer types:
#Member
#Normal


# The presence of multiple payment options shows that customers prefer flexibility in how they pay. This can inform future strategy on maintaining or expanding payment options.
# If Ewallet or Credit Card usage is high, it signals a shift toward digital payments, which could reduce cash handling costs and improve efficiency.


# 21 - Which customer type occurs most frequently?
SELECT Customer_Type, COUNT(Customer_Type) AS Count
FROM amazon
GROUP BY Customer_Type
ORDER BY Count DESC
LIMIT 1;
# This suggests that loyal or returning customers (Members) are more active in purchases compared to Normal customers.
# Marketing campaigns can focus on retaining and upselling to Members, as they already show a high engagement rate.
# If Members make up the majority of purchases, it implies that loyalty programs are effective, and such customers should be nurtured further with rewards or exclusive offers.

# 22 - Identify the customer type with the highest purchase frequency.
SELECT Customer_Type, COUNT(Invoice_ID) AS Purchase_Count
FROM amazon
GROUP BY Customer_Type
ORDER BY Purchase_Count DESC
LIMIT 1;

# This shows that members make purchases more often than non-members (Normal), possibly due to better engagement, benefits, or trust in the platform.
# It's beneficial to invest in retaining Members as they are more likely to return and shop frequently.
# Personalized promotions or upsell offers could be more effective when directed toward high-frequency buyers (Members).

# 23 - Determine the predominant gender among customers.
SELECT Gender, COUNT(Invoice_ID) AS Gender_Count
FROM amazon
GROUP BY Gender
ORDER BY Gender_Count DESC
LIMIT 1;

# This suggests that females made more purchases than males during the recorded sales period.
# If females dominate the customer base, marketing campaigns, product placements, and promotions can be tailored to appeal more to female customers.
# Understanding why the other gender lags in transactions can help unlock growth opportunities.

# 24 - Examine the distribution of genders within each branch.
SELECT Branch, Gender, COUNT(Invoice_ID) AS Gender_Count
FROM amazon
GROUP BY Branch, Gender
ORDER BY Branch, Gender;

# Gender Distribution is Nearly Balanced: All branches show an almost equal number of male and female customers.
# No branch is heavily dominated by one gender, indicating a diverse and balanced customer base across locations.
# Promotions or campaigns can be fine-tuned at the branch level if one gender slightly dominates in that region.
# Investigate average spending or product preferences by gender per branch for deeper behavioral insights.


# 25 - Identify the time of day when customers provide the most ratings.
SELECT Timeofday, COUNT(Rating) AS Rating_Count
FROM amazon
GROUP BY Timeofday
ORDER BY Rating_Count DESC
LIMIT 1;

# afternoon  is the time when most customers leave ratings, indicating peak engagement during that period.
# Customers are likely to be more active and willing to provide feedback later in the day, possibly after completing their purchases.
# Focus on prompting customers for reviews or surveys during Afternoon hours, when they’re more responsive.

# 26 - Determine the time of day with the highest customer ratings for each branch.
-- time of day with the highest average customer ratings for each branch
SELECT Branch, Timeofday, AVG(Rating) AS Avg_Rating
FROM amazon
GROUP BY Branch, Timeofday
ORDER BY Branch, Avg_Rating DESC;

# Branch C is outperforming others in terms of customer satisfaction. Use it as a benchmark to improve service in A and B.
# Branch B needs improvement, especially during the evening. Consider evaluating staff schedules, service workflows, or customer interaction.
# Afternoon appears to be the best-performing time across Branches A and C, suggesting customers may be more satisfied post-lunch or due to quieter service periods.
# Monitor Branch A's evenings — ratings are slowly dipping compared to the rest of the day.

-- top-rated time of day per branch
WITH RatingCTE AS (
  SELECT 
    Branch, 
    Timeofday, 
    AVG(Rating) AS Avg_Rating,
    RANK() OVER (PARTITION BY Branch ORDER BY AVG(Rating) DESC) AS rnk
  FROM amazon
  GROUP BY Branch, Timeofday
)
SELECT Branch, Timeofday, Avg_Rating
FROM RatingCTE
WHERE rnk = 1;

# Afternoons are the strongest time slot overall, especially for Branches A and C. It may be linked to staffing patterns, customer flow, or operational efficiency
# Branch B should analyze morning performance practices and try replicating that success in other times of the day.
# Branch C is leading in customer satisfaction — consider studying its afternoon operations to replicate success at A and B.

# 27 - Identify the day of the week with the highest average ratings.
SELECT dayname, AVG(Rating) AS Avg_Rating
FROM amazon
GROUP BY dayname
ORDER BY Avg_Rating DESC
LIMIT 1;

# Monday has the highest average customer rating of all weekdays, with a score of 7.15.
# This suggests that customers are most satisfied with their shopping experience at the start of the week.
# 

# 28 - Determine the day of the week with the highest average ratings for each branch.

WITH daily_avg AS (
    SELECT Branch, dayname, AVG(Rating) AS Avg_Rating
    FROM amazon
    GROUP BY Branch, dayname
)
SELECT Branch, dayname, Avg_Rating
FROM daily_avg
WHERE (Branch, Avg_Rating) IN (
    SELECT Branch, MAX(Avg_Rating)
    FROM daily_avg
    GROUP BY Branch
);

# Branch A performs best in terms of customer satisfaction on Friday.
# Branch B receives its highest ratings on Monday.
# Branch C also sees its best performance on Friday.
# Two out of three branches (A and C) receive their highest customer ratings on Fridays.
# Indicates potential patterns in customer mood, promotions, or service quality heading into the weekend.
# Identify and replicate what is working on Fridays (A & C) and Mondays (B) across other days/branches to improve overall customer satisfaction.






