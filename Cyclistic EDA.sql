-- Appending all year table into one

Create Table combined_data 
(
	[ride_id] varchar(50) Primary Key,
    [rideable_type] varchar(50),
    [started_at] datetime,
    [ended_at] datetime,
    [start_station_name] varchar(100),
    [start_station_id] varchar(50),
    [end_station_name] varchar(100),
    [end_station_id] varchar(50),
    [start_lat] float,
    [start_lng] float,
    [end_lat] float,
    [end_lng] float,
    [member_casual] varchar(50)
)

insert into combined_data 
(
	[ride_id],
    [rideable_type],
    [started_at],
    [ended_at],
    [start_station_name],
    [start_station_id],
    [end_station_name],
    [end_station_id],
    [start_lat],
    [start_lng],
    [end_lat],
    [end_lng],
    [member_casual]
)

	select * from Cyclistic.dbo.[2022-01-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-02-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-03-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-04-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-05-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-06-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-07-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-08-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-09-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-10-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-11-tripdata]
	union all
	select * from Cyclistic.dbo.[2022-12-tripdata]

select COUNT(*)
from combined_data

-- Getting rid of unwanted columns - Data Cleaning

Create Table TripData
(
	ride_id varchar(50) Primary Key,
	rideable_type varchar(50),
	started_at datetime,
	ended_at datetime,
	start_station_name varchar(100),
	start_station_id varchar(50),
	end_station_name varchar(100),
	end_station_id varchar(50),
	user_cat varchar(50)
)

Insert Into TripData
(
	ride_id,
	rideable_type,
	started_at,
	ended_at,
	start_station_name,
	start_station_id,
	end_station_name,
	end_station_id,
	user_cat
)

select
	ride_id,
	rideable_type,
	started_at,
	ended_at,
	start_station_name,
	start_station_id,
	end_station_name,
	end_station_id,
	user_cat = member_casual
from
	combined_data


select 
	* 
from 
	TripData
order by 
	3

drop table TripData

-- Calculating the ride_length
with a as(
select
	started_at,
	ended_at,
	ride_length_minute = DATEDIFF(MINUTE,started_at, ended_at)
from
	TripData
),
b as
( select
	max(ride_length_minute) as max_ride_length_minute,
	min(ride_length_minute) as min_ride_length_minute
from a
)

select 
	max_ride_length_minute, 
	min_ride_length_minute
from b

-- Checking records that resulted in negative min_ride_length_minute and replacing them with zero - Data Integrity

select
	started_at,
	ended_at
from
	tripdata
where
	started_at > ended_at -- 100 records where started_at > ended_at

-- Replacing the 100 records with zeros - Data Integrity

with a as(
select
	started_at,
	ended_at,
	ride_length_minute = DATEDIFF(MINUTE,started_at, ended_at)
from
	TripData
),
b as(
select
	ride_length_minute_cleaned = 
		CASE
			when ride_length_minute < 0 then 0 -- records were replaced by zero
			else ride_length_minute
		end
from
	a
),
c as(
select
	MAX(ride_length_minute_cleaned) as max_length,
	MIN(ride_length_minute_cleaned) as min_length
from
	b
)
select *
from c -- data have been corrected


---------------------------------------------------------------------------------------------------------------------
-- Defining & Creating Tables for further analysis -- Normalization
select TOP 1000
	*
from
	TripData


select  -- Latest Master Table
	ride_id,
	rideable_type,
	start_station_id,
	end_station_id,
	user_cat
INTO master_table
from
	TripData

select *
from master_table

-- checking for duplicate rows

select
	COUNT(ride_id) - COUNT(distinct ride_id) as duplicate_rows
from master_table

---------------------------------------------------------------------------------------------------------------------
-- ride_data table
With A as
(
select  
	ride_id,
	start_date = DATEFROMPARTS(year(started_at), MONTH(started_at), day(started_at)),
	start_time = CONVERT(VARCHAR(5), started_at, 108) + ':' + 
				RIGHT('00' + CONVERT(VARCHAR(2), DATEPART(SECOND, started_at)), 2),
	end_date = DATEFROMPARTS(year(ended_at), MONTH(ended_at), day(ended_at)),
	end_time = CONVERT(VARCHAR(5), ended_at, 108) + ':' + 
				RIGHT('00' + CONVERT(VARCHAR(2), DATEPART(SECOND, ended_at)), 2),
	start_station_name,
	start_station_id,
	end_station_name,
	end_station_id
from
	TripData
),
B as
(
select
	*,
	ride_length = CONVERT(VARCHAR(8), DATEADD(SECOND, DATEDIFF(SECOND, start_time, end_time), 0), 108),
	sec_diff = DATEDIFF(second, start_time, end_time),
	min_diff = DATEDIFF(MINUTE, start_time, end_time),
	hr_diff = DATEDIFF(HOUR, start_time, end_time)
from A
)
select * 
INTO ride_data
from B


select
	MIN(sec_diff) as min_sec_diff,
	MAX(sec_diff) as max_sec_diff,
	MIN(min_diff) as min_min_diff,
	MAX(min_diff) as max_min_diff,
	MIN(hr_diff) as min_hr_diff,
	MAX(hr_diff) as max_hr_diff
from 
	ride_data -- minimum is below 0, thus replacing -ve records with 0


Update ride_data
SET
sec_diff = CASE
			when sec_diff < 0 then 0
			else sec_diff
		END,
min_diff = CASE
			when min_diff < 0 then 0
			else min_diff
		END,
hr_diff = CASE
			when hr_diff < 0 then 0
			else hr_diff
		END


select
	MIN(sec_diff) as min_sec_diff,
	MAX(sec_diff) as max_sec_diff,
	MIN(min_diff) as min_min_diff,
	MAX(min_diff) as max_min_diff,
	MIN(hr_diff) as min_hr_diff,
	MAX(hr_diff) as max_hr_diff
from 
	ride_data -- -ve replace with 0



select -- ride_data
	*
from 
	ride_data 
order by 2

-- checking for duplicate rows

select
	COUNT(ride_id) - COUNT(distinct ride_id) as duplicate_rows
from ride_data

---------------------------------------------------------------------------------------------------------------------
-- rideable_type table

With distinct_type AS
(
select
	distinct rideable_type as distinct_rideable_type
from
	master_table
),
Indexing AS
(
select
	ROW_NUMBER() over(order by distinct_rideable_type) as rideable_type_id,
	*
from
	distinct_type
)
select
	*
INTO rideable_type
from
	Indexing

select -- rideable_type table created
	*
from
	rideable_type

---------------------------------------------------------------------------------------------------------------------
-- station_data table

select 
	station_id
INTO station_data
from
	(
	select
		start_station_id as station_id
	from 
		TripData
	where 
		start_station_id is not null

	UNION

	select
		end_station_id as station_id
	from 
		TripData
	where 
		end_station_id is not null
	) as distinct_stations


select -- station_data table created
	*
from
	station_data


select * from TripData where  end_station_id= '922'

-- checking for duplicate rows

select
	COUNT(station_id) - COUNT(distinct station_id) as duplicate_rows
from station_data


---------------------------------------------------------------------------------------------------------------------
-- user_cat_data table

select
	Distinct user_cat
INTO user_cat_data
from
	master_table

select
	*
from
	user_cat_data

---------------------------------------------------------------------------------------------------------------------
-- calendar table

Create table calendar
(
	date_value Date,
	day_of_week_name Varchar(32),
	day_of_week_number int,
	day__of_month_number int,
	weekend varchar(5),
	month_number int,
	year_number int,
)

With Dates As
(
	select
		CONVERT(date, '01-01-2022', 103) as calendar_date

	UNION ALL

	select
		DATEADD(day,1,calendar_date)
	from
		Dates
	where
		calendar_date < CONVERT(date, '31-12-2022', 103)
)

INSERT INTO calendar
(
	date_value
)

select
	calendar_date
from 
	Dates
Option
	(maxrecursion 400)


Update calendar
SET
day_of_week_name = FORMAT(date_value, 'dddd'),
day_of_week_number = DATEPART(weekday, date_value),
day__of_month_number = DAY(date_value),
month_number = MONTH(date_value),
year_number = YEAR(date_value)

Update calendar
SET
weekend = 
		CASE
			when day_of_week_name IN ('Saturday', 'Sunday') then 'Yes'
			else 'No'
		end

select * from calendar -- calendar table created


---------------------------------------------------------------------------------------------------------------------
-- joining tables all together

select
	a.ride_id,
	b.rideable_type_id,
	a.rideable_type,
	h.day_of_week_name,
	h.day_of_week_number,
	h.day__of_month_number,
	h.weekend,
	h.month_number,
	h.year_number,
	c.start_date,
	c.start_time,
	c.end_date,
	c.end_time,
	c.start_station_id,
	c.start_station_name,
	c.end_station_id,
	c.end_station_name,
	j.user_cat as user_category

INTO joined_tables
from master_table a
	left join rideable_type b
	on a.rideable_type = b.distinct_rideable_type

	left join ride_data c
	on a.ride_id = c.ride_id

	left join calendar h
	on c.start_date = h.date_value

	left join user_cat_data j
	on a.user_cat = j.user_cat


select top 10
	*
from joined_tables


-- comparing no. of records of both master_table and joined_tables to see if they match before proceeding with EDA

select
	count(*)
from
	master_table

select
	COUNT(*)
from 
	joined_tables -- records matched

-- checking for number of null values in all columns

select
	count(*) - COUNT(ride_id) ride_id,
	count(*) - COUNT(rideable_type_id) rideable_type_id,
	count(*) - COUNT(rideable_type) rideable_type,
	count(*) - COUNT(start_date) start_date,
	count(*) - COUNT(start_time) start_time,
	count(*) - COUNT(end_date) end_date,
	count(*) - COUNT(end_time) end_time,
	count(*) - COUNT(start_station_id) start_station_id, -- 833064 NULL
	count(*) - COUNT(start_station_name) start_station_name, -- 833064 NULL
	count(*) - COUNT(end_station_id) end_station_id, -- 892742 NULL
	count(*) - COUNT(end_station_name) end_station_name, -- 892742 NULL
	count(*) - COUNT(user_category) user_category
from joined_tables -- all null values were from station_id and station_name

-- checking for duplicate rows
select
	COUNT(ride_id) - COUNT(distinct ride_id) as duplicate_rows
from joined_tables


SELECT ride_id, COUNT(*) as duplicate_count
FROM joined_tables
GROUP BY ride_id
HAVING COUNT(*) > 1; -- no duplicate found

SELECT ride_id, COUNT(*) as duplicate_count
FROM master_table
GROUP BY ride_id
HAVING COUNT(*) > 1; -- no duplicate found


-- ride_id length check, has to be 16

select
	len(ride_id) as length_ride_id, COUNT(ride_id) as no_of_rows
from
	joined_tables
group by len(ride_id)

select * from joined_tables
---------------------------------------------------------------------------------------------------------------------
-- EDA

-- mean of ride_length

SELECT
    AVG(CAST(hr_diff AS BIGINT) * 3600 + CAST(min_diff AS BIGINT) * 60 + CAST(sec_diff AS BIGINT)) AS avg_in_seconds,
    FLOOR(AVG(CAST(hr_diff AS BIGINT) * 3600 + CAST(min_diff AS BIGINT) * 60 + CAST(sec_diff AS BIGINT)) / 3600) AS avg_in_hours,
    FLOOR((AVG(CAST(hr_diff AS BIGINT) * 3600 + CAST(min_diff AS BIGINT) * 60 + CAST(sec_diff AS BIGINT)) % 3600) / 60) AS avg_in_minutes
FROM ride_data

--max ride_length

select
	max(min_diff) as max_length_minutes
from
	ride_data

select TOP 1 -- pulling out the reocrd with the max length
	*
from
	ride_data
order by min_diff desc


-- average ride_length for members and casual riders

With riders_type AS
(
select
	a.user_cat,
	b.min_diff
from
	master_table a
	left join ride_data b
	on a.ride_id = b.ride_id
)
select
	AVG(CASE when user_cat = 'member' then min_diff END) as member_avg_length_minutes,
	AVG(CASE when user_cat = 'casual' then min_diff END) as casual_avg_length_minutes
from 
	riders_type

-- average ride_length for users by day_of_week_name

With riders_type AS
(
select
	c.day_of_week_number,
	c.day_of_week_name,
	a.user_cat,
	b.min_diff,
	avg(b.min_diff) as daily_ride_length_avg
from
	master_table a
	left join ride_data b
	on a.ride_id = b.ride_id

	left join calendar c
	on b.start_date = c.date_value

group by c.day_of_week_number, c.day_of_week_name, a.user_cat, min_diff
)
select
	day_of_week_name,
	AVG(CASE when user_cat = 'member' then min_diff END) as member_avg_length_minutes,
	AVG(CASE when user_cat = 'casual' then min_diff END) as casual_avg_length_minutes
from riders_type
group by day_of_week_number, day_of_week_name
order by day_of_week_number

--  number of rides for users by day_of_week

With riders_type AS
(
select
	c.day_of_week_number,
	c.day_of_week_name,
	a.user_cat,
	b.min_diff,
	COUNT(a.ride_id) as daily_rides
from
	master_table a
	left join ride_data b
	on a.ride_id = b.ride_id

	left join calendar c
	on b.start_date = c.date_value

group by c.day_of_week_number, c.day_of_week_name, a.user_cat, min_diff
)
select
	day_of_week_name,
	Count(CASE when user_cat = 'member' then min_diff END) as member_rides,
	Count(CASE when user_cat = 'casual' then min_diff END) as casual_rides
from riders_type
group by day_of_week_number, day_of_week_name
order by day_of_week_number


-- bike types used by riders

select
	rideable_type,
	COUNT(case when user_category = 'member' then ride_id end) as member,
	COUNT(case when user_category = 'casual' then ride_id end) as casual
from
	joined_tables
group by rideable_type
order by rideable_type


-- no. of rides per month

select
	b.month_number,
	DATENAME(month, b.date_value) as month,
	COUNT(a.ride_id) as total_rides
from
	ride_data a
	left join calendar b
	on a.start_date = b.date_value
group by b.month_number, DATENAME(month, b.date_value)
order by b.month_number


-- no. of rides per month by user_cat

select
	b.month_number,
	DATENAME(month, b.date_value) as month,
	COUNT(CASE when c.user_cat = 'member' then a.ride_id END) as member_total_rides,
	COUNT(CASE when c.user_cat = 'casual' then a.ride_id END) as casual_total_rides
from
	ride_data a
	left join calendar b
	on a.start_date = b.date_value

	left join master_table c
	on a.ride_id = c.ride_id
group by b.month_number, DATENAME(month, b.date_value)
order by b.month_number


-- no. of rides per day of week

select
	b.day_of_week_number,
	b.day_of_week_name,
	COUNT(CASE when c.user_cat = 'member' then a.ride_id END) as member_total_rides,
	COUNT(CASE when c.user_cat = 'casual' then a.ride_id END) as casual_total_rides
from
	ride_data a
	left join calendar b
	on a.start_date = b.date_value

	left join master_table c
	on a.ride_id = c.ride_id

group by b.day_of_week_number, b.day_of_week_name
order by b.day_of_week_number


-- no. of rides per hour

select
	DATEPART(hour,(CAST(a.start_time as time))) as hour,
	COUNT(CASE when user_cat = 'member' then a.ride_id END) as member_total_rides,
	COUNT(CASE when user_cat = 'casual' then a.ride_id END) as casual_total_rides
from
	ride_data a
	left join master_table b
	on a.ride_id = b.ride_id

group by DATEPART(hour,(CAST(a.start_time as time)))
order by DATEPART(hour,(CAST(a.start_time as time)))


select * from calendar

-- avg ride length segregated by user_cat

With main_table as
(
select
	a.ride_id,
	a.start_date,
	c.month_number,
	DATENAME(MONTH, c.date_value) as month,
	c.day_of_week_number,
	c.day_of_week_name,
	DATEPART(hour, (cast(a.start_time as time))) as hour,
	a.hr_diff,
	a.min_diff,
	a.sec_diff,
	b.user_cat
from
	ride_data a
	left join master_table b
	on a.ride_id = b.ride_id

	left join calendar c
	on a.start_date = c.date_value
),
monthly_avg as
(
select
	month_number,
	month,
	AVG(CASE when user_cat = 'member' then min_diff END) as member_avg_ride_length_minutes,
	AVG(CASE when user_cat = 'casual' then min_diff END) as casual_avg_ride_length_minutes

from main_table
group by month_number, month
),
day_of_week_avg as
(
select
	b.day_of_week_number as day_no,
	b.day_of_week_name as name,
	AVG(CASE when user_cat = 'member' then min_diff END) as member_avg_ride_length_minutes,
	AVG(CASE when user_cat = 'casual' then min_diff END) as casual_avg_ride_length_minutes

from monthly_avg a
	left join main_table b
	on a.month_number = b.month_number

group by day_of_week_number, day_of_week_name
),
hourly_avg as
(
select
	a.hour,
	AVG(CASE when user_cat = 'member' then min_diff END) as member_avg_ride_length_minutes,
	AVG(CASE when user_cat = 'casual' then min_diff END) as casual_avg_ride_length_minutes

from 
	main_table a
group by hour
),
bucketing as -- segregating based on ride length
(
select
	a.ride_id,
	b.start_station_name,
	b.end_station_name,
	a.min_diff,
	ride_category =
		CASE
			when a.min_diff <= 10 then 'short ride'
			when a.min_diff > 10 and a.min_diff <= 15 then 'average ride'
			ELSE 'long ride'
		END
from main_table a
	left join ride_data b
	on a.ride_id = b.ride_id
),
bucketing_category as
(
select
	ride_category,
	COUNT(CASE when b.user_cat = 'member' then b.ride_id END) member,
	COUNT(CASE when b.user_cat = 'casual' then b.ride_id END) casual

from 
	bucketing a
	left join main_table b
	on a.ride_id = b.ride_id

group by ride_category
)
select * from bucketing_category order by member, casual



-- aggregated Summary for exportation & Visualization

select
	user_category,
	a.rideable_type,
	DATEFROMPARTS(2022, month_number, day__of_month_number) as date,
	DATEPART(QUARTER, a.start_date) as quarter,
	DATENAME(MONTH, a.start_date) as month,
	day__of_month_number,
	day_of_week_number,
	day_of_week_name,
	DATEPART(hour,(CAST(a.start_time as time))) as hour,
	SUM(min_diff) as total_lengths,
	avg(min_diff) AS average_ride_length,
	count(a.ride_id) as ride_id_count,
	COUNT(case when min_diff <= 10 then 'short ride' end) as short_rides,
	count(case when min_diff > 10 and min_diff <= 15 then 'average ride' end) as average_rides,
	COUNT(case when min_diff > 15 then 'long ride' end) as long_rides


from 
	joined_tables a
	left join ride_data b
	on a.ride_id = b.ride_id

group by
	a.user_category,
	a.rideable_type,
	a.month_number,
	DATEPART(QUARTER, a.start_date),
	DATENAME(MONTH, a.start_date),
	day__of_month_number,
	day_of_week_number,
	day_of_week_name,
	DATEPART(hour,(CAST(a.start_time as time)))


order by 
	a.month_number,
	DATEPART(QUARTER, a.start_date),
	DATENAME(MONTH, a.start_date),
	day__of_month_number,
	day_of_week_number,
	DATEPART(hour,(CAST(a.start_time as time))),
	a.user_category,
	a.rideable_type
