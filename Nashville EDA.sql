	select 
		*
	from NashvilleHousing..NashvilleHousing
_____________________________________________________________________

-- Properties per City

	select 
		propertySplitCity,
		COUNT(propertySplitCity) as Properties_Sold
	from NashvilleHousing..NashvilleHousing
	group by propertySplitCity
	order by Properties_Sold desc
_____________________________________________________________________

-- Properties per Owner

	select 
		OwnerName, 
		COUNT(ownername) as Properties_Owned
	from NashvilleHousing..NashvilleHousing
	where ownerName is not null
	group by OwnerName
		--having COUNT(ownername) > 1
	order by COUNT(ownername) desc

_____________________________________________________________________

-- Sold Properties per Year

	select 
		YEAR(SaleDateConverted) as year, 
		count(SaleDateConverted) as Properties_Sold
	from NashvilleHousing..NashvilleHousing
	group by YEAR(SaleDateConverted)
	order by Properties_Sold desc

_____________________________________________________________________

-- Creating Price Categories

With PriceCat as
(
	select
		*,
		Case
			when SalePrice <= 100000 then 'Cheap'
			when SalePrice > 100000 and SalePrice <= 1000000 then 'Average'
			else 'Expensive'
		end as Price_Category

	from NashvilleHousing..NashvilleHousing
)
	select
		Price_Category,
		COUNT([UniqueID ]) as Total_Properties
	from PriceCat
	group by Price_Category

_____________________________________________________________________

-- Price Range per City


with a as
(
	select
		*, 
		case 
			when SalePrice <= 100000 then 'Cheap'
			when SalePrice > 100000 and SalePrice <= 1000000 then 'Average'
			else 'Expensive'
		end as Price_Category

	from NashvilleHousing..NashvilleHousing
),
	b as
(
	select 
		Price_Category, 
		propertysplitcity,
		COUNT([UniqueID ]) as Range
	from a
	group by Price_Category, 
			propertysplitcity
	--order by 1,2
)
	select 
		propertysplitcity,
		Price_Category,
		SUM(range) as Range
	from b
	--where Price_Category like 'Cheap'
	group by  propertysplitcity, Price_Category
	order by Range desc

_____________________________________________________________________

--Category Count per City

with a as
(
	select
		*, 
		case 
			when SalePrice <= 100000 then 'Cheap'
			when SalePrice > 100000 and SalePrice <= 1000000 then 'Average'
			else 'Expensive'
		end as Price_Category

	from NashvilleHousing..NashvilleHousing
),
	b as
(
	select 
		Price_Category, 
		propertysplitcity,
		COUNT([UniqueID ]) as Range
	from a
	group by Price_Category, 
			propertysplitcity
),
	CityName as
(
	select
		distinct propertysplitcity
	from a
)
	select
		c.propertySplitCity,
		COALESCE(Cheap.range, 0) as Cheap_Properties,
		COALESCE(Average.range, 0) as Average_Properties,
		COALESCE(Expensive.range, 0) as Expensive_Properties

	from CityName c
	left join b as Cheap
	on c.propertySplitCity = Cheap.propertySplitCity
	and Cheap.Price_Category = 'Cheap'

		left join b as Average
	on c.propertySplitCity = Average.propertySplitCity
	and Average.Price_Category = 'Average'

		left join b as Expensive
	on c.propertySplitCity = Expensive.propertySplitCity
	and Expensive.Price_Category = 'Expensive'
	order by c.propertySplitCity

