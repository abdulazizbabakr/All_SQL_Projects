-- Dashboard 1
	-- Total Order, Total Sales, Total Items, Avg Order Value, Sales by Category, Top Selling Items, Orders by Hour, Sales by Hour, Orders by Address, Orders by Delivery

	select
		o.order_id,
		i.item_price,
		o.quantity,
		i.item_cat,
		i.item_name,
		o.created_at,
		a.delivery_address1,
		a.delivery_address2,
		a.delivery_city,
		a.delivery_zipcode,
		o.delivery

	from 
		BensPizzeria..orders o
			left join item i
				on o.item_id = i.item_id

			left join address a
				on o.add_id = a.add_id


-- Dashboard 2
	-- Total Quantity by Ingredients, Total Cost of Ingredients, Calculated Cost of Pizza, Percentage Stock Remaining by Ingredient

	select
		s1.item_name,
		s1.ing_id,
		s1.ing_name,
		s1.ing_weight,
		s1.ing_price,
		s1.order_quantity,
		s1.recipe_quantity,
		s1.order_quantity * s1.recipe_quantity as ordered_weight,
		s1.ing_price / s1.ing_weight as unit_cost,
		(s1.order_quantity * s1.recipe_quantity) * (s1.ing_price / s1.ing_weight) as ingredient_cost
	from 
(
	select
		o.item_id,
		i.sku,
		i.item_name,
		r.ing_id,
		ing.ing_name,
		r.quantity as recipe_quantity,
		sum(o.quantity) as order_quantity,
		ing.ing_weight,
		cast(ing.ing_price as float) as ing_price
	from orders o
		left join item i
			on o.item_id = i.item_id

		left join recipe r
			on i.sku = r.recipe_id

		left join ingredient ing
			on ing.ing_id = r.ing_id
	group by 
		o.item_id, 
		i.sku, 
		i.item_name,
		r.ing_id,
		r.quantity,
		ing.ing_name,
		ing.ing_weight,
		ing.ing_price
) s1

-- Creating view to continue querying Dashboard 2


create view [stock1] as 

	select
		s1.item_name,
		s1.ing_id,
		s1.ing_name,
		s1.ing_weight,
		s1.ing_price,
		s1.order_quantity,
		s1.recipe_quantity,
		s1.order_quantity * s1.recipe_quantity as ordered_weight,
		s1.ing_price / s1.ing_weight as unit_cost,
		(s1.order_quantity * s1.recipe_quantity) * (s1.ing_price / s1.ing_weight) as ingredient_cost
	from 
(
	select
		o.item_id,
		i.sku,
		i.item_name,
		r.ing_id,
		ing.ing_name,
		r.quantity as recipe_quantity,
		sum(o.quantity) as order_quantity,
		ing.ing_weight,
		cast(ing.ing_price as float) as ing_price
	from orders o
		left join item i
			on o.item_id = i.item_id

		left join recipe r
			on i.sku = r.recipe_id

		left join ingredient ing
			on ing.ing_id = r.ing_id
	group by 
		o.item_id, 
		i.sku, 
		i.item_name,
		r.ing_id,
		r.quantity,
		ing.ing_name,
		ing.ing_weight,
		ing.ing_price
) s1;

	select
		*
	from stock1

-- Proceeding with queries for Dashboard 2

	select
		s2.ing_name,
		s2.ordered_weight,
		cast(ing.ing_weight as bigint) *  cast(inv.quantity as bigint) as total_inv_weight,
		(cast(ing.ing_weight as bigint) *  cast(inv.quantity as bigint)) - s2.ordered_weight as remaining_weight
	from (
		select 
			ing_id,
			ing_name,
			sum(cast(ordered_weight as bigint)) as ordered_weight
		from stock1
		group by
			ing_name,
			ing_id) s2

			left join inventory inv
				on inv.item_id = s2.ing_id

			left join ingredient ing
				on ing.ing_id = s2.ing_id

-- Dashboard 3
	-- Total Staff Cost, Total Hours Worked, Staff Details Summary
	select
		r.date,
		s.first_name,
		s.last_name,
		s.hourly_rate,
		sh.start_time,
		sh.end_time,
		(datediff(hour,sh.start_time,sh.end_time)+datediff(minute,sh.start_time,sh.end_time))/60 as hours_in_shift,
		(datediff(hour,sh.start_time,sh.end_time)+datediff(minute,sh.start_time,sh.end_time))/60 * s.hourly_rate as staff_cost
	from rota r
		left join staff s
			on r.staff_id = s.staff_id

		left join shift sh
			on r.shift_id = sh.shift_id 




