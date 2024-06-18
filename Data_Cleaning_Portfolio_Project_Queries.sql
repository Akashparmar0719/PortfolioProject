/*
	DATA CLEANING PROJECT IN SQL
*/

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing

-- CHANGING THE DATE FORMAT

SELECT SaleDate, CONVERT(DATE,Saledate)
FROM PortfolioProjects.dbo.NashvilleHousing

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, Saledate)

SELECT SaleDate
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
add SaleDateConverted Date;

Update PortfolioProjects.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProjects.dbo.NashvilleHousing
 

-- Property Address DATA 

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing
--Where PropertyAddress is null							/* on particular parcelid there will be the same address*/
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID							/*  Parcelid is same but not the same row(uniqueID) */
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID							/*  ISNULL(A,B): CHECKS IF THERE ANY NULLS IN "A", AND IF THERE IS THEN, FILL IT WITH "B" */
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
--CHARINDEX(',', PropertyAddress)
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProjects.dbo.NashvilleHousing 

Alter Table PortfolioProjects.dbo.NashvilleHousing
Add SplitPropertyAddress Nvarchar(225);

Update PortfolioProjects.dbo.NashvilleHousing
SET SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table PortfolioProjects.dbo.NashvilleHousing
Add SplitPropertyCity Nvarchar(225);

Update PortfolioProjects.dbo.NashvilleHousing
SET SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProjects.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)											/* PARSENAME LOOKS FOR PERIODS i.e. '.'  so replace the commas in owneraddress column into periods */
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjects.dbo.NashvilleHousing

Alter Table PortfolioProjects.dbo.NashvilleHousing
Add SplitOwnerAddress Nvarchar(225);

Update PortfolioProjects.dbo.NashvilleHousing
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table PortfolioProjects.dbo.NashvilleHousing
Add SplitOwnerCity Nvarchar(225);

Update PortfolioProjects.dbo.NashvilleHousing
SET SplitOwnerCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table PortfolioProjects.dbo.NashvilleHousing
Add SplitOwnerState Nvarchar(225);

Update PortfolioProjects.dbo.NashvilleHousing
SET SplitOwnerState =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProjects.dbo.NashvilleHousing


---------------- --------------------- --------------------------- ------------------------ -------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From PortfolioProjects.dbo.NashvilleHousing

Update PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END


--Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjects.dbo.NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProjects.dbo.NashvilleHousing

-- delete Unused Columns


ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate
