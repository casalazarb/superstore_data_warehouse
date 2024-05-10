USE superstore_data_warehouse;

/* Calculate the total sales by continent for all the period in the DB */
/* Remember we added a 1 to each Foreign Key to avoid conflicts during the denormalization */

SELECT ct.continent AS [Continent], ROUND(SUM(ol.sales), 2) AS [Sum of Sales]
FROM [dbo].[order_line] ol
JOIN [dbo].[order] o ON ol.order_id1 = o.order_id
JOIN [dbo].[city_state] cs ON o.city_state_id1 = cs.city_state_id
JOIN [dbo].[country] c ON cs.country_id1 = c.country_id
JOIN [dbo].[continent] ct ON c.continent_id1 = ct.continent_id
GROUP BY ct.continent
ORDER BY SUM(ol.sales) DESC;

/* Using the data warehouse */
/* Query in dataware house consists of three fewer lines as compared to 
Query in original database */

SELECT cd.Continent, ROUND(SUM(ft.sales), 2) AS [Sum of Sales]
FROM country_dim cd
INNER JOIN fact_table ft on cd.country_id = ft.country_id
GROUP BY cd.continent
ORDER BY SUM(ft.sales) DESC;

/* Calculate the profit in Europe and South America in 2011 and 2012 */
SELECT ct.continent AS [Continent], 
       YEAR(o.order_date) AS [Order Year],
       ROUND(SUM(ol.profit), 2) AS [Sum of Profit]
FROM [dbo].[order_line] ol
JOIN [dbo].[order] o ON ol.order_id1 = o.order_id
JOIN [dbo].[city_state] cs ON o.city_state_id1 = cs.city_state_id
JOIN [dbo].[country] c ON cs.country_id1 = c.country_id
JOIN [dbo].[continent] ct ON c.continent_id1 = ct.continent_id
WHERE (ct.continent = 'Europe' OR ct.continent = 'South America')
  AND (YEAR(o.order_date) = 2011 OR YEAR(o.order_date) = 2012)
GROUP BY ct.continent, YEAR(o.order_date)
ORDER BY ct.continent, YEAR(o.order_date) ASC;

/* Using the data warehouse */
/* Query in dataware house consists of two fewer lines as compared to 
Query in original database */

SELECT cd.continent AS [Continent], 
       YEAR(td.order_date) AS [Order Year],
       ROUND(SUM(ft.profit), 2) AS [Sum of Profit]
FROM country_dim cd
INNER JOIN fact_table ft on ft.country_id = cd.country_id
INNER JOIN time_dim td on td.time_id = ft.time_id
WHERE (cd.continent = 'Europe' OR cd.continent = 'South America')
  AND (YEAR(td.order_date) = 2011 OR YEAR(td.order_date) = 2012)
GROUP BY cd.continent, YEAR(td.order_date)
ORDER BY cd.continent, YEAR(td.order_date) ASC;

/* Top 3 Countries in South America by Sales of Technology */

SELECT TOP 3
	c.country AS [Country],
    ROUND(SUM(ol.sales), 2) AS [Total Sales]
FROM dbo.country c
INNER JOIN dbo.city_state cs ON c.country_id = cs.country_id1
INNER JOIN dbo.[order] o ON cs.city_state_id = o.city_state_id1
INNER JOIN dbo.order_line ol ON o.order_id = ol.order_id1
INNER JOIN dbo.product p ON ol.product_id1 = p.product_id
INNER JOIN dbo.product_subcategory ps ON p.product_subcategory_id1 = ps.product_subcategory_id
INNER JOIN dbo.product_category pc ON ps.product_category_id1 = pc.product_category_id
INNER JOIN dbo.continent cn ON c.continent_id1 = cn.continent_id
WHERE cn.continent = 'South America' AND pc.product_category = 'Technology'
GROUP BY c.country
ORDER BY SUM(ol.sales) DESC;

/* Using the data warehouse */
/* Query in dataware house consists of five fewer lines as compared to 
Query in original database */

SELECT TOP 3
	cd.country AS [Country],
    ROUND(SUM(ft.sales), 2) AS [Total Sales]
FROM country_dim cd
INNER JOIN fact_table ft on ft.country_id = cd.country_id
INNER JOIN subcategory_dim scd on scd.product_subcategory_id = ft.product_subcategory_id
WHERE cd.continent = 'South America' AND scd.product_category = 'Technology'
GROUP BY cd.country
ORDER BY SUM(ft.sales) DESC;



