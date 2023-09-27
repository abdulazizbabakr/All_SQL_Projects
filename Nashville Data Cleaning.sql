-- Data Cleaning in SQL Queries

select *
from [NashvilleHousing].[dbo].[NashvilleHousing]

-- Standardize Date Format

select SaleDateConverted, CONVERT(date, SaleDate)
from [NashvilleHousing].[dbo].[NashvilleHousing]

--update NashvilleHousing
--set SaleDate = CONVERT(date, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

update [NashvilleHousing].[dbo].[NashvilleHousing]
set SaleDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address Data

select *
from [NashvilleHousing].[dbo].[NashvilleHousing]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [NashvilleHousing].[dbo].[NashvilleHousing] a
join [NashvilleHousing].[dbo].[NashvilleHousing] b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [NashvilleHousing].[dbo].[NashvilleHousing] a
join [NashvilleHousing].[dbo].[NashvilleHousing] b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
  where a.PropertyAddress is null


-- Breaking out Property Address into individual columns (Address, City, State)

select SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress)) as address
from [NashvilleHousing].[dbo].[NashvilleHousing]

Alter table [NashvilleHousing].[dbo].[NashvilleHousing]
add propertySplitAddress Nvarchar(255)

update [NashvilleHousing].[dbo].[NashvilleHousing]
set propertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table [NashvilleHousing].[dbo].[NashvilleHousing]
add propertySplitCity nvarchar(255)

update [NashvilleHousing].[dbo].[NashvilleHousing]
set propertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))


-- Breaking out Owner Address into individual columns (Address, City, State)

select
PARSENAME(replace(owneraddress, ',', '.'),3),
PARSENAME(replace(owneraddress, ',', '.'),2),
PARSENAME(replace(owneraddress, ',', '.'),1)
from NashvilleHousing.dbo.NashvilleHousing

alter table NashvilleHousing.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'),3)


alter table NashvilleHousing.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'),2)


alter table NashvilleHousing.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'),1)


-- Changing Y and N to Yes and No

select distinct(SoldAsVacant), COUNT(soldasvacant)
from NashvilleHousing..NashvilleHousing
group by SoldAsVacant
order by 2 desc


select SoldAsVacant,
     case when SoldAsVacant = 'Y' then 'Yes'
	      when soldasvacant = 'N' then 'No'
		  else SoldAsVacant
		  end
from NashvilleHousing..NashvilleHousing

update NashvilleHousing..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	      when soldasvacant = 'N' then 'No'
		  else SoldAsVacant
		  end



-- Removing Duplicates

With RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
				 propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					uniqueID
					) row_num
from NashvilleHousing..NashvilleHousing
)
Delete
from RowNumCTE
where row_num > 1

With RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
				 propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					uniqueID
					) row_num
from NashvilleHousing..NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1


-- Deleting unused columns

alter table NashvilleHousing..NashvilleHousing
	drop column
		OwnerAddress,
		TaxDistrict,
		PropertyAddress,
		
alter table NashvilleHousing..NashvilleHousing
	drop column
		SaleDate


select *
from NashvilleHousing..NashvilleHousing