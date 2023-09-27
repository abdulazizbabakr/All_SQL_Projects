select * from CustomerDemographic
select * from CustomerAddress
select * from Transactions
select * from NewCustomerList 


-------------------------------------------------- TASK 1 --------------------------------------------------
-------------------------------------------------- Data cleaning & normalization --------------------------------------------------

select -- no if columns
	COUNT(*) as total_columns
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CustomerDemographic'

select -- no if columns
	COUNT(*) as total_columns
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CustomerAddress'

select -- no if columns
	COUNT(*) as total_columns
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'Transactions'


----------- uniqueness -----------

select * from CustomerDemographic

select  -- no duplicates found
	COUNT(customer_id) - COUNT(distinct customer_id) as duplicates
from CustomerDemographic

select  -- no duplicates found
	COUNT(customer_id) - COUNT(distinct customer_id) as duplicates
from CustomerAddress

select  -- no duplicates found
	COUNT(transaction_id) - COUNT(distinct transaction_id) as duplicates
from Transactions


-- no od records in each column

select
	COUNT(customer_id) as total_rows,
	COUNT(first_name) as total_rows,
	COUNT(last_name) as total_rows,
	COUNT(gender) as total_rows,
	COUNT(past_3_years_bike_related_purchases) as total_rows,
	COUNT(DOB) as total_rows,
	COUNT(job_industry_category) as total_rows,
	COUNT(wealth_segment) as total_rows,
	COUNT(deceased_indicator) as total_rows,
	COUNT(owns_car) as total_rows,
	COUNT(tenure) as total_rows
from CustomerDemographic


select
	COUNT(customer_id) as total_rows,
	COUNT(address) as total_rows,
	COUNT(postcode) as total_rows,
	COUNT(state) as total_rows,
	COUNT(country) as total_rows,
	COUNT(property_valuation) as total_rows
from CustomerAddress


select
	COUNT(transaction_id) as total_rows,
	COUNT(product_id) as total_rows,
	COUNT(customer_id) as total_rows,
	COUNT(transaction_date) as total_rows,
	COUNT(online_order) as total_rows,
	COUNT(brand) as total_rows,
	COUNT(product_line) as total_rows,
	COUNT(product_class) as total_rows,
	COUNT(product_size) as total_rows,
	COUNT(list_price) as total_rows,
	COUNT(standard_cost) as total_rows,
	COUNT(product_first_sold_date) as total_rows
from Transactions

----------- Checking for NULLs -----------

select
	SUM(CASE when customer_id is NULL then 1 else 0 END) as customer_id,
	SUM(CASE when first_name is NULL then 1 else 0 END) as first_name,
	SUM(CASE when [gender] is NULL then 1 else 0 END) as [gender],
	SUM(CASE when [past_3_years_bike_related_purchases] is NULL then 1 else 0 END) as [past_3_years_bike_related_purchases],
	SUM(CASE when [DOB] is NULL then 1 else 0 END) as [DOB], -- 87 NULLs
	SUM(CASE when [job_title] is NULL then 1 else 0 END) as [job_title], -- 506 NULLs
	SUM(CASE when [job_industry_category] is NULL then 1 else 0 END) as [job_industry_category],
	SUM(CASE when [wealth_segment] is NULL then 1 else 0 END) as [wealth_segment],
	SUM(CASE when [deceased_indicator] is NULL then 1 else 0 END) as [deceased_indicator],
	SUM(CASE when [owns_car] is NULL then 1 else 0 END) as [owns_car],
	SUM(CASE when tenure is NULL then 1 else 0 END) as tenure -- 87 NULLs

from CustomerDemographic


select
	SUM(CASE when customer_id is NULL then 1 else 0 END) as customer_id,
	SUM(CASE when address is NULL then 1 else 0 END) as address,
	SUM(CASE when postcode is NULL then 1 else 0 END) as postcode,
	SUM(CASE when state is NULL then 1 else 0 END) as state,
	SUM(CASE when country is NULL then 1 else 0 END) as country,
	SUM(CASE when property_valuation is NULL then 1 else 0 END) as property_valuation
from CustomerAddress -- no NULLs


select
	SUM(CASE when transaction_id is NULL then 1 else 0 END) as transaction_id,
	SUM(CASE when product_id is NULL then 1 else 0 END) as product_id,
	SUM(CASE when customer_id is NULL then 1 else 0 END) as customer_id,
	SUM(CASE when transaction_date is NULL then 1 else 0 END) as transaction_date,
	SUM(CASE when online_order is NULL then 1 else 0 END) as online_order, -- 360 NULLs
	SUM(CASE when order_status is NULL then 1 else 0 END) as order_status,
	SUM(CASE when brand is NULL then 1 else 0 END) as brand, -- 197 NULLs
	SUM(CASE when product_line is NULL then 1 else 0 END) as product_line, -- 197 NULLs
	SUM(CASE when product_class is NULL then 1 else 0 END) as product_class, -- 197 NULLs
	SUM(CASE when product_size is NULL then 1 else 0 END) as product_size,
	SUM(CASE when list_price is NULL then 1 else 0 END) as list_price,
	SUM(CASE when standard_cost is NULL then 1 else 0 END) as standard_cost, -- 197 NULLs
	SUM(CASE when product_first_sold_date is NULL then 1 else 0 END) as product_first_sold_date -- 197 NULLs
from Transactions

----------- checking for empty records -----------

select
	SUM(CASE when customer_id = ' ' then 1 else 0 END) as customer_id,
	SUM(CASE when first_name = ' ' then 1 else 0 END) as first_name,
	SUM(CASE when [gender] = ' ' then 1 else 0 END) as [gender],
	SUM(CASE when [past_3_years_bike_related_purchases] = ' ' then 1 else 0 END) as [past_3_years_bike_related_purchases], -- 38 records with 0, no spaces all good
	SUM(CASE when [DOB] = ' ' then 1 else 0 END) as [DOB], 
	SUM(CASE when [job_title] = ' ' then 1 else 0 END) as [job_title], 
	SUM(CASE when [job_industry_category] = ' ' then 1 else 0 END) as [job_industry_category],
	SUM(CASE when [wealth_segment] = ' ' then 1 else 0 END) as [wealth_segment],
	SUM(CASE when [deceased_indicator] = ' ' then 1 else 0 END) as [deceased_indicator],
	SUM(CASE when [owns_car] = ' ' then 1 else 0 END) as [owns_car], -- 1976 indicates No, no spaces all good
	SUM(CASE when tenure = ' ' then 1 else 0 END) as tenure 
from CustomerDemographic


select
	SUM(CASE when customer_id = ' ' then 1 else 0 END) as customer_id,
	SUM(CASE when address = ' ' then 1 else 0 END) as address,
	SUM(CASE when postcode = ' ' then 1 else 0 END) as postcode,
	SUM(CASE when state = ' ' then 1 else 0 END) as state,
	SUM(CASE when country = ' ' then 1 else 0 END) as country,
	SUM(CASE when property_valuation = ' ' then 1 else 0 END) as property_valuation
from CustomerAddress -- no spaces


select
	SUM(CASE when transaction_id = ' ' then 1 else 0 END) as transaction_id,
	SUM(CASE when product_id = ' ' then 1 else 0 END) as product_id, -- 1378 of product_id 0, so no missing data
	SUM(CASE when customer_id = ' ' then 1 else 0 END) as customer_id,
	SUM(CASE when transaction_date = ' ' then 1 else 0 END) as transaction_date,
	SUM(CASE when online_order = ' ' then 1 else 0 END) as online_order, -- 9811 indicates the blank and false, so no missing data
	SUM(CASE when order_status = ' ' then 1 else 0 END) as order_status,
	SUM(CASE when brand = ' ' then 1 else 0 END) as brand,
	SUM(CASE when product_line = ' ' then 1 else 0 END) as product_line,
	SUM(CASE when product_class = ' ' then 1 else 0 END) as product_class,
	SUM(CASE when product_size = ' ' then 1 else 0 END) as product_size,
	SUM(CASE when list_price = ' ' then 1 else 0 END) as list_price,
	SUM(CASE when standard_cost = ' ' then 1 else 0 END) as standard_cost,
	SUM(CASE when product_first_sold_date = ' ' then 1 else 0 END) as product_first_sold_date
from Transactions


/* All NULLs will not be deleted unless requested by client, as long as they are not in the unique columns we are good to proceed */

----------- Ensuring consistency -----------

-- CustomerDemographic
select * from CustomerDemographic

Update CustomerDemographic
SET
gender = CASE 
			WHEN gender = 'F' then 'Female'
			WHEN gender = 'Femal' then 'Female'
			WHEN gender = 'M' then 'Male'
			WHEN gender = 'U' then 'Male'
			Else gender
		END,
job_industry_category =
		CASE 
			WHEN job_industry_category = 'n/a' then NULL
			ELSE job_industry_category
		END

select -- consistent
	distinct gender
from CustomerDemographic

select -- consistent
	distinct job_industry_category
from CustomerDemographic

-- CustomerAddress
select * from CustomerAddress


Update CustomerAddress
SET
state = CASE 
			WHEN state = 'Victoria' then 'VIC'
			WHEN state = 'New South Wales' then 'NSW'
			ELSE state
		End

select -- consistent
	distinct state
from CustomerAddress


----------- Finalizing Tables -----------
select * from CustomerDemographic

Alter Table CustomerDemographic
Add age INT

Update CustomerDemographic
SET
age = DATEDIFF(year, DOB, GETDATE())

select * from CustomerDemographic order by age desc

-- Getting Rid of an Outlier "customer age 180

DELETE FROM CustomerDemographic
Where customer_id = 34

-------------------------------------------------- TASK 2 --------------------------------------------------
--------------------------------------------------Data Exploration; Model Development--------------------------------------------------
select * from CustomerDemographic
select * from CustomerAddress
select * from Transactions
select * from NewCustomerList 

-- Adding age column in the NewCustomerList

ALTER TABLE NewCustomerList
ADD age INT

Update NewCustomerList
SET
age = DATEDIFF(year, DOB, GETDATE())

-- Calculating profit in Transactions

ALTER TABLE Transactions
ADD profit float

Update Transactions
SET
profit = list_price - standard_cost

-- Creating Profit Bucketing based on Quartile

select
	MIN(profit) as minimum,
	AVG(profit) as avg_profit,
	MAX(profit) as maximum
from Transactions


With quartiles as -- creating quartiles
(
select
	*,
	NTILE(4) over(order by profit) as quartile
from Transactions
Where profit is not NULL
)
select
	*,
	CASE -- bucketing into 4
		WHEN quartile = 1 then 'Bronze'
		WHEN quartile = 2 then 'Silver'
		WHEN quartile = 3 then 'Gold'
		WHEN quartile = 4 then 'Platinium'
		ELSE CAST(quartile as varchar)
	END as sale_category
from quartiles


-- Now updating the above into the table 

ALTER TABLE transactions
ADD quartile INT, sale_category varchar


With quartiles as
(
select
	transaction_id,
	NTILE(4) over(order by profit) as quartile
from Transactions
Where profit is not NULL
)
Update Transactions
SET quartile = q.quartile
from quartiles q
where Transactions.transaction_id = q.transaction_id


ALTER Table transactions
Alter column sale_category varchar(max) -- increased the length


Update Transactions
SET
sale_category =
	CASE -- bucketing into 4
		WHEN quartile = 1 then 'Bronze'
		WHEN quartile = 2 then 'Silver'
		WHEN quartile = 3 then 'Gold'
		WHEN quartile = 4 then 'Platinium'
		ELSE CAST(quartile as varchar)
	END

select * from Transactions -- done

-- creating age buckets for CustomerDemographic and NewCustomerList

select * from CustomerDemographic
select * from NewCustomerList

select
	MIN(age),
	AVG(age),
	max(age)
from CustomerDemographic

select
	MIN(age),
	AVG(age),
	max(age)
from NewCustomerList

Alter table CustomerDemographic
Add age_range varchar(20)

Alter table NewCustomerList
Add age_range varchar(20)

Update CustomerDemographic
SET
age_range = CASE 
				WHEN age between 20 AND 40 then '21-40'
				WHEN age between 41 AND 60 then '41-60'
				ELSE '60<'
			END

Update NewCustomerList
SET
age_range = CASE 
				WHEN age between 20 AND 40 then '21-40'
				WHEN age between 41 AND 60 then '41-60'
				ELSE '60<'
			END

-- EDA

select
	c.customer_id,
	COUNT(CASE when t.sale_category = 'Gold' then c.customer_id END) gold,
	COUNT(CASE when t.sale_category = 'Platinium' then c.customer_id END) Platinium,
	SUM(t.profit) as total_profit,
	c.wealth_segment

from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.customer_id is not NULL
AND t.order_status = 'Approved'

group by c.customer_id, c.wealth_segment

order by 4 desc, 1


select
	c.customer_id,
	SUM(t.profit) as total_profit
	--t.sale_category
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.customer_id is not NULL
AND t.order_status = 'Approved'

group by c.customer_id--,t.sale_category
order by 2 desc,1

/* the above 2 queries gave us the saame customerIDs, indicating that our numbers are correct*/
/* customerid 941, 2637, 1460, 1558, 729, 3326, 322, 2770, 1597 and 195 yielding the most profit, thus we will look into them and their
demographics to analyze it further and try to match them with the new customers demographics as well */

select TOP 10
	c.customer_id,
	COUNT(CASE when t.sale_category = 'Gold' then c.customer_id END) gold,
	COUNT(CASE when t.sale_category = 'Platinium' then c.customer_id END) Platinium,
	SUM(t.profit) as total_profit,
	c.wealth_segment,
	c.age_range,
	c.gender,
	c.job_industry_category,
	c.job_title,
	c.owns_car,
	c.past_3_years_bike_related_purchases
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.customer_id is not NULL
AND t.order_status = 'Approved'

group by c.customer_id, c.wealth_segment, c.age_range, c.gender, c.job_industry_category, c.job_title, c.owns_car, c.past_3_years_bike_related_purchases
order by 4 desc, 1


-- profit yielded based on job industry

select
	c.job_industry_category,
	Round(SUM(t.profit),2) as total_profit
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.job_industry_category is not NULL
AND t.order_status = 'Approved'

group by c.job_industry_category

order by 2 desc

/* Manufacturing, Financial Services yielded most profits */

-- profit yielded based on job title

select
	c.job_title,
	Round(SUM(t.profit),2) as total_profit
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.job_title is not NULL
AND t.order_status = 'Approved'

group by c.job_title

order by 2 desc

/* 5 of the 10 top titles are managers */

-- profit yielded based on state

select
	c.state,
	Round(SUM(t.profit),2) as total_profit
	
from Transactions t
left join CustomerAddress c
on t.customer_id = c.customer_id

where c.state is not NULL
AND t.order_status = 'Approved'

group by c.state

order by 2 desc

/* clearly NSW generated more profits that the other two states combined */

-- profit yielded based on car ownership

select
	c.owns_car,
	Round(SUM(t.profit),2) as total_profit
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.owns_car is not NULL
AND t.order_status = 'Approved'

group by c.owns_car

order by 2 desc

/* we don't see a huge gap between customers with or w/o cars, so it will not be considered in the analysis */

-- profit yielded based on wealth segment

select
	c.wealth_segment,
	Round(SUM(t.profit),2) as total_profit
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.wealth_segment is not NULL
AND t.order_status = 'Approved'

group by c.wealth_segment

order by 2 desc

/* Mass Customers yielded more profit than the other 2, we will focus on that */

-- profit yielded based on gender

select
	c.gender,
	Round(SUM(t.profit),2) as total_profit
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.gender is not NULL
AND t.order_status = 'Approved'

group by c.gender

order by 2 desc

/* not that much of a gap, thus won't be taken into consideration */

-- profit yielded based on age range

select
	c.age_range,
	Round(SUM(t.profit),2) as total_profit
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.age_range is not NULL
AND t.order_status = 'Approved'

group by c.age_range

order by 2 desc

/* customers age ranged between 41-60 yielded more profit than the other 2 combined, which makes since as mostly
they will be buying the bikes either for them or for their family members */

-- profit yielded based on bike related purchases

select
	c.past_3_years_bike_related_purchases,
	Round(SUM(t.profit),2) as total_profit
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

where c.past_3_years_bike_related_purchases is not NULL
AND t.order_status = 'Approved'

group by c.past_3_years_bike_related_purchases

order by 2 desc

/* we don't see a pattern here, thus won't be taken into consideration */

-- profit yielded based on bike brand
select * from Transactions
select
	brand,
	Round(SUM(profit),2) as total_profit
	
from Transactions

where brand is not NULL
AND order_status = 'Approved'

group by brand
order by 2 desc

/* WeareA2B and Solex yielded most of the profit with significant gap compared to the rest of brands */

-------------------------------------------------- Interpretation --------------------------------------------------

/* from the above analysis we conclude the following:

1- Manufacturing, Financial Services yielded most profits
2- NSW generated more profits than the other two states combined
3- Mass Customers yielded more profit than the other 2
4- customers age ranged between 41-60 yielded more profit than the other 2 combined, which makes since as mostly
they will be buying the bikes either for them or for their family members
5- WeareA2B and Solex yielded most of the profit with significant gap compared to the rest of brands
6- Manager roles yield more profit

Now we're gonna try to identify new customers that fall within the above criterias for marketing purposes
*/

-- Top 10 current customers

select TOP 10
	c.customer_id,
	COUNT(CASE when t.sale_category = 'Gold' then c.customer_id END) gold,
	COUNT(CASE when t.sale_category = 'Platinium' then c.customer_id END) Platinium,
	SUM(t.profit) as total_profit,
	c.job_industry_category,
	a.state,
	c.wealth_segment,
	c.age_range
	--c.gender, excluded based on the above EDA
	--c.owns_car, excluded based on the above EDA
	--c.past_3_years_bike_related_purchases excluded based on the above EDA
	
from Transactions t
left join CustomerDemographic c
on t.customer_id = c.customer_id

left join CustomerAddress a
on t.customer_id = a.customer_id

where c.customer_id is not NULL
AND t.order_status = 'Approved'

group by c.customer_id, c.wealth_segment, c.age_range, c.job_industry_category, a.state
order by 4 desc


-- Now we're gonna look for new customers who falls within the crietria found in the EDA

select 
	*
from NewCustomerList
where job_industry_category in ('Manufacturing', 'Financial Services')
AND state = 'NSW'
AND wealth_segment = 'Mass Customer'
--AND job_title like '%Manager%' -- excluded as no record matched
AND age_range = '41-60'


/* we are left with 44 new customers who fits all the crietria that resulted in most of profits, now we can present the findings to the team and client */


select * from CustomerDemographic
select * from CustomerAddress
select * from Transactions
select * from NewCustomerList

select
	brand,
	SUM(profit) as total_profit

from Transactions
group by brand