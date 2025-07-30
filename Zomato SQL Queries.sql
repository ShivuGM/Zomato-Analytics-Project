create database zomato_analysis;
use zomato_analysis;
select * from data;
select * from country;

# 1. Total Countries
select count(distinct(countrycode)) as Total_Countries from data;

# 2. Total Cities
select count(distinct(city)) as Total_Cities from data;

# 3. Total Restaurants
select count(distinct(restaurantid)) as Total_Restaurants from data;

# 4. Average Rating
select round(avg(rating),2) as Average_Rating from data;

# 5. Total Votes
select concat(round(sum(votes)/1000000,2),"M") as Total_Votes from data;

# 6. Average Cost Across Restaurants
select concat("$", round(avg(`average_cost_for_two(usd)`),2)) as Average_Cost from data;

select has_online_delivery, 
	concat(round(count(*)*100/sum(count(*)) over (),2),"%") as Online_Delivery_Availability
from data
group by has_online_delivery;

select has_table_booking, 
	concat(round(count(*)*100/sum(count(*)) over (),2),"%") as Table_Booking_Availability
from data
group by has_table_booking;

# Country and city wise restaurant count
select c.countryname as Country, city ,count(restaurantid)
from data as d
join
country as c
on d.countrycode=c.countryid
group by Country, City
order by country;

SELECT 
  COALESCE(c.countryname, 'Grand Total') AS Country, 
  COALESCE(d.city, 'Total') AS City, 
  COUNT(d.restaurantid) AS Restaurant_Count
FROM data AS d
JOIN country AS c
  ON d.countrycode = c.countryid
GROUP BY c.countryname, d.city WITH ROLLUP
ORDER BY c.countryname, d.city;

# Trend of Restaurant Opening over time
select date(Date) as Date, count(*) as Total_Restaurants 
from data 
group by date
order by date;

# Monthly Trend
select date_format(Date,'%Y-%m') as month, count(*) as Total_Restaurants 
from data 
group by month
order by month;

# Yearly Trend
select year(Date) as year, count(*) as Total_Restaurants 
from data 
group by year
order by year;

# Quarterly Trend
select year(Date) as Year, quarter(date) as Quarter, count(*) as Total_Restaurants 
from data 
group by year,quarter
order by year,quarter;

SELECT 
  CONCAT(YEAR(Date), '-Q', QUARTER(Date)) AS quarter,
  COUNT(*) AS Total_Restaurants
FROM data
GROUP BY QUARTER
ORDER BY QUARTER;

# Cross Country Comparison
select
	c.countryname as Country,
    count(distinct(d.cuisines)) as Unique_Cuisine,
    concat("$",round(avg(`average_cost_for_two(USD)`),2)) as Average_Cost,
    round(avg(rating),2) as Average_Rating
from data as d
join country as c
on d.countrycode=c.countryid
group by Country
order by Average_Rating desc;

# Distribution of Restuarants by Rating
select
	case 
		when rating <= 2 then "Poor (0-2)"
        when rating <= 3.5 then "Average (2-3.5)"
        when rating <= 4 then "Good (3.5-4)"
        else "Excellent (4-5)"
	end as Rating_Bucket,
    count(*) as Restaurant_Count
from data
group by Rating_Bucket;
    
# Restaurant Count by Average Dinning Cost
select
	case
		when `average_cost_for_two(USD)` <= 10 then "Budget (0-10)"
        when `average_cost_for_two(USD)` <= 25 then "Reasonable (10-25)"
        when `average_cost_for_two(USD)` <= 50 then "Mid-Range (25-50)"
        when `average_cost_for_two(USD)` <= 100 then "High (50-100)"
        when `average_cost_for_two(USD)` <= 200 then "Premium (100-200)"
		else "Luxury (200-500)"
	end as Cost_Bucket,
    count(*) as Restaurant_Count
from data
group by Cost_Bucket
order by Restaurant_Count desc;
