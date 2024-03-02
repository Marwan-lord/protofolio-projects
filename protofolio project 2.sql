select *
from [Nashville Housing]


 
 --Standardize Date Format

select saleDateCoverted,convert(date,SaleDate)
 from [Nashville Housing]


 update [Nashville Housing]
 set SaleDate = convert(date,SaleDate)

alter table [Nashville housing]
add saleDateCoverted date;

update [Nashville Housing]
set saleDateCoverted= convert(date,SaleDate)


--populate property Address data

select *
 from [Nashville Housing]
 --where PropertyAddress is null
 order by ParcelID


 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
 from [Nashville Housing] a
 join [Nashville Housing] b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
   where a.PropertyAddress is null


update a 
set  PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing] a
 join [Nashville Housing] b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
   where a.PropertyAddress is null


-- address into columns (address, city, state)

select PropertyAddress
 from [Nashville Housing]
 --where PropertyAddress is null
 --order by ParcelID

 select substring(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1 )  as address
 from [Nashville Housing]


select left(PropertyAddress, CHARINDEX(',', PropertyAddress) -1) as address,
RIGHT(PropertyAddress,len(PropertyAddress)-CHARINDEX(',',PropertyAddress)) as town
from [Nashville Housing]

alter table [Nashville housing]
add SplitAddress nvarchar(255);

alter table [Nashville housing]
add SpliteCity nvarchar(255);

update [Nashville Housing]
set  SplitAddress = left(PropertyAddress, CHARINDEX(',', PropertyAddress) -1)

update [Nashville Housing]
set SpliteCity = RIGHT(PropertyAddress,len(PropertyAddress)-CHARINDEX(',',PropertyAddress))



---------separating owner address----------


select OwnerAddress
from [Nashville Housing]


select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [Nashville Housing]

alter table [Nashville housing]
add ownerSplitAddress nvarchar(255);

alter table [Nashville housing]
add ownerSpliteCity nvarchar(255);

alter table [Nashville housing]
add ownerSpliteState nvarchar(255);


update [Nashville Housing]
set  ownerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

update [Nashville Housing]
set ownerSpliteCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

update [Nashville Housing]
set ownerSpliteState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



select ownerSplitAddress, ownerSpliteCity,ownerSpliteState
from [Nashville Housing]



--------changing y,n to yes and no---------


select distinct(SoldAsVacant), count(SoldAsVacant)
from [Nashville Housing]
group by SoldAsVacant
order by 2







select SoldAsVacant, 
    case when SoldAsVacant = 'Y' then 'Yes' 
	     when SoldAsVacant = 'N' then 'NO'
		 else SoldAsVacant
		 end 
from [Nashville Housing]



update [Nashville Housing]
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes' 
	     when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end 

------deleting duplicates------

with Row_numb_CTE as(
select *, ROW_NUMBER() over(
partition by ParcelID,
PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID)
row_num
from [Nashville Housing]
--order by ParcelID
)
select *
from Row_numb_CTE
where row_num >1
