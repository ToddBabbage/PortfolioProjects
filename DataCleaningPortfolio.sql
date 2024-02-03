

-- Cleaning Data in SQL Queries


Select *
From PortfolioProject..NashvilleHousing


-- Standardize Date Format
-- Non-Destructive

Select SaleDate, SaleDateConverted
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)




-- Populate Property Address Data


Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)  -- Identify Record Errors in PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)  -- Update PropertyAddress errors using UniqueID & ParcelID
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breakdown Address into Columns (Address, City, State)
-- Using Substring

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Address,
Substring(PropertyAddress, Charindex(',', PropertyAddress)+1,  LEN(PropertyAddress)) as City
 
From PortfolioProject..NashvilleHousing




Alter Table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress)+1,  LEN(PropertyAddress))


Select PropertyAddress,PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing



-- Using Parsename

Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select 
Parsename(replace(OwnerAddress,',','.'),3) as Address,
Parsename(replace(OwnerAddress,',','.'),2) as City,
Parsename(replace(OwnerAddress,',','.'),1) as State
From PortfolioProject..NashvilleHousing




Alter Table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(replace(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(replace(OwnerAddress,',','.'),2)


Alter Table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(replace(OwnerAddress,',','.'),1)


Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject..NashvilleHousing




-- Change SoldAsVacant formatting, Y to Yes, N to No

Select SoldAsVacant, COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing



Update NashvilleHousing
Set SoldAsVacant = 
					CASE When SoldAsVacant = 'Y' Then 'Yes'
						 When SoldAsVacant = 'N' Then 'No'
						 Else SoldAsVacant
					End


-- Remove Duplicates
-- Destructive

Select *
From PortfolioProject..NashvilleHousing

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By ParcelID
				) row_num

From PortfolioProject..NashvilleHousing
)

Select *            -- Replace with Delete to execute
From RowNumCTE
Where row_num > 1


----Delete
----From RowNumCTE
----Where row_num > 1



-- Delete Unused Columns
-- Destructive

Select *
From PortfolioProject..NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
 










